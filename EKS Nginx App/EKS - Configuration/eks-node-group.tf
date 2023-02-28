resource "aws_iam_role" "iam-node-role" {

  //name of the role 
  name = "role-iam-node"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  //the policy that grants an entity permisson to assume the role 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-attach" {
  //the ARN of the policy we want to apply
  //This policy allows Amazon EKS worker nodes to connect to Amazon EKS Clusters.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  //attach this policy to the role previously created
  role = aws_iam_role.iam-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-ec2-container" {
  //the ARN of the policy we want to apply
  //Provides read-only access to Amazon EC2 Container Registry repositories. this will also allow us to pull images from our private ECR repo
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  //attach this policy to the role previously created
  role = aws_iam_role.iam-node-role.name
}

resource "aws_iam_role_policy_attachment" "eks-cni-plugin" {
  //the ARN of the policy we want to apply
  //Provides capabilities to modify IP address configuration on your EKS cluster.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  //attach this policy to the role previously created
  role = aws_iam_role.iam-node-role.name
}

resource "aws_eks_node_group" "node-grp" {
  //name of our cluster we created in EKS.tf  
  cluster_name = aws_eks_cluster.eks.name
  //set up a node group name
  node_group_name = "example"
  //IAM role of the permissions that grant 
  node_role_arn = aws_iam_role.iam-node-role.arn
  //identifiers of EC2 subnets to associate with the EKS node group
  //these subnets must have the specified resource tag "kubernetes.io/cluster/eks"  
  subnet_ids = [aws_subnet.private_subnet1.id, aws_subnet.private_subnet2.id]

  scaling_config {
    //Desired number of worker nodes
    desired_size = 1
    //Maximum number of worker nodes
    max_size = 2
    //Minimum number of worker nodes
    min_size = 1
  }
  //type of Amazon Machine Image (AMI) associated with the EKS node group
  //valid values: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64
  ami_type = "AL2_x86_64"


  //instance type of nodes
  //instance type will default to t3.medium. this size has the capabilities to host the nodes 


  //type of capacity associated with the EKS node group 
  //valid values: SPOT, ON_DEMAND
  capacity_type = "ON_DEMAND"


  //disk size of worker node in GiB
  disk_size = 20

  //policies need to be depended on for node group starts 
  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-attach,
    aws_iam_role_policy_attachment.eks-ec2-container,
    aws_iam_role_policy_attachment.eks-cni-plugin
  ]
}