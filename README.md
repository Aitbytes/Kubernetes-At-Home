# Example usage :

Start by copying and editing the `secretvars` example file 

```bash
cp ./secrets/secretvars.example.tf ./secrets/secretvars.tf
```

Then download a service account key in the secrets directory. Make sure it has the following roles  :
 - Compute Admin
 - Compute Instance Admin (v1)

Then edit the `main.tf` to reference it.

```terraform
# main.tf

provider "google" {
  credentials = file("./secrets/credentials.json") # Change this line
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

```
Then use the following commands :

```bash

tofu init
tofu plan --var-file ./secrets/secretvars.tf
tofu apply --var-file ./secrets/secretvars.tf
```

You can reuse the IPs of the machines provisioned by terraform with the following command :

```bash

mv inventory.yml ./ansible/inventory/gcp/hosts.yml
```

You can then proceed to start the ansible playbook :

```bash
cd ansible # Start by changing current directory
ansible-playbook -i ./inventory/gcp/hosts.yml ./site.yml
```

And let the magic happen

