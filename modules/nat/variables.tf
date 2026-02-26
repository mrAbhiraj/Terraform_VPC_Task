variable "nat_gateway_count" {
  type = number
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "nat_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
