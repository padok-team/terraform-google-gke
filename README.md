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

```hcl
module "google-gke-cluster" {
  source     = "https://github.com/padok-team/terraform-google-gke"

  name       = var.name
  location   = var.location
  network    = var.network
  subnetwork = var.subnetwork
}
```

## Examples

- [Example of regional cluster with IP whitelisting on master and one custom node pool](examples/regional_private_cluster)
- [Example of zonal cluster with two custom node pools](examples/zonal_multiple_node_pool)
- [Example of cluster with one regional ip address and one global ip address](examples/cluster_with_ip_addresses)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The zone or region to deploy the cluster to. It defines if cluster is regional or zonal | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the GKE cluster. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | The network parameters used to deploy the resources | <pre>object({<br>    self_link           = string            // The self link for network. It's required for shared VPC.<br>    subnet_self_link    = string            // The self link for subnetwork. It's requirred for shared VPC.<br>    pods_range_name     = string            // The name of pod range created in network.<br>    services_range_name = string            // The name of service range created in network.<br>    master_cidr         = string            // The private ip range to use for control plane. It can not be created in network module.<br>    master_allowed_ips  = list(map(string)) // The ips to whitelist to access master.<br>    webhook_ports       = list(string)      // The ports to open to allow GKE master nodes to connect to admission controllers/webhooks.<br>  })</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project to deploy the ressrouces to. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy the cluster to. | `string` | n/a | yes |
| <a name="input_registry_project_ids"></a> [registry\_project\_ids](#input\_registry\_project\_ids) | The project ids on which registry access will be granted. | `list(string)` | n/a | yes |
| <a name="input_release_channel"></a> [release\_channel](#input\_release\_channel) | The release channel to look for latest versions on. | `string` | n/a | yes |
| <a name="input_maintenance_start_time"></a> [maintenance\_start\_time](#input\_maintenance\_start\_time) | Time window specified for daily maintenance operations. Specify start\_time in RFC3339 format 'HH:MM', where HH : [00-23] and MM : [00-59] GMT. | `string` | `"00:00"` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | The node pools to create and add to the cluster. | <pre>map(object({<br>    name         = string<br>    locations    = list(string) // Zones to deploy the nodes into<br>    min_size     = string<br>    max_size     = string<br>    machine_type = string // The GCE machine type the pool is made of.<br>    preemptible  = bool<br>    taints       = list(map(string))<br>    labels       = map(string)<br>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_command_to_connect"></a> [command\_to\_connect](#output\_command\_to\_connect) | The gcloud command to run to connect to the cluster. |
<!-- END_TF_DOCS -->
