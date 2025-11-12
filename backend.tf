terraform {
  backend "s3" {
    bucket       = "ido-terraform-state-cp"
    key          = "devops-infra/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true

    profile = "codeidog"
  }
}
