terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.47"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
  }
  required_version = ">= 1.0"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}
