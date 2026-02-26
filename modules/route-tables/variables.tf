variable "vpc_id" {
  type = string
}

variable "route_table_name" {
  type = string
}

variable "routes" {
  type    = list(map(string))
  default = []
}

variable "subnet_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
