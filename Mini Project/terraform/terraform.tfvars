# terraform/terraform.tfvars
aws_region     = "us-east-1"
project_name   = "flask-ecs-app"
environment    = "production"
fargate_cpu    = "256"
fargate_memory = "512"
app_count      = 2