resource "oci_core_instance" "ubuntu_vm" {
  availability_domain = var.availability_domain
  shape               = var.instance_shape
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_display_name

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_2204_image_ocid
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    display_name     = "${var.instance_display_name}_vnic"
    hostname_label   = "webbiblioteca-vm-3"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key

    # ⚠️ Aquí se pasan las variables al template del cloud-init
    user_data = base64encode(templatefile("${path.module}/cloud_init.sh", {
      DOCKER_USER   = var.docker_user
      SUPA_BASE_URL = var.supa_base_url
      SUPA_ANON_KEY = var.supa_anon_key
      JWT_SECRET    = var.jwt_secret
    }))
  }

  freeform_tags = {
    project = "WebBibliotecaTerra"
  }
}

# -----------------------
#  SALIDAS (outputs)
# -----------------------

output "public_ip" {
  description = "IP pública de la instancia desplegada"
  value       = oci_core_instance.ubuntu_vm.public_ip
}

output "instance_id" {
  description = "OCID de la instancia desplegada"
  value       = oci_core_instance.ubuntu_vm.id
}
