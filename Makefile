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

help:
	@printf 'Usage: make <target> [PROVIDER=<name>]  (default: digitalocean)\n\nTargets (documented in README.md):\n'
	@awk -F: '/^[a-zA-Z_-]+:([^=]|$$)/ && !/^check-provider/ {print "  " $$1}' $(MAKEFILE_LIST)

list-providers:
	@find terraform/providers -mindepth 1 -maxdepth 1 -type d ! -name '_*' -printf '%f\n' | sort

check-provider:
	@test -d "$(TF_DIR)" || { \
	  echo "error: unknown provider '$(PROVIDER)' ($(TF_DIR) not found)"; \
	  echo "available providers:"; \
	  $(MAKE) --no-print-directory list-providers; \
	  exit 1; }

deps:
	ansible-galaxy collection install -r ansible/requirements.yml

init: check-provider
	terraform -chdir=$(TF_DIR) init

plan: init
	terraform -chdir=$(TF_DIR) plan

provision: init
	terraform -chdir=$(TF_DIR) apply

configure: check-provider deps
	ansible-playbook -i $(INVENTORY) $(PLAYBOOK)

deploy: provision configure

destroy: check-provider
	terraform -chdir=$(TF_DIR) destroy

output: check-provider
	terraform -chdir=$(TF_DIR) output

forget-host: check-provider
	ssh-keygen -R "$$(terraform -chdir=$(TF_DIR) output -raw server_ipv4)"

test:
	@set -e; for dir in terraform/modules/*/ terraform/providers/*/; do \
	  if [ -d "$$dir/tests" ]; then \
	    echo "==> terraform test $$dir"; \
	    terraform -chdir=$$dir init -backend=false -input=false > /dev/null; \
	    terraform -chdir=$$dir test; \
	  fi; \
	done

fmt:
	terraform fmt -recursive terraform/

lint:
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
