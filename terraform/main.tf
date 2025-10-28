resource "oci_core_instance" "webbiblioteca_vm" {
  availability_domain = var.availability_domain
  shape               = var.instance_shape
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_image_ocid
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    display_name     = "${var.instance_display_name}_vnic"
    hostname_label   = var.instance_display_name
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud_init.tpl", {
      DOCKER_USER   = var.docker_user
      SUPA_BASE_URL = var.supa_base_url
      SUPA_ANON_KEY = var.supa_anon_key
      JWT_SECRET    = var.jwt_secret
    }))
  }

  freeform_tags = {
    Project     = "WebBibliotecaTerra"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }

  # Timeouts para dar tiempo a la inicialización
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}