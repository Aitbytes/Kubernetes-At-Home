# Configure the Proxmox provider
terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.0.100:8006/api2/json"
  pm_api_token_id = "root@pam!tokenid001"
  pm_api_token_secret = "bf710f10-56f5-4b37-a91f-5c779d9b8185"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "my_vm" {
 name       = "my-vm"
 target_node = "zsus-pve"
 clone      = "VM 9003"
 agent = 1
 os_type = "cloud-init"
 sockets = 1
 vcpus = 0
 cpu = "host"
 cores      = 2
 memory     = 2048
 scsihw = "virtio-scsi-pci"
 
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size = 20
          cache = "writeback"
          storage = "local-lvm"
          replicate = true
        }
      }
    }
  }
  vga {
    type = "std"
    memory = 4
  }
  network {
    model = "virtio"
    bridge = "vmbr0"
  }
  serial {
    id = 0
    type = "socket"
  }
  boot = "order=scsi0"
  ipconfig0 = "ip=dhcp"
  ciuser = "test"
  cipassword = "test"
}



# # Define a Proxmox VM resource
# resource "proxmox_vm_qemu" "example_vm" {
#   count = 2  # Create 2 identical VMs
#   name = "vm-${count.index + 1}"
#   target_node = "zsus-pve"
#   vm_state = "running"
#
#   # VM Template name
#   clone = "StdDebian"
#   cores = 4
#   memory = 2048
#   agent = 1
#   ipconfig0 = "dhcp"
#   bootdisk = "scsi0"
#
# }
#
# # Output the VM IPs
# output "vm_ips" {
#   value = proxmox_vm_qemu.example_vm[*].default_ipv4_address
# }
