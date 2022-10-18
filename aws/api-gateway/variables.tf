variable "name" {
  type = string
}

variable "type" {
  type = string
  default = "HTTP"
}

variable "auto_deploy" {
  type = bool
  default = true
}

variable "logs_retention" {
  type = number
  default = 30
}

variable "default_throttling_burst_limit" {
  description = "0 = unlimited"
  type = number
  default = 100
}

variable "default_throttling_rate_limit" {
  description = "0 = unlimited"
  type = number
  default = 100
}

variable "integrations" {
  type = any
}

variable "tags" {
  description = "Maps of common tags to be assigned"
  type        = map(string)
  default     = {}
}

variable "cors_allow_credentials" {
  type = bool
  default = false
}

variable "cors_allow_headers" {
  type = list(string)
  default = ["*"]
}

variable "cors_allow_methods" {
  type = list(string)
  default = ["*"]
}

variable "cors_allow_origins" {
  type = list(string)
  default = ["*"]
}

variable "cors_expose_headers" {
  type = list(string)
  default = ["*"]
}

variable "cors_max_age" {
  type = string
  default = 0
}

