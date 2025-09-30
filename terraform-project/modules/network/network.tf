/*==== Criando a VPC ======*/
resource "aws_vpc" "vpc" {
  cidr_block                = "10.0.0.0/24"
  enable_dns_hostnames      = true
  enable_dns_support        = true
  tags = {
    Name                    = "vpc-optimiza"
  }
}

/*==== internet gateway igw ====*/
resource "aws_internet_gateway" "igw" {
  vpc_id                    = aws_vpc.vpc.id
  tags = {
    Name                    = "igw-optimiza"
  }
}

/*==== NAT gateway nat ====*/
#ip elastico NAT
resource "aws_eip" "nat-gateway-eip" {
  vpc                       = true
  depends_on                = [aws_internet_gateway.igw]
  tags = {
    Name                    = "nat-ip-elastico-optimiza"
  }
}

#NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id             = aws_eip.nat-gateway-eip.id
  subnet_id                 = aws_subnet.public_subnet[0].id
  depends_on                = [aws_internet_gateway.igw]
  tags = {
    Name                    = "nat-optimiza"
  }
}

/*==== sub-redes públicas ====*/
resource "aws_subnet" "public_subnet" {
    count                   = length(var.public_subnet_cidrs)
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnet_cidrs[count.index]
    map_public_ip_on_launch = true
    availability_zone       = var.a_zones[count.index]
    tags = {
      Name                  = "sub-rede-publica-optimiza-${count.index + 1}"
    }  
}

/*==== sub-redes privadas ======*/
resource "aws_subnet" "private_subnet" {
    count                   = length(var.private_subnet_cidrs)
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.private_subnet_cidrs[count.index]
    availability_zone       = var.a_zones[count.index]
    tags = {
      Name                  = "sub-rede-privada-optimiza-${count.index + 1}"
    }  
}

/*==== tabela de rota pública ====*/
resource "aws_route_table" "public_rt" {
    vpc_id                  = aws_vpc.vpc.id
    route {
      cidr_block            = "0.0.0.0/0"
      gateway_id            = aws_internet_gateway.igw.id
    }
    tags = {
      Name                  = "rt-public-optimiza"
 }
}
resource "aws_route_table_association" "public" {
    count                   = length(aws_subnet.public_subnet)
    route_table_id          = aws_route_table.public_rt.id
    subnet_id               = aws_subnet.public_subnet[count.index].id
}

/*==== tabela de rota privada ====*/
resource "aws_route_table" "private_rt" {
    vpc_id                  = aws_vpc.vpc.id
    route {
      cidr_block            = "0.0.0.0/0"
      nat_gateway_id        = aws_nat_gateway.nat.id
    }
    tags = {
        Name                = "rt-private-optimiza"
    }
}
resource "aws_route_table_association" "private" {
    count                   = length(aws_subnet.private_subnet)
    route_table_id          = aws_route_table.private_rt.id
    subnet_id               = aws_subnet.private_subnet[count.index].id
}

/*==== criando ACL ====*/ 
resource "aws_network_acl" "acl_publica" {
  vpc_id                    = aws_vpc.vpc.id
  subnet_ids                = aws_subnet.public_subnet[*].id
  ingress { # permitindo SSH
    protocol                = "tcp"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 22
    to_port                 = 22
  }
  ingress { # permitindo http
    protocol                = "tcp"
    rule_no                 = 200
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 80
    to_port                 = 80
  }
  ingress { # permitindo https
    protocol                = "tcp"
    rule_no                 = 300
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 443
    to_port                 = 443
  }
  ingress { # permitindo retorno de entrada internet
    protocol                = "tcp"
    rule_no                 = 400
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 32000
    to_port                 = 65535
  }
  egress { # Permite saída para todo tráfego
    protocol                = "-1"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 0
    to_port                 = 0
  }
  ingress {
  protocol    = "tcp"
  rule_no     = 500
  action      = "allow"
  cidr_block  = "0.0.0.0/0"
  from_port   = 8000
  to_port     = 8000
}

  tags = {
    Name                    = "acl_publica_optimiza"
  }
}

resource "aws_network_acl" "acl_privada" {
  vpc_id                    = aws_vpc.vpc.id
  subnet_ids                = [ aws_subnet.private_subnet.id ]
  ingress {
    protocol                = "tcp"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "10.0.0.0/25"
    from_port               = 22
    to_port                 = 22
  }
  ingress {
    protocol                = "tcp"
    rule_no                 = 200
    action                  = "allow"
    cidr_block              = "10.0.0.0/25"
    from_port               = 80
    to_port                 = 80
  }  
  ingress {
    protocol                = "tcp"
    rule_no                 = 300
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 32000
    to_port                 = 65535
  }
  egress {
    protocol                = "-1"
    rule_no                 = 100
    action                  = "allow"
    cidr_block              = "0.0.0.0/0"
    from_port               = 0
    to_port                 = 0
  }
  ingress {
  protocol    = "tcp"
  rule_no     = 250
  action      = "allow"
  cidr_block  = "10.0.0.0/24" # ou o bloco da subnet pública
  from_port   = 3306
  to_port     = 3306
}
egress {
  protocol    = "tcp"
  rule_no     = 250
  action      = "allow"
  cidr_block  = "10.0.0.0/24"
  from_port   = 3306
  to_port     = 3306
}
  tags = {
    Name                    = "acl_privada"
  }
}

/*==== Criando Security Group ====*/
resource "aws_security_group" "sg" {
  name                      = "basic_security"
  description               = "Allow SSH/HTTP/HTTPS access"
  vpc_id                    = aws_vpc.vpc.id
  ingress {
    from_port               = "22"
    to_port                 = "22"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = "80"
    to_port                 = "80"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
    from_port               = "443"
    to_port                 = "443"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  egress {
    from_port               = 0
    to_port                 = 0
    protocol                = "-1"
    cidr_blocks             = ["0.0.0.0/0"]
  }
  ingress {
  from_port   = 8000
  to_port     = 8000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
}

/*==== Criando Security Group Para EC2 Privada====*/
resource "aws_security_group" "mysql_sg" {
  name        = "mysql_security_group"
  description = "Allow MySQL from Private EC2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    # Liberando para o SG da EC2 pública:
    security_groups = [aws_security_group.sg.id]
  }

  ingress {
    from_port               = "22"
    to_port                 = "22"
    protocol                = "tcp"
    cidr_blocks             = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

/*==== Outputs para exportar ====*/
output "subnet_public_ids" {
    value = aws_subnet.public_subnet[*].id
}
output "subnet_private_ids" {
    value = aws_subnet.private_subnet[*].id
}
output "subnet_public_id" {
    value = aws_subnet.public_subnet[0].id
}
output "subnet_private_id" {
    value = aws_subnet.private_subnet[0].id
}
output "nat_id" {
    value = aws_nat_gateway.nat.id
}
output "vpc_id" {
    value = aws_vpc.vpc.id
}
output "igw_id" {
    value = aws_internet_gateway.igw.id
}
output "sg_id" {
  value = aws_security_group.sg.id
}

output "mysql_sg_id" {
  value = aws_security_group.mysql_sg.id
}