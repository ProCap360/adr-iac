#!/bin/bash

error() {
    echo $*
    exit 1
}

PATH=$PATH:~/.local/bin
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook --connection=local --inventory 127.0.0.1, playbook_terraform.yaml || error Failed to complete playbook_terraform.yaml
ansible-playbook --private-key ./ssh.pem -i $(terraform output -raw vm_ip_address), -u adr-poc-admin playbook.yaml || error Failed to complete playbook.yaml
