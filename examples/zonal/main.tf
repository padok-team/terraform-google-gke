module "kubernetes" {
  source = "../.."

  name       = "zonal"
  project_id = "padok-playground"

  location = "europe-north1-b"

  registry_project_ids = ["padok-playground"] // Used to grant access to the created sa

  network = {
    private             = false
    subnet_self_link    = "https://www.googleapis.com/compute/v1/projects/padok-playground/regions/europe-north1/subnetworks/test-refacto-kubernetes"
    pods_range_name     = "gke-pods-test"
    services_range_name = "gke-service-test"
    master_cidr         = "192.168.128.0/28"
    master_allowed_ips  = [{ name = "Internet", cidr = "0.0.0.0/0" }] // The ips to whitelist to access master
    webhook_ports       = []                                          // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks
  }

  node_pools = {
    main = {
      name         = "classy-node-pool"
      locations    = ["europe-north1-b"]
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
