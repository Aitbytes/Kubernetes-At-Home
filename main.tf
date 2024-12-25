# Configure the Proxmox provider
terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url         
  pm_api_token_id     = var.pm_api_token_id    
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = true
}

# VM configuration variables
locals {
  vm_configs = [
    {
      name    = "k3s-vm-1"
      macaddr = "7E:DF:B4:97:C7:1A"
    },
    {
      name    = "k3s-vm-2"
      macaddr = "A6:2D:3A:F0:16:44"
    },
    {
      name    = "k3s-vm-3"
      macaddr = "BE:50:AE:E3:AF:DC"
    }
  ]

  vm_base_config = {
    target_node = "zsus-pve"
    clone       = "VM 9003"
    agent       = 1
    os_type     = "cloud-init"
    sockets     = 1
    vcpus       = 0
    cpu         = "host"
    cores       = 2
    memory      = 2048
    scsihw      = "virtio-scsi-pci"
  }
}

# VM resource
resource "proxmox_vm_qemu" "vms" {
  count = length(local.vm_configs)
  name  = local.vm_configs[count.index].name
  vmid  = 500 + count.index


  # Base configuration
  target_node = local.vm_base_config.target_node
  clone       = local.vm_base_config.clone
  agent       = local.vm_base_config.agent
  os_type     = local.vm_base_config.os_type
  sockets     = local.vm_base_config.sockets
  vcpus       = local.vm_base_config.vcpus
  cpu         = local.vm_base_config.cpu
  cores       = local.vm_base_config.cores
  memory      = local.vm_base_config.memory
  scsihw      = local.vm_base_config.scsihw

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
          size      = 20
          cache     = "writeback"
          storage   = "local-lvm"
          replicate = true
        }
      }
    }
  }

  vga {
    type   = "std"
    memory = 4
  }

  network {
    model   = "virtio"
    bridge  = "vmbr0"
    macaddr = local.vm_configs[count.index].macaddr

  }

  serial {
    id   = 0
    type = "socket"
  }

  boot       = "order=scsi0"
  nameserver = "192.168.0.1"
  ipconfig0  = "ip=dhcp"
  ciuser     = "k3s-user-${count.index+1}"
  cipassword = random_password.ci_password.result
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
