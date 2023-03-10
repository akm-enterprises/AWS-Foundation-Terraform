variable "password_length" {
  description = "The minimum length of passwords for IAM users in the account(aws supports between 6 and 128)"
  type        = number
  default     = 8
}

variable "require_lowercase" {
  description = "Whether to require at least one lowercase character in passwords"
  type        = bool
  default     = true
}

variable "require_uppercase" {
  description = "Whether to require at least one uppercase character in passwords"
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Whether to require at least one numeric character in passwords"
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Whether to require at least one symbol character in passwords"
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Whether IAM users are allowed to change their own passwords"
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "The maximum number of days that a password can be used before it must be changed (aws supports 1 and 1095 days )"
  type        = number
  default     = 90
}

variable "password_reuse_prevention" {
  description = "The number of previous passwords that cannot be reused (aws support between 1 and 24)"
  type        = number
  default     = 3
}

variable "hard_expiry" {
  description = "Whether to enforce a hard password expiry"
  type        = bool
  default     = false
}
