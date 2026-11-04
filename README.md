# 클라우드 seed — jyoliar-platform-terraform

홈랩이 혼자 할 수 없는 것을 AWS 와 Cloudflare 에 Terraform 으로 만드는 저장소다. 산출물은 jyoliar-k8s 가 소비하고, 클러스터 하부는 onpremise-k8s 가 세운다.

## 디렉터리 구조

```
tfc/                          # Terraform Cloud 의 선언 층 — 프로젝트 · variable set · 다른 모든 워크스페이스. 유일한 로컬 apply 루트
└── _modules/                 # project · workspace — tfc 전용 모듈
_modules/                     # 루트들이 공유하는 모듈
├── careerhub/auth/           # 환경 하나의 careerhub 인증 재료 — Zitadel masterkey · Google OAuth 클라이언트 → Parameter Store
├── cnpg-backup/              # CNPG 클러스터 하나의 백업 재료 — S3 버킷과 그 IRSA Role
├── nat/                      # NAT 인스턴스
└── tfc_remote_state/         # 다른 워크스페이스의 출력 읽기
shared/                       # 공유 루트 — 환경 축이 없는 리소스
├── admin-oauth/              # argocd · grafana 로그인용 Google 클라이언트 → Parameter Store
├── alert/                    # Discord 알림 채널 · webhook → Parameter Store
├── ci/                       # GitHub Actions 용 CodeBuild 러너 · ECR 저장소
├── cloudflare/               # DNS zone · 터널 · 엣지 보호 · external-dns 토큰 → Parameter Store
└── iam/                      # 클러스터의 OIDC 발급자를 신뢰하는 IAM OIDC Provider 와 IRSA Role
envs/                         # 환경 루트 — envs/<env>/<루트>
└── prod/
    └── careerhub/            # prod 의 careerhub 재료 — _modules/careerhub/auth · _modules/cnpg-backup 호출 둘
lab/                          # 실험 루트 — AWS 모의 환경
├── vpc/                      # 실험 네트워크
│   └── _modules/             # vpc · subnets — lab/vpc 전용 모듈
└── vpn/                      # 실험 노드 — Tailscale 라우터 · 워커 인스턴스
```

`_modules/` 가 아닌 리프 디렉터리 하나가 Terraform Cloud 워크스페이스 하나다. 각 루트의 `outputs.tf` 가 그 워크스페이스가 밖으로 넘기는 전부이고, 다른 워크스페이스의 출력은 [`_modules/tfc_remote_state`](_modules/tfc_remote_state) 로만 읽는다.

## 워크스페이스

이름은 디렉터리 좌표다 — `shared/<루트>` → `shared-<루트>`, `lab/<루트>` → `lab-<루트>`, `envs/<env>/<루트>` → `<env>-<루트>`. `tfc` 는 `tfc` 다.

| 워크스페이스 | 디렉터리 | 프로젝트 | 구동 |
|---|---|---|---|
| `tfc` | `tfc/` | `Default Project` | 로컬 CLI(local 실행 모드) |
| `shared-admin-oauth` | `shared/admin-oauth/` | `shared` | VCS |
| `shared-alert` | `shared/alert/` | `shared` | VCS |
| `shared-ci` | `shared/ci/` | `shared` | VCS |
| `shared-cloudflare` | `shared/cloudflare/` | `shared` | VCS |
| `shared-iam` | `shared/iam/` | `shared` | VCS |
| `prod-careerhub` | `envs/prod/careerhub/` | `prod-careerhub` | VCS |
| `lab-vpc` | `lab/vpc/` | `lab` | VCS |
| `lab-vpn` | `lab/vpn/` | `lab` | VCS |

워크스페이스의 이름 · working directory · VCS 연결 · trigger 패턴 · 실행 설정 · 비밀 아닌 변수는 전부 [`tfc/`](tfc) 가 tfe provider 로 선언한다([`tfc/ws-shared.tf`](tfc/ws-shared.tf) · [`tfc/ws-envs.tf`](tfc/ws-envs.tf) · [`tfc/ws-lab.tf`](tfc/ws-lab.tf) · [`tfc/ws-tfc.tf`](tfc/ws-tfc.tf)). 프로젝트와 그 variable set 은 [`tfc/projects.tf`](tfc/projects.tf) 다. VCS 워크스페이스는 자기 디렉터리와 쓰는 공유 모듈 아래가 바뀔 때 run 이 생긴다.

## 백엔드 — 모든 루트에 `backend.tf`

모든 루트에 `backend.tf` 가 있다 — `cloud { organization = "jyoliar"  workspaces { name = "<워크스페이스>" } }`. 로컬 CLI 바인딩용이고 러너는 쓰지 않는다 — 원격 run 은 HCP Terraform 이 주입한 백엔드로 돈다. `tfc` 의 것([`tfc/providers.tf`](tfc/providers.tf))만 실제 실행 백엔드다.

`backend.tf` 의 `workspaces.name` 은 `tfc/` 가 선언한 이름과 같아야 한다. 로컬의 `state mv` · `import` · `state push` 도 이 바인딩을 따르므로, 이름이 틀리면 다른 워크스페이스의 state 를 친다. 로컬 바인딩을 `*_override.tf` 로 두지 않는다 — HCP 가 자기 백엔드를 override 파일로 주입하므로 충돌한다(`.gitignore` 가 그 이름을 거른다).

## 반영 방법

- **VCS 루트** — PR 을 머지하면 run 이 생기고 plan 까지 돈다. 변경이 있으면 run 은 확인 대기에서 멈추고, 사람이 Terraform Cloud 콘솔에서 plan 을 읽고 apply 를 승인(또는 폐기)한다 — `auto_apply` 는 모든 워크스페이스에서 `false` 다. 로컬에서는 그 디렉터리에서 `terraform init` · `terraform plan` 으로 speculative plan 만 본다 — 로컬 apply 는 거부된다.
- **`tfc`** — 운영자의 `terraform login` 자격증명으로 `tfc/` 에서 `terraform plan` · `terraform apply` 한다. 조직 수준 tfe 토큰은 어느 워크스페이스에도 두지 않는다.
- **워크스페이스 추가 · 개명 · 경로 변경**은 `tfc/` 의 PR 이다. 그때 그 루트의 `backend.tf` 도 같은 PR 에서 고친다.

인프라 현황은 Terraform 으로만 본다 — 루트 디렉터리에서 `terraform state list` · `terraform show` · `terraform output`. AWS CLI 는 쓰지 않는다.

## 변수

- 비밀 아닌 변수는 `tfc/` 의 `tfe_variable` 이다(워크스페이스 모듈의 `variables`). sensitive 변수는 Terraform Cloud 콘솔에 둔다 — 코드에 값을 적지 않는다.
- 프로젝트가 `env` 값의 단위다. 프로젝트가 소유한 variable set 이 그 프로젝트의 모든 워크스페이스에 `env` · `region` 을 준다(`priority = true` — 워크스페이스 변수가 덮지 못한다). 워크스페이스에는 `env` · `region` 변수가 없다.

  | 프로젝트 | variable set | `env` | `region` |
  |---|---|---|---|
  | `shared` | `shared` | `shared` | `ap-northeast-2` |
  | `lab` | `lab` | `lab` | `ap-northeast-2` |
  | `prod-careerhub` | `prod` | `prod` | `ap-northeast-2` |
  | `Default Project` | — | — | — |

- 모든 AWS 루트의 provider `default_tags` 는 `env = var.env` 와 `managed_by = "terraform"` 이다. 공유 리소스의 `env` 는 `shared`, 실험 리소스의 `env` 는 `lab` 이다.
- `env` 는 태그만이 아니라 이름의 재료다 — 환경마다 따로 서는 리소스(버킷 · IAM Role · SSM 경로)의 이름은 `env` 에서 파생시키고, 환경 이름을 리터럴로 박지 않는다.
- Parameter Store 파라미터가 어느 환경 · 어느 서비스의 것인지는 각 `aws_ssm_parameter` 의 `name` 이 답한다.

## 공유 → 환경, 단방향

환경 루트는 공유 루트의 출력을 `_modules/tfc_remote_state` 로 읽는다 — `prod-careerhub` 가 `shared-iam` 의 OIDC Provider ARN 을 읽어 CNPG 백업 IRSA Role 의 신뢰 정책에 쓴다([`envs/prod/careerhub/main.tf`](envs/prod/careerhub/main.tf)). 공유 루트가 환경 루트를 읽는 일은 없다. state 를 읽을 수 있는 워크스페이스는 읽히는 쪽의 `remote_state_consumer_ids`(`tfc/`)가 열거한다 — 조직 전체 공개는 열지 않는다.

실험 루트끼리도 같은 방식이다 — `lab-vpn` 이 `lab-vpc` 의 출력을 읽는다([`lab/vpn/data.tf`](lab/vpn/data.tf)).

## 새 환경 추가

`stg` 를 예로 든다. careerhub 환경 하나는 디렉터리 하나(모듈 호출 둘 — 인증 재료 · PostgreSQL 백업) · `tfc/` 선언 · 콘솔 변수다. 아래 순서대로 한다.

1. **GCP 콘솔에서 Google OAuth 클라이언트를 먼저 만든다.** redirect URL 도 거기서 정한다. 클라이언트 id · secret · redirect URL 세 값은 Terraform 이 만들지 않는다 — 4 에서 콘솔 변수로 넣는다.
2. **`tfc/` 에 선언하는 PR** — 머지한 뒤 `tfc/` 에서 로컬 `terraform plan` · `terraform apply`.
   - [`tfc/projects.tf`](tfc/projects.tf) — 프로젝트와 그 프로젝트가 소유하는 variable set:
     ```hcl
     module "project_stg_careerhub" {
       source = "./_modules/project"

       name = "stg-careerhub"

       variable_sets = {
         stg = {
           description = "env · region — stg-careerhub 프로젝트의 워크스페이스에 주입한다"
           priority    = true
           variables = {
             env    = { value = "stg" }
             region = { value = local.region }
           }
         }
       }
     }
     ```
   - [`tfc/ws-envs.tf`](tfc/ws-envs.tf) — 워크스페이스:
     ```hcl
     module "stg_careerhub" {
       source = "./_modules/workspace"

       name                     = "stg-careerhub"
       project_id               = module.project_stg_careerhub.id
       working_directory        = "envs/stg/careerhub"
       vcs                      = local.vcs
       another_trigger_patterns = ["_modules/careerhub/auth/**/*", "_modules/cnpg-backup/**/*", "_modules/tfc_remote_state/**/*"]
     }
     ```
     워크스페이스는 생성 직후 run 을 만들지 않는다(`queue_all_runs = false` 는 모듈이 고정한다).
   - [`tfc/ws-shared.tf`](tfc/ws-shared.tf) — `shared-iam` 의 `remote_state_consumer_ids` 에 새 워크스페이스를 더한다. 환경 루트가 OIDC Provider ARN 을 읽으려면 소비자로 등록돼 있어야 한다 — 등록 전에는 `tfe_outputs` 가 비어 환경 루트의 plan 이 실패한다.
     ```hcl
     remote_state_consumer_ids = [module.prod_careerhub.id, module.stg_careerhub.id]
     ```
3. **콘솔에서 `stg-careerhub` 워크스페이스에 변수를 둔다** — `google_client_id` · `google_client_secret`(sensitive) 와 `google_redirect_url`. 1 에서 GCP 콘솔이 정한 값 그대로다.
4. **`envs/stg/careerhub/` 디렉터리를 만드는 PR** — [`envs/prod/careerhub/`](envs/prod/careerhub) 와 같은 파일 다섯 개다. 환경 이름은 `env` 변수로만 들어오므로 `backend.tf` 의 이름 말고는 내용이 같다.
   - `main.tf` — 모듈 호출 둘과 remote state 읽기.
     - `module "auth" { source = "../../../_modules/careerhub/auth"  env = var.env  google_client_* = var.google_client_* }`
     - `module "tfc_remote_state" { source = "../../../_modules/tfc_remote_state"  workspaces = ["shared-iam"] }`
     - `module "cnpg_backup" { source = "../../../_modules/cnpg-backup"  namespace = "careerhub-${var.env}"  cluster_name = "careerhub-postgresql"  k8s_oidc_provider_arn = module.tfc_remote_state.outputs["shared-iam"]["k8s_oidc_provider_arn"]  k8s_oidc_issuer_url = var.k8s_oidc_issuer_url }` — 버킷 · Role 이름은 모듈이 `cnpg-backup-<namespace>-<cluster>` 로 파생한다. 이름 override 입력은 없다.
   - `variables.tf` — `env` · `region`(값은 variable set 이 준다) · `google_client_id` · `google_client_secret`(sensitive) · `google_redirect_url` · `k8s_oidc_issuer_url`(default `https://k8s-oidc.jyo-liar.com`)
   - `providers.tf` — `aws` · `random` · `tfe` provider(`provider "tfe" {}` — remote state 읽기), `aws` 의 `region = var.region` 과 `default_tags`(`env` · `managed_by`)
   - `outputs.tf` — `ssm_masterkey_path` · `ssm_google_client_path` · `cnpg_backup_bucket` · `cnpg_backup_role_arn`
   - `backend.tf` — `workspaces { name = "stg-careerhub" }`
5. 머지하면 `stg-careerhub` 에 run 이 생긴다 — 콘솔에서 plan 을 읽고 apply 를 승인한다. Parameter Store 에 `/jyo-liar/k8s/baremetal/careerhub/stg/zitadel/masterkey` · `/jyo-liar/k8s/baremetal/careerhub/stg/oauth/google-client` 가 서고, S3 버킷 `cnpg-backup-careerhub-stg-careerhub-postgresql-<account_id>` 와 IAM Role `cnpg-backup-careerhub-stg-careerhub-postgresql` 이 선다. 버킷 이름과 Role ARN 은 `terraform output` 으로 읽어 jyoliar-k8s 의 `ObjectStore`(`destinationPath` · `AWS_ROLE_ARN`)에 넘긴다.

환경 루트가 다른 공유 루트의 출력을 더 읽어야 하면, 같은 방식으로 읽히는 공유 워크스페이스의 `remote_state_consumer_ids` 에 새 워크스페이스를 더한다(`tfc/`).

## 주의

- `lab-vpc` 는 destroy 하지 않는다 — `lab-vpn` 이 그 출력을 읽는다.
- CNPG 백업 버킷(`_modules/cnpg-backup` 의 `aws_s3_bucket`)은 `prevent_destroy` 다 — 백업 데이터를 담은 stateful 리소스라, 환경 워크스페이스의 destroy · replace 가 든 plan 은 plan 단계에서 멈춘다. 버킷의 보존 정책은 barman 이 관리하고 버저닝은 없다.
- `prod-careerhub` 의 Zitadel masterkey 는 `prevent_destroy` 다 — 값이 바뀌면 Zitadel 이 기동하지 못한다([`_modules/careerhub/auth/main.tf`](_modules/careerhub/auth/main.tf)).
- `shared-iam` 은 plan 때 OIDC 발급자 URL 에 TLS 로 접속해 인증서를 읽는다([`shared/iam/oidc.tf`](shared/iam/oidc.tf)). 그 호스트의 DNS 레코드와 터널은 `shared-cloudflare` 가 만들므로 `shared-cloudflare` 가 먼저다. 클러스터는 없어도 된다 — 레코드가 proxied 라 엣지가 TLS 를 종단한다.

## 다른 저장소와의 경계

다른 두 저장소에서 받는 것은 없다 — 이 저장소가 가장 먼저 선다.

합의하는 값 — 이 저장소의 변수 기본값이 먼저 정하고, 두 저장소가 같은 값을 쓴다:

| 무엇 | 이 저장소의 자리 | 따르는 자리 |
|---|---|---|
| OIDC 발급자 URL | `k8s_oidc_issuer_url`([`shared/iam/variables.tf`](shared/iam/variables.tf) · [`envs/prod/careerhub/variables.tf`](envs/prod/careerhub/variables.tf)) | onpremise-k8s 인벤토리 `service_account_issuer` · jyoliar-k8s `cloudflare-tunnel` 의 ingress hostname |
| IRSA 가 신뢰하는 ServiceAccount 좌표 | `shared/iam` 의 `*_sa_namespace` · `*_sa_name` · `_modules/cnpg-backup` 의 `namespace` · `cluster_name` 입력(`<cluster_name>` · `<cluster_name>-restore` SA) → 신뢰 정책의 `sub` 조건 | jyoliar-k8s 의 해당 ServiceAccount 이름 · 네임스페이스 |

넘기는 것 — 전부 jyoliar-k8s 가 받는다:

| 무엇 | 이 저장소의 자리 | 그쪽의 자리 |
|---|---|---|
| Parameter Store 파라미터 | `shared/admin-oauth` · `shared/alert` · `shared/cloudflare` · `envs/prod/careerhub` 의 `aws_ssm_parameter` | `ClusterSecretStore/aws-parameter-store` 를 쓰는 ExternalSecret |
| IRSA Role | [`shared/iam/irsa_roles.tf`](shared/iam/irsa_roles.tf)(External Secrets · ECR pull) · [`_modules/cnpg-backup/irsa.tf`](_modules/cnpg-backup/irsa.tf)(PostgreSQL 백업 — `envs/<env>/careerhub` 출력 `cnpg_backup_role_arn`) | ServiceAccount 의 `eks.amazonaws.com/role-arn` annotation |
| S3 백업 버킷 | [`_modules/cnpg-backup/s3.tf`](_modules/cnpg-backup/s3.tf)(`envs/<env>/careerhub` 출력 `cnpg_backup_bucket`) | CloudNativePG `ObjectStore` 의 `destinationPath` |
| ECR 저장소 | [`shared/ci/ecr.tf`](shared/ci/ecr.tf) | overlay kustomization 의 `images` |
| Cloudflare 터널 자격증명 | `shared-cloudflare` 출력 `tunnel_credentials`([`shared/cloudflare/outputs.tf`](shared/cloudflare/outputs.tf)) | `platform/overlays/create-tunnel-token.sh` 가 Secret 으로 옮긴다 |

`shared-ci` 의 CodeBuild 러너는 GitHub Actions 가 부른다 — 홈랩이 받는 것이 아니다. `lab/` 의 출력은 다른 두 저장소가 받지 않는다.

Terraform 은 클러스터 안을 알지 못한다. 방향은 한쪽이다.
