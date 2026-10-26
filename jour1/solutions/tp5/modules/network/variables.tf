variable "prefix" {
  type        = string
  description = "Préfixe des noms de ressources (dev, prod)"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type        = map(string)
  description = "Nom court du sous-réseau vers son CIDR"
}

variable "nsg_rules" {
  type = map(object({
    priority = number
    port     = string
    access   = string
  }))
  default = {
    allow-https = { priority = 100, port = "443", access = "Allow" }
    deny-ssh    = { priority = 200, port = "22", access = "Deny" }
  }
}
