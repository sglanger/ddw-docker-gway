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
host="127.0.0.1"
image="ddw-gway"
instance="ddw-gw"

case "$1" in
	build)
		# first clean up if any running instance
		# Comment out the rmi line if you really don't want to rebuild the docker
		sudo docker stop $instance
		sudo docker rmi -f $image
		sudo docker rm $instance

		# now build from clean. The DOcker run line uses --net="host" term to expose all the docker ports
		# on the Host's NIC. For better security, remove it. But then must do work shown in case "start"
		sudo docker build --rm=true -t $image .
		sudo docker run --net="host" --name $instance -e POSTGRES_PASSWORD=postgres -d $image
		sleep 3
		sudo docker ps
		sudo docker exec -u root $instance /docker-entrypoint-initdb.d/service-start.sh
	;;

	conn)
		sudo docker exec -it $instance /bin/bash 
	;;


	conn_r)
		sudo docker exec -u root -it $instance /bin/bash
	;;

	restart)
		$0 stop
		$0 start
	;;

	status)
		sudo docker ps; echo
		sudo docker images 
	;;

	stop)
		# stops but does not remove image from DOcker engine
		sudo docker stop $instance
		sudo docker rm $instance
	;;

	start)
		# here we launch DOcker w/out the --net="host" tag , but then no ports are exposed including 104
		# so we expose them one at a time with -p switches on the container address
		host=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $instance)
		# the trick is to know the IP before the docker is created, and yes it is a trick
		sudo docker run -p $host:8080:8080 -p $host:8443:8443 -p $host:10004:104 --name $instance -e POSTGRES_PASSWORD=postgres -d $image
		sleep 3
		sudo docker ps
		#sudo docker exec -u root $instance /docker-entrypoint-initdb.d/service-start.sh
	;;


	*)
		echo "invalid option"
		echo "valid options: build/start/stop/status/conn"
		exit
	;;
esac
