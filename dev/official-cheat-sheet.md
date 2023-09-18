# Official Cheat Sheet
**Setting up a Rink that controls two NS nameservers**

These earlier steps assume creation of VPS instances described later

## Nameserver settings for related domains
- In these instructions, `mynsdomain.tld` is a demo domain which should be replaced with your own domain
- `rink.mynsdomain.tld` handles the rinks, so DNS records must be entered manually
- all verb domains must point to `ns1.mynsdomain.tld` and `ns2.mynsdomain.tld` for NS records, along with all other domains that users plan to host

# Installing Arch on a VPS
Follow this guide: [Arch VPS Install](https://github.com/inkVerb/VIP/blob/master/Cheat-Sheets/Arch-VPS-Install.md)

# Preparing the Rink server, NS servers, and Verber snapshots

This presumes that your local machine is running Arch or Manjaro as your workstation

0. Start with an Arch VPS that has SSH access

You could do this by creating SSH keys on your local machine and adding them into the SSH Keys area of your Vultr Account, then use these keys when creating your first Arch-OS VPS instance. Instructions for doing this are widely available, search "add SSH keys to my Vultr account" as a likely way to find some. If you do, then you may skip to step 1.

*Follow these instructions if you don't have this Arch-ssh-able VPS already!*

Create a VPS from an Arch image

Gain terminal access through the Vultr website

To be clean and fresh, update the VPS and reset the identity RSA keys...

| **Arch 1** #

```console
pacman -Sy archlinux-keyring --noconfirm
pacman -Syyu --noconfirm
pacman -S git vim --noconfirm
pacman -Qdt --noconfirm
pacman -Scc --noconfirm
rm /etc/ssh/ssh_host_*
ssh-keygen -A
```

...If you had terminal access from your local machine and added the keys, you will need to remove that last entry from your local machine's ~/.ssh/known_hosts file, the line should contain the IP address

On your local Arch/Manjaro machine (`My_Vultr_Key` can be anything)...

| **Arch 2** #

```console
pacman -S openssh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa -N "" -f ~/.ssh/My_Vultr_Key -C My_Vultr_Key
chmod 644 ~/.ssh/My_Vultr_Key.pub
chmod 600 ~/.ssh/My_Vultr_Key
cat ~/.ssh/My_Vultr_Key.pub
```

The key should display in the terminal, ending with `= My_Vultr_Key`; copy it to your clipboard

In the Vultr terminal...

Paste that key from above, ending with `= My_Vultr_Key`, into the code below, and enter it into the Vultr terminal

| **Arch 3** #

```console
cat <<EOF >> /root/.ssh/authorized_keys
abcdefg1234567thatLongKeyLongerThanThis= My_Vultr_Key
EOF
chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
```

Tighten security

| **Arch 4** #

```console
sed -i "s/#PasswordAuthentication yes/PasswordAuthentication no/" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin prohibit-password/" /etc/ssh/sshd_config
sed -i "s/#Port.*/Port 1222/" /etc/ssh/sshd_config
systemctl restart sshd
```

Update and install `git` and `vim` so we can do more work...

| **Arch 5** #

```console
/usr/bin/pacman -Sy archlinux-keyring --noconfirm
/usr/bin/pacman -Syyu --noconfirm
/usr/bin/pacman -Qdt --noconfirm
/usr/bin/pacman -Scc --noconfirm
/usr/bin/pacman -S git vim --noconfirm
/usr/bin/pacman -Qdt --noconfirm
/usr/bin/pacman -Scc --noconfirm
```

To be fully tidy, so you don't get that "add these keys permanently" message, on your local machine...

| **Local 1** $

```console
ssh-keyscan -H -p 22 arch.ipv4.four.addr >> ~/.ssh/known_hosts
```

Now, you have a Vultr Arch VPS that you can access from your local machine

Power it down

| **Arch 6** #

```console
poweroff
```

Then take a snapshot of this called "arch-git-vim"

After creating the snapshot, you can destroy that VPS or keep using it for the next step

1. Create our rink VPS and snapshot
- Create an instance from Arch
- Update pacman keys and packages
- Install git and vim
- *The above are the prerequisites for a verber*

Tip: you can use an `ssh` config to make life easier...

| **~/.ssh/config** : (`chmod 600 ~/.ssh/config`)

```bash
 Host rink
  HostName new.arch.ipv4.addr
  User root
  Port 1222
  IdentityFile ~/.ssh/Vultr_Rink_Key
```

Create or coninue using a VPS based on arch-git-vim

This will be called Rink

Then, `ssh` into the Rink server, probably with `ssh root@the.arch.ipv4.addr` or `ssh rink`

On this "rink" server, create ssh keys in /root/.ssh/Vultr_Rink_Key

| **Rink 1** #

```console
pacman -S openssh
mkdir -p /root/.ssh
chmod 700 /root/.ssh
ssh-keygen -t rsa -N "" -f /root/.ssh/Vultr_Rink_Key -C Vultr_Rink_Key
chmod 644 /root/.ssh/Vultr_Rink_Key.pub
chmod 600 /root/.ssh/Vultr_Rink_Key
cat /root/.ssh/Vultr_Rink_Key.pub
```

That pub key should output to the terminal, ending with `= Vultr_Rink_Key`, copy this to the clipboard or somewhere secure because we will need it in a moment

Power it down

| **Rink 2** #

```console
poweroff
```

Take a snapshot of this VPS called "arch-rink", this is for safekeeping; we can always come back to this point from that snapshot

After the snapshot is finished, power the VPS back on

2. Create our controlled VPS and snapshot

Spin up a new VPS from arch-git-vim

This will be called Keyed

Then, `ssh` into the Rink server, probably with `ssh root@git.vim.ipv4.addr`

You may want to reset the RSA identity key also, then make sure you remove it from ~/.ssh/known_hosts on your local maching

| **Keyed-GitVim 0** #

```console
rm /etc/ssh/ssh_host_*
ssh-keygen -A
```

We now will paste that long key from Vultr_Rink_Key.pub into /root/.ssh/authorized_keys

| **Keyed-GitVim 1** #

```console
chmod 700 /root/.ssh
cat <<EOF >> /root/.ssh/authorized_keys
abcdefg1234567thatLongKeyLongerThanThis= Vultr_Rink_Key
EOF
chmod 600 /root/.ssh/authorized_keys
```

Power it down

| **Keyed-GitVim 2** #

```console
poweroff
```

Take a snapshot of this VPS called "arch-keyed"; we will use this in the next step

After the snapshot is finished, power the VPS back on; we will call it Keyed

3. Prepare a production-ready LAEMP pre-setup Verber
- This runs `make-verber-laemp` on both the Rink and Keyed
- SSH keys have been be created on the Rink and the .pub key already placed in /root/.ssh/authorized_keys on the Keyed snapshot
- The Verber snapshot must already have @rink `/root/.ssh/Vultr_Rink_Key.pub` in @verber `/root/.ssh/authorized_keys`
- Once we install LAEMP from the `verb` repo, the arch-keyed Keyed server will be known as the Verber; Rink will still be called the Rink
- FYI, later, the Rink will need to ssh-keyscan each new Verber's identity keys into /root/.ssh/known_hosts, so keys are a two-way street

Spin up or continue using two VPS instances:
- Rink (from arch-rink snapshot)
- Keyed (from arch-keyed snapshot)

`ssh` into each
- Rink: `ssh root@the.arch.ipv4.addr` or `ssh rink`
- Keyed: `ssh root@git.vim.ipv4.addr` or `ssh verber`

Install Verb on both

| **Rink 0** #

```console
cd /opt
git clone https://github.com/inkverb/verb
/opt/verb/inst/make-preverber
reboot
```

| **Verber 0** # (formerly Keyed, which made or was made from the arch-keyed snapshot)

```console
cd /opt
git clone https://github.com/inkverb/verb
/opt/verb/inst/make-preverber
reboot
```

Each will need to reboot (due to refreshed ssh_host keys and locale), then install Verb-LAEMP so the snapshot is up and ready to go quickly, (make a 4GB swap file so it could work OOB with a 2GB-RAM VPS, or so it is less likely to mem-crash on a non-critical 1GB VPS)

| **Rink 1** #

```console
/opt/verb/inst/make-verber-laemp 4
poweroff
```

| **Verber 1** #

```console
/opt/verb/inst/make-verber-laemp 4
poweroff
```

Make a snapshot of each:
- Rink: arch-laemp-rink
- Verber: arch-laemp-keyed

After the snapshots are finished, you may destroy the Verber VPS instance, but not the Rink

Snapshots and Rink are now ready for production and re-production

4. Whitelist the IP for this Rink
- Find IPs under the Rink's VPS Settings, recommend both IPv4 and IPv6
- Whitelist in: [https://my.vultr.com/settings/#settingsapi]
- Note /32 is the default for that field, enter it manually

5. Install the Rink controller `rink` repo

- Some of these are redundant from rink/README.md
- You will need an API key from Vultr Account > API

SSH into your original VPS we started in step 1

- `ssh root@the.arch.ipv4.addr` or `ssh rink`

| **Rink 2** #

```console
cd /opt
git clone https://github.com/inkverb/rink
/opt/rink/inst/setup LONG_KEY_FROM_VULTR_API
```

List available snapshots

| **Rink 3** #

```console
vultr-cli snapshot list
```

Find the serial number for the arch-laemp-keyed snapshot, use that as the first argument for setsnapshot below; we will nickname it laemp1

| **Rink 4** #

```console
cd /opt/rink/run
./setsnapshot snapshot-long-serial-number laemp1
./setport 1222
./setkey Vultr_Rink_Key
./setrinknames mynsdomain.tld ink rink ns1 ns2 444.444.444.444 11:0:0:11 rink rink1 rink2 America/Los_Angeles America/Los_Angeles America/Chicago lax sea ord laemp1
```

6. Set this up to control two NS servers

- These three nameservers will normally serve other Verber instances, but in this situation, they need to serve each other, including the primary Rink server
- This sets up these two NS servers and the Rink to all serve each other at the top of the server management hierarchy
- Prerequisites are steps 1-5:
  - The Arch LAEMP keyed snapshot is setup with "make-verber-laemp", as per steps 1-5
  - The Arch "Rink" with keys is:
    - Setup with "make-verber-laemp", as per steps 1-4
    - Setup with the rink and setrinknames, as per step 5

| **Rink 5** #

```console
/opt/rink/run/setuprinkns
```

Watch for the two NS servers to spin up, when they are ready for login, press Enter in the terminal

You will need to wait a few minutes more than once

If this fails at any point, just run `setuprinkns` again, it uses progress temp files so it knows where to pick back up

7. Set the hosts for the nameservers

An FQDN may not necessarily be required, but is often deemed a standard for nameservers. There are many ways of achieving this.

From the settings above in `setrinknames`, we are using the nameservers:

- `ns1.mynsdomain.tld`
- `ns2.mynsdomain.tld`
- `rink.mynsdomain.tld` *(This is the rink verber)*

If you are using a different host or domains, consider this article accordingly.

These three hosts need to be added to `mynsdomain.tld` with your registrar:

- `ns1`
- `ns2`
- `rink`

If `mynsdomain.tld` is registered at GoDaddy, you will need to use a special "Host Names" setting in "DNS Management" to add these, *not the main zone file settings!*

If you are parking `mynsdomain.tld` at a cloud platform using `cloud-init` like Vultr or DigitalOcean (if this were adopted to a DigitalOcean project), the VPS instance would need to be named `ns1.mynsdomain.tld` to remain consistent with `/etc/cloud/cloud.cfg` and `/etc/cloud/templates/`. But, "Hostnames" in DNS settings for your `ns*.mynsdomain.tld` domain is how GoDaddy handles this. You need to create three records, for `ns1`, `ns2`, and `,rink` under your nameserver domain.

You will not be able to add these IP addresses to GoDaddy Hostnames until you have fully set up the rink, so it has the DNS nameserver software installed and running. (GoDaddy will check when applying these settings.)

Read these articles on [GoDaddy](https://www.godaddy.com/help/add-my-custom-host-names-12320) and [ServerFault](https://serverfault.com/questions/61015/whats-required-for-a-nameserver-to-be-registered) for more.

8. Ready to serve!

The rink is now set up and ready to start creating and managing verbers

**New VPS via rink**

| **Rink** :$

```console
cd ~/rink
./addvps john ink 1gb laemp1 someuser yto America/Detroit # 1GB RAM $5/month
./addvps john ink 1gb laemp1 someuser # 1GB RAM $5/month
./addvps john ink 1gb laemp1 otherusr sea America/Los_Angeles # 1GB RAM $5/month
./addvps name ink 2gb laemp1 someuser sjc America/Los_Angeles # 2GB RAM $10/month
./addvps john ink 1gb laemp1 someuser ord America/Chicago # 1GB RAM $5/month
```

**Import a pre-existing Verber to become managed by a Rink**

First, make sure the to-be-imported Verber is up-to-date...

| **Imported-Verber** :$

```console
/opt/verb/serfs/updateverber
```

| **Rink** :$

```console
vultr-cli instance list
```

```console
rink/run/importvps name ink start 1c1ee091-0bb2-4871-8f02-170e3f192bcc
```

___

# ###
# Reference

# ## Everything below is for extended reference and may be redundant ##

- Essentially, this describes that the rink/run scripts are doing behind the scenes
- This later describes how to create a custom Arch VPS instance on Vultr based on the Vultr docs

# Preparing for production

## setup
This presumes that rink is installed on this server per instructions farther below
### Rink (Where rink is installed, signup originates, and Vultr API works)
```
cd verb/inst
./make-dns rink mynsdomain.tld
./setup rink ink email vip rink long.rink.ipvr.four long:rink:ipvr:six cb@mynsdomain.tld 100 1000 America/Los_Angeles 1222 boss "$(/usr/bin/pwgen -s -1 16)" verb-update inkverb
reboot
cd rink/run
./newvps ns1 ink 1gb sea laemp1 boss
./newvps ns2 ink 1gb sea laemp1 boss
```
Commands for the two servers below are run from the controlling rink server above
### Slave ns1
```
/opt/verb/inst/make-dns ns1 mynsdomain.tld
/opt/verb/inst/setup rink1 ink email vip ns1 long.ns1.ipvr.four long:ns1:ipvr:six cb@mynsdomain.tld 100 1000 America/Los_Angeles 1222 boss "$(/usr/bin/pwgen -s -1 16)" verb-update
reboot
/opt/verb/serfs/inkdnsaddslave rink.verb.ink long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.email long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.one long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.blue long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.vip long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.red long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.kiwi long.rink.ipvr.four long:rink:ipvr:six
```
### Slave ns2
```
/opt/verb/inst/make-dns ns2 mynsdomain.tld
/opt/verb/inst/setup rink2 ink email vip ns2 long.ns2.ipvr.four long:ns2:ipvr:six cb@mynsdomain.tld 100 1000 America/Los_Angeles 1222 boss "$(/usr/bin/pwgen -s -1 16)" verb-update
reboot
/opt/verb/serfs/inkdnsaddslave rink.verb.ink long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.email long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.one long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.blue long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.vip long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.red long.rink.ipvr.four long:rink:ipvr:six
/opt/verb/serfs/inkdnsaddslave rink.verb.kiwi long.rink.ipvr.four long:rink:ipvr:six
```

### Concluding info, for reference
```
ns1
IP4 long.ns1.ipvr.four
IP6 long:ns1:ipvr:six
ns2
IP4 long.ns2.ipvr.four
IP6 long:ns2:ipvr:six
```

- Zone IP is set for both rink.verb.ink and rink.mynsdomain.tld
- rink.mynsdomain.tld set in /etc/hostname & /etc/hosts
- Nameservers are: ns1.mynsdomain.tld & ns2.mynsdomain.tld

## Managing slave DNS nameserver

- Create NS slave nameservers from a normal "laemp-keyed" snapshot
- Install these using `make-dns` first
  - Host names must match
- All of these instructions are early near the top of this document

## On the nameserver:
- Managed by inkdnsaddslave, inkdnskillslavedns & inkdnsshowslavedns
- Updated according to /opt/verb/conf/inkdns/sdns/s.prairs.com
- Achieved with: inkdnsrefreshbind
- FYI, file will exist, do not create manually:
| **/var/named/named.conf.verb** :
zone "mynsdomain.tld" {
 type slave;
 file "db.mynsdomain.tld";
 masters { 0:ip6::0 1.2.3.4; };
 allow-transfer { none; };
}

## How to add a slave domain (and accomplish the above)
`serfs/inkdnsaddslave mynsdomain.tld 1.1.1.1 0001:0000:0000:0000:0000:0000:0000:0001`
- Theoretically, do this both on the local rink, also remotely to the tertiary rink server set up the same way as ns1.mynsdomain.tld

## On the Verber:
add domains using serfs/adddomain, etc

# ## Vultr CLI API is handled automatically via rink, this is for reference ##

# Vultr
1. Install on Arch
```
pacman -S vultr-cli --noconfirm
```

2. Set the key
export VULTR_API_KEY='LONG_KEY_FROM_VULTR_API'

| **/root/.vultr-cli.yaml**:
```
api-key: LONG_KEY_FROM_VULTR_API
```
OR Command: $
```
echo 'api-key: LONG_KEY_FROM_VULTR_API' > /root/.vultr-cli.yaml
vultr-cli instance list --config /root/.vultr-cli.yaml
```

3. Create a startup script that generates new ssh_host_ keys

https://my.vultr.com/startup/

| **New SSH host keys** :

```
#!/bin/bash

rm /etc/ssh/ssh_host_*
ssh-keygen -A
```

4. Whitelist your IP address in
- https://my.vultr.com/settings/#settingsapi
- Note /32 is the default for that field

5. Start a new server
```
vultr-cli instance create --region sjc --plan vc2-1c-1gb --snapshot snapshot-long-serial-number --label name.verb.ink --ipv6 true
vultr-cli instance create --region sjc --plan vc2-1c-1gb --snapshot snapshot-long-serial-number --label ns1.mynsdomain.tld --ipv6 true
```

Output:
```
INSTANCE INFO
ID			1c2f1494-024b-4d65-8dc1-a244bcc11494
Os			Snapshot
RAM			1024
DISK			0
MAIN IP			0.0.0.0
VCPU COUNT		1
REGION			sjc
DATE CREATED		2021-06-03T10:37:26+00:00
STATUS			pending
ALLOWED BANDWIDTH	1000
NETMASK V4
GATEWAY V4		0.0.0.0
POWER STATUS		running
SERVER STATE		none
PLAN			vc2-1c-1gb
LABEL			name.verb.ink
INTERNAL IP
KVM URL
TAG
OsID			164
AppID			0
FIREWALL GROUP ID
V6 MAIN IP
V6 NETWORK
V6 NETWORK SIZE		0
FEATURES		[]

Output of pending new instance:
IP		NETMASK		GATEWAY		TYPE		REVERSE
0.0.0.0				0.0.0.0		main_ip		0.0.0.0
======================================
TOTAL	NEXT PAGE	PREV PAGE
1
```

Get the instance info:
```
vultr-cli instance list
vultr-cli instance ipv6 list ID
vultr-cli instance ipv4 list ID
```

More info:
```
vultr-cli plans list
vultr-cli os list
vultr-cli regions list
vultr-cli snapshot list
vultr-cli instance
vultr-cli instance stop ID
vultr-cli instance restart ID
vultr-cli instance delete ID
```

# Extra scratch notes

# Add key to local ssh (so you won't be prompted the first time you ssh in)
```
ssh-keyscan -H -p 22 IP4ADDRESS >> ~/.ssh/known_hosts
```

## cat in Arch_Vultr SSH key to root
```
mkdir /root/.ssh
chmod 700 /root/.ssh
cat <<EOF > /root/.ssh/authorized_keys
some_key
EOF
chmod 600 /root/.ssh/authorized_keys
```

## Manage like normal server, after this

## Prep for preverber: ##

## Install Vim and git
```
pacman -S vim git --noconfirm
```

## Install ssh keys
```
mkdir /root/.ssh
chmod 700 /root/.ssh
vim /root/.ssh/authorized_keys # Paste in your keys
chmod 600 /root/.ssh/authorized_keys
```

## Change port
```
sed -i 's/#Port 22/Port 1222/' /etc/ssh/sshd_config
systemctl restart sshd
```

## Useful commands
- `journalctl -xn --unit postfix`
- `journalctl -u postfix`

# Add partitions cheat sheet
1. Create a new block storage
2. Attach it to an instance
- Use the web interface the CLI tool
- HDD and NVMe interact with an instance the same once they are attached, but availability depends on region

*Prerequesite: `parted` must be installed*
```bash
pacman -S --noconfirm --needed parted
```

*The first will be vdb*

```bash
parted -s /dev/vdb mklabel gpt
parted -s /dev/vdb unit mib mkpart primary 0% 100%
mkfs.ext4 /dev/vdb1
mkdir /mnt/SOME_NAME
echo >> /etc/fstab
echo /dev/vdb1               /mnt/SOME_NAME       ext4    defaults,noatime,nofail 0 0 >> /etc/fstab
mount /mnt/SOME_NAME
reboot
```
*Now, it is mounted at* `/mnt/SOME_NAME`

*The next will be vdc*
```bash
parted -s /dev/vdc mklabel gpt
parted -s /dev/vdc unit mib mkpart primary 0% 100%
mkfs.ext4 /dev/vdc1
mkdir /mnt/SOME_NAME2
echo >> /etc/fstab
echo /dev/vdc1               /mnt/SOME_NAME2       ext4    defaults,noatime,nofail 0 0 >> /etc/fstab
mount /mnt/SOME_NAME2
reboot
```
*Now, it is mounted at* `/mnt/SOME_NAME2`

# Another Arch Install exampl
- [https://www.vultr.com/docs/install-arch-linux-with-btrfs-snapshotting/]

