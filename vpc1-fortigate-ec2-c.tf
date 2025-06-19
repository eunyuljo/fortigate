# FortiGate EC2 - AZ C
resource "aws_instance" "fortigate-ec2-c" {
  ami           = "ami-007cad54955b2bc38" # fortinet 에서 제공하는 AMI ID -> 기본 세팅 이후는 스냅샷 활용 
  instance_type = "m5.xlarge" # Attach 가능한 Interface 추가 확인

  network_interface {
    network_interface_id = aws_network_interface.eni_0_c.id
    device_index         = 0
  }
  tags = {
    Name = "fortigate-ec2-c"
    AZ   = "ap-northeast-2c"
  }

  key_name = "eyjo-fnf-test-key" # SSH 접속을 위한 키 페어
}

# ENI_0 생성 - AZ C
resource "aws_network_interface" "eni_0_c" {
  subnet_id       = module.vpc1.public_subnets[1] # ap-northeast-2c
  private_ips     = ["10.0.102.100", "10.0.102.101"]
  security_groups = [aws_security_group.fortigate_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-0-c"
    AZ   = "ap-northeast-2c"
  }
}

# ENI1 생성 - AZ C (Private)
resource "aws_network_interface" "eni_1_c" {
  subnet_id       = module.vpc1.private_subnets[1] # ap-northeast-2c
  private_ips     = ["10.0.2.100"]    
  security_groups = [aws_security_group.fortigate_eni_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-1-c"
    AZ   = "ap-northeast-2c"
  }
}

# ENI2 생성 - AZ C (Intra)
resource "aws_network_interface" "eni_2_c" {
  subnet_id       = module.vpc1.intra_subnets[1] # ap-northeast-2c
  private_ips     = ["10.0.11.100"]    
  security_groups = [aws_security_group.fortigate_eni_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-2-c"
    AZ   = "ap-northeast-2c"
  }
}

# ENI1을 EC2에 Attach - AZ C
resource "aws_network_interface_attachment" "eni_attach_1_c" {
  instance_id          = aws_instance.fortigate-ec2-c.id       
  network_interface_id = aws_network_interface.eni_1_c.id    
  device_index         = 1                                
}

# ENI2를 EC2에 Attach - AZ C
resource "aws_network_interface_attachment" "eni_attach_2_c" {
  instance_id          = aws_instance.fortigate-ec2-c.id       
  network_interface_id = aws_network_interface.eni_2_c.id    
  device_index         = 2                                
}

## FortiGate 접속용 정보 - AZ C ##
output "instance_public_ip_c" {
  description = "The public IP address of the FortiGate instance in AZ C"
  value       = aws_instance.fortigate-ec2-c.public_ip
}

output "instance_id_c" {
  description = "FortiGate instance ID in AZ C"
  value       = aws_instance.fortigate-ec2-c.id
}