#!/usr/bin/env -S just --justfile
# https://github.com/casey/just

bt := '0'

export RUST_BACKTRACE := bt

log := "warn"

export JUST_LOG := log

# just vault (encrypt/decrypt/edit)
vault ACTION:
    EDITOR='code --wait' ansible-vault {{ACTION}} vars/vault.yaml
