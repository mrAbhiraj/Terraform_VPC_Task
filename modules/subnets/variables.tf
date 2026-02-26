variable "vpc_id" {
  type = string
}

variable "subnet_cidrs" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "subnet_name" {
  type = string
}

variable "map_public_ip_on_launch" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
