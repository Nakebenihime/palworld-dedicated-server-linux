variable "ansible_python" {
  description = "Path to the Python interpreter on the remote host."
  type        = string
  default     = "/usr/bin/python3"
}

variable "ansible_ssh_key" {
  description = "Path to the SSH private key used by Ansible."
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ansible_user" {
  description = "Remote user Ansible connects as."
  type        = string
  default     = "root"
}

variable "do_token" {
  description = "DigitalOcean personal access token. Never commit it: export TF_VAR_do_token=... or use an un-committed *.tfvars file."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.do_token) > 0
    error_message = "do_token must not be empty. Export TF_VAR_do_token=<your DigitalOcean personal access token>."
  }
}

variable "droplet_backups" {
  description = "Enable DigitalOcean droplet backups (extra cost)."
  type        = bool
  default     = false
}

variable "droplet_image" {
  description = "Droplet OS image slug. Supported by the Ansible roles: debian-13-x64, ubuntu-26-04-x64, ubuntu-24-04-x64, ubuntu-22-04-x64."
  type        = string
  default     = "debian-13-x64"
}

variable "droplet_name" {
  description = "Droplet name."
  type        = string
  default     = "palworld-dedicated-server"
}

variable "droplet_region" {
  description = "Droplet region slug (e.g. ams3, fra1, nyc1)."
  type        = string
  default     = "ams3"
}

variable "droplet_size" {
  description = "Droplet size slug. Palworld needs ~8 GB of RAM."
  type        = string
  default     = "s-4vcpu-8gb-amd"
}

variable "droplet_tags" {
  description = "Tags applied to the droplet."
  type        = list(string)
  default     = ["palworld", "game-server"]
}

variable "project_description" {
  description = "DigitalOcean project description."
  type        = string
  default     = "Palworld dedicated server provisioned with Terraform and configured with Ansible."
}

variable "project_name" {
  description = "DigitalOcean project name."
  type        = string
  default     = "palworld-dedicated-server"
}

variable "project_purpose" {
  description = "DigitalOcean project purpose."
  type        = string
  default     = "Palworld dedicated server to play with my friends"
}

variable "ssh_key_name" {
  description = "Name of the SSH public key already uploaded to your DigitalOcean account (Settings > Security). Its private counterpart must match var.ansible_ssh_key."
  type        = string
  default     = "palworld-pub-key"
}
