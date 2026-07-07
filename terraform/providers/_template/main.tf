# =============================================================================
# PROVIDER TEMPLATE — how to add a new cloud provider
# =============================================================================
# 1. Copy this directory:  cp -r terraform/providers/_template terraform/providers/<name>
# 2. Follow the numbered TODOs in terraform.tf, providers.tf and this file.
# 3. Point inventory.yml's project_path at your new directory.
# 4. Add a terraform.tfvars.example and a README.md (see ../digitalocean for a
#    complete example).
# 5. Run `make lint` — CI discovers provider directories automatically.
#
# The contract every provider must fulfil is documented in
# docs/provider-contract.md. In short: instantiate the ansible-inventory
# module once, and expose the `server_ipv4` and `server_name` outputs.
#
# This template uses a null_resource placeholder so it stays
# `terraform validate`-able in CI without any cloud credentials.
# =============================================================================

# TODO(3): replace this placeholder with your real server resource, e.g.
# a hcloud_server, an ovh instance, an aws_instance...
resource "null_resource" "server" {
}

locals {
  # TODO(4): point these locals at your server resource's attributes, e.g.:
  #   server_ipv4 = hcloud_server.palworld.ipv4_address
  #   server_name = hcloud_server.palworld.name
  # The placeholder values keep the template applyable locally, which is used
  # to test the Terraform -> Ansible inventory bridge without a cloud account.
  server_ipv4 = "192.0.2.1"
  server_name = "palworld-server-placeholder"
}

# Registers the server in the Ansible dynamic inventory. Do NOT rename the
# module or change the wiring — only `host_ip` ever changes (through the
# locals above).
module "ansible_inventory" {
  source = "../../modules/ansible-inventory"

  host_ip         = local.server_ipv4
  ansible_user    = var.ansible_user
  ansible_ssh_key = var.ansible_ssh_key
  ansible_python  = var.ansible_python
}
