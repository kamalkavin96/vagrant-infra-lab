# macOS Vagrant Environment

This folder contains a Vagrant configuration for a macOS guest VM.

macOS guests require Apple hardware and a macOS-compatible Vagrant box. This setup expects a local or private box by default, because there is no official public macOS Vagrant box.

## What is included

- `Vagrantfile` for a single macOS VM
- Box name supplied with `MACOS_BOX`
- Private network IP address: `192.168.56.30`
- VMware VM display name: `macOS-Vagrant`
- Base resources: `4096 MB` RAM, `2` CPUs
- Provisioning script checks Xcode Command Line Tools and installs basic tools with Homebrew when available

## Prerequisites

Before using this setup, install:

- [Vagrant](https://www.vagrantup.com)
- VMware Fusion or another macOS guest-capable provider
- The Vagrant VMware provider plugin, if using VMware
- A macOS Vagrant box added locally or available from a private registry

## Add or select a macOS box

To add a local box file:

```bash
vagrant box add my-macos /path/to/macos.box
```

Then set `MACOS_BOX` to that box name.

```bash
export MACOS_BOX="my-macos"
```

In PowerShell:

```powershell
$env:MACOS_BOX = "my-macos"
```

## Quick start

From this directory:

```bash
cd d:/vagrant-infra-lab/os/mac/macos
vagrant box add my-macos /path/to/macos.box
export MACOS_BOX="my-macos"
vagrant up --provider=vmware_desktop
```

This command will:

1. use the locally added macOS box
2. create a VMware VM named `macOS-Vagrant`
3. configure the VM with a private network IP of `192.168.56.30`
4. provision the VM by running the inline shell script

> Important: `MACOS_BOX` must point to a macOS box you added locally or can access privately. Vagrant cannot download a public macOS box automatically.

## Connect to the VM

Use the built-in SSH command:

```bash
vagrant ssh
```

If you need the VM IP address, use:

```bash
vagrant ssh -c "ifconfig"
```

## Stop and remove the VM

To stop the VM without destroying it:

```bash
vagrant halt
```

To remove the VM and its state completely:

```bash
vagrant destroy -f
```

## Reload the VM with updated configuration

If you change the `Vagrantfile`, apply the changes with:

```bash
vagrant reload --provision
```

## Resource configuration

The VM resources are configured in `Vagrantfile` under the `vmware_desktop` provider block:

```ruby
config.vm.provider "vmware_desktop" do |vmware|
  vmware.vmx["displayName"] = "macOS-Vagrant"
  vmware.vmx["memsize"] = "4096"
  vmware.vmx["numvcpus"] = "2"
end
```

### Increase resources

To allocate more RAM and CPUs, update the values:

- `memsize` sets the VM RAM in megabytes
- `numvcpus` sets the number of virtual CPUs

Example:

```ruby
vmware.vmx["memsize"] = "8192"
vmware.vmx["numvcpus"] = "4"
```

After editing the file, run:

```bash
vagrant reload --provision
```

If the VM is powered off, use:

```bash
vagrant up --provider=vmware_desktop
```

### Decrease resources

To lower memory or CPU allocation, reduce the values and then reload the VM.

Example:

```ruby
vmware.vmx["memsize"] = "2048"
vmware.vmx["numvcpus"] = "1"
```

> Note: Decreasing resources while the VM is running may require shutting it down first.

## Network configuration

This Vagrantfile configures a private network:

```ruby
config.vm.network "private_network",
  ip: "192.168.56.30"
```

### Change the VM IP address

Edit the IP value and then run:

```bash
vagrant reload --provision
```

### Use port forwarding instead

If you prefer to access services from the host without a private network, replace or add a port forwarding rule, for example:

```ruby
config.vm.network "forwarded_port", guest: 22, host: 2223
```

Then reload Vagrant.

## Provisioning details

The built-in shell provisioner runs during `vagrant up` and `vagrant provision`.

Current provisioning behavior:

- checks whether Xcode Command Line Tools are installed
- updates Homebrew when `brew` is available
- installs common tools with Homebrew when `brew` is available
- prints manual setup guidance when Xcode tools or Homebrew are missing

### Add more packages

Add packages to the `brew install` list in `Vagrantfile`, then run:

```bash
vagrant provision
```

Example:

```ruby
brew install \
  git \
  vim \
  htop \
  tree
```

### Change provisioning behavior

If you want to run a custom script file instead of inline shell code, replace the inline block with:

```ruby
config.vm.provision "shell", path: "bootstrap.sh"
```

Create `bootstrap.sh` in the same folder and make it executable.

## Provider notes

This configuration uses `vmware_desktop`, which maps to VMware Fusion on macOS hosts. Running macOS guests generally requires Apple hardware and a compatible macOS license.

If you use another provider, update the provider block in `Vagrantfile` and ensure the provider supports macOS guests.

VirtualBox on Windows is not a practical target for this macOS guest configuration. If you run this from Windows without a local macOS box, Vagrant will fail with a `local/macos` box not found error.

## Troubleshooting

- If the box is not found, add it with `vagrant box add my-macos /path/to/macos.box` and set `MACOS_BOX`.
- If VMware does not start, confirm VMware Fusion and the Vagrant VMware provider are installed.
- If `vagrant ssh` fails, run `vagrant ssh-config` to inspect the SSH connection details.
- If the VM IP conflicts with another host, choose a different private network range.
- If package installation is skipped, install Homebrew inside the VM and rerun `vagrant provision`.

## Useful commands

- `vagrant status` - show current VM status
- `vagrant global-status` - list all Vagrant machines on the host
- `vagrant up --provider=vmware_desktop` - force provider selection
- `vagrant provision` - rerun provisioning scripts
- `vagrant reload` - restart the VM with updated config

## Recommended workflow

1. Add or select your macOS Vagrant box
2. Open a terminal in this folder
3. Run `vagrant up --provider=vmware_desktop`
4. Use `vagrant ssh` to connect
5. Edit `Vagrantfile` to customize memory, CPUs, network, box name, or packages
6. Run `vagrant reload --provision` after changes

## Additional customization ideas

- Add synced folders with `config.vm.synced_folder ".", "/vagrant"`
- Use a specific private box version with `config.vm.box_version`
- Enable forwarded ports for services
- Add provisioning for language runtimes, build tools, or CI agents

---

For further updates, edit the `Vagrantfile` and rerun `vagrant reload --provision`.
