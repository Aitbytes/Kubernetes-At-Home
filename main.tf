
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
      macaddr = "7E:DF:B4:97:C7:1A"
    },
    {
      macaddr = "A6:2D:3A:F0:16:44"
    },
    {
      macaddr = "BE:50:AE:E3:AF:DC"
    },
    {
      macaddr = "EE:79:E2:B2:65:DA"
    },
    {
      macaddr = "1A:4D:02:1A:E2:80"
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
  name  = "k3s-vm-${count.index+1}-${count.index <= 2 ? "m" : "w" }"
  vmid  = 500 + count.index


  # Base configuration
  target_node = local.vm_base_config.target_node
  clone       = local.vm_base_config.clone
  agent       = local.vm_base_config.agent
  os_type     = local.vm_base_config.os_type
  sockets     = local.vm_base_config.sockets
  vcpus       = local.vm_base_config.vcpus
  cpu         = local.vm_base_config.cpu
  cores       = count.index <= 2 ? 2 : 3
  memory      = count.index <= 2 ? 2048 : 3072
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
  ciuser     = "user"
  cipassword = "very-secret-password" #random_password.ci_password.result
  sshkeys    = file("~/.ssh/id_rsa.pub")
}
