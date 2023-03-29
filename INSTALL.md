# Installation:
## Requirements
This is intended to run on:
- An Arch Linux VPS hosted by Vultr
- It requires 3 servers to manage other production servers:
  1. A "rink" master, which uses the Vultr API to create additional production servers
	  - All "verber" VPS servers are created from this server
		- Installed with "inkVerb/verb", in addition to "inkVerb/rink"
		- Host is someotherdomain.tld, not maindomain.tld
		- Set someotherdomain.tld in `conf/inklists/inkdnsnameservers` as `BaseHostNS=`
	2. First 'DNS slave' nameserver
	  - Installed with "inkverb/verb"
		- Set `inst/make-dns` before running `setup`
		- Host is ns2.someotherdomain.tld
		- This IP and domain must be listed in `conf/inklists/inkdnsnameservers`
		  - `DefaultNS1=`
			- `RINK1ip4=`
			- `RINK1ip6=`
	3. Second 'DNS slave' nameserver
		- Installed with "inkVerb/verb"
		- Set `inst/make-dns` before running `setup`
		- Host is ns2.someotherdomain.tld
		- This IP and domain must be listed in `conf/inklists/inkdnsnameservers`
		  - `DefaultNS2=`
			- `RINK2ip4=`
			- `RINK2ip6=`
	4. Production "Verber" servers
	  - Installed with "inkVerb/verb"
		- Created through the "inkVerb/rink" tools from the "rink" master (Section 1, above)
		- Using defaults as defined above
		- If you want to manage your own instance, you can do this either:
		  - Via a single stand-alone, creating a verber manually, but you must manage DNS records on your own
			- Via two nameservers, then create verbers manually, but DNS will be managed
			- But, you will need to refer to the Customization section at the end of this document
# Install steps

This is a fast overview of the install steps. For a more thorough guide, see the [Official Cheat Sheet](https://github.com/inkVerb/verb/blob/main/dev/official-cheat-sheet.md)

## 1. SSH access
	- You must have SSH root access to an Arch Linux VPS
	- This must have `git` already installed
  - `pacman -S git`
## 2. Download inkVerb from git
	- `cd /opt`
	- `git clone https://github.com/inkVerb/verb`

## 3. Run the installation scripts
	`cd /opt/verb/inst`

### A. Normal installation
#### i. `./make-preverber` prepares the server, mainly for locale
		* Follow in-file instructions, has optional parameters, reboot
		* Locale setup may ask for settings, defaults should be okay, US-English is usually the goal.
		* `reboot`
#### ii. `./make-verber-laemp [ swap size in GB, ie: 2 ]` prepares directories, Apache/Nginx configs, web apps, swap, "boss" users, etc. for installation, but no hostname or IP is defined yet.
		* After, login again and get back to the install directory:
		  * `cd /opt/verb/inst`
		* Follow in-file instructions, requires parameters, reboot
		* Now the server is a standard out-of-box inkVerb, ready to setup, can be copied as-is
		* `reboot`
		* Note that `make-verber-lemp` and `make-verber-lamp` may not function with all features as `make-verber-laemp` is the primary installer used for production, the others are available for other devs to have options in their own customization

At this point (if it is not a `make-dns` server), you may want to take a "snapshot" of your VPS because this will be the model for all future production "verbers" you create, then you can skip the above steps when creating future VPS servers

### B. Optional custom pre-installation
  - Look in the head of these files for instructions
	- The host used in these must match the host used by `setup` later in the installation!
#### ii. Is this a domain mod?
	Are you using your own vanity domain instead of the verb.ink domains?
	- `./make-dommod [ host ] [ domain.tld ]`
	- You will need two other slave DNS verbers set up, according to the next step
#### iii. Is this a DNS slave nameserver?
  This can still operate as a normal verber, but if you want to use it as either a [Rink](https://github.com/inkverb/rink) or as one of the NS servers it controls, you need this
	- `./make-dns [ host ] [ domain.tld ]`
	- This will override some normal host configuration settings

### C. Final stage: Rink vs Custom
  * `./setup [ long list of settings, see instructions inside the file ]` is the final step for a Verber going live
    * sets hostnames, IP, inkVerb namespace, and other settings across the server and the site goes live
  * **Normally do not do this, use the [Rink](https://github.com/inkverb/rink)**
    * To this point, the steps above have prepared the server: both the "Rink" with it's keys and the Verber snapshots (with the Rink public keys installed)
    * From this point, finalization should be run by the Rink, per the steps in the [Official Cheat Sheet](https://github.com/inkVerb/verb/blob/main/dev/official-cheat-sheet.md) at step 5
  * **To continue manually, SSH back into the LAEMP server after reboot**
		* After, login again and get back to the install directory:
		  * `cd verb/inst`
		* Follow in-file instructions near the top of the `setup` file, requires parameters
    * After running `setup`, you will need to run these manually:
      * `rinkupdatekeys`
      * `rinkupdateallverbs`

## 4. Preparing for production
### The 'ink' tool
  - Verbers are equipped with an `ink` CLI tool
	- Access the Help information with `ink -h`
	- Learn how to install and manage SSL certs with `ink cert -h`
	- Explore the Help information to learn how to manage domains, SQL, web settings, and more

## 5. Customization
  - Verbers are intended to be created and maintained by a "rink", using original settings from the GitHub repos
	- You can override these, but you must set them accordingly
	- If you are using your own, customized nameservers, add this line to `conf/inklists/inkdnsnameservers`
	  - `CUSTOMRINK="true"`
		- This will prevent updates from over-riding your custom nameservers

### Custom install instructions

These instructions expand on the instructions above under point 3. A. "Custom pre-installation"

1. Create your Arch Linux VPS with SSH access
  - ***Always use `inst/make-dommod` before any other installers in `inst/` because you are not using the native verb.ink domains!***
	- Install `git` and clone from [https://github.com/inkverb/verb], which is used under a GNU license that you must read and agree to!
	- Installation always begins in `verb/inst`, using the first three main "Install steps" at the top of this document
  - A verber has several "verb domains" available, such as ink, one, email, blue...
  - Verb domains can be enabled and disabled, usually to balance load or for security via compartmentalization
  - To disable or re-enable any verb domains, run these at any point before running `setup`
    - `inst/preverboff`
    - `inst/preverbon`
2. Use custom nameservers or manage DNS records manually
  - **Custom nameservers** (requires two extra servers)
	  - Follow *First/Second 'DNS slave' nameserver* instructions from above, repeated here:
		- Installed with "inkVerb/verb"
		- Set `inst/make-dns` at any point before running `setup`
		- Host is ns1.someotherdomain.tld/ns2.someotherdomain.tld
		- This IP and domain must be listed in `conf/inklists/inkdnsnameservers`
		  - `DefaultNS1=`/`DefaultNS2=`
			- `RINK1ip4=`/`RINK2ip4=`
			- `RINK1ip6=`/`RINK2ip6=`
		- On this and all other Verbers you create, to `conf/inklists/inkdnsnameservers` add:
	  	- `CUSTOMRINK="true"`
    - Run `serfs/rinklocalsetup` to create the keys used to auto-update the NS nameservers
      - Per instructions, you will need to manually add the Rink_... keys created to each NS nameserver
    - Run `serfs/rinkupdatekeys` so SSH updates will be allowed when connecting to your NS nameservers
      - Only do this after the keys from `serfs/rinklocalsetup` have been added
	- **Manual DNS**
	  - With this, you may ignore the above steps because they will be obsolete
	  - DNS records *as they are expected to be* will be in:
		  - `conf/inkdns/zones/` for normal, hosted domains
			- `conf/inkdns/inkzones/` for the basic domains and subdomains managing the verber
		- You must review the db.* and nv.* files here to create DNS records wherever you park your nameservers
		  - With some registrars or hosts, you are allowed to upload a manual Zone file. In that case, you can use these entire files with copy-paste because they are intended to be used as-are
			- However, these files will need some modification because the `NS` records and `inkisaverb.com` domain at the top will need to be changed to whatever your true nameservers are
		- Learn how to easily read these zone files with `ink show -h`
3. Use these same settings (`conf/inklists/inkdnsnameservers` for custom nameservers) in future Verber instances
  - Resume installation under point 3. A. "Normal installation" above

## 6. Developer information

In the `verb/dev/` folder you will find substantial information useful developers who want to "pop the hood" and expand

If you want to know how we do all the installation from our end, look at `verb/dev/official-cheat-sheet.md`

## 7. DNS for your nameservers

Verber NS servers cannot contain DNS zone records for their own domain.

If you want to host a website and/or email for your NS servers

- Simply add that domain on a normal verber or the Rink itself, but neither NS server
  - `ink add domain mynameserver.tld`
- Then manually copy records to the control panel or zone file where the domain is parked, less any NS records
