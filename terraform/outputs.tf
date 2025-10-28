output "public_ip" {
  description = "Dirección IP pública de la VM"
  value       = oci_core_instance.webbiblioteca_vm.public_ip
}

output "instance_id" {
  description = "OCID de la instancia creada"
  value       = oci_core_instance.webbiblioteca_vm.id
}

output "instance_state" {
  description = "Estado de la instancia"
  value       = oci_core_instance.webbiblioteca_vm.state
}

output "frontend_url" {
  description = "URL del frontend"
  value       = "http://${oci_core_instance.webbiblioteca_vm.public_ip}"
}

output "backend_url" {
  description = "URL del backend API"
  value       = "http://${oci_core_instance.webbiblioteca_vm.public_ip}:5000/api"
}