# Unit tests for the ansible-inventory module (plan mode, mocked provider —
# no credentials needed). Run with: terraform test

mock_provider "ansible" {}

variables {
  host_ip = "192.0.2.10"
}

run "registers_host_with_defaults" {
  command = plan

  assert {
    condition     = ansible_host.server.name == "192.0.2.10"
    error_message = "Inventory hostname must be the host_ip passed to the module"
  }

  assert {
    condition     = contains(ansible_host.server.groups, "palworld")
    error_message = "Host must be registered in the 'palworld' group targeted by ansible/playbook.yml"
  }

  assert {
    condition     = ansible_host.server.variables["ansible_user"] == "root"
    error_message = "Default connection user must be root"
  }

  assert {
    condition     = ansible_host.server.variables["ansible_ssh_private_key_file"] == "~/.ssh/id_ed25519"
    error_message = "Default SSH key path must be ~/.ssh/id_ed25519"
  }

  assert {
    condition     = ansible_host.server.variables["ansible_python_interpreter"] == "/usr/bin/python3"
    error_message = "Default Python interpreter must be /usr/bin/python3"
  }
}

run "honors_custom_connection_settings" {
  command = plan

  variables {
    ansible_user    = "deploy"
    ansible_ssh_key = "~/.ssh/palworld_ed25519"
    ansible_python  = "/usr/local/bin/python3"
    groups          = ["palworld", "eu_servers"]
  }

  assert {
    condition     = ansible_host.server.variables["ansible_user"] == "deploy"
    error_message = "Custom ansible_user must be passed through to the inventory"
  }

  assert {
    condition     = ansible_host.server.variables["ansible_ssh_private_key_file"] == "~/.ssh/palworld_ed25519"
    error_message = "Custom SSH key path must be passed through to the inventory"
  }

  assert {
    condition     = ansible_host.server.variables["ansible_python_interpreter"] == "/usr/local/bin/python3"
    error_message = "Custom Python interpreter must be passed through to the inventory"
  }

  assert {
    condition     = length(ansible_host.server.groups) == 2 && contains(ansible_host.server.groups, "palworld")
    error_message = "Custom group lists must be honored while keeping the 'palworld' group"
  }
}

run "rejects_invalid_host_ip" {
  command = plan

  variables {
    host_ip = "not-an-ip-address"
  }

  expect_failures = [
    var.host_ip,
  ]
}

run "rejects_groups_missing_the_palworld_group" {
  command = plan

  variables {
    groups = ["eu_servers"]
  }

  expect_failures = [
    var.groups,
  ]
}
