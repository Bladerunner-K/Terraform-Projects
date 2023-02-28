resource "aws_iam_role" "role-iam" {
  name = "role-iam"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.


  //the policy that grants an entity permisson to assume the role
  //used to access aws resources that you might not normally have access to
  //The role that amazon EKS will use to create aws resources for kubernetes clusters 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-role-att" {
  //the ARN of the policy we want to apply
  //This policy provides Kubernetes the permissions it requires to manage resources on your behalf. 
  //Kubernetes requires Ec2:CreateTags permissions to place identifying information on 
  //EC2 resources including but not limited to Instances, Security Groups, and Elastic Network Interfaces.
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  //attach this policy to the role previously created
  role = aws_iam_role.role-iam.name
}



resource "aws_eks_cluster" "eks" {
  //name of the cluster
  name = "eks"
  //the ARN of the role that will allow for kubernetes control plane to make calls to AWS API operations on your behalf
  role_arn = aws_iam_role.role-iam.arn


  vpc_config {
    //indicates whether or not the Amazon EKS private API endpoint is enabled
    endpoint_private_access = false
    //indicates whether or not the Amazon EKS public API endpoint is enabled, this will mean we can access this from our machine
    endpoint_public_access = true

    //specify the subnets in thier respective availablility zones that we will use for the cluster
    subnet_ids = [
      aws_subnet.public_subnet1.id,
      aws_subnet.public_subnet2.id,
      aws_subnet.private_subnet1.id,
      aws_subnet.private_subnet2.id
    ]
  }

  //ensure the IAM role permissions are created before and deleted after the eks cluster 

  depends_on = [
    aws_iam_role_policy_attachment.eks-role-att
  ]
}

