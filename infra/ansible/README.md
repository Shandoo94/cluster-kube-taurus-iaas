# Ansible Infrastructure for cluster-kube-taurus-iaas

This directory contains Ansible automation for **day-2 state maintenance** of the Kubernetes cluster nodes. It ensures nodes maintain the configuration initially defined in cloud-init.

## Purpose

Maintain consistent state across cluster nodes for:
- Hostname configuration
- Required package installation
- SSH authorized keys
- System configuration (timezone, locale)
- User and sudo configuration

## Prerequisites

- Ansible 2.9+ installed on control machine
- SSH access to all nodes as `kube-admin` user
- SSH key authentication configured
- Python 3 installed on target nodes

### Required Ansible Collections

Install required collections:

```bash
ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general
```

## Directory Structure

```
infra/ansible/
├── ansible.cfg                          # Ansible configuration
├── inventory/
│   ├── hosts.yaml                       # Inventory file (YAML format)
│   └── group_vars/
│       └── all.yaml                     # Common variables for all hosts
├── playbooks/
│   └── maintain-state.yaml              # Main state maintenance playbook
└── README.md                            # This file
```

## Configuration

### Update Inventory

Edit `inventory/hosts.yaml` and update the `ansible_host` values with actual IP addresses or resolvable hostnames:

```yaml
taurus-node-01:
  ansible_host: 192.168.1.10  # Replace with actual IP
  node_hostname: taurus-node-01
```

### Variables

Common variables are defined in `inventory/group_vars/all.yaml`. Key variables:

- `ssh_authorized_key`: SSH public key for kube-admin user
- `required_packages`: List of packages to maintain
- `timezone`: System timezone
- `locale`: System locale

## Usage

### Check Connectivity

Verify Ansible can connect to all nodes:

```bash
cd infra/ansible
ansible all -m ping
```

### Run State Maintenance (Check Mode)

Perform a dry-run to see what would change:

```bash
ansible-playbook playbooks/maintain-state.yaml --check --diff
```

### Run State Maintenance

Apply state maintenance to all nodes:

```bash
ansible-playbook playbooks/maintain-state.yaml
```

### Run Specific Tasks with Tags

Run only specific tasks using tags:

```bash
# Only ensure hostname is set correctly
ansible-playbook playbooks/maintain-state.yaml --tags hostname

# Only ensure packages are installed
ansible-playbook playbooks/maintain-state.yaml --tags packages

# Only ensure SSH keys are configured
ansible-playbook playbooks/maintain-state.yaml --tags ssh

# Multiple tags
ansible-playbook playbooks/maintain-state.yaml --tags hostname,packages
```

Available tags:
- `hostname` - Hostname configuration
- `packages` - Package installation
- `user` - User and sudo configuration
- `ssh` - SSH authorized keys
- `system` - System configuration (timezone, locale)
- `verify` - Verification checks

### Target Specific Hosts

Run playbook against specific hosts:

```bash
# Single host
ansible-playbook playbooks/maintain-state.yaml --limit taurus-node-01

# Multiple hosts
ansible-playbook playbooks/maintain-state.yaml --limit taurus-node-01,taurus-node-02
```

## Maintenance Schedule

Recommended schedule for running state maintenance:

- **Weekly**: Run full playbook to ensure configuration drift is minimal
- **After incidents**: Run immediately after any manual changes to nodes
- **Before upgrades**: Verify state before performing cluster upgrades

## Troubleshooting

### SSH Connection Issues

If you encounter SSH connection issues:

```bash
# Test SSH connectivity manually
ssh kube-admin@taurus-node-01

# Verify SSH key is loaded
ssh-add -l

# Use verbose mode for debugging
ansible-playbook playbooks/maintain-state.yaml -vvv
```

### Permission Issues

Ensure the kube-admin user has passwordless sudo:

```bash
# Verify sudo access on node
ssh kube-admin@taurus-node-01 'sudo -n true'
```

### Package Installation Failures

If package installation fails, manually update apt cache on the node:

```bash
ssh kube-admin@taurus-node-01 'sudo apt update'
```

## Relationship to cloud-init

This Ansible configuration mirrors the state defined in `infra/cloud-init/`:

- `infra/cloud-init/taurus-node-01/user-data` → Initial provisioning
- `infra/ansible/playbooks/maintain-state.yaml` → Day-2 maintenance

The Ansible playbook ensures nodes maintain this state over time, correcting any configuration drift.

## Future Enhancements

Potential additions for future iterations:

- Automated security updates
- Log rotation configuration
- Monitoring agent installation
- Backup verification
- Network configuration validation
