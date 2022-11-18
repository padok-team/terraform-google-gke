variable "name" {
  description = "The name of the GKE cluster."
  type        = string
}

variable "project_id" {
  description = "The project to deploy the ressources to."
  type        = string
}

variable "location" {
  description = "The zone or region to deploy the cluster to. It defines if cluster is regional or zonal"
  type        = string
}

variable "release_channel" {
  description = "The release channel to look for latest versions on."
  type        = string
  default     = "REGULAR"
}

variable "registry_project_ids" {
  description = "The project ids on which registry access will be granted."
  type        = list(string)
}

variable "logging" {
  description = "Enables Stackdriver logging for workloads"
  type        = bool
  default     = false
}

variable "network" {
  description = "The network parameters used to deploy the resources"
  type = object({
    private             = bool              // Determines if the control plane has a public IP or not.
    subnet_self_link    = string            // The self link for subnetwork. It's required for shared VPC.
    pods_range_name     = string            // The name of pod range created in network.
    services_range_name = string            // The name of service range created in network.
    master_cidr         = string            // The private ip range to use for control plane. It can not be created in network module.
    master_allowed_ips  = list(map(string)) // The ips to whitelist to access master.
    webhook_ports       = list(string)      // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks.
  })
}

variable "node_pools" {
  description = "The node pools to create and add to the cluster."
  type = map(object({
    name         = string
    locations    = list(string) // Zones to deploy the nodes into
    min_size     = string
    max_size     = string
    machine_type = string // The GCE machine type the pool is made of.
    preemptible  = bool
    taints       = list(map(string))
    labels       = map(string)
  }))
  default = {}
}

variable "maintenance_start_time" {
  description = "Time window specified for daily maintenance operations. Specify start_time in RFC3339 format 'HH:MM', where HH : [00-23] and MM : [00-59] GMT."
  type        = string
  default     = "00:00"
}

variable "workload_identity_pool" {
  description = "Custom workload identity pool to be used, default will be the project default one"
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "KMS Key ID to encrypt Boot disk and etcd of GKE"
  type        = string
  default     = ""
}