provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.data_center
}
data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datastore" "datastore" {
  name          = var.workload_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.compute_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "sddc-cgw-network-1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network13" {
  name          = var.Subnet13_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "Blue-VM-1"
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_folder" "folder" {
  path          = "terraform-test-folder"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}


resource "vsphere_tag_category" "environment" {
    name        = "environment"
    cardinality = "SINGLE"

    associable_types = [
        "VirtualMachine"
    ]
}

resource "vsphere_tag_category" "region" {
    name        = "region"
    cardinality = "SINGLE"

    associable_types = [
        "VirtualMachine"
    ]
}

resource "vsphere_tag" "environment" {
    name        = "test-dev"
    category_id = vsphere_tag_category.environment.id
}

resource "vsphere_tag" "region" {
    name         = "UK"
    category_id = vsphere_tag_category.region.id
}


resource "vsphere_virtual_machine" "vm" {
    name             = "terraform-test"
    folder           = "Workloads"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id     = data.vsphere_datastore.datastore.id
    firmware         = data.vsphere_virtual_machine.template.firmware
   wait_for_guest_net_timeout = 0
    wait_for_guest_ip_timeout = 0
    num_cpus = 2
    memory   = 4096
    guest_id = data.vsphere_virtual_machine.template.guest_id
    annotation = data.vsphere_virtual_machine.template.disks.0.size
    network_interface {
        network_id   = data.vsphere_network.network.id
        adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
    }

    disk {
        label            = "disk0"
        size             = data.vsphere_virtual_machine.template.disks.0.size
        eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
        thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    }

    scsi_type = data.vsphere_virtual_machine.template.scsi_type

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
}
tags = [
        vsphere_tag.environment.id,
        vsphere_tag.region.id,
   ]
}
