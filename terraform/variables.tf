# Credenciales de Oracle Cloud Infrastructure
variable "tenancy_ocid" {
  description = "OCID del Tenancy de OCI"
  type        = string
}

variable "user_ocid" {
  description = "OCID del usuario de OCI"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint de la API Key de OCI"
  type        = string
}

variable "private_key_path" {
  description = "Ruta al archivo de clave privada de OCI"
  type        = string
}

variable "region" {
  description = "Región de OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

# Configuración de red
variable "compartment_ocid" {
  description = "OCID del compartimento"
  type        = string
}

variable "subnet_id" {
  description = "OCID de la subnet"
  type        = string
}

variable "availability_domain" {
  description = "Dominio de disponibilidad"
  type        = string
}

# Configuración de la instancia
variable "ubuntu_image_ocid" {
  description = "OCID de la imagen de Ubuntu 22.04"
  type        = string
}

variable "instance_shape" {
  description = "Shape de la instancia (tamaño de VM)"
  type        = string
  default     = "VM.Standard.E2.2"
}

variable "instance_display_name" {
  description = "Nombre de la instancia"
  type        = string
  default     = "webbiblioteca-vm"
}

variable "ssh_public_key" {
  description = "Clave pública SSH para acceso a la VM"
  type        = string
}

# Variables de aplicación
variable "docker_user" {
  description = "Usuario de Docker Hub"
  type        = string
}

variable "jwt_secret" {
  description = "Secret para JWT"
  type        = string
  sensitive   = true
}

variable "supa_anon_key" {
  description = "Clave anónima de Supabase"
  type        = string
  sensitive   = true
}

variable "supa_base_url" {
  description = "URL de Supabase"
  type        = string
}