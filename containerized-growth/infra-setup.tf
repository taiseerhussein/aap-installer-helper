terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu://system"
}

# Storage 

resource "libvirt_volume" "aap_virt_disk" {
  name = "aap_virt_disk"
  pool = "default"
  size = 300 * 1024 * 1024 * 1024  # 300GB
  format = "qcow2"
}

# Machine

resource "libvirt_domain" "aap_virt_vm" {
  name = "aap_virt_vm"
  memory = 24576   # 24G
  vcpu = 12
  firmware = "/usr/share/edk2/ovmf/OVMF_CODE.fd"

  cpu {
    mode = "host-passthrough"
  }

  disk {
    file = "/downloads/iso/rhel-9.5-x86_64-dvd.iso"
  }

  disk {
    volume_id = libvirt_volume.aap_virt_disk.id
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
    liste_type = "address"
  }
}

output "vm_ip_address" {
  value = libvirt_domain.aap_virt_vm.network_interface[0].addresses[0]
}
