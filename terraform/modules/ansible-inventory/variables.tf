variable "ansible_python" {
  description = "Path to the Python interpreter on the remote host."
  type        = string
  default     = "/usr/bin/python3"
}

variable "ansible_ssh_key" {
  description = "Path to the SSH private key used to connect to the host."
  type        = string
  default     = "~/.ssh/id_ed25519"
}

variable "ansible_user" {
  description = "Remote user Ansible connects as."
  type        = string
  default     = "root"
}

variable "groups" {
  description = "Ansible inventory groups the host belongs to. The playbook targets the 'palworld' group, so keep it in the list."
  type        = list(string)
  default     = ["palworld"]

  validation {
    condition     = contains(var.groups, "palworld")
    error_message = "The groups list must contain 'palworld' — it is the group ansible/playbook.yml targets (see docs/provider-contract.md)."
  }
}

variable "host_ip" {
  description = "Public IPv4 address of the game server. Registered as the Ansible inventory hostname."
  type        = string

  validation {
    condition     = can(cidrhost("${var.host_ip}/32", 0))
    error_message = "host_ip must be a valid IPv4 address (e.g. 203.0.113.10)."
  }
}
