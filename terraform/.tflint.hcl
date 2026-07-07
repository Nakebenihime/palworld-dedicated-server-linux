# Shared tflint configuration for every provider directory:
#   tflint --chdir terraform/providers/<name> --config "$(pwd)/terraform/.tflint.hcl"

tflint {
  required_version = ">= 0.50"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
}
