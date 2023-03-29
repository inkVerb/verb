# Learning inkVerb

"Serfs" are BASH/SH scripts that do the different jobs of the server, but not in /bin, so you need `./` in front of them.

Serfs are run from `~/verb/serfs/`

Get there with `cd ~/verb/serfs/`

A "Verber" is a web server with "Verb" installed on it.

A "Vrk Station" is a local computer, such as a desktop or laptop, with "Vrk" installed on it.

On a "Vrk Station", "Serfs" are replaced by "Surfers" and can be run from any path, not only `~/verb/serfs/` .

An "Inker" is a Verber with "Ink" installed on it, giving it extra powers to help, backup, update, and support many Verbers.

A "CA Verber" is a Verber that has been made capable of having Clients connect to it.

"CA" stands for "Certificate Authority" because the Verber has some "cert-authority" tools installed on it to govern its connections to Clients.

An "Inker" must be a "CA Verber" always.

A "Verber" must be a "CA Verber" IF you want a "Vrk Station" to connect to it, usually to control it.

To do any of this, first you must install Verb on the web server or Vrk on a local computer.

While you can always connect to your Verber via SSH, installing Vrk on your local computer makes this more convenient.

To do any of this Vrk-Verber connecting, next install inkNet (an inkVerb product included in Verb and Vrk).

Installing "Ink" to make a "Verber" into an "Inker" is optional if you are connecting to an Inker someone else manages.

# Install Verb
On a fresh Ubuntu VPS with ssh keys already installed...

## 0. Set up the Verber

`ssh root@YOUR_IP_ADDRESS`

`apt-get update && apt-get upgrade -y`

`apt-get install git`

`cd /opt && git clone https://github.com/inkverb/verb-dev`

`mv verb-dev verb && cd verb/inst`

`./make-preverber`

`reboot`

`ssh root@YOUR_IP_ADDRESS`

`cd verb/inst`

`./make-verber 4` (or other number for swap size in GB: 1, 2, 4, 8, 16, 32, 64)

*(There is an additional option in `./make-verber` to set the mysql root password, but it is best for that to be automated because you don't need it unless you have some preexisting reason)*

This: `./setup [host] [namespace] [tld] [email] [serverIPv4] [serverIPv6 - if none use IPv6NA ] [SSLemail] [php.file-limit] [php.up-size] [php.city] [new-port] [new-boss] [boss-pass] [update-repo - optional]`...

Eg: `./setup johnny johnny ink email 56.22.108.77 IPv6NA letsencrypt-messages@example.com 100 1000 America/New_York 22 boss bosspassword verb-dev-update`

`reboot`

`ssh root@YOUR_IP_ADDRESS`

`cd ~/verb/serfs`

...Now you're ready to work...

## 1. Certbot

`./inkcertinstall YOUR_DIGITALOCEAN_API_KEY`

`apt-get update && apt-get upgrade -y`

`./inkcertdocbdigoc-all-verbs`

## 2. Vmail

`./inkvmailinstall YOUR_SECRET`

## 3. Start adding your domains

`./inkcertdole EACH_HOSTED_DOMAIN`


All done!

# Install Ink (optional)

# Install Vrk (probably, but optional)

# Install inkNet
*NOTE: This is only for verb.ink namespace Verbers. If you are running the (free) "domain mod" on a "domVerber" (i.e. 'ink.jessesteele.com' etc. rather than paying for 'jessesteele.verb.ink'), you will need "inknetdom..." Serfs ON THE DOM-VERBER. If you are connecting a normal Verber to a domVerber, run normal "inknet..." Serfs on the Verber and "inkdom..." Serfs on the domVerber.*

## I. Make your machine a Client (optionally for Verbers: also a CA Verber or an Inker)
### A. On an Inker
*Type all this on the Inker to-be CA Verber also*
1. Tell inkNet it is an Inker:
`./inknetmakeverberclient I_AM_INKER`
2. That's it. You're done. Next step...

### B. On a Verber, NOT an Inker (your server in the cloud that does everything)
*Type all this on the to-be CA Verber*
1. First always, set the information for the Primary CA Verber you intend to connect to:
`./inknetmakeverberclient [CA Verber host] [CA Verber URI] [CA Verber name] [CA Verber IP]`
*Get the info from the CA Verber, either from your own Verber (`./showinknet`) or use the information you were given.
Eg:
`./inknetmakeverberclient rinkhost ink.verb.ink rinkhost_ink_verb_ink 999.99.99.999`
`./inknetmakeverberclient i1host inkisaverb.com i1host_inkisaverb_com 999.99.99.999`
2. Then, you can make your Verber a Secondary CA Verber, even if it is not an Inker:
`./inknetmakeca`
*For many purposes, backup servers, or just to allow a Vrk Station to connect.
3. (FYI) You can also make your Verber a client to Secondary CA Verbers:
`./inknetaddsecondarycaverber [CA Verber host] [CA Verber URI] [CA Verber name] [CA Verber IP]`
*Usually for a backup server or backup email server or your own DNS and handled automatically by other Serfs.
Eg:
`./inknetaddsecondarycaverber joey1 joestrucking.verb.ink joey1_joestrucking_verb_ink 444.44.44.444`

### C. On a Vrk Station (your computer at home that you use to manage Verbers)
*Type all this on the to-be Vrk Station*
*Vrk Station Surfers are in the /bin, so they don't need* `./` *in front of them.*
1. You can just run `inknetinstall`, which will ask you questions if you don't add any information.
*This only adds one Verber. To add more Verbers after this step, you can run it again.*
*For developers who want to make a script, follow instructions inside* `inknetinstall`
##### If you complete Step one, you can skip steps 3-5 below. Below is mainly for developers, if you are into that.
2. You can make your Vrk Station a Client manually (CA Verber info added later):
`inknetmakevrkclient [Vrk IP - if known] [Vrk URI - if known] (must add IP first, if unknown, use 'NOT_SET')`
Eg:
`inknetmakevrkclient 333.33.33.333`
`inknetmakevrkclient 333.33.33.333 joesoffice.joestrucking.verb.ink`
`inknetmakevrkclient NOT_SET joesoffice.joestrucking.verb.ink` (if URI is known, but IP is not)

3. Then, add (additional) Verbers one at a time:
`inknetaddverber [Verber URI] [Verber inkNet machine name] [Verber IP]`

4. Then add the CA Verber's info (which will download and install the CA Verber's public key):
*Get the info with* `showinknet`
`inknetaddcaverberpubkey verber_server_machine_name`

## Legacy and incomplete
*Below is legacy information that may have been incomplete at the time .ink tools were developed for the `ink` command.*

*This is intended to connect the Arch web server to a local Arch/Manjaro machine for some seamless workflow*

*It is possible that `rsync` could be used as a more effective tool*

*Or, in product roadmapping, this could be depreciated as "building nails because we already hold an otherwise useless hammer"*

## II. Start Connecting Client to CA Verber
### A. On a Verber Client
*Type all this on the Client Verber*
1. First, create your Client key: (It will also be displayed.)
`./inknetnewverberclientkey`
*Don't do this too often. Once you change your Client key, any connections to other CA Verbers will break and need to be remade.*

2. (FYI) Get the Client key on your Client Verber again, if you want to connect it to a Secondary CA Verber
`./showinknetverberclientkey`

### B. On a Vrk Client
*Type all this on the Client Vrk Station*
1. You should already have seen your Vrk Client key. To see it again:
`showinknetkey`

2. (FYI) Reset the Vrk Client key anytime to break connections to CA Verbers:
`inknetnewvrkclientkey`
*Don't do this too often. Once you change your Client key, any connections to other CA Verbers will break and need to be remade.*

## III. Register the Client on the CA Verber
### A. For a Client Verber
*Type all this on the CA Verber*
- Add the Client Verber's information on the CA Verber:
`./inknetaddverberclient [Verber host - usually same as namespace] [Verb namespace] [Verber tld] [Verber IP]`
Eg:
`./inknetaddverberclient joey joey ink 999.999.999.999 (most common)`
`./inknetaddverberclient joey joey email 999.999.999.999 (if email is on a different server)`
`./inknetaddverberclient joey2 joey ink 999.999.999.999 (if there are two servers for joey, rare but possible)`
*The CA Verber will give you instructions*

### B. For a Client Vrk Station
*Type all this on the CA Verber*
- Add the Client Vrk Station's information on the CA Verber:
`inknetaddverber [Verber URI] [Verber inkNet machine name] [Verber IP]`
Eg:
`inknetaddverber john john ink 999.999.99.999 (for john namespace)`
`inknetaddverber john john email 999.999.99.999 (for john namespace, if he has a separate server for the NAME.verb.email address)`
`inknetaddverber john2 john ink 999.999.99.999 (for john namespace, if he has a separate server for the NAME.verb.email address, and if john2 is the special chosen hostname)`
`inknetaddverber ink2 ink.inkisaverb.com ink2_ink_inkisaverb_com 999.999.99.999 (for Domain Verber mod, and if ink2 is the special chosen hostname)`

## IV. Finalize the Connection
### A. For a Client Verber
*Type all this on the Client Verber*
- Install the CA Verber's credential pack on using the code the CA Verber gave you:
`./inknetaddcavpkg [code from CA Verber]`
*You don't need any special information to this Serf, but if you don't, you will be prompted for the code.*

### B. For a Client Vrk Station
*Do all this on the Client Vrk Station*
1. Download and install the .ink package from the CA Verber. Follow the instructions that the CA Verber gave you.
2. Put the downloaded file in your home folder: `~/` ( same as `/home/YOUR-USER-NAME/` )
3. Install the CA Verber/Inker's credential pack on the Client Vrk Station:
`inknetaddcavpkg`
*You don't need any special information to this Surfer*

## V. Finished
Now, the Client and CA have been connected on inkNet.

From this point forward, you won't see evidence of inkNet in use, but it will allow your Vrk Stations and Verbers to talk to each other when they need to, such as for updates, SSH login from the Vrk Station, or chances in settings.
