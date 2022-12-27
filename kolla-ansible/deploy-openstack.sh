#!/bin/bash

# Generate all openstack passwords and keys and copy the file to working dir
kolla-genpwd && cp /etc/kolla/passwords.yml ./

# Prepare VMs for kolla-ansible
ansible-playbook -i ./multinode ./pre-bootstrap.yml | tee ./pre-bootstrap.log

# Prepare VMs for OpenStack installation
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode bootstrap-servers | tee ./bootstrap-servers.log

# Fix a common bug in /etc/hosts
ansible-playbook -i ./multinode ./fix-hosts-file.yml

# Run prechecks to verify that the VMs are ready for OpenStack deployment
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode --skip-tags haproxy prechecks | tee ./prechecks.log

# Deploy OpenStack
kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode deploy | tee ./deploy.log

# Destroy OpenStack deployment
# kolla-ansible --passwords ./passwords.yml --configdir "$(readlink -e ./)" --inventory ./multinode --yes-i-really-really-mean-it destroy

