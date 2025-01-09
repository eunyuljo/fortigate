resource "aws_instance" "fortifate-ec2" {
  ami           = "ami-007cad54955b2bc38" # 마켓플레이스 AMI ID
  instance_type = "t3.medium"

  tags = {
    Name = "fortifate-ec2"
  }

  # 선택적으로 추가 가능:
  key_name = "eyjo-fnf-test-key" # SSH 접속을 위한 키 페어
  subnet_id = module.vpc1.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.fortigate_sg.id] # 보안 그룹 설정
}


# Fortigate 기본 보안그룹 
resource "aws_security_group" "fortigate_sg" {
  name        = "example-security-group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.vpc1.vpc_id # VPC와 연결

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP 허용 (주의: 실 운영 환경에서는 제한적으로 사용)
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP 허용
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Fortigate"
    from_port   = 541
    to_port     = 541
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Fortigate"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Fortigate"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    description = "GENEVE - is this need"
    from_port   = 6081
    to_port     = 6081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }  


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fortigate-sg"
    Environment = "Test"
  }
}

# 추가 ENI 보안 그룹

resource "aws_security_group" "fortigate_eni_sg" {
  name        = "fortigate_eni_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = module.vpc1.vpc_id # VPC와 연결

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP 허용
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fortigate-sg"
    Environment = "Test"
  }
}

# ENI 생성
resource "aws_network_interface" "eni" {
  subnet_id       = module.vpc1.private_subnets[0]
  private_ips     = ["10.0.1.100"]    
  security_groups = [aws_security_group.fortigate_eni_sg.id] 

  tags = {
    Name = "fortie-eni"
  }
}

# ENI를 EC2에 Attach
resource "aws_network_interface_attachment" "eni_attach" {
  instance_id          = aws_instance.fortifate-ec2.id       
  network_interface_id = aws_network_interface.eni.id    
  device_index         = 1                                
}