#!/bin/bash

error() {
    echo $*
    exit 1
}

subdomain=adr-poc
if [ -n "$1" ]; then
    subdomain=$1
fi

PATH=$PATH:~/.local/bin
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook --connection=local --inventory 127.0.0.1, playbook_terraform.yaml --extra-vars subdomain=$subdomain || error Failed to complete playbook_terraform.yaml
ansible-playbook --private-key ./ssh.pem -i $(terraform output -raw vm_ip_address), -u "$subdomain-admin" playbook.yaml --extra-vars subdomain=$subdomain || error Failed to complete playbook.yaml
