variable "name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "Zone or region to deploy the cluster to"
  type        = string
}

variable "min_master_version" {
  description = "Minimum version for GKE control plane"
  type        = string
  default     = "1.20.10"

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}.*$", var.min_master_version))
    error_message = "Please set valid version. 'latest' is not accepted. See https://cloud.google.com/kubernetes-engine/versioning#specifying_cluster_version."
  }
}

variable "private_endpoint" {
  type        = bool
  description = "Whether the kubernetes master endpoint should be private or not"
  default     = false
}

variable "enable_dataplane_v2" {
  type        = bool
  description = "Whether to enable Dataplane V2 or not"
  default     = true
}

variable "node_service_account" {
  type = object({
    email = string
  })
  description = "The service account to use for your node identities."
  default     = { email = null }
}

variable "node_pools" {
  description = <<-DESCRIPTION
  Node pools to create and add to the cluster.
  Use `min_size` and `max_size` to set the pool's size.
  Use `machine_type` to specify which GCE machine type the pool is made of.
  DESCRIPTION
  type = map(object({
    min_size     = number
    max_size     = number
    machine_type = string
    preemptible  = bool
  }))
  default = {}
}

variable "node_locations" {
  type        = list(string)
  description = "The zones in which your cluster's nodes are located"
  default     = null
}

variable "network" {
  description = "The virtual network the cluster's nodes will be connected to"
  type = object({
    id = string
  })
}

variable "subnetwork" {
  description = "The subnetwork the cluster's nodes will be connected to"
  type = object({
    id = string
  })
}

variable "cidr_master" {
  type        = string
  description = "The cidr of the subnet ip range to use for the control plane"
  default     = null

  validation {
    condition     = can(regex("(^192\\.168\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^172\\.([1][6-9]|[2][0-9]|[3][0-1])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^10\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])[\\/](([0-9]|[1-2][0-9]|3[0-2]))+$)", var.cidr_master)) || var.cidr_master == null
    error_message = "Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use."
  }
}
variable "cidr_pods" {
  type        = string
  description = "The cidr block of the subnet ip range to use for pods"
  default     = null

  validation {
    condition     = can(regex("(^192\\.168\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^172\\.([1][6-9]|[2][0-9]|[3][0-1])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^10\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])[\\/](([0-9]|[1-2][0-9]|3[0-2]))+$)", var.cidr_pods)) || var.cidr_pods == null
    error_message = "Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use."
  }
}

variable "cidr_services" {
  type        = string
  description = "The cidr of the subnet ip range to use for services"
  default     = null

  validation {
    condition     = can(regex("(^192\\.168\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^172\\.([1][6-9]|[2][0-9]|[3][0-1])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])$)|(^10\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])\\.([0-9]|[0-9][0-9]|[0-2][0-9][0-9])[\\/](([0-9]|[1-2][0-9]|3[0-2]))+$)", var.cidr_services)) || var.cidr_services == null
    error_message = "Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use."
  }
}


variable "firewall_webhook_ports" {
  type        = list(string)
  description = "Ports to open to allow GKE master nodes to connect to admission controllers/webhooks"
  default     = []

  validation {
    condition     = can([for p in var.firewall_webhook_ports : regex("^[0-9]{1,5}$", p)])
    error_message = "Please provide a list of valid ports."
  }
}
