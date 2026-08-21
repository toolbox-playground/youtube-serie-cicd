variable "subscription_id" {
  type        = string
  description = "ID da assinatura Azure (az account show --query id -o tsv)"
  default     = "e2a25891-08c3-4cda-b9ff-8b88c8a7bdfc"
}

variable "location" {
  type        = string
  description = "Regiao do Azure"
  default     = "brazilsouth"
}

variable "prefixo" {
  type        = string
  description = "Prefixo aplicado ao nome de todos os recursos"
  default     = "tbx"
}

variable "admin_user" {
  type        = string
  description = "Usuario administrador da VM"
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Caminho da chave publica SSH"
  default     = "~/.ssh/id_jhkpereira.pub"
}

variable "meu_ip_cidr" {
  type        = string
  description = "Seu IP publico em CIDR para liberar SSH. Ex: 200.1.2.3/32. Use 0.0.0.0/0 apenas em laboratorio descartavel."
  default     = "0.0.0.0/0"
}
