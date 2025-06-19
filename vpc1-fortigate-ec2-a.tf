# FortiGate EC2 - AZ A
resource "aws_instance" "fortigate-ec2-a" {
  ami           = "ami-007cad54955b2bc38" # fortinet 에서 제공하는 AMI ID -> 기본 세팅 이후는 스냅샷 활용 
  instance_type = "m5.xlarge" # Attach 가능한 Interface 추가 확인

  network_interface {
    network_interface_id = aws_network_interface.eni_0_a.id
    device_index         = 0
  }
  tags = {
    Name = "fortigate-ec2-a"
    AZ   = "ap-northeast-2a"
  }

  key_name = "eyjo-fnf-test-key" # SSH 접속을 위한 키 페어
}

# ENI_0 생성 - AZ A
resource "aws_network_interface" "eni_0_a" {
  subnet_id       = module.vpc1.public_subnets[0] # ap-northeast-2a
  private_ips     = ["10.0.101.100", "10.0.101.101"]
  security_groups = [aws_security_group.fortigate_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-0-a"
    AZ   = "ap-northeast-2a"
  }
}

# ENI1 생성 - AZ A (Private)
resource "aws_network_interface" "eni_1_a" {
  subnet_id       = module.vpc1.private_subnets[0] # ap-northeast-2a
  private_ips     = ["10.0.1.100"]    
  security_groups = [aws_security_group.fortigate_eni_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-1-a"
    AZ   = "ap-northeast-2a"
  }
}

# ENI2 생성 - AZ A (Intra)
resource "aws_network_interface" "eni_2_a" {
  subnet_id       = module.vpc1.intra_subnets[0] # ap-northeast-2a
  private_ips     = ["10.0.10.100"]    
  security_groups = [aws_security_group.fortigate_eni_sg.id] 
  source_dest_check = false 

  tags = {
    Name = "fortigate-eni-2-a"
    AZ   = "ap-northeast-2a"
  }
}

# ENI1을 EC2에 Attach - AZ A
resource "aws_network_interface_attachment" "eni_attach_1_a" {
  instance_id          = aws_instance.fortigate-ec2-a.id       
  network_interface_id = aws_network_interface.eni_1_a.id    
  device_index         = 1                                
}

# ENI2를 EC2에 Attach - AZ A
resource "aws_network_interface_attachment" "eni_attach_2_a" {
  instance_id          = aws_instance.fortigate-ec2-a.id       
  network_interface_id = aws_network_interface.eni_2_a.id    
  device_index         = 2                                
}

## FortiGate 접속용 정보 - AZ A ##
output "instance_public_ip_a" {
  description = "The public IP address of the FortiGate instance in AZ A"
  value       = aws_instance.fortigate-ec2-a.public_ip
}

output "instance_id_a" {
  description = "FortiGate instance ID in AZ A"
  value       = aws_instance.fortigate-ec2-a.id
}