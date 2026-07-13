# `ansible-inventory` module

Registers a provisioned server in Terraform state in the form the
[`cloud.terraform.terraform_provider`](https://github.com/ansible-collections/cloud.terraform)
dynamic inventory plugin reads back — the single bridge between Terraform
(provisioning) and Ansible (configuration). Every provider root instantiates
this module, so the inventory group name and connection variable names can
never drift from what `ansible/deploy-palworld.yml` expects.

Every provider under `terraform/providers/` MUST call this module exactly
once — see [docs/provider-contract.md](../../../docs/provider-contract.md).

## Usage

```hcl
module "ansible_inventory" {
  source = "../../modules/ansible-inventory"

  host_ip         = digitalocean_droplet.palworld.ipv4_address
  ansible_user    = var.ansible_user
  ansible_ssh_key = var.ansible_ssh_key
  ansible_python  = var.ansible_python
}
```

Real consumers: [`providers/digitalocean`](../../providers/digitalocean/main.tf),
[`providers/_template`](../../providers/_template/main.tf).

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| [ansible/ansible](https://registry.terraform.io/providers/ansible/ansible/latest) | ~> 1.3 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `host_ip` | Public IPv4 of the server; becomes the inventory hostname (validated as IPv4) | `string` | n/a | yes |
| `ansible_python` | Python interpreter path on the remote host | `string` | `"/usr/bin/python3"` | no |
| `ansible_ssh_key` | SSH private key path on the control machine | `string` | `"~/.ssh/id_ed25519"` | no |
| `ansible_user` | Remote user Ansible connects as | `string` | `"root"` | no |
| `groups` | Inventory groups; must keep `"palworld"` (validated) | `list(string)` | `["palworld"]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `groups` | Ansible inventory groups the host was registered in |
| `host_ip` | IP address registered in the Ansible inventory |

## Testing

Plan-mode unit tests with a mocked `ansible` provider live in
[`tests/defaults_unit_test.tftest.hcl`](tests/defaults_unit_test.tftest.hcl):

```bash
terraform -chdir=terraform/modules/ansible-inventory init -backend=false
terraform -chdir=terraform/modules/ansible-inventory test
# or, from the repository root:
make test
```
