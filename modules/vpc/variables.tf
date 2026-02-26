variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
