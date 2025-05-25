resource "aws_vpc" "daenamu_vpc" {
  cidr_block = var.vpc_cidr_block
  tags       = {
    Name = var.vpc_name
  }
}

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.daenamu_vpc.default_route_table_id
  tags                   = {
    Name = "${var.vpc_name}-default"
  }
}

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.daenamu_vpc.id
  tags   = {
    Name = "${var.vpc_name}-default"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.daenamu_vpc.id
  tags   = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.daenamu_vpc.id
  tags   = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_route" "public_worldwide" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.daenamu_vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                    = "${var.vpc_name}-public-${count.index + 1}"
    "kubernetes.io/cluster/${var.vpc_name}" = "owned"
    "kubernetes.io/role/elb"                = "1"
    "karpenter.sh/discovery"                = var.vpc_name
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  tags = {
    Name = "${var.vpc_name}-natgw"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.vpc_name}-natgw"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.daenamu_vpc.id
  tags   = {
    Name = "${var.vpc_name}-private"
  }
}

resource "aws_route" "private_worldwide" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.daenamu_vpc.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name                                    = "${var.vpc_name}-private-${count.index + 1}"
    "kubernetes.io/cluster/${var.vpc_name}" = "owned"
    "kubernetes.io/role/internal-elb"       = "1"
    "karpenter.sh/discovery"                = var.vpc_name
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
