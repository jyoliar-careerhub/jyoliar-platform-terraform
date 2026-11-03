variable "name" {
  description = "프로젝트 이름"
  type        = string
}

variable "variable_sets" {
  description = "이 프로젝트가 소유하고 이 프로젝트에 붙는 variable set. 키는 set 이름이다(조직 안에서 유일)"
  type = map(object({
    description = optional(string)
    # provider 기본값과 같게 둔다 — priority 는 호출하는 쪽에서 명시한다
    priority = optional(bool, false)
    variables = map(object({
      value    = string
      category = optional(string, "terraform")
      hcl      = optional(bool, false)
    }))
  }))
  default = {}

  # 한 프로젝트의 set 끼리 같은 (category, key) 를 갖지 않는다 — 겹치면 어느 값이 이기는지 set 이름 순서에 맡기게 된다.
  validation {
    condition = (
      length(flatten([for s in values(var.variable_sets) : [for k, v in s.variables : "${v.category}/${k}"]]))
      == length(distinct(flatten([for s in values(var.variable_sets) : [for k, v in s.variables : "${v.category}/${k}"]])))
    )
    error_message = "같은 프로젝트의 variable set 끼리 같은 category/key 를 가질 수 없다."
  }
}
