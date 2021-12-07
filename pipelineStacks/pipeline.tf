resource "aws_codepipeline" "codepipeline" {
  name     = "tf-test-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.example.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner    = var.githubOwner
        Repo     = var.githubRepo
        Branch      = var.githubBranch
        OAuthToken = var.githubToken
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = "coebuild-project"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = "ziyotek-app"
        DeploymentGroupName = "ziyotek-group"
      }
    }
  }
}


resource "aws_iam_role" "codepipeline_role" {
  name = "pipiline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "codepipeline_policy" {
  name = "codepipeline_policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject",
        "ec2:*",
        "ssm:*",
        "*"
      ],
      "Resource": [
        "${aws_s3_bucket.example.arn}",
        "${aws_s3_bucket.example.arn}/*",
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild",
        "codebuild:*",
        "ssm:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "pipe_attach" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codepipeline_policy.arn
}

resource "aws_s3_bucket" "example" {
  bucket = "rady-bucket-pipeline-artifacts"
  acl    = "private"
      provisioner "local-exec" {
    when    = destroy
    #command = "echo ${self.id} > testfile.txt"
    command = "aws s3 rm s3://rady-bucket-pipeline-artifacts --recursive"
  }
}

variable "githubOwner" {
    default = "rpaskalev"
}

variable "githubRepo" {
    default = "ziyotek-pipeline"
}

variable "githubBranch" {
    default = "main"
}
#go to github -> account settings -> Developer Settings -> 
variable "githubToken" {
    default = "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"
}

