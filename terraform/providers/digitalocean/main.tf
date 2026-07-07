# SSH public key already uploaded to the DigitalOcean account; it is injected
# into the droplet so Ansible can connect with the matching private key.
data "digitalocean_ssh_key" "palworld" {
  name = var.ssh_key_name
}

resource "digitalocean_project" "palworld" {
  name        = var.project_name
  description = var.project_description
  purpose     = var.project_purpose
  resources   = [digitalocean_droplet.palworld.urn]
}

resource "digitalocean_droplet" "palworld" {
  name    = var.droplet_name
  image   = var.droplet_image
  region  = var.droplet_region
  size    = var.droplet_size
  tags    = var.droplet_tags
  backups = var.droplet_backups

  ssh_keys = [
    data.digitalocean_ssh_key.palworld.id
  ]
}

module "ansible_inventory" {
  source = "../../modules/ansible-inventory"

  host_ip         = digitalocean_droplet.palworld.ipv4_address
  ansible_user    = var.ansible_user
  ansible_ssh_key = var.ansible_ssh_key
  ansible_python  = var.ansible_python
}
