terraform {
  required_version = "~> 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.21"
    }
    random = {
      source  = "random"
      version = ">= 3.0"
    }
  }
}
