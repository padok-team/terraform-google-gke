output "command_to_connect" {
  description = "The gcloud command to run to connect to the cluster."
  value       = format("gcloud container clusters get-credentials %s ${local.is_region ? "--region=%s" : "--zone=%s"} --project=%s", var.name, var.location, var.project_id)
}
