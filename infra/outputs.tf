output "public_ip" {
  description = "Public IP address of the instance"
  value       = oci_core_instance.ubuntu_vm.public_ip
}
