# Provider contract outputs — every provider root must expose these names.
# See docs/provider-contract.md.

output "server_ipv4" {
  description = "Public IPv4 address of the Palworld server."
  value       = digitalocean_droplet.palworld.ipv4_address
}

output "server_name" {
  description = "Human-readable name of the server instance."
  value       = digitalocean_droplet.palworld.name
}
