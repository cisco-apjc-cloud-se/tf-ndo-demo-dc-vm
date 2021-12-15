output "diskSize" {
  value = data.vsphere_virtual_machine.ubuntuTemplate.disks.0.size
}
