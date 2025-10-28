data "template_file" "cloud_init_script" {
  template = file("${path.module}/cloud_init.sh")
}

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
    hostname_label   = lower(replace(var.instance_display_name, "/[^a-z0-9-]/", "-"))
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(data.template_file.cloud_init_script.rendered)
  }

  freeform_tags = {
    project = "WebBibliotecaTerra"
  }
}

# Output para la IP pública
output "public_ip" {
  value = oci_core_instance.ubuntu_vm.public_ip
}

output "instance_id" {
  value = oci_core_instance.ubuntu_vm.id
}