# Introduction

_**RARE (Router for Academic, Research & Education)**_ focus is on determining if a routing software platform  solution can fit R&E use cases. The project aims to inte
grate different pieces of software related to these building blocks:

* control plane,
* date plane
* and communication between the control plane and data plane.
A key part of the work consists in enabling a control plane software to pilot a data plane via a programmatic interface. P4 is a such language proposing an interface t
hat allows data plane programmability. P4 is also inherently independent from the target or NPU processor architecture.
Using P4 language leverages several existing software components. A feature rich dataplane software switch written in P4 is already available; communication between th
e control plane and data plane is also already part of the specification standard.

# Repository structure
RARE/
├── labs
└── utils

**Credits**
All materials here inherit from several P4Lang public resources:
*	[P4Lang project resources]i (https://p4.org/) 
*	[Andy Fingerhut P4 guides] (https://github.com/jafingerhut/p4-guide)
*	[P4Lang material from ETH Zurich / Advanced Topics in Communication Networks lecture] (https://github.com/kevinbird61/p4-researching.git)
*	[Kevin Cyu] (https://github.com/kevinbird61/p4-researching.git)

