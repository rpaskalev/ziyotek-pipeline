module "instance_profile" {
    source = "../../modules/iam"
    environment = var.environment
}