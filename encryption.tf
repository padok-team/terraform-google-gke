resource "google_kms_key_ring" "this" {
  project = var.project_id
  name    = "gke-${var.name}-keyring"
  # Must be the same location as the location of data at rest
  # you will encrypt with the CMEK
  location = replace(var.location, "/-[a-d]/", "")
}

# create a random_id to suffix `google_kms_crypto_key.this`
# useful because kms
resource "random_id" "kms_key" {
  byte_length = 3
  prefix      = "gke-${var.name}-key-"
}

resource "google_kms_crypto_key" "this" {
  #checkov:skip=CKV_GCP_82:Ensure KMS keys are protected from deletion
  #checkov:skip=CKV_GCP_43:Ensure KMS encryption keys are rotated within a period of 90 days
  name                       = random_id.kms_key.hex
  key_ring                   = google_kms_key_ring.this.id
  rotation_period            = "7890000s" # 3 months
  destroy_scheduled_duration = "604800s"  # 7 days

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

# Binding for KMS Key encryption and decryption
resource "google_project_service_identity" "container" {
  provider = google-beta

  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_kms_crypto_key_iam_member" "container_crypto_key" {
  crypto_key_id = local.kms_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.container.email}"
}

resource "google_project_iam_member" "compute_crypto" {
  project = var.project_id

  role = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  # 23/12/2022: we can not use the service identity resource as it is not available for compute google api yet,
  # Instead we need to build the email using the project ID
  member = "serviceAccount:service-${data.google_project.this.number}@compute-system.iam.gserviceaccount.com"
}
