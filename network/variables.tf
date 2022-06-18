variable "max_subnets" {
  type = number
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
var "all_ips_allowed" {
  type = string
}

var "is_vpc" {
  type = string
}
