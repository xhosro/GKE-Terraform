resource "google_service_account" "service-1" {
    account_id = "service-1"
}

# grant access to the service account to list bucket, Its non-authoritative, other members for the role for the project are preserved in the
resource "google_project_iam_member" "service-1" {
    project = "terraform-422613"
    role    = "roles/storage.admin"
    member  = "serviceAccount:${google_service_account.service-1.email}"
}


# allow the kubernetes service account to impersonate this service account
resource "google_service_account_iam_member" "service-1" {
    service_account_id = google_service_account.service-1.id
    role               = "roles/iam.workloadIdentityUser"
    member             = "serviceAccount:terraform-422613.svc.id.goog[staging/service-1]"
}

# to establish a link between the kubernetes RBAC system and the gcp IAM system.its always the same workload identity user, but you need to update a member
# staging = namespace
# service-1 = kubernetes service account