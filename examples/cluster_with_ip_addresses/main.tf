# Short description of the use case in comments

provider "google" {
  project = "padok-cloud-factory"
  region  = "europe-west1"
}

module "custom_service_account" {
  source = "git@github.com:padok-team/terraform-google-serviceaccount.git"

  service_accounts = {
    gke-sa = {
      predifined_roles = []
      permissions = [
        "container.clusters.create",
        "container.clusters.delete",
        "container.clusters.get",
        "container.clusters.list",
        "container.clusters.update",
        "resourcemanager.projects.get",
      ]
      description = "Service account for my GKE nodes."
    }
  }
}

module "custom_network" {
  source  = "git@github.com:padok-team/terraform-google-network.git"
  project = "padok-cloud-factory"
  name    = "my-super-duper-cluster-network"
  subnets = {
    "kubernetes-nodes" = {
      cidr   = "10.21.0.0/16"
      region = "europe-west1"
    }
  }
}

module "ip_address_use_case" {
  source = "../.."

  name     = "cluster-with-ip-address"
  location = "europe-west1"

  node_service_account = {
    email = module.custom_service_account.service_account_emails["gke-sa"]
  }

  cidr_master = "10.168.0.0/28"
  network     = module.custom_network.compute_network
  subnetwork  = module.custom_network.compute_network.subnets["kubernetes-nodes"] # Reference the subnet created above

  node_pools = {
    "classy-node-pool" = {
      min_size     = 1
      max_size     = 2
      machine_type = "e2-micro"
      preemptible  = true
    }
  }

  ip_addresses = {
    "ip-address-1" = {
      external = true
      global   = false
    }
    "ip-address-2" = {
      external = false
      global   = true
    }
  }
}

output "service_account_email" {
  value = module.custom_service_account.service_account_emails["gke-sa"]
}

output "this" {
  value     = module.ip_address_use_case.this
  sensitive = true
}

output "ip_addresses" {
  value = module.ip_address_use_case.compute_addresses
}

output "gloabl_ip_addresses" {
  value = module.ip_address_use_case.compute_global_addresses
}
