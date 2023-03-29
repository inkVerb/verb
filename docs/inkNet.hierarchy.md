#!/bin/sh
# inkVerb flow, verb.ink
# This shows the flow process of adding SSH keys and certs between a CA and Clients in the inkNetwork
## This is a dependency for the inkCert SSL cert service, along with other P2P communication, between local computers (Vrk Stations) and inkVerb servers (Verbers) and the main server Verbers connect to for basic services (Inker)

## This is intended to be run on any Verber, but is also the same core basis for an Inker, with only a few changes in variables.

## Serf? with a question mark runs based on if-statements for fulfilling dependencies and other conditions

## Long "hashlines" of hash marks allow hiding notes in them
### Hashlines are hierarchical, the serf at the top line automatically runs all serfs under it in a cluster, like so:
#### Runme
### Automaticallyrunme
## Automaticallyrunmealso
### Nextautomaticallyrunme
### Nextnextautomaticallyrunme
##FINISH
## Now, the above cluster has finished, by running one command: Runme


# inkNet

## Setup

# CA Verber #
##### Serf: inknetmakeverberclient I_AM_INKER
#### Serf: setinkcertsslca
#### Serf: setinkcertsshca
#### Serf: setinkgetrepo
#### Serf: setinknetsslca
#### Serf: setinknetsshca
#### Serf: setinknetrepo
#### Serf: inknetinstallivapp

##### Serf: inknetinstallca
#### Serf? inknetmakeca
### Serf? inkcertinstall
#### Serf: inknetnewcaselfauthpubkey
#### Serf: inknetnewcahostkey
#### Serf: inknetsecuredldircron
#### Serf? inknetinstallivapp

# Client Verber #
##### Serf: inknetmakeverberclient
#### Serf: setinkcertsslca
#### Serf: setinkcertsshca
#### Serf: setinkgetrepo
#### Serf: setinknetsslca
#### Serf: setinknetsshca
#### Serf: setinknetrepo
#### Serf: inknetinstallivapp
#### Serf: inknetivappnewclientsailor
### Serf: inknetaddcaverberpubkey

# Client Vrk Station #
##### Surfer: inknetinstall
#### Surfer: inknetmakevrkclient
#### Surfer: inknetaddverber
#### Surfer: inknetaddcaverberkey
#### Surfer: inknetnewvrkclientkey
### Serf: showinknetkey

## Connect

# Client Verber (Primary Inker) #
##### Serf? inknetnewverberclientkey (run first time only)
#### Serf: showinknetverberclientkey

##### Serf: showinknetverberclientkey (use to see the key to connect to additional CA Verbers)

# Client Verber (For Secondary CA) #
##### Serf: inknetaddsecondarycaverber
#### Serf: inknetivappnewclientsailor
### Serf: inknetaddcaverberpubkey
##### Serf: inknetnewverber2clientkey


# Client Vrk Station #
##### Serf?: showinknetkey (use if needed, )

# CA Verber #
##### Serf: inknetaddvrkclient/inknetaddverberclient
#### Serf: inknetivappadduser
##### Serf: inknetaddclientkey
##### Serf: inknetpackclientpkg

# Client (Verber / Vrk Station) #
##### Serf/Surfer: inknetaddcavpkg (same name, different on Vrk and Verb!!)

# Client Verber (For Secondary CA) #
##### Serf/Surfer: inknetaddca2vpkg


## Done
## Now, the Client can login to the CA Verber with inknetlogin
######################################################################################

## Explanation of work-flow:
### Client to trust Host's Signed HostCertificate:
 - @ cert-authority declaration of CA's pub-signing key must be in ~/.ssh/known_hosts of the client
 - HostKey & HostCertificate must be listed in /etc/ssh/sshd_config
 - CA's pub-signing key sighed the HostKey, producing HostCertificate

### Host to trust Client Key:
 - CA: authorized_keys identify file is: /etc/ssh/authorized_keys/USER
 - CA: echo "AuthorizedKeysFile /etc/ssh/authorized_keys/%u" >> /etc/ssh/sshd_config
 - CA: cat inknet_client_CLIENTNAME_key.pub >> /etc/ssh/authorized_keys/USER
 - Client:
      echo "Host *
             IdentityFile /etc/ssh/inknet_client_CLIENTNAME_key" >> /etc/ssh/ssh_config

