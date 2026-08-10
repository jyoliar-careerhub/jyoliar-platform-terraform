# Zitadel masterkey — 암호화 데이터 복구의 필수 재료.
# PG 덤프만으로는 복구가 완결되지 않으므로(ADR-0030) 원본을 클러스터 밖에 둔다.
# 클러스터는 ExternalSecret으로 이 파라미터를 당겨 쓴다.
#
# 회전 대상 시크릿이 아니라 불변 루트 키 재료다 — Zitadel에 masterkey 회전
# 기능이 없다(zitadel/zitadel#6768, 미착수). 유실이 누출보다 무섭다.
#
# special = false: Zitadel masterkey는 정확히 32바이트여야 하고,
# 영숫자만 쓰면 문자 수 = 바이트 수가 보장된다.
resource "random_password" "zitadel_masterkey" {
  length  = 32
  special = false

  # terraform 경로에서 새 masterkey가 생기는 유일한 통로가 이 리소스의 교체다
  # (length·special 수정, keepers 추가는 전부 ForceNew).
  # 파라미터 쪽 prevent_destroy는 value의 in-place update를 막지 못하므로,
  # 값의 불변은 여기서 지킨다.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_ssm_parameter" "zitadel_masterkey" {
  name  = "/jyo-liar/k8s/baremetal/careerhub/prod/zitadel/masterkey"
  type  = "SecureString"
  value = random_password.zitadel_masterkey.result

  # 값을 바꾸면 ExternalSecret 재동기화 후 다음 pod 재시작에서 복호화 실패로
  # 기동 불능이 된다. 사고 방지용 경고를 파라미터 자체에 남긴다.
  description = "Zitadel masterkey — 회전 불가. 교체·삭제 금지(값 교체 시 기동 불능). 절차: ops-workflow docs/careerhub/discussion/260810_1910_zitadel-masterkey-rotation-paths.md"

  # 파라미터 삭제는 버전 이력까지 함께 지운다 — terraform 경로의 삭제 실수를 막는다.
  lifecycle {
    prevent_destroy = true
  }
}
