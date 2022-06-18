variable "max_subnets" {
  type = number
}

variable "vpc_cidr_block" {
  type = string
}

variable "is_dns_support" {
  type = bool
}

variable "is_dns_hostname" {
  type = bool
}

variable "managed_by" {
  type = string
}

variable "public_sn_count" {
  type = number
}

variable "public_sn_cidrs" {
  type = list(any)
}

variable "private_sn_count" {
  type = number
}

variable "private_sn_cidrs" {
  type = list(any)
}

variable "all_ips_allowed" {
  type = string
}

variable "is_vpc" {
  type = string
}
