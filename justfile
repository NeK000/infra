#!/usr/bin/env -S just --justfile
# https://github.com/casey/just

bt := '0'

export RUST_BACKTRACE := bt

log := "warn"

export JUST_LOG := log

## repo stuff
# optionally use --force to force reinstall all requirements
reqs *FORCE:
	ansible-galaxy install -r requirements.yaml {{FORCE}}

# just vault (encrypt/decrypt/edit)
vault ACTION:
    EDITOR='code --wait' ansible-vault {{ACTION}} vars/vault.yaml

# configure
configure-prod:
    ansible-playbook -b playbooks/prod-servers.yaml
configure-test:
    ansible-playbook -b playbooks/test-servers.yaml
configure-storage:
    ansible-playbook -b playbooks/prod-storage.yaml