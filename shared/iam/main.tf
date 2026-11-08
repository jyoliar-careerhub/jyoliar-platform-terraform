# IAM Policy for reading /jyo-liar/k8s path in Parameter Store
resource "aws_iam_policy" "k8s_parameter_store_read" {
  name        = "k8s-parameter-store-read-policy"
  description = "Policy to read parameters under /jyo-liar/k8s path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/jyo-liar/k8s/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters"
        ]
        Resource = "*"
      }
    ]
  })
}
