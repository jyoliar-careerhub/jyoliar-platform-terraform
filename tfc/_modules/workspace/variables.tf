variable "name" {
  description = "워크스페이스 이름"
  type        = string
}

variable "project_id" {
  description = "워크스페이스가 속한 프로젝트 id"
  type        = string
}

variable "working_directory" {
  description = "저장소 루트 기준 실행 디렉터리. null 이면 저장소 루트"
  type        = string
  default     = null
}

variable "vcs" {
  description = "VCS 연동. null 이면 CLI 구동"
  type = object({
    identifier                 = string
    github_app_installation_id = string
  })
  default = null
}

variable "another_trigger_patterns" {
  description = "기본 패턴(<working_directory>/**/*) 외에 run 을 만들 파일의 glob — 쓰는 공유 모듈 등. VCS 연동에서만 뜻이 있다"
  type        = list(string)
  default     = []
}

variable "auto_apply" {
  description = "plan 성공 시 자동 apply. run trigger 로 만들어진 run 에도 같은 값을 쓴다"
  type        = bool
  default     = true
}

variable "file_triggers_enabled" {
  description = "VCS push 의 변경 파일로 run 여부를 거를지"
  type        = bool
  default     = true
}

variable "execution_mode" {
  description = "실행 모드 — remote | local"
  type        = string
  default     = "remote"
}

variable "remote_state_consumer_ids" {
  description = "이 워크스페이스의 state 를 읽을 수 있는 워크스페이스 id. 조직 전체 공개(global)는 열지 않는다"
  type        = set(string)
  default     = []
}

variable "variables" {
  description = "워크스페이스 변수 — key 는 변수 이름. 비밀(sensitive) 변수는 여기 두지 않는다"
  type = map(object({
    value    = string
    category = optional(string, "terraform") # terraform | env
    hcl      = optional(bool, false)
  }))
  default = {}
}
