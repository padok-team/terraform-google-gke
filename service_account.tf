resource "google_service_account" "node_pool_service_account" {
  project      = var.project_id
  account_id   = "${var.name}-pool"
  display_name = "Terraform-managed service account for GKE node pools"
}

resource "google_project_iam_member" "node_pool_service_account-log_writer" {
  project = google_service_account.node_pool_service_account.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-metric_writer" {
  project = google_project_iam_member.node_pool_service_account-log_writer.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-monitoring_viewer" {
  project = google_project_iam_member.node_pool_service_account-metric_writer.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-resourceMetadata-writer" {
  project = google_project_iam_member.node_pool_service_account-monitoring_viewer.project
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-gcr" {
  for_each = toset(var.registry_project_ids)
  project  = each.key
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}

resource "google_project_iam_member" "node_pool_service_account-artifact-registry" {
  for_each = toset(var.registry_project_ids)
  project  = each.key
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${google_service_account.node_pool_service_account.email}"
}
