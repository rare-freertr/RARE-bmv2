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

The machine contains the directory RARE with the repository in its last version and every dependency needed.

The way to launch and test the different labs is as addressed in [RARE Repos](https://github.com/frederic-loui/RARE)


