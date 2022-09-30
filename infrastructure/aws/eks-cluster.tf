resource "aws_eks_cluster" "graph-indexer" {
  name     = "graph-indexer"
  role_arn = aws_iam_role.graph-indexer-eks.arn
  version  = var.eks_version

  vpc_config {
    security_group_ids = [aws_security_group.graph-indexer.id]
    subnet_ids         = aws_subnet.graph-indexer-eks-subnets[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.graph-indexer-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.graph-indexer-AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "graph-indexer-node-group" {
  cluster_name    = aws_eks_cluster.graph-indexer.name
  node_group_name = "graph-indexer-node-group"
  node_role_arn   = aws_iam_role.graph-indexer-node.arn
  subnet_ids      = aws_subnet.graph-indexer-eks-subnets[*].id
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.eks_node_group_scaling_desired
    max_size     = var.eks_node_group_scaling_max
    min_size     = var.eks_node_group_scaling_min
  }

  tags = {
    Name = "graph-indexer-cluster-worker-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.graph-indexer-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.graph-indexer-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.graph-indexer-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "helm_release" "nginx-ingress" {

  repository = var.nginx_ingress_helm_repo_url
  chart      = var.nginx_ingress_helm_chart_name
  version    = var.nginx_ingress_helm_chart_version

  create_namespace = var.k8s_create_namespace
  namespace        = var.k8s_namespace
  name             = var.nginx_ingress_helm_release_name

  set {
    name = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/aws-load-balancer-type\""
    value = "nlb"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  depends_on = [
    aws_eks_cluster.graph-indexer, 
    aws_eks_node_group.graph-indexer-node-group,
    aws_internet_gateway.graph-indexer-igw
  ]
}
