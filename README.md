# 클라우드 seed — jyoliar-platform-terraform

홈랩이 혼자 할 수 없는 것을 AWS 와 Cloudflare 에 Terraform 으로 만드는 저장소다. 산출물은 jyoliar-k8s 가 소비하고, 클러스터 하부는 onpremise-k8s 가 세운다.

## 디렉터리 구조

```
_modules/              # 워크스페이스가 공유하는 모듈 — tfc_remote_state(다른 워크스페이스의 출력 읽기) · nat
alert/                 # Discord 알림 채널 · webhook → Parameter Store
backup/                # PostgreSQL 백업 S3 버킷과 그 IRSA Role
ci/                    # GitHub Actions 용 CodeBuild 러너 · ECR 저장소
cloudflare/            # DNS zone · 터널 · 엣지 보호 · external-dns 토큰 → Parameter Store
iam/                   # 클러스터의 OIDC 발급자를 신뢰하는 IAM OIDC Provider 와 IRSA Role
oauth/                 # Google OAuth 클라이언트 → Parameter Store
vpc/                   # AWS 쪽 실험 네트워크
└── _modules/          # vpc 전용 모듈
vpn/                   # AWS 쪽 실험 노드 — Tailscale 라우터 · 워커 인스턴스
zitadel/               # Zitadel masterkey → Parameter Store
```

최상위 디렉터리 하나가 Terraform 워크스페이스 하나다. 각 디렉터리의 `outputs.tf` 가 그 워크스페이스가 밖으로 넘기는 전부이고, 다른 워크스페이스의 출력은 [`_modules/tfc_remote_state`](_modules/tfc_remote_state) 로만 읽는다([`backup/data.tf`](backup/data.tf) · [`vpn/data.tf`](vpn/data.tf)).

## 환경

- 워크스페이스는 Terraform Cloud 에 있다. 디렉터리 하나가 워크스페이스 하나다. 워크스페이스 이름과 변수는 Terraform Cloud 의 워크스페이스 설정이 답한다 — 코드에 백엔드 블록은 없다.
- `env` · `region` 은 워크스페이스 변수로 주입된다. `env` 는 태그가 아니라 이름의 재료다 — 환경마다 따로 서는 리소스의 이름은 `env` 에서 파생시키고, 환경 이름을 리터럴로 박지 않는다.
- Parameter Store 파라미터가 어느 환경 · 어느 서비스의 것인지는 각 `aws_ssm_parameter` 의 `name` 이 답한다.

## 반영 방법

PR 로 바꾸고 Terraform Cloud 워크스페이스에서 plan 을 읽은 뒤 apply 한다. 구동 방식은 워크스페이스마다 다르다 — VCS 연동(머지가 plan · apply 를 만든다)과 로컬 CLI(디렉터리에서 `terraform plan` · `terraform apply`)가 섞여 있고, VCS 연동으로 옮기는 중이다. 어느 쪽인지는 그 워크스페이스의 Terraform Cloud 설정이 답한다.

인프라 현황은 Terraform 으로만 본다 — `terraform state list` · `terraform show` · `terraform output`. AWS CLI 는 쓰지 않는다.

주의:

- `vpc` 는 destroy 하지 않는다 — `vpn` 이 그 출력을 읽는다.
- `backup` 은 데이터를 담은 stateful 리소스라 destroy 의 파급이 다르다. 그래서 `iam` 과 state 를 섞지 않고 따로 뗐다.
- `iam` 은 plan 때 OIDC 발급자 URL 에 실제로 접속한다([`iam/oidc.tf`](iam/oidc.tf)). 그 호스트가 살아 있지 않으면 plan 이 실패한다.

## 다른 저장소와의 경계

받는 것:

| 넘기는 저장소 | 무엇 | 그쪽의 자리 | 이 저장소의 자리 |
|---|---|---|---|
| onpremise-k8s | OIDC 발급자 URL | 인벤토리 `service_account_issuer` | `iam` 변수 `k8s_oidc_issuer_url`([`iam/variables.tf`](iam/variables.tf)) — 두 값이 같아야 IRSA 가 선다 |
| jyoliar-k8s | OIDC 발급자 호스트의 공개 서빙(JWKS) | `gitops/base/bootstrap/oidc-provider` + `cloudflare-tunnel` | [`iam/oidc.tf`](iam/oidc.tf) 가 그 URL 의 TLS 인증서를 읽어 OIDC Provider 를 만든다 |

넘기는 것 — 전부 jyoliar-k8s 가 받는다:

| 무엇 | 이 저장소의 자리 | 그쪽의 자리 |
|---|---|---|
| Parameter Store 파라미터 | `oauth` · `alert` · `cloudflare` · `zitadel` 의 `aws_ssm_parameter` | `ClusterSecretStore/aws-parameter-store` 를 쓰는 ExternalSecret |
| IRSA Role | [`iam/irsa_roles.tf`](iam/irsa_roles.tf)(External Secrets · ECR pull) · [`backup/irsa.tf`](backup/irsa.tf)(PostgreSQL 백업) | ServiceAccount 의 `eks.amazonaws.com/role-arn` annotation |
| S3 백업 버킷 | [`backup/s3.tf`](backup/s3.tf) | CloudNativePG `ObjectStore` 의 `destinationPath` |
| ECR 저장소 | [`ci/ecr.tf`](ci/ecr.tf) | overlay kustomization 의 `images` |
| Cloudflare 터널 자격증명 | `cloudflare` 출력 `tunnel_credentials`([`cloudflare/outputs.tf`](cloudflare/outputs.tf)) | `platform/overlays/create-tunnel-token.sh` 가 Secret 으로 옮긴다 |

`ci` 의 CodeBuild 러너는 GitHub Actions 가 부른다 — 홈랩이 받는 것이 아니다. `vpc` · `vpn` 의 출력은 지금 다른 두 저장소가 받지 않는다.

Terraform 은 클러스터 안을 알지 못한다. 방향은 한쪽이다.
