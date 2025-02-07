provider "aws" {
  region = "ap-northeast-2"
}

module "vpc1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"# 최신 버전 확인 필요

  name = "eyjo-parnas-sec-vpc1"
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  map_public_ip_on_launch = true

  #각 VPC 환경은 NAT를 사용하지 않고 FW 을 통해 경유하도록 구성한다.
  #enable_nat_gateway = true
  #single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Test"
    Project     = "Test"
  }
}


module "vpc2" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "eyjo-parnas-sec-vpc2"
  cidr = "10.1.0.0/16"

  azs             = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  map_public_ip_on_launch = true
  #각 VPC 환경은 NAT를 사용하지 않고 FW 을 통해 경유하도록 구성한다.
  #enable_nat_gateway       = true
  #single_nat_gateway       = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "Test"
    Project     = "Test"
  }
}

### ssm endpoint - vpc1

resource "aws_security_group" "ssm" {
  vpc_id = module.vpc1.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 필요에 따라 IP 제한을 설정
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-sg"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = module.vpc1.vpc_id
  service_name       = "com.amazonaws.ap-northeast-2.ssm"  
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.vpc1.private_subnets[0]] 
  security_group_ids = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = module.vpc1.vpc_id
  service_name        = "com.amazonaws.ap-northeast-2.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids          = [module.vpc1.private_subnets[0]]
  security_group_ids  = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "ssm-messages-endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = module.vpc1.vpc_id
  service_name       = "com.amazonaws.ap-northeast-2.ec2messages" 
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [module.vpc1.private_subnets[0]]
  security_group_ids = [aws_security_group.ssm.id]
  private_dns_enabled = true

  tags = {
    Name = "ec2-messages-endpoint"
  }
}


### ssm endpoint - vpc1