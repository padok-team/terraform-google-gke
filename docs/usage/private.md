# Private

## Specifications

- Private nodes
- Private Control Plane
- Regional Cluster
- Custom Service Account for nodes
- Cilium *(aka Dataplane V2)* enabled
- No Database Encryption (Encrypted secrets in ETCD)
- Firewall rule to allow common admission controllers
- Release channel: **Standard**

## Dependencies

- Subnetwork
- 2 Provisioned Secondary Ranges

> :information_source: You can provision those resources using this [module](https://library.padok.cloud/catalog/default/component/terraform-google-network)

## Example

[Link](../../examples/regional/main.tf)

```terraform
{%
   include-markdown "../../examples/regional/main.tf"
%}
```
