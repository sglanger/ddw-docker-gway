#!/bin/bash

###############################################
# Author: SG Langer Jan 2016
# Purpose: put all the Docker commands to build/run 
#	ddw-gway in one easy place
#
# Notes: If you are building from scratch, run this whole thing
#	If pulling from Docker hub, just run the RUN and EXEC lines
##########################################

# first clean up if any running instance
# Comment out the rmi line if you really don't want to rebuild the docker
sudo docker stop ddw-gw
sudo docker rmi -f ddw-gway
sudo docker rm ddw-gw


# now build from clean. The DOcker run line uses --net="host" term to expose the docker
# on the Host's NIC. For better security, remove it

sudo docker build --rm=true -t ddw-gway .
sudo docker run --net="host" --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway
sleep 3
sudo docker ps
sudo docker exec -u root ddw-gw /docker-entrypoint-initdb.d/service-start.sh

# still cannot start mirth hwen it points to postgres, it's related to table access rights see here
# http://dba.stackexchange.com/questions/33943/granting-access-to-all-tables-for-a-user
# GRANT CONNECT ON DATABASE database_name  TO user_name;




