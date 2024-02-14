# Palworld Dedicated Server Setup on DigitalOcean using Terraform and Ansible
This repository streamlines the setup of a dedicated Palworld server on DigitalOcean using Terraform and Ansible.
The server is configured as a systemd service with an automatic restart policy in case of failure, enhancing its resilience.

Moreover, upon each service initiation:
- A steamcmd command is triggered to validate and install any available Palworld updates, guaranteeing the server's currency.
- Game save files are backed up systematically to maintain data integrity.

## Prerequisites
To get started, make sure you have the following tools installed:

1. A DigitalOcean account: Try DigitalOcean for free with a $200 credit. [Welcome to the developer cloud](https://try.digitalocean.com/developerbrand/)
2. Terraform installed on your system: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Ansible installed on your system: [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Technology Stack
Component                           | Technology                                        |                                        
---                                 | ---                                               |
Server Configuration and Automation |[`ansible`](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html), [`terraform`](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)                              | 
Terraform Modules                   |[`digitalocean/digitalocean`](https://registry.terraform.io/providers/digitalocean/digitalocean/latest), [`ansible/ansible`](https://registry.terraform.io/providers/ansible/ansible/latest) |
Ansible Modules                     |[`cloud.terraform`](https://github.com/ansible-collections/cloud.terraform/tree/main)  |
Libraries                           |[`passlib`](https://pypi.org/project/passlib/)                                         |
Infrastructure as a Service         |[`digitalocean`](https://www.digitalocean.com/)                                        |

## Project Structure
Understanding the project structure is crucial for navigating and customizing the Palworld Dedicated Server setup. Here's an overview of the project's directory structure:

```
palworld-dedicated-server-linux
|
*---ansible
|    |
│    *---inventory.yml                             <--(defines host and group for Ansible)
│    *---playbook.yml                              <--(primary Ansible playbook)
│    *---roles                                     <--(directory with specific task roles for Ansible)
│        |
|        *---digitalocean                          <--(specific role for managing resources on DigitalOcean) 
|        |   *---defaults 
|        |      *---main.yml                       <--(default variables for the role)
|        |   *---files
|        |   *---handlers
|        |      *---main.yml                       <--(default handlers for the role)
|        |   *---meta
|        |      *---main.yml
|        |   *---tasks                             <--(directory containing task definitions used by the role) 
|        |      *---ansible_debian.yml             <--(Ansible tasks related to debian configuration)
|        |      *---ansible_palworld.yml           <--(Ansible tasks related to palworld configuration)
|        |      *---ansible_steamcmd.yml           <--(Ansible tasks related to steamcmd configuration)
|        |      *---ansible_ufw_firewall.yml       <--(Ansible tasks related to firewall configuration)
|        |      *---main                           <--(primary Ansible tasks playbook)
|        |   *---templates                         <--(directory containing Jinja2 templates used by the role)
|        |      *---palworld_settings.j2           <--(palworld settings j2 template)
|        |      *---palworld_systemd_service.j2    <--(palworld systemd j2 template)
|        |      *---palworld_maintenance_script.j2 <--(palworld maintenance script j2 template)
|        |   *---tests
|        |      *---inventory
|        |      *---test.yml
|        |   *---vars
|        |      *---main.yml
|        *---requirements.yml                      <--(contains required Ansible Collections)
*---terraform
    |
    *---main.tf                                    <--(primary Terraform configuration) 
    *---outputs.tf                                 <--(defines output values) 
    *---terraform.tfvars                           <--(contains sensitive variables 'not committed') 
    *---variables.tf                               <--(defines Terraform variables)
    *---.terraform.locl.hcl                        <--(defines 'dependencies' versions in Terraform)
```

## Getting Started
1. Clone the application repository using the following command:
```
git clone https://github.com/Nakebenihime/palworld-dedicated-server-linux.git
```

2. Generate an SSH key pair on UNIX and UNIX-like systems:
```
ssh-keygen -b 4096 -t rsa -c "<your_email_address>"
```
3. Import your SSH public key (*.pub) to DigitalOcean:

Import your SSH public key (*.pub) to DigitalOcean by navigating to: Settings >> Security >> SSH Keys >> Add SSH key to the menu that pops up. For more details, refer to [How to add SSH keys in DO](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-team/). Keep in mind the key name used, as it will be useful when configuring Terraform.

4. Generate a Personal Access Token on DigitalOcean with read and write scopes:

Generate a Personal Access Token with read and write scopes by navigating to: API >> Tokens >> Generate New Token. Ensure you add the "write" scope; otherwise, it won't work. For details, see [How to create a Personal Access Token in DO](https://docs.digitalocean.com/reference/api/create-personal-access-token/). Save the key in a secure location, as it will be needed during the Terraform configuration.

### Terraform configuration
1. Create a `terraform.tfvars` file in the `terraform` directory and enter the Personal Access Token generated in the previous section:
```
do_token = "<your_digitalocean_token>"
```

2. In the `terraform/main.tf` file, specify the name of the SSH key you imported into DigitalOcean:
```
data "digitalocean_ssh_key" "terraform" {
  name = "<your_digitalocean_ssh_key_name>"
}
```

3. Customize the `variables.tf` file based on your preferences, requirements, and budget. For example, I've chosen an AMD processor with 4 vCPUs located in Amsterdam for my setup and it proved its efficiency by supporting around 3-4 players simultaneously playing. 

```
variable "droplet_size" {
  description = "Droplet size identifier"
  default     = "s-4vcpu-8gb-amd"
  type        = string
}
```

Explore and identify the name of the droplet size and other parameter values using DigitalOcean APIs. [Try the DigitalOcean API (Swagger)](https://docs.digitalocean.com/reference/api/api-try-it-now/#/)


### Ansible configuration
Dynamic inventory allows Ansible to automatically discover and manage your infrastructure. To set up dynamic inventory, key parameters are specified in the  `terraform/variables.tf` file.

1. Examine and adjust the Ansible configuration variables in the `terraform/variables.tf` file to match your environment, for ease, the root user is utilized, as it is the default user generated during droplet instantiation:

```
variable "ansible_user" {
  type        = string
  description = "The Ansible user used to connect to the instance"
  default     = "root"
}

variable "ansible_ssh_key" {
  type        = string
  description = "Path to the SSH key file associated with the Ansible user"
  default     = "~/.ssh/id_ed25519"
}

variable "ansible_python" {
  type        = string
  description = "Path to the Python executable that Ansible should use"
  default     = "/usr/bin/python3"
}
```

2. Use the following command to install the collection dependencies before executing any Ansible tasks:
```
# ~/palworld-dedicated-server-linux/ansible
ansible-galaxy collection install -r roles/requirements.yml --force
```
```
# ~/palworld-dedicated-server-linux/ansible
ansible-galaxy collection list | grep cloud.terraform
cloud.terraform                          2.0.0
```

2. Refer to the `defaults/main.yml` file for customization according to your preferences. (the majority of fields are documented directly in the file)

This can help you tuning your systemd **palworld.service**:
| Parameter                        | Type   | Possible Values                                                                                           |
|--------------------------------|--------|-----------------------------------------------------------------------------------------------------------|
| palworld_advanced_options      | String | "-useperfthreads", "-NoAsyncLoadingThread", "-UseMultithreadForDS"                                                                                                 |
| restart_policy                 | String | "no", "always", "on-success", "on-failure", "on-abnormal", "on-abort", "on-watchdog"                     |
| restart_waiting_policy         | String | Any time duration (e.g., "30s", "1m", "1h")                                                                |
| max_runtime                    | String | Any time duration (e.g., "4h", "2h30m")                                                                    |
| max_memory                     | String | Any memory value (e.g., "7G", "1GB", "500MB")                                                              |

This can help you tuning your **palworld-maintenance.sh** script:
| Parameter                        | Type   | Possible Values                                                                                           |
|--------------------------------|--------|-----------------------------------------------------------------------------------------------------------|
| palworld_backup_directory                    | String | Any string (be careful with permissions)|
| palworld_backup_retention_days                    | Number | Any positive number |                                                                                       |




This can help you tuning your palworld settings (**palworld_settings_options**): 
| Parameter                              | Type     | Possible Values                      |
|----------------------------------------|----------|--------------------------------------|
| difficulty                             | String   | "None", "Easy", "Medium", "Hard"    |
| day_time_speed_rate                    | Number   | Any positive number                  |
| night_time_speed_rate                  | Number   | Any positive number                  |
| exp_rate                               | Number   | Any positive number                  |
| pal_capture_rate                       | Number   | Any positive number                  |
| pal_spawn_num_rate                     | Number   | Any positive number                  |
| pal_damage_rate_attack                 | Number   | Any positive number                  |
| pal_damage_rate_defense                | Number   | Any positive number                  |
| player_damage_rate_attack              | Number   | Any positive number                  |
| player_damage_rate_defense             | Number   | Any positive number                  |
| player_stomach_decrease_rate           | Number   | Any positive number                  |
| player_stamina_decrease_rate           | Number   | Any positive number                  |
| player_auto_hp_regene_rate             | Number   | Any positive number                  |
| player_auto_hp_regene_rate_in_sleep    | Number   | Any positive number                  |
| pal_stomach_decrease_rate              | Number   | Any positive number                  |
| pal_stamina_decrease_rate              | Number   | Any positive number                  |
| pal_auto_hp_regene_rate                | Number   | Any positive number                  |
| pal_auto_hp_regene_rate_in_sleep       | Number   | Any positive number                  |
| build_object_damage_rate               | Number   | Any positive number                  |
| build_object_deterioration_damage_rate | Number   | Any positive number                  |
| collection_drop_rate                   | Number   | Any positive number                  |
| collection_object_hp_rate              | Number   | Any positive number                  |
| collection_object_respawn_speed_rate   | Number   | Any positive number                  |
| enemy_drop_item_rate                   | Number   | Any positive number                  |
| death_penalty                          | String   | "None", "Item", "ItemAndEquipment", "All" |
| b_enable_player_to_player_damage       | Boolean  | true, false                          |
| b_enable_friendly_fire                 | Boolean  | true, false                          |
| b_enable_invader_enemy                 | Boolean  | true, false                          |
| b_active_unko                          | Boolean  | true, false                          |
| b_enable_aim_assist_pad                | Boolean  | true, false                          |
| b_enable_aim_assist_keyboard           | Boolean  | true, false                          |
| drop_item_max_num                      | Number   | Any positive number                  |
| drop_item_max_num_unko                 | Number   | Any positive number                  |
| base_camp_max_num                      | Number   | Any positive number                  |
| base_camp_worker_max_num               | Number   | Any positive number                  |
| drop_item_alive_max_hours              | Number   | Any positive number                  |
| b_auto_reset_guild_no_online_players   | Boolean  | true, false                          |
| auto_reset_guild_time_no_online_players| Number   | Any positive number                  |
| guild_player_max_num                   | Number   | Any positive number                  |
| pal_egg_default_hatching_time          | Number   | Any positive number                  |
| work_speed_rate                        | Number   | Any positive number                  |
| b_is_multiplay                         | Boolean  | true, false                          |
| b_is_pvp                               | Boolean  | true, false                          |
| b_can_pickup_other_guild_death_penalty_drop | Boolean | true, false                      |
| b_enable_non_login_penalty             | Boolean  | true, false                          |
| b_enable_fast_travel                   | Boolean  | true, false                          |
| b_is_start_location_select_by_map      | Boolean  | true, false                          |
| b_exist_player_after_logout            | Boolean  | true, false                          |
| b_enable_defense_other_guild_player    | Boolean  | true, false                          |
| coop_player_max_num                    | Number   | Any positive integer                 |
| server_player_max_num                  | Number   | Any positive integer                 |
| server_name                            | String   | Any string                           |
| server_description                     | String   | Any string                           |
| admin_password                         | String   | Any string                           |
| server_password                        | String   | Any string                           |
| public_port                            | String   | Any string                           |
| public_ip                              | String   | Any string                           |
| rcon_enabled                           | Boolean  | true, false                          |
| rcon_port                              | Number   | Any positive number                  |
| region                                 | String   |                                      |
| b_use_auth                             | Boolean  | true, false                          |
| ban_list_url                           | String   | Any string (URL format)              |

## Usage
### Provisioning Infrastructure and Configuration with Terraform
The initial step is to initialize the Terraform configuration. Utilizing the command `terraform init` accomplishes this by setting up the working directory, downloading essential plugins, and establishing an environment suitable for creating and managing infrastructure through Terraform.
```
#  ~/palworld-dedicated-server-linux/terraform
terraform init
```

The `terraform apply` command is used to apply the changes defined in the Terraform configuration (the `-auto-approve` flag skips the interactive approval prompt, allowing for a fully automated execution of the provisioning process):
```
# ~/palworld-dedicated-server-linux/terraform
terraform apply -auto-approve
```

### Executing Ansible Playbooks without Infrastructure Creation/Deletion (Terraform)
Before proceeding with the execution of the Ansible playbook, verify that your Ansible hosts have been correctly generated:
```
# ~/palworld-dedicated-server-linux/ansible
ansible-inventory -i inventory.yml --graph --vars
```

Next, execute the Ansible playbook on your hosts:
```
# ~/palworld-dedicated-server-linux/ansible
ansible-playbook -i inventory.yml playbook.yml
```
### Destroying Infrastructure and Configuration with Terraform
You can dismantle the infrastructure and its configuration by utilizing the following Terraform command:
```
# ~/palworld-dedicated-server-linux/terraform
terraform destroy -auto-approve
```

### Only executing Ansible Playbooks
You have the option to utilize Ansible separately from Terraform. This is particularly handy if Terraform wasn't used initially. In such scenarios, you'll need to manually create the inventory.yml file with your specific information and then execute the following command:
```
# ~/palworld-dedicated-server-linux/ansible
ansible-playbook -i inventory.yml playbook.yml
```
### Start | Stop the palworld.service
To connect to the server using SSH, use the following command:
```
#replace <public-ip-address> with the actual public IP address of the server you want to connect to. 

ssh root@<public-ip-address>
```
**Start or Restart the server**: 

Use the command from the server `systemctl start palworld.service` or directly from your machine: 
```
#~/palworld-dedicated-server-linux/ansible
ansible all -i inventory.yml -m ansible.builtin.shell -a "systemctl start palworld.service
```
**Stop the server**: 

Use the command from the server `systemctl stop palworld.service` or directly from your machine:
```
#~/palworld-dedicated-server-linux/ansible
ansible all -i inventory.yml -m ansible.builtin.shell -a "systemctl stop palworld.service
```

Whenever the palworld.service is restarted, the palworld service will undergo an update, and a backup will be generated in the directory `/home/<steamcmd_user>/palworld_backups/`.

## FAQ
### Resolving Python Crypt module deprecation warning:
```
[DEPRECATION WARNING]: Encryption using the Python crypt module is deprecated.The Python crypt module is deprecated and will be removed from Python 3.13. Install the passlib library for continued encryption functionality. This feature will be removed in version 2.17. Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible cfg. 
```

To address the deprecation warning related to the Python crypt module, use pip or pip3 to install the Passlib library:
```
pip3 install passlib
```

Passlib provides continued encryption functionality, ensuring compatibility with future Python versions beyond 3.13.

### Modifying Palworld Settings:

If you've been playing on your Palworld server and need to adjust settings, follow these steps:
1. **Stop the Palworld server**: To modify settings, stop the Palworld server using the command:
```
#~/palworld-dedicated-server-linux/ansible
ansible all -i inventory.yml -m ansible.builtin.shell -a "systemctl stop palworld.service"
```

2. **Modify Palworld Settings**: Navigate to your Palworld server directory and find the main.yml file located in the defaults directory. Use a text editor to open main.yml and adjust the settings according to your preferences.

3. **Apply Changes Using Ansible Playbook:**: Utilize Ansible Playbook to apply the modifications across your server infrastructure. Execute the following command:
```
# ~/palworld-dedicated-server-linux/ansible
ansible-playbook -i inventory.yml playbook.yml
```

4. **Start the Palworld server**: After applying the changes, restart the Palworld server to implement the modifications:
```
#~/palworld-dedicated-server-linux/ansible
ansible all -i inventory.yml -m ansible.builtin.shell -a "systemctl start palworld.service"
```

### Rollback to a Previous Backup Save (Locally):
1. Prior to restoring the backup, ensure that the Palworld server is halted:
```
systemctl stop palworld.service
```

2. Connect as the designated steamcmd user and navigate to the home directory (e.g., /home/steam):
```
sudo -u <steamcmd_user> -s
cd /home/steam
```

4. Remove the data from the previous server with caution, making sure to have a backup in place:
```
# ~/home/steam
rm -rf /home/steam/.steam/steam/steamapps/common/PalServer/Pal/Saved
```

5. Extract the archive using the following command:
```
# ~/home/steam
tar -xzvf palworld_backups/palworld_YYYY-MM-DD_HH-MM-SS.tar.gz -C /
```
Make sure to replace <steamcmd_user> with the actual steamcmd user and palworld_YYYY-MM-DD_HH-MM-SS.tar.gz with the correct backup file name and timestamp.

### Transferring / copying server configuration files from one server to another:
1. Ensure the new server has undergone a fresh installation (you could re-use ansible to provision the new server)
2. Ensure that SSH is properly configured on the new server and that you have the necessary credentials (username and password or SSH keys) to log in.
3. Use SCP to securely transfer the file to the new server.
```
# command to be launched from old server
scp /home/steam/palworld_backups/palworld_YYYY-MM-DD_HH-MM-SS.tar.gz IP_ADRESS_NEW_SERVER:/home/steam/palworld_backups/
```
4. You need to manually update the public IP address in the `PalWorldSettings.ini` file to reflect the new server's public IP.

## General Advice
Feel free to make adjustments based on your project's specific requirements and preferences. Happy gaming with your Palworld Dedicated Server!