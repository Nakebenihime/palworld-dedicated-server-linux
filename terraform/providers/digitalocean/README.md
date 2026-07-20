# DigitalOcean provider

Provisions a single droplet, attaches it to a DigitalOcean project, and
registers it in the Ansible dynamic inventory (group `palworld`).

## Prerequisites

1. A DigitalOcean account and a [personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/) with write scope.
2. An SSH key pair; the **public** key uploaded to DigitalOcean
   (*Settings → Security → SSH keys*) under the name you pass as
   `ssh_key_name` (default: `palworld-pub-key`):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
   ```

## Usage

```bash
export TF_VAR_do_token="dop_v1_..."   # never commit the token

# optional: cp terraform.tfvars.example terraform.tfvars and customize

make deploy PROVIDER=digitalocean     # from the repository root
```

See [`terraform.tfvars.example`](terraform.tfvars.example) for all variables.

## Notes

| Topic | Detail |
|-------|--------|
| Image | `droplet_image` must be a Debian/Ubuntu slug the Ansible roles support (`debian-13-x64`, `ubuntu-26-04-x64`, `ubuntu-24-04-x64`) |
| State | Local to this directory by default; for team use, configure a [remote backend](../../../docs/provider-contract.md#remote-state) |
| Running commands | Always go through the root `Makefile` — `inventory.yml`'s relative `project_path` depends on running from the repo root |
