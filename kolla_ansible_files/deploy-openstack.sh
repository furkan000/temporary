#!/bin/bash

# Generate all openstack passwords and keys and copy the file to working dir
kolla-genpwd -p ./passwords.yml

# Prepare VMs for kolla-ansible
ansible-playbook -i ./multinode ./pre-bootstrap.yml | tee ./pre-bootstrap.log

# Prepare VMs for OpenStack installation
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode bootstrap-servers | tee ./bootstrap-servers.log

# Fix a common bug in /etc/hosts
ansible-playbook -i ./multinode ./fix-hosts-file.yml

# Deploy OpenStack
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode deploy | tee ./prechecks.log

# create ./admin-rc.sh (you might need to change the ownership of ./admin-rc.sh)
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode post-deploy

# Destroy OpenStack deployment
# kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode --yes-i-really-really-mean-it destroy

