# Ubuntu 24.04 Vagrant Environment

This folder contains a configurable multi-VM Vagrant environment for Ubuntu 24.04 LTS using the `bento/ubuntu-24.04` box and VirtualBox provider.

## What is included

- `Vagrantfile` builds one or more Ubuntu 24.04 VMs from `config.yml`
- `config.yml` controls VM count, names, box, CPU, memory, and private network IP range
- `scripts/setup.sh` provisions each VM with common command-line tools
- Default VM count: `3`
- Default VM names: `ubuntu-24-01`, `ubuntu-24-02`, `ubuntu-24-03`
- Default hostnames: `ubuntu-01`, `ubuntu-02`, `ubuntu-03`
- Default private IPs: `192.168.56.10`, `192.168.56.11`, `192.168.56.12`
- Default resources per VM: `2048 MB` RAM, `2` CPUs

## Folder layout

```text
ubuntu-24.04/
|-- Vagrantfile
|-- config.yml
|-- README.md
`-- scripts/
    `-- setup.sh
```

## Prerequisites

Before using this setup, install:

- [Vagrant](https://www.vagrantup.com)
- [VirtualBox](https://www.virtualbox.org)

Optionally, install `vagrant-vbguest` if you want guest additions to be kept up to date.

## Quick start

From this directory:

```bash
cd d:/vagrant-infra-lab/os/ubuntu/ubuntu-24.04
vagrant up
```

This command will:

1. download the `bento/ubuntu-24.04` box if it is not already available locally
2. read VM settings from `config.yml`
3. create three VirtualBox VMs by default
4. configure each VM with a private network IP
5. provision each VM with `scripts/setup.sh`

## Current configuration

The default `config.yml` is:

```yaml
instance_count: 3

vm:
  name_prefix: ubuntu-24
  hostname_prefix: ubuntu
  box: bento/ubuntu-24.04

resources:
  memory: 2048
  cpus: 2

network:
  base_ip: "192.168.56"
  start_ip: 10
```

This creates:

| VM name | Hostname | Private IP | Memory | CPUs |
| --- | --- | --- | --- | --- |
| `ubuntu-24-01` | `ubuntu-01` | `192.168.56.10` | `2048 MB` | `2` |
| `ubuntu-24-02` | `ubuntu-02` | `192.168.56.11` | `2048 MB` | `2` |
| `ubuntu-24-03` | `ubuntu-03` | `192.168.56.12` | `2048 MB` | `2` |

## Connect to a VM

Because this environment defines multiple machines, include the VM name when using SSH:

```bash
vagrant ssh ubuntu-24-01
```

Other examples:

```bash
vagrant ssh ubuntu-24-02
vagrant ssh ubuntu-24-03
```

To check IP addresses from inside a VM:

```bash
vagrant ssh ubuntu-24-01 -c "ip a"
```

## Manage the environment

Start all VMs:

```bash
vagrant up
```

Start one VM:

```bash
vagrant up ubuntu-24-01
```

Show VM status:

```bash
vagrant status
```

Stop all VMs:

```bash
vagrant halt
```

Stop one VM:

```bash
vagrant halt ubuntu-24-01
```

Remove all VMs and their state:

```bash
vagrant destroy -f
```

Remove one VM:

```bash
vagrant destroy -f ubuntu-24-01
```

## Reload after changes

If you change `Vagrantfile`, `config.yml`, or provisioning behavior, apply the changes with:

```bash
vagrant reload --provision
```

For one VM:

```bash
vagrant reload ubuntu-24-01 --provision
```

## Change the number of VMs

Edit `instance_count` in `config.yml`.

Example for five VMs:

```yaml
instance_count: 5
```

With the default network settings, this creates IP addresses from `192.168.56.10` through `192.168.56.14`.

After editing, run:

```bash
vagrant up
```

If you reduce `instance_count`, destroy the extra VMs that are no longer defined.

## Resource configuration

VM resources are controlled in `config.yml`:

```yaml
resources:
  memory: 2048
  cpus: 2
```

### Increase resources

Example:

```yaml
resources:
  memory: 4096
  cpus: 4
```

Then apply the change:

```bash
vagrant reload --provision
```

### Decrease resources

Example:

```yaml
resources:
  memory: 1024
  cpus: 1
```

> Note: Decreasing resources while a VM is running may require shutting it down first.

## Network configuration

Private IPs are generated from `network.base_ip` and `network.start_ip`.

```yaml
network:
  base_ip: "192.168.56"
  start_ip: 10
```

The Vagrantfile calculates each IP like this:

```ruby
ip_address = "#{network["base_ip"]}.#{network["start_ip"] + i - 1}"
```

To move the environment to another private range, update `base_ip` and `start_ip`, then reload:

```bash
vagrant reload --provision
```

## Provisioning details

Each VM runs:

```ruby
node.vm.provision "shell",
  path: "scripts/setup.sh"
```

The script currently:

- prints a setup header
- shows the VM hostname
- runs `apt-get update`
- installs common tools:
  - `curl`
  - `wget`
  - `git`
  - `vim`
  - `nano`
  - `net-tools`
  - `iputils-ping`
  - `telnet`
  - `unzip`
  - `htop`
  - `mc`

Rerun provisioning on all VMs:

```bash
vagrant provision
```

Rerun provisioning on one VM:

```bash
vagrant provision ubuntu-24-01
```

## Add more packages

Edit `scripts/setup.sh` and add packages to the `apt-get install -y` list.

Example:

```bash
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    tree \
    build-essential
```

Then run:

```bash
vagrant provision
```

## Provider notes

This configuration uses VirtualBox:

```ruby
node.vm.provider "virtualbox" do |vb|
  vb.name = vm_name
  vb.memory = resources["memory"]
  vb.cpus = resources["cpus"]
end
```

To use another provider, update the provider block in `Vagrantfile` and ensure the provider is installed.

Common providers:

- `virtualbox`
- `hyperv` on Windows
- `libvirt` on Linux
- `vmware_desktop`

## Troubleshooting

- If the box fails to download, verify your internet connection and the `vm.box` value in `config.yml`.
- If VirtualBox does not start, ensure virtualization is enabled in BIOS/UEFI and no conflicting hypervisors are blocking it.
- If `vagrant ssh` fails, run `vagrant ssh-config ubuntu-24-01` to inspect the SSH connection details.
- If a VM IP conflicts with another host, change `network.base_ip` or `network.start_ip`.
- If provisioning fails, rerun `vagrant provision <vm-name>` after fixing `scripts/setup.sh`.
- If stale VM state causes confusion, run `vagrant status` and destroy only the VM names you no longer need.

## Useful commands

- `vagrant status` - show current VM status
- `vagrant global-status` - list all Vagrant machines on the host
- `vagrant up --provider=virtualbox` - force provider selection
- `vagrant ssh ubuntu-24-01` - connect to the first VM
- `vagrant provision` - rerun provisioning scripts on all VMs
- `vagrant reload --provision` - restart VMs and rerun provisioning

## Recommended workflow

1. Open PowerShell or CMD in this folder
2. Review `config.yml`
3. Run `vagrant up`
4. Use `vagrant ssh ubuntu-24-01` to connect
5. Edit `config.yml` for VM count, resources, names, or network settings
6. Edit `scripts/setup.sh` for provisioning changes
7. Run `vagrant reload --provision` after configuration changes

## Additional customization ideas

- Add synced folders with `config.vm.synced_folder ".", "/vagrant"`
- Use a more specific box version by adding `config.vm.box_version`
- Enable forwarded ports for web services
- Add provisioning for Docker, Node.js, Python, Ansible, or Kubernetes tools
- Split provisioning into multiple scripts for base packages, developer tools, and application setup

---

For further updates, edit `config.yml`, `scripts/setup.sh`, or `Vagrantfile`, then rerun `vagrant reload --provision`.
