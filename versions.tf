terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.90, < 4.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 3.90, < 4.0.0"
    }
  }
}
