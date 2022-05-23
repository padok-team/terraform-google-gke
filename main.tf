locals {
  network_tag_webhook     = "gke-${var.project_id}-${var.name}"
  master_version          = data.google_container_engine_versions.this.release_channel_default_version[var.release_channel]
  is_region               = length(split("-", var.location)) == 2
  google_compute_apis_url = "https://www.googleapis.com/compute/v1/"
}

data "google_compute_subnetwork" "this" {
  self_link = "${local.google_compute_apis_url}${var.network.subnet_self_link}"
}

data "google_container_engine_versions" "this" {
  project  = var.project_id
  location = var.location
}

resource "google_container_cluster" "this" {
  name     = var.name
  location = var.location
  project  = var.project_id

  release_channel {
    channel = var.release_channel
  }

  min_master_version = local.master_version

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  initial_node_count       = 1

  node_config {
    service_account = google_service_account.node_pool_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # This enables workload identity. For more information:
  # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  network         = trimprefix(data.google_compute_subnetwork.this.network, local.google_compute_apis_url)
  subnetwork      = var.network.subnet_self_link
  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = var.network.pods_range_name
    services_secondary_range_name = var.network.services_range_name
  }

  # The cluster is private (ie. nodes are not accessible from the Internet).
  # The cluster's API endpoint is public (ie. the cluster can be operated from
  # the Internet).
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.network.private
    master_ipv4_cidr_block  = var.network.master_cidr
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.network.private ? concat(var.network.master_allowed_ips, [{ name = "Node Subnet", cidr = tostring(data.google_compute_subnetwork.this.ip_cidr_range) }]) : var.network.master_allowed_ips
      content {
        cidr_block   = cidr_blocks.value.cidr
        display_name = cidr_blocks.value.name
      }
    }
  }

  # This is where Dataplane V2 is enabled.
  datapath_provider = "ADVANCED_DATAPATH"

  monitoring_config {
    enable_components = var.monitoring ? ["SYSTEM_COMPONENTS", "WORKLOADS"] : ["SYSTEM_COMPONENTS"]
  }

  logging_config {
    enable_components = var.logging ? ["SYSTEM_COMPONENTS", "WORKLOADS"] : ["SYSTEM_COMPONENTS"]
  }

  addons_config {
    http_load_balancing {
      # Waiting for NEGs to be ready makes Argo think some applications are not
      # fully deployed even though they are.
      # We don't use GKE's native HTTP load balancing anyway.
      disabled = true
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.maintenance_start_time
    }
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  lifecycle {
    ignore_changes = [min_master_version, node_config]
  }

  depends_on = [google_service_account.node_pool_service_account]
}

resource "google_container_node_pool" "this" {
  for_each = var.node_pools

  name     = each.key
  project  = var.project_id
  location = google_container_cluster.this.location
  cluster  = google_container_cluster.this.name


  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = each.value.min_size
    max_node_count = each.value.max_size
  }

  initial_node_count = each.value.min_size
  node_locations     = each.value.locations

  node_config {
    image_type   = "COS_CONTAINERD"
    machine_type = each.value.machine_type
    preemptible  = each.value.preemptible
    labels       = each.value.labels
    tags         = [local.network_tag_webhook]

    dynamic "taint" {
      for_each = each.value.taints
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.val
      }
    }

    gcfs_config {
      enabled = true
    }

    metadata = merge(
      { "cluster_name" = var.name },
      { "node_pool" = each.key },
      { "disable-legacy-endpoints" = true },
    )

    # This enables workload identity. For more information:
    # https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.node_pool_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  lifecycle {
    ignore_changes = [node_count, version]
  }
  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
  depends_on = [google_container_cluster.this, google_service_account.node_pool_service_account]
}

resource "google_compute_firewall" "master_webhooks" {
  name        = "gke-${substr(var.name, 0, min(25, length(var.name)))}-${google_container_cluster.this.project}-webhooks"
  description = "Managed by terraform gke module: Allow master to hit pods for admission controllers/webhooks"
  project     = data.google_compute_subnetwork.this.project
  network     = trimprefix(data.google_compute_subnetwork.this.network, local.google_compute_apis_url)
  direction   = "INGRESS"

  source_ranges = [google_container_cluster.this.private_cluster_config[0].master_ipv4_cidr_block]
  target_tags   = [local.network_tag_webhook]

  allow {
    protocol = "tcp"
    ports    = concat(["8443", "9443", "15017"], var.network.webhook_ports)
  }
}
