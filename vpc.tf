####################################
# VPC and Networking Configuration #
####################################

# VPC 모듈: 퍼블릭 및 프라이빗 서브넷을 포함하는 VPC를 생성
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~>5.7"

  name = "${var.ClusterBaseName}-VPC"
  cidr = var.VpcBlock
  azs  = var.availability_zones

  enable_dns_support   = true
  enable_dns_hostnames = true

  public_subnets  = var.public_subnet_blocks
  private_subnets = var.private_subnet_blocks

  enable_nat_gateway = false

  manage_default_network_acl = false

  map_public_ip_on_launch = true

  igw_tags = {
    "Name" = "${var.ClusterBaseName}-IGW"
  }

  public_subnet_tags = {
    "Name"                     = "${var.ClusterBaseName}-PublicSubnet"
    "kubernetes.io/role/elb"   = "1"
  }

  private_subnet_tags = {
    "Name"                             = "${var.ClusterBaseName}-PrivateSubnet"
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    "Environment" = "home-protector"
  }
}

################################
# Routing Table Configuration #
################################
resource "aws_route_table" "bastion_to_db" {
  vpc_id = module.vpc.vpc_id
  tags = {Name = "rt-for-public-ec2"}
}

################################
# Security Group Configuration #
################################

# 보안 그룹: Bastion Host를 위한 보안 그룹을 생성
resource "aws_security_group" "eks_sec_group" {
  vpc_id = module.vpc.vpc_id

  name        = "${var.ClusterBaseName}-eks-sec-group"
  description = "Security group for ${var.ClusterBaseName} Host"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [var.SgIngressSshCidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ClusterBaseName}-HOST-SG"
  }
}

resource "aws_security_group" "rds_sec_group" {
  vpc_id = module.vpc.vpc_id

  name = "${var.ClusterBaseName}-rds-sec-group"
  description = "Security group for ${var.ClusterBaseName} RDS"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ClusterBaseName}-RDS-SG"
  }
}

resource "aws_security_group" "elasticache_sec_group" {
  vpc_id = module.vpc.vpc_id

  name = "${var.ClusterBaseName}-elasticache-sec-group"
  description = "Security group for ${var.ClusterBaseName} ElastiCache"

  ingress {
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // 읽기 전용 6380 port
  ingress {
    from_port = 6380
    to_port = 6380
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ClusterBaseName}-Elasticache-SG"
  }
}

