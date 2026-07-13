# =============================================================================
# Palworld dedicated server — single entry point.
#
#   make deploy PROVIDER=digitalocean    # provision + configure, end to end
#
# Run from the repository root. `make help` lists all targets.
# =============================================================================

PROVIDER ?= digitalocean
TF_DIR    := terraform/providers/$(PROVIDER)
INVENTORY := $(TF_DIR)/inventory.yml
PLAYBOOK  := ansible/deploy-palworld.yml

export ANSIBLE_CONFIG := ansible/ansible.cfg

.DEFAULT_GOAL := help
.PHONY: help list-providers check-provider deps init plan provision configure \
        deploy destroy output lint fmt test forget-host

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make <target> [PROVIDER=<name>]  (default: digitalocean)\n\nTargets:\n"} \
	  /^[a-zA-Z_-]+:.*?##/ {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

list-providers: ## List available providers
	@find terraform/providers -mindepth 1 -maxdepth 1 -type d ! -name '_*' -printf '%f\n' | sort

check-provider:
	@test -d "$(TF_DIR)" || { \
	  echo "error: unknown provider '$(PROVIDER)' ($(TF_DIR) not found)"; \
	  echo "available providers:"; \
	  $(MAKE) --no-print-directory list-providers; \
	  exit 1; }

deps: ## Install the required Ansible collections
	ansible-galaxy collection install -r ansible/requirements.yml

init: check-provider ## Initialize Terraform for the selected provider
	terraform -chdir=$(TF_DIR) init

plan: init ## Show the Terraform execution plan
	terraform -chdir=$(TF_DIR) plan

provision: init ## Create the server (terraform apply)
	terraform -chdir=$(TF_DIR) apply

configure: check-provider deps ## Configure the server (ansible-playbook)
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

deploy: provision configure ## Provision + configure, end to end

destroy: check-provider ## Destroy the server (terraform destroy)
	terraform -chdir=$(TF_DIR) destroy

output: check-provider ## Show Terraform outputs (server IP, name)
	terraform -chdir=$(TF_DIR) output

forget-host: check-provider ## Remove the server's key from known_hosts (after destroy/recreate)
	ssh-keygen -R "$$(terraform -chdir=$(TF_DIR) output -raw server_ipv4)"

test: ## Run terraform tests (mocked/local providers; no credentials needed)
	@set -e; for dir in terraform/modules/*/ terraform/providers/*/; do \
	  if [ -d "$$dir/tests" ]; then \
	    echo "==> terraform test $$dir"; \
	    terraform -chdir=$$dir init -backend=false -input=false > /dev/null; \
	    terraform -chdir=$$dir test; \
	  fi; \
	done

fmt: ## Format all Terraform code
	terraform fmt -recursive terraform/

lint: ## Run all linters (mirrors CI; requires terraform, tflint, ansible-lint, yamllint)
	terraform fmt -check -diff -recursive terraform/
	@set -e; for dir in terraform/providers/*/; do \
	  echo "==> validate $$dir"; \
	  terraform -chdir=$$dir init -backend=false -input=false > /dev/null; \
	  terraform -chdir=$$dir validate; \
	done
	@set -e; for dir in terraform/providers/*/; do \
	  echo "==> tflint $$dir"; \
	  tflint --chdir "$$dir" --config "$(CURDIR)/terraform/.tflint.hcl"; \
	done
	yamllint .
	ansible-lint ansible/
	ansible-playbook --syntax-check -i localhost, $(PLAYBOOK)
