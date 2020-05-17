
resource "aws_security_group" "simple-cluster-sg" {
  name        = "simple-cluster-sg"
  description = "Cluster/nodes communication"
  vpc_id      = aws_vpc.simple-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-eks"
  }
}

resource "aws_security_group_rule" "simple-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.simple-cluster-sg.id
  source_security_group_id = aws_security_group.simple-node-sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "simple-cluster-sg-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.simple-cluster-sg.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "simple-node-sg" {
  name        = "simple-node-sg"
  description = "Nodes SG"
  vpc_id      = aws_vpc.simple-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                             = "simple-node-sg"
    "kubernetes.io/cluster/simple-eks" = "owned"
  }
}


resource "aws_security_group_rule" "simple-node-sg-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.simple-node-sg.id
  source_security_group_id = aws_security_group.simple-node-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "simple-node-sg-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.simple-node-sg.id
  source_security_group_id = aws_security_group.simple-cluster-sg.id
  to_port                  = 65535
  type                     = "ingress"
}



resource "aws_eks_cluster" "simple-eks" {
  name     = "simple-eks"
  role_arn = aws_iam_role.simple-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.simple-cluster-sg.id]
    subnet_ids         = [aws_subnet.simple-subnet-private-1.id, aws_subnet.simple-subnet-private-2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.simple-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.simple-cluster-AmazonEKSServicePolicy,
  ]
}


data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.simple-eks.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

locals {
  simple-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.simple-eks.endpoint}' --b64-cluster-ca '${aws_eks_cluster.simple-eks.certificate_authority[0].data}' 'simple-eks'
USERDATA

}

resource "aws_launch_configuration" "simple-lc" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.simple-node.name
  image_id                    = data.aws_ami.eks-worker.id
  instance_type               = "t2.small"
  name_prefix                 = "simple-eks"
  security_groups             = [aws_security_group.simple-node-sg.id]
  user_data_base64            = base64encode(local.simple-node-userdata)

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "simple-asg" {
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.simple-lc.id
  max_size             = 2
  min_size             = 1
  name                 = "simple-asg"
  vpc_zone_identifier  = [aws_subnet.simple-subnet-private-1.id, aws_subnet.simple-subnet-private-2.id]

  tag {
    key                 = "Name"
    value               = "simple-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/simple-eks"
    value               = "owned"
    propagate_at_launch = true
  }
}