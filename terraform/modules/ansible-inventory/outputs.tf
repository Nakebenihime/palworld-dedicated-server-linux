output "groups" {
  description = "Ansible inventory groups the host was registered in."
  value       = ansible_host.server.groups
}

output "host_ip" {
  description = "IP address registered in the Ansible inventory."
  value       = ansible_host.server.name
}
