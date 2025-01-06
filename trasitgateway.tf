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