# ---------------------------------------------------------------
# Mesmo laboratorio, traduzido para AWS.
# Compare lado a lado com ../azure: o Terraform e identico,
# muda o "resource". Essa e a tese do video.
# ---------------------------------------------------------------
terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type    = string
  default = "sa-east-1"
}

variable "prefixo" {
  type    = string
  default = "tbx"
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_jhkpereira.pub"
}

variable "meu_ip_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# Na AWS existe VPC padrao; no Azure voce declara a rede na mao.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "lab" {
  key_name   = "${var.prefixo}-lab"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_security_group" "lab" {
  name        = "${var.prefixo}-sg-web"
  description = "Laboratorio TBX - SSH e HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.meu_ip_cidr]
  }

  ingress {
    description = "HTTP"
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
}

resource "aws_instance" "lab" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  key_name               = aws_key_pair.lab.key_name
  vpc_security_group_ids = [aws_security_group.lab.id]
  user_data              = file("${path.module}/../azure/cloud-init.yaml")

  tags = {
    Name      = "${var.prefixo}-vm-web"
    projeto   = "aula-terraform"
    descartar = "sim"
  }
}

output "url" {
  value = "http://${aws_instance.lab.public_ip}"
}
