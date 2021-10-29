# GCP GKE Terraform module

Terraform module which creates **GKE** resources on **GCP**.
<!-- This module is an abstraction of the [MODULE_NAME](https://github.com/a_great_module) by [@someoneverysmart](https://github.com/someoneverysmart). -->

## User Stories for this module

- AASRE I can deploy a GKE cluster with private node
- AASRE I can deploy GKE cluster with a public control plane behind IP whitelisting
- AASRE I can remove the default Node Pool
- AASRE I can create my custom Node Pools

## Usage

```hcl
module "google" {
  source = "https://github.com/padok-team/terraform-google-gke"

  example_of_required_variable = "hello_world"
}
```

## Examples

- [Example of use case](examples/example_of_use_case/main.tf)
- [Example of other use case](examples/example_of_other_use_case/main.tf)

<!-- BEGIN_TF_DOCS -->
## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Zone or region to deploy the cluster to | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the GKE cluster | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | The virtual network the cluster's nodes should be connected to | <pre>object({<br>    id = string<br>  })</pre> | n/a | yes |
| <a name="input_node_service_account"></a> [node\_service\_account](#input\_node\_service\_account) | The service account to use for your node identities. | <pre>object({<br>    email = string<br>  })</pre> | n/a | yes |
| <a name="input_cidr_master"></a> [cidr\_master](#input\_cidr\_master) | The cidr of the subnet ip range to use for the control plane | `string` | `null` | no |
| <a name="input_cidr_pods"></a> [cidr\_pods](#input\_cidr\_pods) | The cidr block of the subnet ip range to use for pods | `string` | `null` | no |
| <a name="input_cidr_services"></a> [cidr\_services](#input\_cidr\_services) | The cidr of the subnet ip range to use for services | `string` | `null` | no |
| <a name="input_enable_dataplane_v2"></a> [enable\_dataplane\_v2](#input\_enable\_dataplane\_v2) | Whether to enable Dataplane V2 or not | `bool` | `true` | no |
| <a name="input_firewall_webhook_ports"></a> [firewall\_webhook\_ports](#input\_firewall\_webhook\_ports) | Ports to open to allow GKE master nodes to connect to admission controllers/webhooks | `list(string)` | `[]` | no |
| <a name="input_min_master_version"></a> [min\_master\_version](#input\_min\_master\_version) | Minimum version for GKE control plane | `string` | `"1.20.10"` | no |
| <a name="input_node_locations"></a> [node\_locations](#input\_node\_locations) | The zones in which your cluster's nodes are located | `list(string)` | `null` | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Node pools to create and add to the cluster.<br>Use `min_size` and `max_size` to set the pool's size.<br>Use `machine_type` to specify which GCE machine type the pool is made of. | <pre>map(object({<br>    min_size     = number<br>    max_size     = number<br>    machine_type = string<br>    preemptible  = bool<br>  }))</pre> | `{}` | no |
| <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint) | Whether the kubernetes master endpoint should be private or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_example"></a> [example](#output\_example) | A meaningful description |
<!-- END_TF_DOCS -->
