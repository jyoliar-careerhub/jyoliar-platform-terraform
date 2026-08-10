# On-Premise 모의 환경 Terraform 프로젝트

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

Kubernetes on-premise 환경을 AWS에서 모의 구축하기 위한 Terraform 프로젝트입니다.

## 디렉토리 구조

```
├── _modules/              # 공통 모듈
│   ├── tfc_remote_state/
│   └── nat/
├── vpc/                   # VPC 워크스페이스
│   └── _modules/          # VPC 전용 모듈
│       ├── vpc/
│       └── subnets/
├── iam/                   # IAM 워크스페이스
├── vpn/                   # VPN 워크스페이스
└── backup/                # 백업 워크스페이스
```

## 워크스페이스

| 워크스페이스 | Terraform Cloud | 용도 | 상태 |
|-------------|-----------------|------|------|
| vpc | onpremise-vpc | VPC, Subnets, Route Tables | 항상 유지 |
| iam | onpremise-iam | IAM User, Access Key | 항상 유지 |
| vpn | - | VPN | 구성 중 |
| backup | onpremise-backup | 백업 저장소(S3)와 그 접근 권한 | 항상 유지 |

백업 저장소는 데이터를 담은 stateful 리소스라 destroy의 파급이 다른 워크스페이스와 다릅니다. 그래서 IAM·VPC와 state를 섞지 않고 `backup`으로 가릅니다. 접근 권한(IRSA Role)은 버킷과 수명이 같으므로 같은 워크스페이스에 두고, OIDC Provider ARN만 `onpremise-iam`의 출력에서 읽습니다(`_modules/tfc_remote_state`).

## 네트워크

- VPC CIDR: 10.0.0.0/16
- EKS Private Subnet: 10.0.25.0/24 (k8s 노드 배치)
- Core Public Subnet: NAT 인스턴스, ansible-server 배치

## 변수

`env`와 `region`은 Terraform Cloud 워크스페이스에서 주입됩니다.
- env: 워크스페이스가 대상으로 삼는 환경 이름 (모의 인프라 워크스페이스는 `onpremise`, `backup`은 `prod`)
- region: ap-northeast-2

`env`는 태그용 문자열이 아니라 **이름의 재료**입니다. 환경마다 따로 서는 리소스(버킷, IAM Role 등)의 이름은 `env`에서 파생시켜, 나중에 같은 워크스페이스가 다른 환경으로 한 벌 더 서더라도 이름이 겹치지 않게 합니다. 환경 이름을 리터럴로 박아 넣지 마십시오.

## 인프라 상태 확인

인프라 현황 확인 시 **Terraform 명령어**를 사용합니다. AWS CLI는 사용하지 않습니다.

| 용도 | 명령어 |
|------|--------|
| 리소스 목록 | `terraform state list` |
| 상세 정보 | `terraform show` |
| 출력값 확인 | `terraform output` |

## 주의사항

1. **vpc 워크스페이스는 destroy 하지 마세요** - 다른 워크스페이스가 의존합니다
