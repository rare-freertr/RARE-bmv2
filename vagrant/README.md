# Vagrant definition of RARE Demo VM

In order to launch this VMs you will need vagrant and ansible installed as well as a virtualization engine. Nowadays VirtualBox and LibVirt are supported.

The system is launched with command:
- vagrant up

You can force either provider with:
- vagrant up --provider=virtualbox
- vagrant up --provider=libvirt

To connect to the machine:
- vagrant ssh

If you want to stop the machine:
- vagrant stop

If you want to delete everything and do a clean start:
- vagrant destroy

Before destroying there is the posibility to re-provision the machine downloading again the sources:
- vagrant provision
Provisioning allows you to use the --provision-with as shown below.

If vagrant was updated you may need to update your plugins:
- vagrant up --provider virtualbox  --provision-with repositories,ansible,unoptimized-ipv4

vagrant plugin update
- vagrant plugin update


The machine contains the directory RARE with the repository in its last version and every dependency needed.

The way to launch and test the different labs is as addressed in [RARE Repos](https://github.com/frederic-loui/RARE)

## Launching Unit Labs
### Unoptimized-ipv4
[Unoptimized IPv4 simple lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0001-unoptimized-ipv4-forwarding/p4src)
Launching the unoptimized IPv4 Unit Lab
vagrant up --provider virtualbox  --provision-with repositories,ansible,unoptimized-ipv4,unoptimized-ipv4-controlp,unoptimized-ipv4-connc


### IPv4 ISIS and Segment Routing
[ISIS-SR unit lab](https://github.com/frederic-loui/RARE/tree/master/00-unit-labs/0006-ipv4-isis-sr-operation/p4src)
vagrant up --provider virtualbox  --provision-with repositories,ansible,ipv4-isis-sr,ipv4-isis-sr-controlp,ipv4-isis-sr-connc
