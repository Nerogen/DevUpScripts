provider "aws" {
  access_key = "" # delete for git
  secret_key = ""
  region     = "us-east-1"
}


module "infra" {
  source = "../modules"
}

# setup
# mkdir modules
# touch modules/main.tf modules/variables.tf modules/outputs.tf
# mkdir project
# touch project/main.tf
# work with nano
# sudo nano modules/main.tf
