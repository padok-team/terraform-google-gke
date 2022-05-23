# Google GKE Terraform module

Terraform module which creates **Google Kubernetes Engine** resources on **GCP**.

## License

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## User Stories for this module

- AASRE I can deploy a GKE cluster with private node
- AASRE I can deploy GKE cluster with a public control plane behind IP whitelisting
- AASRE I can remove the default Node Pool
- AASRE I can create my custom Node Pools
- AASRE I can deploy a GKE cluster and create some IPs (that I can later use for my LBs' IPs)

## Usage

```terraform
module "google-gke-cluster" {
  source     = "https://github.com/padok-team/terraform-google-gke"

  name       = var.name
  project_id = var.project_id

  region   = var.region
  location = var.location // Whether the cluster is regional or zonal

  release_channel = var.release_channel // Use latest release on creation

  registry_project_ids = var.registry_project_ids // Used to grant access to the created sa

  network = var.network

  node_pools = var.nod_pools
}
```

## Examples

- [Example of regional cluster with private node and public control plane](examples/public)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The zone or region to deploy the cluster to. It defines if cluster is regional or zonal | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the GKE cluster. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | The network parameters used to deploy the resources | <pre>object({<br>    private             = bool              // Determines if the control plane has a public IP or not.<br>    subnet_self_link    = string            // The self link for subnetwork. It's required for shared VPC.<br>    pods_range_name     = string            // The name of pod range created in network.<br>    services_range_name = string            // The name of service range created in network.<br>    master_cidr         = string            // The private ip range to use for control plane. It can not be created in network module.<br>    master_allowed_ips  = list(map(string)) // The ips to whitelist to access master.<br>    webhook_ports       = list(string)      // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks.<br>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project to deploy the ressources to. | `string` | n/a | yes |
| <a name="input_registry_project_ids"></a> [registry\_project\_ids](#input\_registry\_project\_ids) | The project ids on which registry access will be granted. | `list(string)` | n/a | yes |
| <a name="input_logging"></a> [logging](#input\_logging) | Enables Stackdriver logging for workloads | `bool` | `false` | no |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | Time window specified for daily maintenance operations. Specify start\_time in RFC3339 format 'HH:MM', where HH : [00-23] and MM : [00-59] GMT. | `string` | `"00:00"` | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | Enables Cloud Monitoring for workloads | `bool` | `false` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | The node pools to create and add to the cluster. | <pre>map(object({<br>    name         = string<br>    locations    = list(string) // Zones to deploy the nodes into<br>    min_size     = string<br>    max_size     = string<br>    machine_type = string // The GCE machine type the pool is made of.<br>    preemptible  = bool<br>    taints       = list(map(string))<br>    labels       = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | The release channel to look for latest versions on. | `string` | `"REGULAR"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_command_to_connect"></a> [command\_to\_connect](#output\_command\_to\_connect) | The gcloud command to run to connect to the cluster. |
| <a name="output_node_network_tag"></a> [node\_network\_tag](#output\_node\_network\_tag) | If you want to create firewall rules on node pools, use this network tag |
<!-- END_TF_DOCS -->
