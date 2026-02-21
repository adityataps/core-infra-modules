terraform {
  required_version = ">= 1.6.0"

  required_providers {
    # TODO: mirror provider pins from the module's versions.tf
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = "~> X.Y"
    # }
  }
}
