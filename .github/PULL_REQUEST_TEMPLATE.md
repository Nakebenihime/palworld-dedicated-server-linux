# Description

<!-- What does this PR change and why? -->

## Type of change

- [ ] Bug fix
- [ ] New cloud provider (`terraform/providers/<name>/`)
- [ ] New distribution support (role `vars/` + `tasks/` files)
- [ ] Feature / enhancement
- [ ] Documentation

## Checklist

- [ ] `make lint` passes locally (terraform fmt/validate, tflint, ansible-lint, yamllint)
- [ ] `make test` passes locally (terraform tests, mocked — no credentials needed)
- [ ] No credentials or secrets committed (`sensitive = true` variables, `TF_VAR_*` documented)
- [ ] Documentation updated (README / provider README / CONTRIBUTING)

### For new providers only

- [ ] Fulfils the [provider contract](../docs/provider-contract.md): `server_ipv4` + `server_name` outputs, `ansible_inventory` module call, standard connection variables
- [ ] `inventory.yml` `project_path` points at the new directory
- [ ] `terraform.tfvars.example` and `README.md` included
- [ ] Tested end-to-end with `make deploy PROVIDER=<name>`

### For new distributions only

- [ ] `vars`/`tasks` files added per role (see CONTRIBUTING table); no shared task files modified
- [ ] Role `meta/main.yml` platforms updated
- [ ] Tested end-to-end against a real server running the distribution
