variable "tenancy_ocid" { type = string }
variable "user_ocid"    { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }
variable "region" { type = string }

variable "compartment_ocid" { type = string }
variable "subnet_id" { type = string }
variable "availability_domain" { type = string }
variable "ubuntu_2204_image_ocid" { type = string }

variable "ssh_public_key" { type = string }

# opcional: tamaño de la VM
variable "instance_shape" {
  type    = string
  default = "VM.Standard.E2.2"
}

# nombre de la instancia
variable "instance_display_name" {
  type    = string
  default = "ubuntu_docker_vm"
}
