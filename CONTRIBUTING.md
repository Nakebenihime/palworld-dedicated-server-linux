# Contributing

Thanks for helping make this project work on more clouds and more Linux
distributions! The architecture is designed so that both kinds of
contribution are **additive**: you create new files in a well-defined place
and never touch shared code.

- Cloud providers live in `terraform/providers/<name>/` (one directory = one provider).
- Distribution support lives inside the Ansible roles as `vars/` + `tasks/` files
  selected at runtime from `ansible_distribution` / `ansible_os_family` facts.

CI discovers new provider directories automatically — there is nothing to
register anywhere.

## Adding a cloud provider (Hetzner, OVH, AWS, ...)

1. **Copy the template:**

   ```bash
   cp -r terraform/providers/_template terraform/providers/<name>
   ```

2. **Follow the numbered `TODO(n)` comments** in `terraform.tf`, `providers.tf`,
   `main.tf`, `variables.tf` and `inventory.yml`:
   - pin your cloud provider in `terraform.tf` and configure it in `providers.tf`;
   - declare credentials as `sensitive = true` variables with no default;
   - replace the `null_resource` placeholder with your server resource;
   - point the `locals` (`server_ipv4`, `server_name`) at your resource's attributes;
   - set `project_path: terraform/providers/<name>` in `inventory.yml`.

3. **Do not touch** the `module "ansible_inventory"` wiring or the
   `outputs.tf` block — they implement the
   [provider contract](docs/provider-contract.md) that keeps providers
   interchangeable.

4. **Add the user-facing files**: `terraform.tfvars.example` (every variable,
   commented) and `README.md` (account prerequisites, token creation, SSH key
   upload, usage). Use `terraform/providers/digitalocean/` as the reference
   implementation.

5. **Pick a supported default image**: the Ansible roles currently support
   Debian 13 and Ubuntu 22.04/24.04/26.04.

6. **Write credential-free tests** in `tests/*_unit_test.tftest.hcl`: declare a
   `mock_provider` for your cloud and assert your defaults and the contract
   outputs in plan mode. Use
   `terraform/providers/digitalocean/tests/defaults_unit_test.tftest.hcl` as
   the reference — CI runs `terraform test` in every provider directory that
   has a `tests/` folder.

7. **Validate:**

   ```bash
   make lint                              # fmt + validate + tflint + ansible/yaml lint
   make test                              # terraform tests (mocked, no credentials)
   make plan PROVIDER=<name>              # with your real credentials
   make deploy PROVIDER=<name>            # full end-to-end test
   ```

That's it — no Makefile, playbook, or CI changes needed.

## Adding a Linux distribution (Fedora, openSUSE, ...)

Distro-specific behavior is isolated in per-role `vars/` and `tasks/` files,
selected at runtime by this lookup chain (most to least specific):

```text
vars/<Distribution>-<major_version>.yml   e.g. vars/Fedora-40.yml
vars/<Distribution>.yml                   e.g. vars/Fedora.yml
vars/<os_family>.yml                      e.g. vars/RedHat.yml
```

and `tasks/setup-<os_family>.yml` / `tasks/install-<os_family>.yml`.
(Debian and Ubuntu both resolve to os_family `Debian`, which is why they
share task files but have their own vars.)

For a new distribution family (e.g. RedHat), add to each role:

| Role | Files to add | What they must provide |
|------|--------------|------------------------|
| `common` | `vars/RedHat.yml`, `tasks/setup-RedHat.yml` | package upgrade, extra repos (e.g. EPEL/rpmfusion), any multi-arch setup |
| `steamcmd` | `vars/RedHat.yml`, `tasks/install-RedHat.yml` | `steamcmd_binary` path + an install method (no RPM package exists — a tarball install into the steam user's home is the usual approach) |
| `firewall` | `vars/RedHat.yml`, `tasks/firewalld.yml` | `firewall_backend: firewalld` + tasks honoring `firewall_default_policies` / `firewall_rules` |
| `palworld` | usually nothing | it is distro-agnostic (systemd + paths derived from the vars above) |

Then update each role's `meta/main.yml` platforms list, and test:

```bash
ansible-playbook --syntax-check -i localhost, ansible/playbook.yml
ansible-lint ansible/
make deploy PROVIDER=<any> # against a server running your distro
```

If your target distribution needs a different *image* on an existing cloud
provider, that's just a variable (e.g. `droplet_image`) — no code change.

## Development guidelines

- Run `make lint` before opening a PR; CI runs the same checks.
- Keep credentials out of the repo: `sensitive = true` variables, `TF_VAR_*`
  env vars, git-ignored `*.tfvars`.
- Pin versions: Terraform providers with `~>`, Ansible collections in
  `ansible/requirements.yml`.
- Ansible: fully-qualified module names (`ansible.builtin.*`), role-prefixed
  variable names (`palworld_*`, `firewall_*`, ...), handlers for service
  restarts.
- One logical change per pull request.

## Reporting issues

Use the issue templates: bug report, feature request, or "new provider /
distribution request".
