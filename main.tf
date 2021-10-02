provider "aws" {
    region = "us-east-1"
}

# Resources

resource "aws_instance" "ec2" {
    ami                     = var.ami 
    instance_type           = var.instance_type
    user_data               = file("ec2_bootstrap")
    monitoring              = true
    key_name                = aws_key_pair.main.key_name
    security_groups         =  [aws_security_group.main.id]
    subnet_id               = aws_subnet.main.id
    disable_api_termination = true

    tags = {
        Name                = "${var.namespace}_ec2"
    }
}

# Networking

resource "aws_route_table_association" "main" {
  subnet_id                 = aws_subnet.main.id
  route_table_id            = aws_route_table.main.id
}
resource "aws_internet_gateway" "main" {
    vpc_id                  = aws_vpc.main.id
    tags    = {
        Name                = "${var.namespace}_gateway"
    }
}

resource "aws_route_table" "main" {
    vpc_id                  = aws_vpc.main.id

    route {
        cidr_block          = "0.0.0.0/0"
        gateway_id          = aws_internet_gateway.main.id
    }
    tags = {
        Name                = "${var.namespace}_routetable"
    }
}

resource "aws_eip" "main" {
    instance                = aws_instance.ec2.id
    vpc                     = true
}

resource "aws_key_pair" "main" {
    key_name                = "id_rsa"
    public_key              = file(var.keypath)
}

resource "aws_subnet" "main" {
    cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 3, 1)
    vpc_id                  = aws_vpc.main.id
    availability_zone       = "us-east-1a"
}

resource "aws_security_group" "main" {
    name                    = "${var.namespace}_sg"
    vpc_id                  = aws_vpc.main.id
    
    ingress {
            from_port       = 22
            to_port         = 22
            protocol        = "tcp"
            cidr_blocks     = ["0.0.0.0/0"]

        }

    egress {
            from_port       = 0
            to_port         = 0
            protocol        = -1
            cidr_blocks     = ["0.0.0.0/0"]
        }
}


resource "aws_vpc" "main" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
        Name                = "${var.namespace}_vpc"
    }
}

# Outputs

output "ec2_ip" {
    value                   = aws_eip.main.public_ip
}

output "ec2_dns" {
    value                   = aws_eip.main.public_dns
}
