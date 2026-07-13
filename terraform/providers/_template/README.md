# `_template` — provider skeleton

Starting point for a new cloud provider — intentionally cloud-free (the
server is a `null_resource` placeholder), so it always passes
`terraform validate` in CI and can even be `terraform apply`d locally (free,
no credentials) to test the Terraform → Ansible inventory bridge end-to-end.

## Adding a provider

```bash
cp -r terraform/providers/_template terraform/providers/<name>
```

Then follow the numbered `TODO(n)` comments across `terraform.tf`,
`providers.tf`, `main.tf`, `variables.tf` and `inventory.yml`. The full walkthrough lives in
[CONTRIBUTING.md](../../../CONTRIBUTING.md); the interface you must fulfil is
in [docs/provider-contract.md](../../../docs/provider-contract.md).

## Testing the inventory bridge locally

The bridge is covered by an automated apply-mode test
([`tests/bridge_integration_test.tftest.hcl`](tests/bridge_integration_test.tftest.hcl))
that runs in CI and via `make test` — free, local, no credentials.

To additionally see the Ansible side read the inventory:

```bash
terraform -chdir=terraform/providers/_template init
terraform -chdir=terraform/providers/_template apply -auto-approve
ansible-inventory -i terraform/providers/_template/inventory.yml --graph
# expect: group 'palworld' containing 192.0.2.1
terraform -chdir=terraform/providers/_template destroy -auto-approve
```
