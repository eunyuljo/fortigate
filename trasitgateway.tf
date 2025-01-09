# Transit Gateway 생성
resource "aws_ec2_transit_gateway" "tgw" {
  description = "Test Transit Gateway"
  tags = {
    Name = "Test-TGW"
  }
}

# TGW와 기존 VPC 연결 (Transit Gateway Attachment)
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc1_attachment" {
  subnet_ids         = module.vpc1.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc1.vpc_id

  tags = {
    Name = "VPC1-TGW-Attachment"
  }
}

# TGW와 새 VPC 연결 (Transit Gateway Attachment)
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc2_attachment" {
  subnet_ids         = module.vpc2.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc2.vpc_id

  tags = {
    Name = "VPC2-TGW-Attachment"
  }
}



# VPC1 Route Table Map
locals {
  vpc1_public_route_table_map = {
    for idx, rtb_id in module.vpc1.public_route_table_ids : "public_${idx}" => rtb_id
  }
  vpc1_private_route_table_map = {
    for idx, rtb_id in module.vpc1.private_route_table_ids : "private_${idx}" => rtb_id
  }
}

# VPC2 Route Table Map
locals {
  vpc2_public_route_table_map = {
    for idx, rtb_id in module.vpc2.public_route_table_ids : "public_${idx}" => rtb_id
  }
  vpc2_private_route_table_map = {
    for idx, rtb_id in module.vpc2.private_route_table_ids : "private_${idx}" => rtb_id
  }
}


# VPC1 Public 서브넷 라우팅 테이블 업데이트
resource "aws_route" "vpc1_public_to_vpc2" {
  for_each             = local.vpc1_public_route_table_map
  route_table_id       = each.value
  destination_cidr_block = "10.1.0.0/16" # VPC2 CIDR
  transit_gateway_id   = aws_ec2_transit_gateway.tgw.id
}

# VPC1 Private 서브넷 라우팅 테이블 업데이트
resource "aws_route" "vpc1_private_to_vpc2" {
  for_each             = local.vpc1_private_route_table_map
  route_table_id       = each.value
  destination_cidr_block = "10.1.0.0/16" # VPC2 CIDR
  transit_gateway_id   = aws_ec2_transit_gateway.tgw.id
}

# VPC2 Public 서브넷 라우팅 테이블 업데이트
resource "aws_route" "vpc2_public_to_vpc1" {
  for_each             = local.vpc2_public_route_table_map
  route_table_id       = each.value
  destination_cidr_block = "10.0.0.0/16" # VPC1 CIDR
  transit_gateway_id   = aws_ec2_transit_gateway.tgw.id
}

# VPC2 Private 서브넷 라우팅 테이블 업데이트
resource "aws_route" "vpc2_private_to_vpc1" {
  for_each             = local.vpc2_public_route_table_map
  route_table_id       = each.value
  destination_cidr_block = "10.0.0.0/16" # VPC1 CIDR
  transit_gateway_id   = aws_ec2_transit_gateway.tgw.id
}