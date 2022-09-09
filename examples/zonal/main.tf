module "kubernetes" {
  source = "../.."

  name       = "zonal"
  project_id = "library-344516"

  location = "europe-west1-b"

  registry_project_ids = ["padok-playground"] // Used to grant access to the created sa

  network = {
    private             = false
    subnet_self_link    = "https://www.googleapis.com/compute/v1/projects/library-344516/regions/europe-west1/subnetworks/eu"
    pods_range_name     = "gke-pods-main"
    services_range_name = "gke-services-main"
    master_cidr         = "192.168.128.0/28"
    master_allowed_ips  = [{ name = "Internet", cidr = "0.0.0.0/0" }] // The ips to whitelist to access master
    webhook_ports       = []                                          // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks
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
