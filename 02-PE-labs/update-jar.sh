#!/bin/bash
wget src.freertr.org/src/rtr.jar
mv rtr.jar 0000-topology-A/bin/
git add .
git commit -m "updating jar"
git push
