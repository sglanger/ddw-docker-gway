FROM postgres:9.2

MAINTAINER Steve Langer <sglanger@fastmail.COM>
###############################################################
# DDW-GWAY
# Purpose: SGL extensions to postgresql for DDW
# 	inspired by 	https://docs.docker.com/engine/examples/postgresql_service/
# 	and 		https://hub.docker.com/_/postgres/
#
# External Dependencies: all the "ADD" files below and
# 			run_ddw_gw.sh 	and
#			Docker ddw-db
##############################################################

# Build with  "sudo docker build --rm=true -t ddw-gway . "
# Run it with "sudo docker run --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway "
# Connect to above instance with "sudo docker exec -it ddw-gw /bin/bash" or "sudo docker exec -u root -it ddw-gw /bin/bash"
# get IP of instance with "sudo docker inspect ddw-gw "

# standard tools
ADD service-start.sh /docker-entrypoint-initdb.d/service-start.sh
ADD mirthdb.sql	/docker-entrypoint-initdb.d/mirthdb.sql
RUN chmod -R 777 /docker-entrypoint-initdb.d
RUN apt-get update && apt-get -y install nano
ENV TERM xterm
RUN apt-get -y install net-tools
RUN apt-get -y install nmap
RUN apt-get -y install ssh

########################## now install mirth 
# see http://www.mirthproject.org/community/forums/showthread.php?t=5077
#
RUN mkdir /usr/local/mirth
RUN apt-get -y install default-jre
RUN apt-get -y install curl
RUN curl -O http://downloads.mirthcorp.com/connect/3.4.1.8057.b139/mirthconnect-3.4.1.8057.b139-unix.sh
RUN chmod +x /mirthconnect-3.4.1.8057.b139-unix.sh
RUN ./mirthconnect-3.4.1.8057.b139-unix.sh -q -dir "/usr/local/mirth" -Dinstall4j.keepLog=true


################### Create a POstgresql cluster as ROOT
RUN pg_createcluster -u postgres 9.2 main
# now that postgres exists, we are going to replace the default MIRTH Derby dbase w/ it 
# to use it - MUST do this BEFORE becoming user postgres
ADD mirth.properties.psql /usr/local/mirth/conf/mirth.properties.new

# Run the rest of the commands as the ``postgres`` user 
USER postgres

# Create a PostgreSQL role named ``postgres`` with ``postgres`` as the password and
# then create the database `mirthdb` owned by the ``postgres`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
 	createdb -O postgres -U postgres mirthdb

# Adjust PostgreSQL configuration so remote connections to database are possible.
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.2/main/pg_hba.conf 
RUN echo "host all  all    127.0.0.1/32 trust" >> /etc/postgresql/9.2/main/pg_hba.conf
RUN echo "local all  all    trust" >> /etc/postgresql/9.2/main/pg_hba.conf

RUN echo "mirthdb	root		postgres" >> /etc/postgresql/9.2/main/pg_ident.conf
RUN echo "mirthdb	postgres	postgres" >> /etc/postgresql/9.2/main/pg_ident.conf


# STEP 21: And add ``listen_addresses`` to ``/etc/postgresql/9.2/main/postgresql.conf``
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.2/main/postgresql.conf

# STEP 22: Expose ports (DICOM, MIRTH)
EXPOSE 104
EXPOSE 8443
EXPOSE 8081

# from https://docs.docker.com/engine/examples/postgresql_service
# sudo docker run --volumes-from ddw-gw -t -i busybox sh
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# STEP 23: Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.2/bin/postgres", "-D", "/var/lib/postgresql/9.2/main", "-c", "config_file=/etc/postgresql/9.2/main/postgresql.conf"]

# When I run below the Docker starts, then dies
#   CMD /docker-entrypoint-initdb.d/service-start.sh
# so we have to use the CMD [ ] line above, then manually start MIRTH after DOcker is running thus
# "sudo docker exec  ddw-gw /docker-entrypoint-initdb.d/service-start.sh "



