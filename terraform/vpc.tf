# ============================================================
# Terraform — VPC & Networking
# ============================================================
# Architecture:
#
#   Internet
#       |
#   [ Internet Gateway ]
#       |
#   ┌───────────── VPC (10.0.0.0/16) ─────────────┐
#   │                                               │
#   │  ┌── AZ-a ──────────┐  ┌── AZ-b ──────────┐ │
#   │  │ Public: 10.0.1.0  │  │ Public: 10.0.2.0  │ │
#   │  │  - NAT Gateway    │  │                    │ │
#   │  │  - NLB / Service  │  │  - NLB / Service   │ │
#   │  │    LoadBalancer   │  │    LoadBalancer    │ │
#   │  ├───────────────────┤  ├───────────────────┤ │
#   │  │ Private: 10.0.11.0│  │ Private: 10.0.12.0│ │
#   │  │  - EKS Nodes      │  │  - EKS Nodes      │ │
#   │  │  - Pods           │  │  - Pods            │ │
#   │  └───────────────────┘  └───────────────────┘ │
#   └───────────────────────────────────────────────┘
#
# NOTE: Using 2 AZs for cost optimization.
# For production HA, add a third AZ (just duplicate the subnet blocks).
# ============================================================

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Internet Gateway ---
# Required for public subnets to reach the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- Public Subnets (2 AZs) ---
# NAT Gateway and Service LoadBalancer resources live here
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                           = "${var.project_name}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                        = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

# --- Private Subnets (2 AZs) ---
# EKS nodes run here — no direct internet access, more secure
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 11}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                           = "${var.project_name}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

# --- NAT Gateway ---
# Allows private subnet resources to access the internet (for pulling images, etc.)
# without being directly accessible from the internet.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# --- Route Tables ---

# Public route table: route internet traffic through IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table: route internet traffic through NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = 2

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
