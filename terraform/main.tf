terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }
  }
}

# set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
# export TF_VAR_do_token=...
variable "do_token" {}

# configure the DigitalOcean Provider
provider "digitalocean" { token = var.do_token }

# Terraform automatically add this key to any new droplets created
data "digitalocean_ssh_key" "terraform" {
  name = "palworld-pub-key"
}

# create a project resource
resource "digitalocean_project" "palworld-project" {
  name        = var.project_name
  description = var.project_description
  purpose     = var.project_purpose
  resources   = [digitalocean_droplet.palworld-droplet.urn]
}

# create a droplet resource inside the project resource
resource "digitalocean_droplet" "palworld-droplet" {
  name    = var.droplet_name
  image   = var.droplet_image
  region  = var.droplet_region
  size    = var.droplet_size
  tags    = var.droplet_tags
  backups = var.droplet_backups
  ssh_keys = [
    data.digitalocean_ssh_key.terraform.id
  ]
}

resource "time_sleep" "wait_20_seconds" {
  depends_on      = [digitalocean_droplet.palworld-droplet]
  create_duration = "20s"
}

# create a dynamic inventory
resource "ansible_host" "droplet_instance" {
  name   = digitalocean_droplet.palworld-droplet.ipv4_address
  groups = ["palword_hosts"]
  variables = {
    ansible_user                 = var.ansible_user
    ansible_ssh_private_key_file = var.ansible_ssh_key
    ansible_python_interpreter   = var.ansible_python
  }
  depends_on = [time_sleep.wait_20_seconds]
}

resource "terraform_data" "ansible_inventory" {
  provisioner "local-exec" {
    command = "ansible-inventory -i ../ansible/inventory.yml --graph --vars"
  }
  depends_on = [ansible_host.droplet_instance]
}

resource "terraform_data" "ansible_playbook" {
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory.yml ../ansible/playbook.yml"
  }
  depends_on = [terraform_data.ansible_inventory]
}