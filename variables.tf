variable "data_center" { default = "SDDC-Datacenter" }
variable "cluster" { default = "Cluster-1" }
variable "workload_datastore" { default = "WorkloadDatastore" }
variable "compute_pool" { default = "Compute-ResourcePool" }

variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}


variable "Subnet13_name" { default = "seg13" }
variable "subnet13" { default = "13.13.13.0/24" }