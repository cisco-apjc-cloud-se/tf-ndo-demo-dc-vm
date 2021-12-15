### Vault Provider ###
## Username & Password provided by Workspace Variable
variable "vault_url" {
  type = string
}

variable "vault_username" {
  type = string
}

variable "vault_password" {
  type = string
  sensitive = true
}

provider "vault" {
  address = var.vault_url
  skip_tls_verify = true
  auth_login {
    path = "auth/userpass/login/${var.vault_username}"
    parameters = {
      password = var.vault_password
    }
  }
}

### CPOC vCenter Secrets ###
data "vault_generic_secret" "cpoc-vcenter" {
  path = "kv/cpoc-vcenter"
}
