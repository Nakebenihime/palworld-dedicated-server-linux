# Unit tests for the DigitalOcean provider (plan mode, mocked provider — no
# account or token needed). Run with: terraform test

mock_provider "digitalocean" {
  mock_data "digitalocean_ssh_key" {
    defaults = {
      id   = 12345678
      name = "palworld-pub-key"
    }
  }
}

variables {
  do_token = "mock-token-never-used"
}

run "creates_droplet_with_supported_defaults" {
  command = plan

  assert {
    condition     = digitalocean_droplet.palworld.image == "debian-12-x64"
    error_message = "Default image must be a distribution supported by the Ansible roles (debian-12-x64)"
  }

  assert {
    condition     = digitalocean_droplet.palworld.region == "ams3"
    error_message = "Default region must be ams3"
  }

  assert {
    condition     = digitalocean_droplet.palworld.size == "s-4vcpu-8gb-amd"
    error_message = "Default size must provide ~8 GB RAM (s-4vcpu-8gb-amd)"
  }

  assert {
    condition     = digitalocean_droplet.palworld.backups == false
    error_message = "Paid droplet backups must be off by default"
  }

  assert {
    condition     = contains(digitalocean_droplet.palworld.tags, "palworld")
    error_message = "Droplet must carry the 'palworld' tag"
  }

  assert {
    condition     = length(digitalocean_droplet.palworld.ssh_keys) == 1
    error_message = "Exactly one SSH key (the uploaded account key) must be injected"
  }

  assert {
    condition     = digitalocean_project.palworld.name == "palworld-dedicated-server"
    error_message = "Default project name must be palworld-dedicated-server"
  }
}

run "fulfils_the_provider_contract" {
  command = plan

  assert {
    condition     = output.server_name == "palworld-dedicated-server"
    error_message = "Contract output server_name must expose the droplet name"
  }
}

run "honors_custom_variables" {
  command = plan

  variables {
    droplet_name   = "palworld-eu"
    droplet_image  = "ubuntu-24-04-x64"
    droplet_region = "fra1"
    droplet_size   = "s-2vcpu-4gb"
    droplet_tags   = ["palworld", "testing"]
    ssh_key_name   = "my-own-key"
  }

  assert {
    condition     = digitalocean_droplet.palworld.name == "palworld-eu"
    error_message = "Custom droplet_name must be honored"
  }

  assert {
    condition     = digitalocean_droplet.palworld.image == "ubuntu-24-04-x64"
    error_message = "Ubuntu image slugs must be usable"
  }

  assert {
    condition     = digitalocean_droplet.palworld.region == "fra1"
    error_message = "Custom droplet_region must be honored"
  }

  assert {
    condition     = contains(digitalocean_droplet.palworld.tags, "testing")
    error_message = "Custom droplet_tags must be honored"
  }

  assert {
    condition     = output.server_name == "palworld-eu"
    error_message = "Contract output server_name must follow the custom droplet_name"
  }
}

run "rejects_an_empty_token" {
  command = plan

  variables {
    do_token = ""
  }

  expect_failures = [
    var.do_token,
  ]
}
