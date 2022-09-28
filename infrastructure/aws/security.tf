# Security group for communicating within the EKS cluster
resource "aws_security_group" "graph-indexer" {
  name        = "graph-indexer-eks"
  description = "Communication within the EKS cluster"
  vpc_id      = aws_vpc.graph-indexer-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "graph-indexer-eks"
  }
}

# Allow EKS to communicate with the RDS database
resource "aws_security_group_rule" "thegraph-cluster-ingress-vpc-PSQL" {
  description       = "Allow EKS VPC Network to communicate with the PSQL server"
  security_group_id = aws_security_group.graph-indexer.id
  cidr_blocks       = ["10.0.0.0/16"]
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  type              = "ingress"
}


# External IPs allowed to connect to the EKS cluster
resource "aws_security_group_rule" "graph-indexer-ingress-managementIPs-https" {
  description       = "Allow management IPs to communicate with the cluster API Server"
  security_group_id = aws_security_group.graph-indexer.id
  cidr_blocks       = var.eks_management_ips
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  type              = "ingress"
}

# External IPs allowed to connect to the RDS database
resource "aws_security_group_rule" "graph-indexer-ingress-managementIPs-PSQL" {
  description       = "Allow management IPs to communicate with the PSQL server"
  security_group_id = aws_security_group.graph-indexer.id
  cidr_blocks       = var.eks_management_ips
  protocol          = "tcp"
  from_port         = 5432
  to_port           = 5432
  type              = "ingress"
}


