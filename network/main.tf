data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = var.is_dns_support
  enable_dns_hostnames = var.is_dns_hostname

  tags = {
    Name       = "vpc"
    managed_by = var.managed_by
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name       = "igw"
    managed_by = var.managed_by
  }
}

resource "aws_subnet" "public_sn" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_sn_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name       = "public_subnet_${count.index + 1}"
    managed_by = var.managed_by
  }

}

resource "aws_subnet" "private_sn" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_sn_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone        = random_shuffle.az_list.result[count.index]

  tags = {
    Name       = "private_subnet_${count.index + 1}"
    managed_by = var.managed_by
  }


}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name       = "public_rt"
    managed_by = var.managed_by
  }
}

resource "aws_route_table_association" "public_ascn" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.public_sn.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "private_ascn" {
  count          = var.private_sn_count
  subnet_id      = aws_subnet.private_sn.*.id[count.index]
  route_table_id = aws_route_table.priv-rt.*.id[count.index]


}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = var.all_ips_allowed
  gateway_id             = aws_internet_gateway.igw.id

}

resource "aws_default_route_table" "def_priv_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  tags = {
    Name       = "default_rt_private"
    managed_by = var.managed_by
  }

}

resource "aws_eip" "eip_for_natgw" {
  count = var.private_sn_count
  vpc   = var.is_vpc
}

resource "aws_nat_gateway" "ngw" {
  count         = var.private_sn_count
  allocation_id = aws_eip.eip_for_natgw.*.id[count.index]
  subnet_id     = aws_subnet.private_sn.*.id[count.index]

  tags = {
    Name       = "ngw"
    managed_by = var.managed_by
  }

}

resource "aws_route_table" "priv-rt" {
  count  = var.private_sn_count
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.all_ips_allowed
    nat_gateway_id = aws_nat_gateway.ngw.*.id[count.index]
  }
  
  tags = {
    Name       = "priv_rt"
    managed_by = var.managed_by
  }

}
