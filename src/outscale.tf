terraform {
  required_providers {
    outscale = {
      source  = "outscale/outscale"
      version = ">= 1.1.3"
    }
  }
}

provider "outscale" {
  # access_key_id = var.access_key_id
  # secret_key_id = var.secret_key_id
  config_file = pathexpand("~/.osc/config.json")
  region      = var.region
  profile     = var.profile
}