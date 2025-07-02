################################
# RDS Configuration #
################################

# Primary RDS Instance in private subnet 192.168.11.0/24
resource "aws_db_instance" "primary_rds" {
  allocated_storage    = 8
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "root"
  password             = "a1b2c3d4!"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
  multi_az             = false

  db_name = "protectorDB"
  backup_retention_period = 7
  deletion_protection     = false

  vpc_security_group_ids = [aws_security_group.rds_sec_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "${var.ClusterBaseName}-Primary-RDS"
  }
}

# RDS Read Replica in private subnet 192.168.11.0/24
resource "aws_db_instance" "read_replica" {
  replicate_source_db   = aws_db_instance.primary_rds.arn
  instance_class        = "db.t3.micro"
  engine               = "mysql"
  engine_version       = "8.0"
  # username              = "admin"
  # password              = "a1b2c3d4!"
  multi_az              = false
  vpc_security_group_ids = [aws_security_group.rds_sec_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name = "${var.ClusterBaseName}-Read-Replica"
  }
}

# RDS Subnet Group (192.168.11.0/24. 192.168.12.0/24 두 개는 필수)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.ClusterBaseName}-rds-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "${var.ClusterBaseName}-RDS-Subnet-Group"
  }
}

################################
# ElastiCache Configuration #
################################

# # ElastiCache Cluster in private subnet 192.168.12.0/24
# resource "aws_elasticache_cluster" "elasticache" {
#   cluster_id           = "${var.ClusterBaseName}-elasticache"
#   engine               = "valkey"
#   node_type            = "cache.t2.micro"
#   engine_version       =  "7.0"
#   num_cache_nodes      = 1
#   parameter_group_name = "default.redis7"
#   port = 6379
#
#   subnet_group_name    = aws_elasticache_subnet_group.elasticache_subnet_group.name
#   security_group_ids   = [aws_security_group.elasticache_sec_group.id]
#
#   tags = {
#     Name = "${var.ClusterBaseName}-ElastiCache"
#   }
# }

# ElastiCache Cluster in private subnet 192.168.12.0/24
resource "aws_elasticache_serverless_cache" "elasticache" {
  name           = "${var.ClusterBaseName}-elasticache"
  engine               = "valkey"
  major_engine_version =  "8"

  subnet_ids    = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]]
  security_group_ids   = [aws_security_group.elasticache_sec_group.id]

  tags = {
    Name = "${var.ClusterBaseName}-ElastiCache"
  }
}



# ElastiCache Subnet Group (192.168.12.0/24)
resource "aws_elasticache_subnet_group" "elasticache_subnet_group" {
  name       = "${var.ClusterBaseName}-elasticache-subnet-group"
  subnet_ids = [module.vpc.private_subnets[0], module.vpc.private_subnets[1], module.vpc.private_subnets[2]] # 192.168.12.0/24

  tags = {
    Name = "${var.ClusterBaseName}-ElastiCache-Subnet-Group"
  }
}

# output "master_db_endpoint" {
#   value = aws_db_instance.primary_rds.endpoint
# }
#
# output "slave_db_endpoint" {
#   value = aws_db_instance.read_replica.endpoint
# }
#
# output "redis_endpoint" {
#   value = aws_elasticache_serverless_cache.elasticache.endpoint
#   description = "Elasticache Valkey 클러스터 엔드포인트"
# }
