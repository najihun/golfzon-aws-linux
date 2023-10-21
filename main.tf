data "template_file" "hostname_init" {
    template = "${file("${path.module}/hostname.tpl")}"
    vars = {
        host_name = "${aws_instance.web.private_ip}"
    }
    depends_on = [ 
        aws_instance.web
     ]
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"

  ## network interface for ip addrs attachment dynamically
  network_interface {
    network_interface_id = aws_network_interface.golfzon-nic.id
    device_index         = 0
  }
  
  user_data = "${data.template_file.hostname_init.rendered}"

  tags = {
    Name = "golfzon-poc"
  }
}

## network interface for instance: 
resource "aws_network_interface" "golfzon-nic" {
  subnet_id   = aws_subnet.golfzon-subnet.id
  private_ips = [ var.priv_ip ]
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
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "golfzon-poc"
  }
}
