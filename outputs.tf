output "command_to_connect" {
  description = "The gcloud command to run to connect to the cluster."
  value       = format("gcloud container clusters get-credentials %s ${local.is_region ? "--region=%s" : "--zone=%s"} --project=%s", var.name, var.location, var.project_id)
}

output "node_network_tag" {
  description = "If you want to create firewall rules on node pools, use this network tag"
  value       = local.network_tag_webhook
}
