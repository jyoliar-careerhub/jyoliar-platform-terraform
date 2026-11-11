# jyoliar-platform-terraform — 클라우드 seed Terraform 프로젝트

## ⚠️ 필수 행동 규칙

**작업 실패/오류 발생 시:**
1. 원인 파악까지만 진행
2. **절대 임의로 조치하지 않음** (cleanup, rollback, destroy, 재시도 등 금지)
3. 상황을 보고하고 사용자 지시 대기

이 규칙을 어기면 안 됩니다.

## ⛔ 금지 사항

- **AWS CLI 사용 금지** - 모든 인프라 작업은 Terraform으로만 수행
- Terraform 인증 실패 시 AWS CLI로 대체하지 않고 오류 보고
- `aws` 명령어 실행 금지 (`aws ec2`, `aws s3`, `aws iam` 등 모두 해당)

## 개요

홈랩이 혼자 할 수 없는 것을 AWS와 Cloudflare에 Terraform으로 만드는 프로젝트입니다. 공유 리소스(`shared/`), 환경별 리소스(`envs/<env>/`), AWS 모의 환경(`lab/`)을 Terraform Cloud 워크스페이스로 나누고, 그 워크스페이스들은 `tfc/`가 선언합니다. 운영자용 설명은 `README.md`에 있습니다.

## 디렉토리 구조

```
├── tfc/                       # 프로젝트 · variable set · 다른 모든 워크스페이스의 선언. 유일한 로컬 apply 루트
│   └── _modules/              # project · workspace
├── _modules/                  # 공유 모듈
│   ├── careerhub/auth/
│   ├── cnpg-backup/
│   ├── nat/
│   └── tfc_remote_state/
├── shared/                    # 공유 루트 — 환경 축 없음
│   ├── admin-oauth/
│   ├── alert/
│   ├── ci/
│   ├── cloudflare/
│   └── iam/
├── envs/                      # 환경 루트 — envs/<env>/<루트>
│   ├── prod/
│   │   └── careerhub/
│   └── stg/
│       └── careerhub/
└── lab/                       # 실험 루트 — AWS 모의 환경
    ├── vpc/
    │   └── _modules/          # vpc · subnets
    └── vpn/
```

## 워크스페이스

이름은 디렉터리 좌표입니다 — `shared/<루트>` → `shared-<루트>`, `lab/<루트>` → `lab-<루트>`, `envs/<env>/<루트>` → `<env>-<루트>`. 선언은 전부 `tfc/`(`ws-*.tf`)에 있습니다.

| 워크스페이스 | 디렉터리 | 프로젝트 | 구동 | 용도 |
|-------------|----------|----------|------|------|
| tfc | `tfc/` | Default Project | 로컬 CLI | 프로젝트 · variable set · 워크스페이스 선언 |
| shared-admin-oauth | `shared/admin-oauth/` | shared | VCS | argocd · grafana 로그인용 Google 클라이언트 → Parameter Store |
| shared-alert | `shared/alert/` | shared | VCS | Discord 알림 채널 · webhook → Parameter Store |
| shared-ci | `shared/ci/` | shared | VCS | CodeBuild 러너 · ECR 저장소 |
| shared-cloudflare | `shared/cloudflare/` | shared | VCS | DNS zone · 터널 · 엣지 보호 · external-dns 토큰 |
| shared-iam | `shared/iam/` | shared | VCS | IAM OIDC Provider · IRSA Role |
| prod-careerhub | `envs/prod/careerhub/` | prod-careerhub | VCS | Zitadel masterkey · Google OAuth 클라이언트 → Parameter Store · PostgreSQL 백업 S3 버킷과 그 IRSA Role |
| stg-careerhub | `envs/stg/careerhub/` | stg-careerhub | VCS | prod-careerhub 와 같은 재료의 stg 한 벌 |
| lab-vpc | `lab/vpc/` | lab | VCS | VPC, Subnets, Route Tables |
| lab-vpn | `lab/vpn/` | lab | VCS | Tailscale 라우터 · 워커 인스턴스 |

환경 하나 = 워크스페이스 하나입니다. 환경 루트(`envs/<env>/careerhub`)는 `_modules/careerhub/auth`(인증 재료)와 `_modules/cnpg-backup`(PostgreSQL 백업 S3 버킷과 그 IRSA Role) 두 모듈을 부릅니다. 백업 버킷은 데이터를 담은 stateful 리소스라 `prevent_destroy`로 보호합니다 — destroy · replace가 든 plan은 plan 단계에서 멈춥니다. 접근 권한(IRSA Role)은 버킷과 수명이 같으므로 같은 모듈에 두고, OIDC Provider ARN만 `shared-iam`의 출력에서 읽습니다(`_modules/tfc_remote_state`).

## 백엔드

모든 루트에 `backend.tf`가 있습니다 — 로컬 CLI 바인딩용이고 러너는 쓰지 않습니다(원격 run은 HCP Terraform이 주입한 백엔드로 돕니다). `tfc`의 것(`tfc/providers.tf`)만 실제 실행 백엔드입니다.

- `backend.tf`의 `workspaces.name`은 `tfc/`가 선언한 이름과 같아야 합니다. 로컬 `state mv` · `import` · `state push`도 이 바인딩을 따르므로, 틀리면 다른 워크스페이스의 state를 칩니다.
- 로컬 바인딩을 `*_override.tf`로 만들지 마십시오 — HCP가 자기 백엔드를 override 파일로 주입하므로 충돌합니다.

## 공유 → 환경, 단방향

환경 루트는 공유 루트의 출력을 `_modules/tfc_remote_state`로 읽습니다. 공유 루트가 환경 루트를 읽는 일은 없습니다. 읽을 수 있는 워크스페이스는 읽히는 쪽의 `remote_state_consumer_ids`(`tfc/`)가 열거합니다.

- `prod-careerhub` · `stg-careerhub` → `shared-iam`(CNPG 백업 IRSA Role의 OIDC Provider ARN)
- `lab-vpn` → `lab-vpc`

## 네트워크 (lab/vpc)

- VPC CIDR: 10.0.0.0/16
- EKS Private Subnet: 10.0.25.0/24 (k8s 노드 배치)
- Core Public Subnet: NAT 인스턴스, ansible-server 배치

## 변수

- 비밀 아닌 변수는 `tfc/`의 `tfe_variable`(워크스페이스 모듈의 `variables`)입니다. sensitive 변수는 Terraform Cloud 콘솔에 둡니다 — 코드에 값을 적지 마십시오.
- `env`와 `region`은 워크스페이스가 속한 프로젝트가 소유한 variable set이 주입합니다(`tfc/projects.tf`, `priority = true`). 워크스페이스에는 그 변수가 없습니다.
  - env: 프로젝트 단위의 환경 이름 — `shared`(shared 프로젝트) · `lab`(lab 프로젝트) · `prod`(prod-careerhub 프로젝트) · `stg`(stg-careerhub 프로젝트)
  - region: ap-northeast-2
- 모든 AWS 루트의 provider `default_tags`는 `env = var.env`와 `managed_by = "terraform"`입니다.

`env`는 태그용 문자열만이 아니라 **이름의 재료**입니다. 환경마다 따로 서는 리소스(버킷, IAM Role, SSM 경로 등)의 이름은 `env`에서 파생시켜, 같은 루트가 다른 환경으로 한 벌 더 서더라도 이름이 겹치지 않게 합니다. 환경 이름을 리터럴로 박아 넣지 마십시오.

## 반영 — apply 는 사람이 승인한다

워크스페이스의 `auto_apply`는 기본 `false`입니다(`tfc/_modules/workspace`의 기본값, 예외 없음).

- PR을 머지하면 VCS가 run을 만들고 plan까지 자동으로 돕니다.
- plan에 변경이 있으면 run은 확인 대기("Needs Confirmation")에서 멈춥니다. **머지 뒤에도 apply는 사람이 Terraform Cloud 콘솔에서 별도로 승인합니다**(Confirm & Apply). 변경이 없으면 run은 그대로 끝납니다.
- 따라서 머지는 반영의 끝이 아닙니다. 머지 후 각 워크스페이스의 run plan을 읽고, 승인 또는 폐기(Discard)까지가 한 번의 반영입니다.
- 확인 대기 run이 남아 있으면 그 워크스페이스의 다음 run은 그 뒤에 줄을 섭니다 — 승인하거나 폐기해 비웁니다.
- VCS 루트에서 로컬로 돌릴 수 있는 것은 `terraform init` · `terraform plan`(speculative plan)뿐입니다 — 로컬 apply는 거부됩니다.
- `tfc`만 로컬에서 `terraform plan` · `terraform apply`합니다(운영자의 `terraform login` 자격증명).
- 워크스페이스 추가 · 개명 · 경로 변경은 `tfc/`의 PR입니다. 개명 · 경로 변경이면 그 루트의 `backend.tf`도 같은 PR에서 고칩니다. 새 루트의 `backend.tf`는 루트 디렉터리를 만드는 PR에 듭니다(README "새 환경 추가").

## 새 환경 추가

절차는 `README.md`의 "새 환경 추가" 절입니다 — `envs/<env>/careerhub` 디렉터리 하나(모듈 호출 둘 — `careerhub/auth` · `cnpg-backup`) + `tfc/`에 프로젝트(`<env>-careerhub`) · variable set(`env` · `region`) · 워크스페이스(`<env>-careerhub`) 선언 · `shared-iam`의 `remote_state_consumer_ids`에 새 워크스페이스 추가 + 콘솔에 sensitive 변수. Google OAuth 클라이언트는 GCP 콘솔에서 먼저 만듭니다.

## 인프라 상태 확인

인프라 현황 확인 시 **Terraform 명령어**를 사용합니다. AWS CLI는 사용하지 않습니다.

| 용도 | 명령어 |
|------|--------|
| 리소스 목록 | `terraform state list` |
| 상세 정보 | `terraform show` |
| 출력값 확인 | `terraform output` |

## 주의사항

1. **lab-vpc 워크스페이스는 destroy 하지 마세요** - lab-vpn이 그 출력을 읽습니다
2. **환경 워크스페이스(prod-careerhub · stg-careerhub)의 Zitadel masterkey는 교체 · 삭제하지 마세요** - `prevent_destroy`이고, 값이 바뀌면 Zitadel이 기동하지 못합니다
3. **CNPG 백업 버킷은 `prevent_destroy`입니다** - 백업 데이터를 담습니다. 환경 워크스페이스에 destroy · replace가 든 plan은 plan 단계에서 멈춥니다
