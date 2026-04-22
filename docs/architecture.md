# Infrastructure Repo Layout

This repository is split into three explicit layers:

- `terraform/`: infrastructure provisioning and machine metadata.
- `ansible/`: operating system configuration, Docker, and service deployment.
- `terraform/templates/cloud-init/`: first-boot bootstrap data for VM instances.

Ownership boundaries:

- Terraform creates VMs and LXCs, network attachments, disks, tags, and outputs host connection data.
- Cloud-init bootstraps VM instances with users, SSH keys, baseline packages, and initial networking.
- Ansible applies ongoing configuration and deploys services after a host exists and is reachable.

Workflow:

1. Apply Terraform for the target environment under `terraform/environments/`.
2. Export or generate Ansible inventory from Terraform outputs.
3. Run `just run <config> <host>` from repo root, or run `ansible-playbook` with the repo-root `ansible.cfg` against `ansible/playbooks/site.yml`.

Current state:

- `ansible/inventory/lab/hosts.yml` is still static.
- `terraform/` is scaffolded for the next step: replacing static inventory with generated host data.
