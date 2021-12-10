# Short description of the use case in comments

provider "google" {
  project = "padok-playground"
  region  = "europe-west1"
}

module "custom_service_account" {
  source = "git@github.com:padok-team/terraform-google-serviceaccount.git"

  list_serviceaccount = {
    gke-zonal-test-sa = {
      predifined_roles = ["roles/compute.admin", "roles/container.admin"]
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
  source = "git@github.com:padok-team/terraform-google-network.git"

  name = "my-zonal-super-duper-cluster-network"
  subnets = {
    "zonal-kubernetes-nodes" = {
      cidr   = "10.21.0.0/16"
      region = "europe-west1"
    }
  }
}

module "zonal_cluster_use_case" {
  source = "../.."

  name     = "my-zonal-cluster"
  location = "europe-west1-b"

  node_service_account = {
    email = module.custom_service_account.service_account_email["gke-zonal-test-sa"]
  }
  ip_whitelist_master_network = [
    { "name" = "pierrea", "cidr" = "31.32.227.74/32" },
    { "name" = "kims", "cidr" = "82.216.204.48/32" }
  ]

  cidr_master = "10.168.1.0/28"
  network     = module.custom_network.network
  subnetwork  = module.custom_network.network.subnets["zonal-kubernetes-nodes"] # Reference the subnet created above

  node_pools = {
    "first-zonal-node-pool" = {
      min_size     = 1
      max_size     = 2
      machine_type = "e2-micro"
      preemptible  = true
    },
    "second-zonal-node-pool" = {
      min_size     = 1
      max_size     = 3
      machine_type = "e2-micro"
      preemptible  = false
    }
  }
}

output "service_account_output" {
  value = module.custom_service_account.service_account_email["gke-zonal-test-sa"]
}

output "kubernetes_cluster" {
  value     = module.zonal_cluster_use_case.kubernetes_cluster
  sensitive = true
}
