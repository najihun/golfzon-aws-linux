data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  
  ## private ip customization
  private_ip    = var.priv_ip

  ## network interface for eip attachment dynamically
  network_interface {
    network_interface_id = aws_network_interface.golfzon-nic.id
    device_index         = 0
  }
  
  tags = {
    Name = "golfzon-poc"
  }
}

## network interface for instance: 
resource "aws_network_interface" "golfzon-nic" {
  subnet_id   = aws_subnet.golfzon-subnet.id
  #security_groups = [""]

  tags = {
    Name = "golfzon-poc"
  }
}

## elastic ip: attach to golfzon-nic for instance && associate private ip for instance
resource "aws_eip" "golfzon-eip" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.golfzon-nic.id
  associate_with_private_ip = var.priv_ip
}

## test vpc: golfzon-vpc (10.0.0.0/16)
resource "aws_vpc" "golfzon-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "golfzon-poc"
  }
}

## test subnet on golfzon-vpc: golfzon-subnet (10.0.1.0/24)
resource "aws_subnet" "golfzon-subnet" {
  vpc_id            = aws_vpc.golfzon-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northast-2a"

  tags = {
    Name = "golfzon-poc"
  }
}
