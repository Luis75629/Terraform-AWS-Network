provider "aws" {
  assume_role {
    role_arn     = "arn:aws:iam::409909364364:role/Network-terraform"
    session_name = "TerraformSession"
  }
}


resource "aws_vpc" "AWS-terraform" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true

  tags = {
    Name = "AWS-terraform"
  }
}

resource "aws_subnet" "Terra-AWS" {
  vpc_id            = aws_vpc.AWS-terraform.id
  cidr_block        = var.subnet_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "example-subnet"
  }
}

resource "aws_subnet" "Terra-AWS2" {
  vpc_id            = aws_vpc.AWS-terraform.id
  cidr_block        = var.subnet_cidr2
  availability_zone = "us-east-1b"

  tags = {
    Name = "example2-subnet"
  }
}

resource "aws_instance" "VM1" {
  ami           = var.instance_ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Terra-AWS.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]  

  tags = {
    Name = "ExampleInstanceOne"
  }
}

resource "aws_instance" "VM2" {
  ami           = var.instance_ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Terra-AWS.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]  

  tags = {
    Name = "ExampleInstanceTwo"
  }
}

resource "aws_internet_gateway" "IG" {
  vpc_id = aws_vpc.AWS-terraform.id
}

resource "aws_lb" "terraform-lb" {
  name               = "terraform-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.Terra-AWS.id, aws_subnet.Terra-AWS2.id] 
  security_groups    = [aws_security_group.example_lb_sg.id]  

  tags = {
    Name = "ExampleLoadBalancer"
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.AWS-terraform.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.terraform-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

resource "aws_lb_target_group_attachment" "group_one" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.VM1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "group_two" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.VM2.id
  port             = 80
}

resource "aws_security_group" "instance_sg" {
  vpc_id = aws_vpc.AWS-terraform.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.x.xx/32"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "instance_sg"
  }
}

resource "aws_security_group" "example_lb_sg" {
  vpc_id = aws_vpc.AWS-terraform.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example_lb_sg"
  }
}

