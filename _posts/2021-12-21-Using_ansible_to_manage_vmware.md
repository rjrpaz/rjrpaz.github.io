---
layout: post
title: "Using ansible to manage vmware"
date: 2021-12-21 00:00:00 -0000
categories: ansible vmware IaC
---
Using ansible to manage vmware

This projects includes a set of ansible playbook to manage vmware-based infrastructure: [https://github.com/rjrpaz/ansible-vmware](https://github.com/rjrpaz/ansible-vmware)

Playbooks include some very basic VM tasks like:

- get summary information from a VM
- creating a VM
- get a list of VMs from the cluster
- get size of a VM (real storage size, not nominal size)
- get a list of VMs from the cluster
- get disk information from a VM
- power on/power off a VM
- set CPU/memory size
- set/unset hot add values that allows hot resizing for CPU and memory
- set VM OS version according to the VMWare labeling reference
- set hot add values that allows hot resizing for CPU and memory
- rename a VM
- remove a VM
- move a VM to a different folder
- upgrade VMWare tools in a VM
- clone VM from an existent template
- clone a new template from an existent template

Allows to get information from the VMWare cluster:

- get summary information from cluster host
- get host info
- get cluster info
- get DSR rules
- get datastores (emptiest one as an example)
- get DVS portgroups
- get resource pool

Allows to manage VM snapshots:

- get list of snaphots
- take a snapshot
- remove a snapshot
- revert VM to a specific snapshot

Allows to manage disks:

- add a disk
- delete last added disk
- resize a disk

## Some toughts about this project

This playbooks use the community edition of the ansible modules: [https://github.com/ansible-collections/community.vmware](https://github.com/ansible-collections/community.vmware)

This modules use pyvmomi underneath, so this tool is required: [https://github.com/vmware/pyvmomi](https://github.com/vmware/pyvmomi)

This playbooks are checked using *ansible lint v. 5.3.1*.

Most of this playbooks use *name* as the parameter to identify a VM. However, name are not necessarily unique in a VMWare cluster. If this is the case, playbook should be modified to use **uuid**, which is a unique identifier to a VM.

A lot of vmware modules accept *datacenter* or *cluster* name as valid input parameters. This playbooks use the first option in most cases.

You can run a playbook as follows:

```console
ansible-playbook -i 'localhost,' playbook.yml
```

Extra vars are prompted. You can run the playbook in a single command line passing the extra vars like this:

```console
ansible-playbook -i 'localhost,' -e "extra_var1=extra_var_value1 extra_var2=extra_var_value2 ..." playbook.yml
```
