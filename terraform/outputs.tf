output "droplet_public_ipv4_address" {
  value       = digitalocean_droplet.palworld-droplet.ipv4_address
  description = "The public IP address of your droplet."
}
