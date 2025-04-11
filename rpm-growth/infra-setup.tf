terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Variables

variable "vm_names" {
  type = map(
    object(
        {
            name = string
            size = number
            memory = number
            vcpus = number
        }
    )
  )
  default = {
    "vm1" = {
        name = "automationgateway",
        size = 64424509440 # 60GB,
        memory = 8192,  # 8GB
        vcpus = 2 },
    "vm2" = {
        name = "automationcontroller"
        size = 107374182400 # 100GB,
        memory = 8192,  # 8GB
        vcpus = 2 },
    "vm3" = {
        name = "automationhub"
        size = 64424509440 # 60GB,
        memory = 8192,  # 8GB
        vcpus = 2 },
    "vm4" = {
        name = "automationedacontroller"
        size = 64424509440 # 60GB,
        memory = 8192,  # 8GB
        vcpus = 2 },
    "vm5" = {
        name = "executionnode1"
        size = 64424509440 # 60GB,
        memory = 8192,  # 8GB
        vcpus = 2 },
    "vm6" = {
        name = "automationdatabase"
        size = 322122547200 # 300GB,
        memory = 16384,  # 16GB
        vcpus = 4 }
  }
}

# Machines

resource "libvirt_volume" "vm_disk" {
  for_each = var.vm_names
  name = "${each.value.name}.qcow2"
  pool = "default"
  format = "qcow2"
  size = each.value.size
}

resource "libvirt_domain" "vm" {
  for_each = var.vm_names
  name = each.value.name
  memory = each.value.memory
  vcpu = each.value.vcpus
  firmware = "/usr/share/edk2/ovmf/OVMF_CODE.fd"

  cpu {
    mode = "host-passthrough"
  }

  disk {
    file = "/downloads/iso/rhel-9.5-x86_64-dvd.iso"
  }

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  boot_device {
    dev = ["cdrom","hd"]
  }

  network_interface {
    network_name = "default"
    wait_for_lease = true
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  console {
    type = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  graphics {
    type = "spice"
    autoport = true
    listen_type = "address"
  }
}

