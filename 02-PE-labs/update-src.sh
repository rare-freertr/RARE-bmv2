#!/bin/bash
wget src.freertr.org/rtr.zip
mkdir a
unzip -d a/ rtr.zip
rm rtr.zip
mv a/misc/p4bmv2/forwarder.py p4src/
mv a/misc/p4bmv2/router.p4 p4src/
mv a/misc/p4bmv2/include/* p4src/include/
mv a/misc/p4bmv2/p4runtime_lib/* p4src/p4runtime_lib/
rm -Rf a
git add .
git commit -m "updating p4 sources"
git push
