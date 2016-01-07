#!/bin/bash

###############################################
# Author: SG Langer Jan 2016
# Purpose: put all the Docker commands to build/run 
#	ddw-dbase in one easy place
#
# Notes: If you are building from scratch, run this whole thing
#	If pulling from Docker hub, jusr run the RUN and EXEC lines
##########################################

# first clean up if any running instance
# Comment out the rmi line if you really don't want to rebuild the docker
sudo docker stop ddw-gw
sudo docker rmi -f ddw-gway
sudo docker rm ddw-gw


# now build from clean. The DOcker run line uses --net="host" term to expose the docker
# on the Host's NIC. For better security, remove it
sudo docker build --rm=true -t ddw-gway .
#sudo docker run --net="host" --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway
sudo docker run  --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway
sleep 1
sudo docker ps
sleep 3
sudo docker exec -u root ddw-gw /docker-entrypoint-initdb.d/service-start.sh



