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



# Common VM configuration
locals {
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

# VM 1
resource "proxmox_vm_qemu" "vm_1" {
  name = "my-vm-1"
  
  # Apply base configuration
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

  # External network interface (connected to physical NIC)
  network {
    model  = "virtio"
    bridge = "vmbr0"  # This bridge is connected to physical network
    macaddr = "7E:DF:B4:97:C7:1A" 
    # On the local router the dhcp resevation was set for this mac address
  }


  serial {
    id   = 0
    type = "socket"
  }

  boot       = "order=scsi0"
  nameserver = "192.168.0.1"
  ipconfig0  = "ip=192.168.0.51/24,gw=192.168.0.1"
  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = file("~/.ssh/id_rsa.pub")

}

# VM 2
resource "proxmox_vm_qemu" "vm_2" {
  name = "my-vm-2"
  depends_on = [proxmox_vm_qemu.vm_1]

  # Apply base configuration
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

  # External network interface (connected to physical NIC)
  network {
    model  = "virtio"
    bridge = "vmbr0"  # This bridge is connected to physical network
    macaddr = "A6:2D:3A:F0:16:44"
    # On the local router the dhcp resevation was set for this mac address
  }


  # Private network interface for VM2-VM3 connection
  # network {
  #   model  = "virtio"
  #   bridge = "private1"  # Internal bridge, not connected to physical network
  # }

  serial {
    id   = 0
    type = "socket"
  }

  boot       = "order=scsi0"
  nameserver = "192.168.0.1"
  ipconfig0  = "ip=192.168.0.52/24,gw=192.168.0.1"
  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = file("~/.ssh/id_rsa.pub")

}

# VM 3
resource "proxmox_vm_qemu" "vm_3" {
  name = "my-vm-3"
  depends_on = [proxmox_vm_qemu.vm_2]
  
  # Apply base configuration
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

  # External network interface (connected to physical NIC)
  network {
    model  = "virtio"
    bridge = "vmbr0"  # This bridge is connected to physical network
    macaddr = "BE:50:AE:E3:AF:DC"
    # On the local router the dhcp resevation was set for this mac address
  }


  serial {
    id   = 0
    type = "socket"
  }

  boot       = "order=scsi0"
  nameserver = "192.168.0.1"
  ipconfig0  = "ip=192.168.0.53/24,gw=192.168.0.1"
  ciuser     = var.ciuser
  cipassword = var.cipassword
  sshkeys    = file("~/.ssh/id_rsa.pub")
}


