variable "name" {
  description = "Name of the GKE cluster."
  type        = string
}

variable "location" {
  description = "Zone or region to deploy the cluster to."
  type        = string
}

variable "min_master_version" {
  description = "Minimum version for GKE control plane."
  type        = string
  default     = "1.20"

  validation {
    condition     = can(regex("^[0-9]{1,3}\\.[0-9]{1,3}.*$", var.min_master_version))
    error_message = "Please set valid version. 'latest' is not accepted. See https://cloud.google.com/kubernetes-engine/versioning#specifying_cluster_version."
  }
}

variable "private_endpoint" {
  description = "Whether the kubernetes master endpoint should be private or not."
  type        = bool
  default     = false
}

variable "ips_whitelist_master_network" {
  description = "IP or CIDR whitelisted to access master kubernetes."
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

variable "enable_dataplane_v2" {
  description = "Whether to enable Dataplane V2 or not."
  type        = bool
  default     = true
}

variable "node_service_account" {
  description = "The service account to use for your node identities."
  type = object({
    email = string
  })
  default = { email = null }
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
  description = "The zones in which your cluster's nodes are located."
  type        = list(string)
  default     = null
}

variable "network" {
  description = "The virtual network the cluster's nodes will be connected to."
  type = object({
    id = string
  })
}

variable "subnetwork" {
  description = "The subnetwork the cluster's nodes will be connected to."
  type = object({
    id = string
  })
}

variable "cidr_master" {
  description = "The CIDR of the subnet ip range to use for the control plane."
  type        = string
  default     = "10.168.0.0/28"
}
variable "pods_cidr" {
  description = "The CIDR block of the subnet ip range to use for pods."
  type        = string
  default     = null
}

variable "services_cidr" {
  description = "The cidr of the subnet ip range to use for services"
  type        = string
  default     = null
}


variable "firewall_webhook_ports" {
  description = "Ports to open to allow GKE master nodes to connect to admission controllers/webhooks."
  type        = list(string)
  default     = []

  validation {
    condition     = can([for p in var.firewall_webhook_ports : regex("^[0-9]{1,5}$", p)])
    error_message = "Please provide a list of valid ports."
  }
}

variable "ip_addresses" {
  description = "Map of IP that you need to create (GLOBAL or NOT / EXTERNAL or NOT). Internal purpose must be VPC_PEERING or PRIVATE_SERVICE_CONNECT"
  type = map(object({
    external         = bool
    global           = bool
    internal_purpose = optional(string)
  }))
  default = {}
}
