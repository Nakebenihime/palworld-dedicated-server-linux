# Integration test for the Terraform -> Ansible inventory bridge (apply mode).
# The template only contains a null_resource and the logical ansible_host, so
# this applies REAL providers without any cloud account, credentials or cost —
# proving the exact wiring every real provider reuses.
# Run with: terraform test

run "placeholder_fulfils_the_provider_contract" {
  command = apply

  assert {
    condition     = output.server_ipv4 == "192.0.2.1"
    error_message = "Contract output server_ipv4 must expose the placeholder address"
  }

  assert {
    condition     = output.server_name == "palworld-server-placeholder"
    error_message = "Contract output server_name must expose the placeholder name"
  }
}

run "registers_the_server_in_the_ansible_inventory" {
  command = apply

  assert {
    condition     = module.ansible_inventory.host_ip == output.server_ipv4
    error_message = "The inventory host must be the server's public IPv4"
  }

  assert {
    condition     = contains(module.ansible_inventory.groups, "palworld")
    error_message = "The server must be registered in the 'palworld' inventory group"
  }
}
