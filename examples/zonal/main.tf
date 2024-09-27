# Create network and its subnets
module "vpc" {
  #checkov:skip=CKV2_GCP_18: firewalls will be managed elsewhere
  source  = "terraform-google-modules/network/google"
  version = "9.2.0"

  project_id = "library-344516"

  network_name = "gke-zonaltest"
  routing_mode = "GLOBAL"
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "172.17.24.0/21"
      subnet_region = "europe-west3"
    },
  ]
  secondary_ranges = {
    subnet-01 = [
      {
        range_name    = "gke-pods-main"
        ip_cidr_range = "10.4.0.0/14"
      },
      {
        range_name    = "gke-services-main"
        ip_cidr_range = "192.168.2.0/23"
      },
    ]
  }
  auto_create_subnetworks = false
  mtu                     = 0
}

module "kubernetes" {
  source = "../.."

  name       = "zonaltest"
  project_id = "library-344516"

  location = "europe-west3-a"

  registry_project_ids = ["library-344516"] // Used to grant access to the created sa

  network = {
    private             = false
    subnet_self_link    = module.vpc.subnets_self_links[0]
    pods_range_name     = "gke-pods-main"
    services_range_name = "gke-services-main"
    master_cidr         = "192.168.128.0/28"
    master_allowed_ips  = [{ name = "Internet", cidr = "0.0.0.0/0" }] // The ips to whitelist to access master
    webhook_ports       = []                                          // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks
  }

  node_pools = {
    main = {
      name         = "classy-node-pool"
      locations    = ["europe-west3-a"]
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
