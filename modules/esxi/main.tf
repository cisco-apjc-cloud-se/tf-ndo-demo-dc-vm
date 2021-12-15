terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      # version = "1.24.2"
    }
  }
}

locals {
  ### App -> Tier List ###
  apptierlist = flatten([
    for app_key, app in var.dc_apps : [
      for vm_key, vm in app.instances :
      {
        segment_name    = app.segment
        app_name        = app.name
        tier            = vm.tier
      }
    ]
  ])

  apptiermap = {
    for val in local.apptierlist:
      lower(format("%s-%s", val["app_name"], val["tier"])) => val
  }

  ### App -> VM -> Instance List ###
  appvminstlist = flatten([
    for app_key, app in var.dc_apps : [
      for vm_key, vm in app.instances : [
        for i in range(vm.instance_count) :
        {
          segment_name    = app.segment
          app_name        = app.name
          tier            = vm.tier
          instance_name   = vm.instance_name
          instance_count  = vm.instance_count # Total instances
          instance_number = i+1 # Specific instance number, starts at 0
          ip_prefix       = vm.ip_prefix
          ip_offset       = vm.ip_offset
          ip_masklength   = vm.ip_masklength
          ip_gateway      = vm.ip_gateway
        }
        // if site.type != "aci"
      ]
    ]
  ])

  appvminstmap = {
    for val in local.appvminstlist:
      lower(format("%s-%s-%d", val["app_name"], val["tier"], val["instance_number"])) => val
  }
}

### Common Data Sources ###
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

### Lookup Networks (Port Groups) by Name - Assumes ACI VMM Domain Format ###
data "vsphere_network" "network" {
  for_each = local.apptiermap

  name          = format("%s|%s|%s", var.tenant, each.value.app_name, each.value.tier)
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

### Build Demo VMs from Template ###
resource "vsphere_virtual_machine" "vm" {
  for_each = local.appvminstmap


  name             = format("%s-%d", each.value.instance_name, each.value.instance_number)
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = 2
  memory    = 1024
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network[format("%s-%s", each.value.app_name, each.value.tier)].id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.template.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = format("%s-%d", each.value.instance_name, each.value.instance_number)
        domain    = var.domain
      }

      network_interface {
        ipv4_address = cidrhost(format("%s/%d",each.value.ip_prefix, each.value.ip_masklength), (each.value.ip_offset + each.value.instance_number))
        ipv4_netmask = each.value.ip_masklength
      }
      ipv4_gateway = each.value.ip_gateway
      dns_server_list = var.dns_server_list
    }
  }
}
