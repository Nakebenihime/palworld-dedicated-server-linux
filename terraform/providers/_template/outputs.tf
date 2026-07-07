# Provider contract outputs — every provider root must expose exactly these
# names (see docs/provider-contract.md). Wire them through the locals in
# main.tf; the output blocks themselves never change.

output "server_ipv4" {
  description = "Public IPv4 address of the Palworld server."
  value       = local.server_ipv4
}

output "server_name" {
  description = "Human-readable name of the server instance."
  value       = local.server_name
}
