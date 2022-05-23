# Options

## Monitoring and Logging

By default clusters are set up to only log and monitor **system** components. If you don't have any other monitoring or logging solutions you can enable the GCP managed one using:

```terraform
logging    = true
monitoring = true
```

> :warning: Activating this feature is not recommended if you can have another monitoring/logging stack

## Private Cluster

You can have a private control plane using:

```terraform
network {
  private = true
}
```

> :information_source: We recommend you to use this [module](https://library.padok.cloud/catalog/default/component/terraform-google-bastion) to set up an IAP bastion able to access your cluster.

## Release Channel

By default this module sets your cluster on the **REGULAR** release channel but you can modify it:

```terraform
release_channel = "RAPID"
```

## Admission Controller firewalling

By default this module opens those ports between control plane and node pools:

- 8443
- 9443
- 15017

You can add new ones using:

```terraform
network {
  webhook_ports = ["9562"]
}
```

> :information_source: If a port becomes common in our K8S stack don't hesitate to add the port as a default one in this module.
