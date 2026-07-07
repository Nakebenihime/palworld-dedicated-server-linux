terraform {
  required_version = ">= 1.6"

  required_providers {
    # TODO(1): replace the null provider with your cloud provider
    # (and configure the provider itself in providers.tf), e.g.:
    #   hcloud = {
    #     source  = "hetznercloud/hcloud"
    #     version = "~> 1.45"
    #   }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}
