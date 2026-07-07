# Registers the provisioned server in the Terraform state in a form the
# cloud.terraform.terraform_provider dynamic inventory plugin understands.
# Every provider root instantiates this module exactly once — it is the single
# bridge between Terraform (provisioning) and Ansible (configuration), and it
# guarantees the inventory group and connection variable names never drift
# from what ansible/playbook.yml expects.
resource "ansible_host" "server" {
  name   = var.host_ip
  groups = var.groups

  variables = {
    ansible_user                 = var.ansible_user
    ansible_ssh_private_key_file = var.ansible_ssh_key
    ansible_python_interpreter   = var.ansible_python
  }
}
