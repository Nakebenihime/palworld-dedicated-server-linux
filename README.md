# palworld-dedicated-server-linux

Deploy a [Palworld](https://www.pocketpair.jp/palworld) dedicated server on
Linux in one command, using **Terraform** (provision the server) and
**Ansible** (configure the OS and the game).

```bash
make deploy PROVIDER=digitalocean
```

The project is built to be extended by the community:

- **Cloud providers are pluggable** — each one is a self-contained directory
  under [`terraform/providers/`](terraform/providers/). DigitalOcean ships
  ready to use; adding Hetzner, OVH, AWS... means copying the
  [`_template`](terraform/providers/_template/) directory and filling in the
  TODOs. See [CONTRIBUTING.md](CONTRIBUTING.md).
- **Linux distributions are pluggable** — Debian 12 and Ubuntu 22.04/24.04
  are supported out of the box; the Ansible roles select distro-specific
  vars/tasks at runtime, so new distributions are additive files, not edits.

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
dynamic inventory plugin. No IP copy-pasting, no generated files, and each
tool can be run (and re-run) on its own.

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | >= 1.6 | |
| [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) | core >= 2.15 | `pipx install ansible` |
| GNU make | any | |
| An account at a supported provider | | see `make list-providers` |

## Quickstart (DigitalOcean)

1. **SSH key** — create one and upload the public key to DigitalOcean
   (*Settings → Security → SSH keys*) under the name `palworld-pub-key`:

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
   ```

2. **API token** — create a
   [personal access token](https://docs.digitalocean.com/reference/api/create-personal-access-token/)
   with write scope and export it (never commit it):

   ```bash
   export TF_VAR_do_token="dop_v1_..."
   ```

3. **Set the game passwords** (required — the deploy fails fast without them)
   in [`ansible/group_vars/palworld.yml`](ansible/group_vars/palworld.yml):

   ```yaml
   palworld_server_password: "..."   # players need this to join
   palworld_admin_password: "..."    # admin/RCON password
   ```

   Generate strong ones with `openssl rand -base64 15`. To knowingly run a
   public password-less server, set `palworld_allow_empty_passwords: true`
   instead.

4. **Deploy:**

   ```bash
   make deploy PROVIDER=digitalocean
   ```

5. **Play** — get the IP with `make output PROVIDER=digitalocean`, then
   connect in-game to `<ip>:8211`.

Optional tuning: copy
[`terraform/providers/digitalocean/terraform.tfvars.example`](terraform/providers/digitalocean/terraform.tfvars.example)
to `terraform.tfvars` in the same directory (region, droplet size, image —
`debian-12-x64` or `ubuntu-24-04-x64`...).

## Everyday usage

| Command | Effect |
|---------|--------|
| `make help` | list all targets |
| `make list-providers` | list available providers |
| `make plan PROVIDER=<p>` | preview infrastructure changes |
| `make provision PROVIDER=<p>` | create/update the server (terraform apply) |
| `make configure PROVIDER=<p>` | (re-)run the Ansible configuration — day-2 changes |
| `make deploy PROVIDER=<p>` | provision + configure |
| `make output PROVIDER=<p>` | show server IP / name |
| `make destroy PROVIDER=<p>` | tear everything down |
| `make forget-host PROVIDER=<p>` | drop the server's SSH key from known_hosts |
| `make lint` | run every linter CI runs |
| `make test` | run the Terraform tests (mocked providers, no credentials) |

Changing game settings later: edit `ansible/group_vars/palworld.yml`, then
`make configure` — the palworld role re-renders the config and restarts the
service (via handlers) only when something actually changed.

> **Always run make from the repository root.** The dynamic inventory
> resolves its `project_path` relative to the working directory.

## Configuration reference

All user-facing knobs live in
[`ansible/group_vars/palworld.yml`](ansible/group_vars/palworld.yml)
(passwords, server name, gameplay tweaks via `palworld_settings_overrides`,
firewall rules, backup retention). The full catalogs with defaults:

| Area | File |
|------|------|
| Gameplay settings (~60 keys), systemd limits, backups, paths | [`ansible/roles/palworld/defaults/main.yml`](ansible/roles/palworld/defaults/main.yml) |
| Firewall policies & rules | [`ansible/roles/firewall/defaults/main.yml`](ansible/roles/firewall/defaults/main.yml) |
| Steam user | [`ansible/roles/steamcmd/defaults/main.yml`](ansible/roles/steamcmd/defaults/main.yml) |
| OS preparation | [`ansible/roles/common/defaults/main.yml`](ansible/roles/common/defaults/main.yml) |
| Infrastructure (region, size, image, SSH key name) | `terraform/providers/<name>/terraform.tfvars.example` |

Gameplay keys map 1:1 to the official
[PalWorldSettings.ini options](https://tech.palworldgame.com/optimize-game-balance)
(`exp_rate` → `ExpRate`, ...).

### Service & maintenance behavior

- The game runs as the unprivileged `steam` user under systemd
  (`palworld.service`), restarted automatically on crash and every 4h
  (`runtime_max_sec`) to mitigate the server's memory leak.
- Before every start, `palworld-maintenance.sh` updates the server via
  steamcmd and archives the save data to `~steam/palworld_backups/`
  (retention: `palworld_backup_retention_days`, default 5 days).
- Restoring a backup: stop the service, extract the archive over
  `.../PalServer/Pal/Saved`, start the service.

```bash
ssh root@<server-ip>
systemctl status palworld     # logs: journalctl -u palworld
```

## Security posture

- **Credentials**: cloud tokens are `sensitive = true` Terraform variables,
  supplied via `TF_VAR_*` env vars or git-ignored `*.tfvars`.
- **SSH**: key-only auth; trust-on-first-use host key checking
  (`StrictHostKeyChecking=accept-new`) — a *changed* host key is a hard
  failure (after destroy/recreate on a recycled IP, run `make forget-host`).
- **Firewall**: default deny inbound; only 22/tcp (SSH) and 8211/udp (game)
  are open. RCON (25575/tcp) stays closed unless you opt in.
- **Game passwords**: the deploy refuses to ship an unprotected server unless
  you explicitly opt out.
- **Runtime user**: the game runs as a locked, unprivileged `steam` user.

## Extending the project

- **New cloud provider** (Hetzner, OVH, ...): copy
  [`terraform/providers/_template/`](terraform/providers/_template/), fill in
  the numbered TODOs, done — the Makefile and CI pick it up automatically.
  Full guide: [CONTRIBUTING.md](CONTRIBUTING.md) · interface:
  [docs/provider-contract.md](docs/provider-contract.md).
- **New distribution** (Fedora, ...): add per-role `vars/` + `tasks/` files
  keyed on `ansible_os_family` — no shared code changes. Guide:
  [CONTRIBUTING.md](CONTRIBUTING.md).

## FAQ

**Can I run Ansible/Terraform directly instead of make?**
Yes — from the repository root:
`terraform -chdir=terraform/providers/digitalocean apply` and
`ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i terraform/providers/digitalocean/inventory.yml ansible/playbook.yml`.

**Upgrading from the pre-modular layout?**
The Terraform layout and resource addresses changed. Destroy the old
deployment with your **old** checkout (`terraform destroy` in the old
`terraform/` directory) before deploying with this version — or move your
state manually if you must keep the server (`terraform state mv`, advanced).

**How do I transfer a world to a new server?**
Back up on the old server (the maintenance script already does this on every
service start), copy the archive, extract over `.../PalServer/Pal/Saved` on
the new one, restart.

**Where is the Terraform state stored?**
Locally in `terraform/providers/<name>/` (git-ignored). Remote backends are
supported — see
[docs/provider-contract.md](docs/provider-contract.md#remote-state).

## License

[MIT](LICENSE)
