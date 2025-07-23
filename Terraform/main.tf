provider "aws" {
  region = "us-east-1"
}

locals {
  server_names = [
    "master",
    "node1",
    "node2",
    "node3",
    "bank_database",
    "casino_database"
  ]

  ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpzRDauEQGRtqQQVpNq4F+jSKyxlIkvJmuDJkVURqWMJMWpb4zDx4VhXQCZiflVSWB8FgbwP0uGW/nJ7an9iz5PAlK3edvsjuzlPW2LEFYMiPr7e9nmZvdDzy3YJbQvrcCTRQKLavPDeoRnNkxhadlGuHljy8ylBA7914Hf0kAps4xdp0iCpXDOBL/5dO6e+GA7wywE4RqZ/i8i0cxO/53rwePhP1xO6vQwmzxl7wCcQHqA+jq9Pmhu8pf2JMn3JMxYqeVsJipZeeKltP3YG3owbSHYG/CxvMxuohMCkxwta0abF/khbu4tISrX4PLVBNI0yRjf/L1zqEMUUwUfLkgb6ekbL8iXFw8DXrSomADEA4vI5Ke0ZydGQVfqG6skw+9XGP8FJhC0YMzkBKE8L5nlf31qPxbezFRWfo/fXr1WS6xJP9TibmRz9XCxb004i2fZlwpyzJYZQw8oJIGoDY44Dk3AtXs941J4F6YmlDmISU+QC53oTII90rhweRDkw0= robert@Brutforce"

  pairs = flatten([
    for source in local.server_names : [
      for target in local.server_names : {
        source = source
        target = target
      } if source != target
    ]
  ])
}


resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_subnet" "public" {
  count                   = 6
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 4, count.index)
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index % 3]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 6
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sgs" {
  for_each = toset(local.server_names)

  name        = each.value
  description = "SG for ${each.value}"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = each.value
  }
}

resource "aws_instance" "servers" {
  count         = length(local.server_names)
  ami           = "ami-020cba7c55df1f615"  # Ubuntu 22.04 LTS - us-east-1
  instance_type = "t3.micro"

  subnet_id = aws_subnet.public[count.index].id

  vpc_security_group_ids = [
    aws_security_group.sgs[local.server_names[count.index]].id
  ]

  associate_public_ip_address = true

  tags = {
    Name = local.server_names[count.index]
  }

  user_data = <<-EOF
              #!/bin/bash
              mkdir -p /home/ubuntu/.ssh
              echo "${local.ssh_public_key}" > /home/ubuntu/.ssh/authorized_keys
              chown -R ubuntu:ubuntu /home/ubuntu/.ssh
              chmod 700 /home/ubuntu/.ssh
              chmod 600 /home/ubuntu/.ssh/authorized_keys
              EOF
}
resource "aws_security_group_rule" "all_to_all_except_self" {
  for_each = {
    for pair in local.pairs :
    "${pair.source}_to_${pair.target}" => pair
  }

  type                     = "ingress"
  from_port               = 0
  to_port                 = 0
  protocol                = "-1"
  security_group_id       = aws_security_group.sgs[each.value.target].id
  source_security_group_id = aws_security_group.sgs[each.value.source].id
}