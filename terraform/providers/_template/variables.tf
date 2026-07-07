# TODO(5): declare your cloud credentials as sensitive variables with no
# default, and document the TF_VAR_* environment variable in your README:
#   variable "hcloud_token" {
#     description = "Hetzner Cloud API token. Export TF_VAR_hcloud_token=..."
#     type        = string
#     sensitive   = true
#
#     validation {
#       condition     = length(var.hcloud_token) > 0
#       error_message = "hcloud_token must not be empty. Export TF_VAR_hcloud_token=..."
#     }
#   }

# TODO(6): add your provider-specific variables (region, size, image...) with
# sensible defaults, keeping declarations in alphabetical order. Keep the
# image default on a distribution supported by the Ansible roles (Debian 12,
# Ubuntu 22.04/24.04).

# --- ansible connection (provider contract — keep these as-is) -----------------

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
