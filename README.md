# Proxmox VM Configuration

## Description
This project contains Terraform configurations for provisioning virtual machines on a Proxmox server. It sets up three VMs with common configurations and specific network settings.

## Prerequisites
- Terraform or OpenTofu installed on your machine.
- Access to a Proxmox server.
- Proxmox API token for authentication.

## Usage
1. Clone this repository.
2. Navigate to the directory containing `main.tf`.
3. Initialize Terraform:

```bash
terraform init
```

Or

```bash
tofu init
```

4. Configure secrets inside `secrets.tfvars` or clone, modify and rename `example.secrets.tfvars`:
   ```bash
   cp example.secrets.tfvars secrets.tfvars
   ```

5. Apply the configuration:
   ```bash
   terraform apply -var-file="secrets.tfvars"
   ```

## Configuration
- The base VM configuration is defined in the `locals` block.
- Each VM resource (`proxmox_vm_qemu`) inherits the base configuration.
- Modify the `pm_api_url`, `pm_api_token_id`, and `pm_api_token_secret` in `main.tf` for your Proxmox setup.

## License
This project is licensed under the MIT License.
