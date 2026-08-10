# Zitadel masterkey — 암호화 데이터 복구의 필수 재료.
# PG 덤프만으로는 복구가 완결되지 않으므로(ADR-0030) 원본을 클러스터 밖에 둔다.
# 클러스터는 ExternalSecret으로 이 파라미터를 당겨 쓴다.
#
# special = false: Zitadel masterkey는 정확히 32바이트여야 하고,
# 영숫자만 쓰면 문자 수 = 바이트 수가 보장된다.
resource "random_password" "zitadel_masterkey" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "zitadel_masterkey" {
  name  = "/jyo-liar/k8s/baremetal/careerhub/prod/zitadel/masterkey"
  type  = "SecureString"
  value = random_password.zitadel_masterkey.result
}
