provider "google" {
  region = "europe-west1"
}

provider "google-beta" {
  region = "europe-west1"
}

module "kubernetes" {
  source = "../.."

  name       = "regional"
  project_id = "padok-lab"

  location = "europe-west1"

  registry_project_ids = ["padok-lab"] // Used to grant access to the created sa

  network = {
    private             = true
    subnet_self_link    = "https://www.googleapis.com/compute/v1/projects/padok-lab/regions/europe-west1/subnetworks/subnet-staging-1"
    pods_range_name     = "gke-pods-test"
    services_range_name = "gke-service-test"
    master_cidr         = "192.168.128.0/28"
    master_allowed_ips  = [] // The ips to whitelist to access master
    webhook_ports       = [] // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks
  }

  node_pools = {
    main = {
      name         = "classy-node-pool"
      locations    = ["europe-west1-b"]
      min_size     = 1
      max_size     = 2
      machine_type = "e2-micro"
      preemptible  = true
      taints       = []
      labels       = {}
    }
  }
}

output "command" {
  value = module.kubernetes.command_to_connect
}
