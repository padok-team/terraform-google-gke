# Here you can reference 2 type of terraform objects :
# 1. Ressources from you provider of choice
# 2. Modules from official repositories which include modules from the following github organizations
#     - AWS: https://github.com/terraform-aws-modules
#     - GCP: https://github.com/terraform-google-modules
#     - Azure: https://github.com/Azure

data "google_project" "this" {}

resource "google_container_cluster" "this" {
  provider = google-beta

  name           = var.name
  location       = var.location
  project        = data.google_project.this.project_id
  node_locations = var.node_locations

  min_master_version = var.min_master_version
  release_channel {
    channel = "STABLE"
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  enable_shielded_nodes = true
  node_config {
    service_account = var.node_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # This enables workload identity. For more information:
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
  workload_identity_config {
    identity_namespace = "${data.google_project.this.project_id}.svc.id.goog"
  }

  network         = var.network.id
  subnetwork      = var.subnetwork.id
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cidr_pods
    services_ipv4_cidr_block = var.cidr_services
  }

  network_policy {
    # Enabling NetworkPolicy for clusters with DatapathProvider=ADVANCED_DATAPATH is not allowed (yields error)
    enabled = var.enable_dataplane_v2 ? false : true
    # CALICO provider overrides datapath_provider setting, leaving Dataplane v2 disabled
    provider = var.enable_dataplane_v2 ? "PROVIDER_UNSPECIFIED" : "CALICO"
  }
  # This is where Dataplane V2 is enabled.
  datapath_provider = var.enable_dataplane_v2 ? "ADVANCED_DATAPATH" : "DATAPATH_PROVIDER_UNSPECIFIED"

  # The cluster is private (ie. nodes are not accessible from the Internet).
  # The cluster's API endpoint is public (ie. the cluster can be operated from
  # the Internet).
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.private_endpoint
    master_ipv4_cidr_block  = var.cidr_master
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.ip_whitelist_master_network
      content {
        cidr_block   = cidr_blocks.value.cidr
        display_name = cidr_blocks.value.name
      }
    }
  }

  addons_config {
    http_load_balancing {
      # Waiting for NEGs to be ready makes Argo think some applications are not
      # fully deployed even though they are.
      # We don't use GKE's native HTTP load balancing anyway.
      disabled = true
    }
  }
}

resource "google_container_node_pool" "this" {
  for_each = var.node_pools

  name = each.key

  location       = google_container_cluster.this.location
  cluster        = google_container_cluster.this.name
  node_locations = var.node_locations

  initial_node_count = each.value.min_size

  autoscaling {
    min_node_count = each.value.min_size
    max_node_count = each.value.max_size
  }

  node_config {
    machine_type = each.value.machine_type

    labels = {
      "padok.fr/nodepool" = each.key
    }

    # This enables workload identity. For more information:
    # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    shielded_instance_config {
      enable_secure_boot = true
    }
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = var.node_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_compute_firewall" "allow_webhooks" {
  name        = "k8s-${var.name}-webhooks"
  description = "Managed by Terraform: allow GKE master nodes to connect to admission controllers/webhooks."
  network     = var.network.id
  direction   = "INGRESS"

  allow {
    protocol = "tcp"
    ports = toset(concat([
      "8080", // Sealed Secrets controller
      "8443", // NGINX ingress controller admission webhook
      "8443", // Kyverno webhooks
    ], var.firewall_webhook_ports))
  }
}
