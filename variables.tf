variable "tenant" {
  type = string
}

variable "domain" {
  type = string
}

variable "dns_server_list" {
  type = list(string)
}

variable "vsphere_datacenter" {
  type = string
}

variable "vsphere_cluster" {
  type = string
}

variable "vsphere_template" {
  type = string
}

variable "vsphere_datastore" {
  type = string
}

variable "dc_apps" {
  type = map(object({
    name = string
    segment = string
    instances = map(object({
      tier = string
      instance_name = string
      instance_count = number
      ip_prefix = string
      ip_offset = number
      ip_masklength = number
      ip_gateway = string
    }))
  }))
}
