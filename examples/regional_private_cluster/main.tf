# Short description of the use case in comments

provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "europe-west1"
}

module "custom_service_account" {
  source = "git@github.com:padok-team/terraform-google-serviceaccount.git"

  list_serviceaccount = {
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
  source = "git@github.com:padok-team/terraform-google-network.git"
  project = "<YOUR_PROJECT_ID>"
  name = "my-super-duper-cluster-network"
  subnets = {
    "kubernetes-nodes" = {
      cidr   = "10.21.0.0/16"
      region = "europe-west1"
    }
  }
}

module "regional_cluster_use_case" {
  source = "../.."

  name     = "my-regional-cluster"
  location = "europe-west1"

  node_service_account = {
    email = module.custom_service_account.service_account_email["gke-sa"]
  }

  cidr_master = "10.168.0.0/28"
  network     = module.custom_network.network
  subnetwork  = module.custom_network.network.subnets["kubernetes-nodes"] # Reference the subnet created above

  node_pools = {
    "classy-node-pool" = {
      min_size     = 1
      max_size     = 2
      machine_type = "e2-micro"
      preemptible  = true
    }
  }
}

output "service_account_output" {
  value = module.custom_service_account.service_account_email["gke-sa"]
}

output "kubernetes_cluster" {
  value = module.regional_cluster_use_case.kubernetes_cluster

}
