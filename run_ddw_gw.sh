#!/bin/bash

###############################################
# Author: SG Langer Jan 2016
# Purpose: put all the Docker commands to build/run 
#	ddw-gway in one easy place
#
# Notes: If you are building from scratch, run this whole thing
#	If pulling from Docker hub, just run the RUN and EXEC lines
##########################################

# still cannot start mirth hwen it points to postgres, it's related to table access rights see here
# http://dba.stackexchange.com/questions/33943/granting-access-to-all-tables-for-a-user
# GRANT CONNECT ON DATABASE database_name  TO user_name;

############## main ###############
# Purpose: Based on command line arg either
#		a) build all Docker from scratch or
#		b) kill running docker or
#		c) start Docker or
#		d) restart
# Caller: user
###############################
clear

case "$1" in
	build)
		# first clean up if any running instance
		# Comment out the rmi line if you really don't want to rebuild the docker
		sudo docker stop ddw-gw
		sudo docker rmi -f ddw-gway
		sudo docker rm ddw-gw

		# now build from clean. The DOcker run line uses --net="host" term to expose the docker ports
		# on the Host's NIC. For better security, remove it
		sudo docker build --rm=true -t ddw-gway .
		sudo docker run --net="host" --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway
		sleep 3
		sudo docker ps
		sudo docker exec -u root ddw-gw /docker-entrypoint-initdb.d/service-start.sh
	;;

	status)
		sudo docker ps; echo
		sudo docker images 
	;;

	stop)
		# stops but does not remove image from DOcker engine
		sudo docker stop ddw-gw
		sudo docker rm ddw-gw
	;;

	start)
		sudo docker run --net="host" --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway
		sleep 3
		sudo docker ps
		sudo docker exec -u root ddw-gw /docker-entrypoint-initdb.d/service-start.sh
	;;


	*)
		echo "invalid option"
		echo "valid options: build/start/stop/status"
		exit
	;;
esac
