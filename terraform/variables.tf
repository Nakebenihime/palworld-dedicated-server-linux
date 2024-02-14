# project variables
variable "project_name" {
  description = "Project name"
  default     = "palworld-linux-dedicated-server-project"
  type        = string
}

variable "project_description" {
  description = "Project description"
  default     = "Palworld Dedicated Server on a Digital Ocean Droplet with Debian 12"
  type        = string
}

variable "project_purpose" {
  description = "Project purpose"
  default     = "Palworld Dedicated Server to play with my friends"
  type        = string
}

# droplet variables
variable "droplet_name" {
  description = "Droplet name"
  default     = "palworld-dedicated-server-droplet"
  type        = string
}
variable "droplet_image" {
  description = "Droplet OS image identifier"
  default     = "debian-12-x64"
  type        = string
}
variable "droplet_region" {
  description = "Droplet region identifier"
  default     = "ams3"
  type        = string
}
variable "droplet_size" {
  description = "Droplet size identifier"
  default     = "s-4vcpu-8gb-amd"
  type        = string
}
variable "droplet_tags" {
  description = "Tags for the DigitalOcean Droplet"
  default     = ["palword", "debian"]
  type        = list(string)
}
variable "droplet_backups" {
  description = "Droplet Backups"
  default     = false
  type        = bool
}
variable "ansible_user" {
  type        = string
  description = "Ansible user used to connect to the instance"
  default     = "root"
}

variable "ansible_ssh_key" {
  type        = string
  description = "Path to the SSH key file associated with the ansible_user"
  default     = "~/.ssh/id_ed25519"
}

variable "ansible_python" {
  type        = string
  description = "Path to python executable that Ansible should use"
  default     = "/usr/bin/python3"
}
