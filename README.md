# palworld-dedicated-server-linux

Deploy a [Palworld](https://www.pocketpair.jp/palworld) dedicated server on
Linux in one command, using **Terraform** (provision the server) and
**Ansible** (configure the OS and the game).

```bash
make deploy PROVIDER=<name>
```

The project is built to be extended by the community:

| Layer | Pluggability |
|-------|--------------|
| Cloud providers | Self-contained directory under [`terraform/providers/`](terraform/providers/). DigitalOcean ships ready to use; add Hetzner/OVH/AWS by copying [`_template`](terraform/providers/_template/) and filling in the TODOs — see [CONTRIBUTING.md](CONTRIBUTING.md) |
| Linux distributions | Debian 13 and Ubuntu 22.04/24.04/26.04 supported out of the box; the Ansible roles select distro-specific vars/tasks at runtime, so new distros are additive files, not edits |

## How it works

```text
                make deploy PROVIDER=<name>
                     │
        ┌────────────┴─────────────┐
        ▼ make provision           ▼ make configure
  terraform apply            ansible-playbook
  terraform/providers/<name>       │ reads the dynamic inventory
        │                          │ (cloud.terraform plugin ← terraform state)
        │ creates the VM +         ▼
        │ registers it in the    roles: common → steamcmd → firewall → palworld
        └─► ansible inventory    (OS prep) (installer)    (ufw)  (game+systemd)
```

Terraform and Ansible stay decoupled: Terraform writes an `ansible_host`
resource into its state (via the shared
[`ansible-inventory` module](terraform/modules/ansible-inventory/)), and
Ansible reads it back through the
[`cloud.terraform.terraform_provider`](https://github.com/ansible-collections/cloud.terraform)
dynamic inventory plugin — no IP copy-pasting, no generated files, and each
tool runs (and re-runs) on its own.

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.6 | |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) | core >= 2.15 | `pipx install ansible` |
| GNU make | any | |
| An account at a supported provider | | see `make list-providers` |

## Quickstart

1. **Pick a provider** and follow its README to set up credentials:

   ```bash
   make list-providers
   ```

   | Provider | README |
   |----------|--------|
   | DigitalOcean | [`terraform/providers/digitalocean/README.md`](terraform/providers/digitalocean/README.md) |

2. **Set the game passwords** (required — the deploy fails fast without them):

   **Option A — via `make` (recommended):**

   ```bash
   eval $(make gen-passwords)
   ```

   **Option B — manually:**

   ```bash
   export PALWORLD_SERVER_PASSWORD="$(openssl rand -base64 15)"
   export PALWORLD_ADMIN_PASSWORD="$(openssl rand -base64 15)"
   ```

   | Variable | Purpose |
   |----------|---------|
   | `PALWORLD_SERVER_PASSWORD` | Players need this to join |
   | `PALWORLD_ADMIN_PASSWORD` | Admin/RCON password |

   Read by
   [`ansible/group_vars/palworld/palworld.yml`](ansible/group_vars/palworld/palworld.yml)
   at deploy time (swap for `ansible-vault` if you prefer). Set
   `palworld_allow_empty_passwords: true` there to run password-less.

3. **Deploy:**

   ```bash
   make deploy PROVIDER=<name>
   ```

4. **Play** — get the server IP with `make output PROVIDER=<name>`, then
   connect in-game to `<ip>:8211`.

## Everyday usage

| Command | Effect |
|---------|--------|
| `make help` | list all targets |
| `make list-providers` | list available providers |
| `make deps` | install the required Ansible collections |
| `make init PROVIDER=<p>` | initialize Terraform for the selected provider |
| `make plan PROVIDER=<p>` | preview infrastructure changes |
| `make provision PROVIDER=<p>` | create/update the server (terraform apply) |
| `make configure PROVIDER=<p>` | (re-)run the Ansible configuration — day-2 changes |
| `make deploy PROVIDER=<p>` | provision + configure |
| `make output PROVIDER=<p>` | show server IP / name |
| `make destroy PROVIDER=<p>` | tear everything down |
| `make forget-host PROVIDER=<p>` | drop the server's SSH key from known_hosts |
| `make gen-passwords` | generate random server and admin passwords |
| `make fmt` | format all Terraform code |
| `make lint` | run every linter CI runs |
| `make test` | run the Terraform tests (mocked providers, no credentials) |

Changing game settings later: edit the files in `ansible/group_vars/palworld/`, then
`make configure` — the palworld role re-renders the config and restarts the
service (via handlers) only when something actually changed.

> **Always run make from the repository root.** The dynamic inventory
> resolves its `project_path` relative to the working directory.

## Configuration reference

All user-facing knobs live in
[`ansible/group_vars/palworld/`](ansible/group_vars/palworld/) — one file per
role: `palworld.yml` (passwords, server name, gameplay tweaks via
`palworld_settings_overrides`, backup retention), `firewall.yml` (SSH port,
inbound rules), `steamcmd.yml` (steam user) and `common.yml` (OS preparation).
The full catalogs with defaults:

| Area | Reference |
|------|-----------|
| Game settings (115 keys, descriptions, types, defaults) | [`docs/palworld-settings.md`](docs/palworld-settings.md) |
| Systemd limits, backups, paths, service behavior | [`ansible/roles/palworld/defaults/main.yml`](ansible/roles/palworld/defaults/main.yml) |
| Firewall policies & rules | [`ansible/roles/firewall/defaults/main.yml`](ansible/roles/firewall/defaults/main.yml) |
| Steam user | [`ansible/roles/steamcmd/defaults/main.yml`](ansible/roles/steamcmd/defaults/main.yml) |
| OS preparation | [`ansible/roles/common/defaults/main.yml`](ansible/roles/common/defaults/main.yml) |
| Infrastructure (region, size, image, SSH key name) | `terraform/providers/<name>/README.md` and `terraform.tfvars.example` |

### Service & maintenance behavior

| Aspect | Behavior |
|--------|----------|
| Process | Runs as the unprivileged `steam` user under systemd (`palworld.service`); auto-restarts on crash and every 4h (`runtime_max_sec`) to mitigate the server's memory leak |
| Backups | `palworld-maintenance.sh` updates via steamcmd and archives saves to `~steam/palworld_backups/` before every start (retention: `palworld_backup_retention_days`, default 5 days) |
| Restore | Stop the service, extract the archive over `.../PalServer/Pal/Saved`, start the service |

```bash
ssh root@<server-ip>
systemctl status palworld     # logs: journalctl -u palworld
```

## Security posture

| Area | Posture |
|------|---------|
| Credentials | Cloud tokens are `sensitive = true` Terraform variables, supplied via `TF_VAR_*` env vars or git-ignored `*.tfvars` |
| SSH | Key-only auth; trust-on-first-use host key checking (`StrictHostKeyChecking=accept-new`) — a *changed* host key is a hard failure (run `make forget-host` after destroy/recreate on a recycled IP) |
| Firewall | Default deny inbound; only 22/tcp (SSH) and 8211/udp (game) are open. RCON (25575/tcp) stays closed unless you opt in |
| Game passwords | The deploy refuses to ship an unprotected server unless you explicitly opt out |
| Runtime user | The game runs as a locked, unprivileged `steam` user |

## Extending the project

| To add | How |
|--------|-----|
| A cloud provider (Hetzner, OVH, ...) | Copy [`terraform/providers/_template/`](terraform/providers/_template/), fill in the numbered TODOs — the Makefile and CI pick it up automatically. Guide: [CONTRIBUTING.md](CONTRIBUTING.md) · interface: [docs/provider-contract.md](docs/provider-contract.md) |
| A distribution (Fedora, ...) | Add per-role `vars/` + `tasks/` files keyed on `ansible_os_family` — no shared code changes. Guide: [CONTRIBUTING.md](CONTRIBUTING.md) |

## FAQ

| Question | Answer |
|----------|--------|
| Can I run Ansible/Terraform directly instead of `make`? | Yes — see the provider's README for the exact paths, or run `make help` to see how the Makefile composes the commands |
| Upgrading from the pre-modular layout? | Terraform addresses changed — `terraform destroy` with your **old** checkout first, or migrate state manually with `terraform state mv` |
| How do I transfer a world to a new server? | Back up on the old server (the maintenance script does this on every start), copy the archive, extract over `.../PalServer/Pal/Saved` on the new one, restart |
| Where is the Terraform state stored? | Locally in `terraform/providers/<name>/` (git-ignored); remote backends are supported — see [Remote state](docs/provider-contract.md#remote-state) |

## License

[MIT](LICENSE)
