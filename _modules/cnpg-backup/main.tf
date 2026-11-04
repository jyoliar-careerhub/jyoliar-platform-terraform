# CNPG(PostgreSQL) 클러스터 하나의 백업 재료 — S3 버킷과 그 IRSA Role.
# 입력은 클러스터의 좌표(네임스페이스 · Cluster 이름)와 OIDC Provider 뿐이다 — 환경 이름은 네임스페이스가 이미 든다
# (careerhub-prod / careerhub-stg). 이름은 전부 그 좌표에서 파생하므로 같은 환경에 CNPG 클러스터가 둘이어도 겹치지 않는다.

data "aws_caller_identity" "current" {}

locals {
  # 버킷 · Role · Policy 이름의 줄기 — cnpg-backup-<namespace>-<cluster>.
  # 버킷은 뒤에 계정 ID가 붙어 63자 한계에 가깝다 — namespace 와 cluster_name 의 합이 38자를 넘으면 이 규칙으로 못 짓는다.
  name = "cnpg-backup-${var.namespace}-${var.cluster_name}"

  oidc_issuer_host = replace(var.k8s_oidc_issuer_url, "https://", "")

  # CNPG는 Cluster 이름과 같은 이름의 SA를 만든다. 복구는 원본을 덮어쓰는 것이
  # 아니라 별도 Cluster를 세우는 일이므로, 그 클러스터의 SA도 신뢰해야 한다 —
  # 아니면 복구 훈련을 할 때마다 AWS 변경이 선행되어야 한다.
  # 와일드카드 대신 이름을 열거한다. `<이름>*`로 열면 pooler SA까지 딸려 들어와
  # 백업 버킷 쓰기 권한이 불필요하게 넓어진다.
  trusted_subs = [
    "system:serviceaccount:${var.namespace}:${var.cluster_name}",
    "system:serviceaccount:${var.namespace}:${var.cluster_name}-restore",
  ]
}
