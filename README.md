# Cardano Node Local Core #

An Ansible Role to build a Docker image and spin a container to manage a Cardano stake pool operations locally.

To save CPU cycles and quite some time, this Role downloads the binaries for ```cardano-node, cardano-cli, cardano-hw-cli```. SPO Scripts are cloned from the latest repo.

## Specs ##

### Operating System ###

The base Docker image is [Ubuntu 20.04 LTS](https://ubuntu.com/blog/ubuntu-20-04-lts-arrives).

### Build Tools ###

- Cabal Version: 3.4
- GHC Version: 8.10.4

### System Tools ###

When building the image, the environment installs the following:

- [Cardano Node + CLI](https://github.com/input-output-hk/cardano-node/)
- [Cardano Configs](https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/index.html)
- [Cardano HW CLI](https://github.com/vacuumlabs/cardano-hw-cli)
- [SPO Scripts](https://github.com/gitmachtl/scripts/)

## Requirements ##

- [Python 3](https://python.org)
- [Ansible](https://www.ansible.com/)
- [Docker](https://www.docker.com/)

### Install Python ###

If your system doesn't come with Python 3 already installed, please install it.

#### macOS ####

I suggest you use [Homebrew](https://brew.sh).

```shell
brew install python@3.9
```

#### Linux ####

Please refer to your distro documentation and instructions.

#### Windows ####

nah.

### Install Ansible ###

Once you have Python 3 installed, installing Ansible is a matter of running:

```shell
python3 -m pip install ansible
```

If you would like another approach, please refer to [the official Ansible documentation](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).

### Install Docker Desktop ###

**macOS/Windows**: Install and run Docker Desktop, for your OS from [the official site](https://www.docker.com/products/docker-desktop), on your local computer.

**Linux**: use Docker directly. Linux doesn't require Docker Desktop.

### Clone This Repo ###

```shell
git clone https://github.com/gacallea/local-cnode-docker.git
```

### Adjust The Variables ###

Within the Role ```vars``` directory, you can find a couple of variables you need to modify:

```yaml
---
# YOUR NODE TIMEZONE (LEAVE AS 'UTC' IF UNSURE)
timezone: UTC

# SET YOUR POOL TICKER AND ID HERE
pool_ticker: SALAD
pool_id: e29b14719f694767d0faf92f654cf66585bcefd8139bf5a33b7ed181

# DEFINE THE MOUNT POINT TO YOUR SECRET KEYS AND ADDRESSES HERE
secret_path: "/mnt/data"
```

The variable are pretty self-explanatory. However, I should explain the ```secret_path```. **This needs to match the mount point of a USB device** where you have your keys, addresses, and stake pool data. You'll be using them in conjunction with Martin's SPO Scripts to carry on whatever task you need to carry on.

## Usage ##

### Let The Magic Happen ###

Once you have everything in place, it's time to let Ansible and Docker do their work.

```shell
ansible-playbook local-cnode-docker.yml
```

### Connect To The Container ###

When Ansible and Docker are done and you have container running, you can connect to it.

```shell
docker container exec -it local_core_1 /bin/bash
```

### Check Node Sync ###

**The node sync will take a while**. Plan ahead. Once the Cardano Node is 100% in sync, you can carry out your operations. For example: rotate your KES and Opcert, withdraw your rewards, or do anything that Martin's SPO Scripts allow you to do.

```shell
cardano-cli query tip --mainnet
```

SPO Scripts reside under the ```cnode``` user home directory:

```shell
cnode@fe9ab1887d0d:~$ pwd
/home/cardano-node

cnode@fe9ab1887d0d:~$ ll
config
data
db
keys
scripts
socket
```

### Enjoy ###
