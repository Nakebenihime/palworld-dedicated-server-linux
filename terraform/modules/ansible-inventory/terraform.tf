terraform {
  required_version = ">= 1.6"

  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.3"
    }
  }
}
