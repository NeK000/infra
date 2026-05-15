#!/usr/bin/env -S just --justfile

ansible_config := "ansible/ansible.cfg"
inventory := "ansible/hosts.yaml"
playbook := "ansible/run.yaml"
requirements := "ansible/requirements.yaml"
terraform_lab := "terraform/environments/lab"

# Terraform destroy, plan, and apply for one LXC in the lab environment
tf HOST:
  doppler run -p ninik-lab -c prd -- terraform -chdir={{terraform_lab}} destroy -target='module.lxc["{{HOST}}"]'
  doppler run -p ninik-lab -c prd -- terraform -chdir={{terraform_lab}} plan -target='module.lxc["{{HOST}}"]'
  doppler run -p ninik-lab -c prd -- terraform -chdir={{terraform_lab}} apply -target='module.lxc["{{HOST}}"]'

# Ansible playbook against specific host
run HOST *TAGS:
  doppler run -p ninik-lab -c prd -- env ANSIBLE_CONFIG={{ansible_config}} ansible-playbook -b -i {{inventory}} {{playbook}} --limit {{HOST}} {{TAGS}}

# Rebuild one LXC end-to-end and wait for name resolution before Ansible
all HOST *TAGS:
  just tf {{HOST}}
  doppler run -p ninik-lab -c prd -- env ANSIBLE_CONFIG={{ansible_config}} ansible all -i {{inventory}} --limit {{HOST}} -m ansible.builtin.wait_for_connection -a 'timeout=300 sleep=2 connect_timeout=5'
  just run {{HOST}} {{TAGS}}

# docker compose against remote host via Ansible
compose HOST *V:
  env ANSIBLE_CONFIG={{ansible_config}} ansible-playbook -i {{inventory}} {{playbook}} --limit {{HOST}} --tags compose {{V}}

# Refresh all compose stacks after pulling repo changes
refresh *V:
  doppler run -p ninik-lab -c prd -- env ANSIBLE_CONFIG={{ansible_config}} ansible-playbook -b -i {{inventory}} {{playbook}} --limit compose_stacks --tags compose -e compose_stack_remove_before_deploy=false {{V}}

# Core edge nodes (DNS + VIP)
core *TAGS:
  env ANSIBLE_CONFIG={{ansible_config}} ansible-playbook -b -i {{inventory}} {{playbook}} --limit dns,edge {{TAGS}}

# Apply only AdGuard DNS rewrites on the DNS node
dns:
  doppler run -p ninik-lab -c prd -- env ANSIBLE_CONFIG={{ansible_config}} ansible-playbook -b -i {{inventory}} {{playbook}} --limit dns --tags dns_rewrites


# optionally use --force to force reinstall all requirements
repo *FORCE:
  ANSIBLE_CONFIG={{ansible_config}} ansible-galaxy install -r {{requirements}} -p ansible/galaxy_roles {{FORCE}}
