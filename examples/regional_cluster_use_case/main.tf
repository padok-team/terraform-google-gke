# Short description of the use case in comments

provider "google" {
  project = "padok-cloud-factory"
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

  name    = "my-super-duper-cluster-network"
  subnets = {}
}

module "regional_cluster_use_case" {
  source = "../.."

  name     = "my-regional-cluster"
  location = "europe-west1"

  node_service_account = {
    email = module.custom_service_account.service_account_email["gke-sa"]
  }
  cidr_master = "10.168.0.0/28"
  network = {
    id = "projects/padok-cloud-factory/global/networks/${module.custom_network.network.name}"
  }
}
