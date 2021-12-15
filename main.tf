terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "mel-ciscolabs-com"
    workspaces {
      name = "tf-ndo-demo-dc-vm"
    }
  }
  required_providers {
    vault = {
      source = "hashicorp/vault"
      # version = "2.18.0"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

### Setup VMware vCenter/vSphere Provider ###
provider "vsphere" {
  user           = data.vault_generic_secret.cpoc-vcenter.data["username"]
  password       = data.vault_generic_secret.cpoc-vcenter.data["password"]
  vsphere_server = data.vault_generic_secret.cpoc-vcenter.data["server"]

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

## VMware vSphere Module
module "esxi" {
  source = "./modules/esxi"

  tenant            = var.tenant
  domain            = var.domain

  vsphere_dc        = var.vsphere_dc
  vsphere_cluster   = var.vsphere_cluster
  vsphere_template  = var.vsphere_template
  vsphere_datastore = var.vsphere_datastore

  dc_apps           = var.dc_apps
}
