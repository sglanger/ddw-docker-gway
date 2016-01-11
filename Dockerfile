FROM postgres:9.0

MAINTAINER Steve Langer <sglanger@bluebottle.COM>
# SGL extensions to postgresql for DDW
# inspired by 	https://docs.docker.com/engine/examples/postgresql_service/
# and 			https://hub.docker.com/_/postgres/

# Build with  "sudo docker build --rm=true -t ddw-gway . "
# Run it with "sudo docker run --name ddw-gw -e POSTGRES_PASSWORD=postgres -d ddw-gway "
# Connect to the above instance with "sudo docker exec -it ddw-gw /bin/bash"
# get IP of instance with "sudo docker inspect ddw-gw "

# standard tools
ADD service-start.sh /docker-entrypoint-initdb.d/service-start.sh
ADD mirthdb.sql /docker-entrypoint-initdb.d/mirthdb.sql
RUN chmod 777 /docker-entrypoint-initdb.d/service-start.sh
RUN apt-get update && apt-get -y install nano
ENV TERM xterm
RUN apt-get -y install net-tools
RUN apt-get -y install nmap


########################## now install mirth 
# see http://www.mirthproject.org/community/forums/showthread.php?t=5077
#
RUN mkdir /usr/local/mirth
RUN apt-get -y install default-jre
RUN apt-get -y install curl
RUN curl -O http://downloads.mirthcorp.com/connect/2.2.3.6825.b80/mirthconnect-2.2.3.6825.b80-unix.sh
RUN chmod +x /mirthconnect-2.2.3.6825.b80-unix.sh
RUN ./mirthconnect-2.2.3.6825.b80-unix.sh -q -dir "/usr/local/mirth" -Dinstall4j.keepLog=true


################### Create a POstgresql cluster as ROOT
RUN pg_createcluster -u postgres 9.0 main
# now that postgres exists, we are going to replace the default dbase setup of MIRTH
# to use it - MUST do this BEFORE becoming user postgres
ADD mirth.properties /usr/local/mirth/conf/mirth.properties

# Run the rest of the commands as the ``postgres`` user 
USER postgres

# Create a PostgreSQL role named ``postgres`` with ``postgres`` as the password and
# then create a database `ddw` owned by the ``postgres`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
 	createdb -O postgres -U postgres mirthdb

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.0/main/pg_hba.conf 
RUN echo "host all  all    127.0.0.1/32 trust" >> /etc/postgresql/9.0/main/pg_hba.conf
RUN echo "local all  all    trust" >> /etc/postgresql/9.0/main/pg_hba.conf

# STEP 21: And add ``listen_addresses`` to ``/etc/postgresql/9.0/main/postgresql.conf``
RUN echo "listen_addresses = '*'" >> /etc/postgresql/9.0/main/postgresql.conf

# STEP 22: Expose ports (DICOM, MIRTH)
#EXPOSE 104
EXPOSE 5432
EXPOSE 8443
EXPOSE 8081

# STEP 23: Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.0/bin/postgres", "-D", "/var/lib/postgresql/9.0/main", "-c", "config_file=/etc/postgresql/9.0/main/postgresql.conf"]

# When I run below the Docker starts, then dies
#   CMD /docker-entrypoint-initdb.d/service-start.sh
# so we have to use the CMD [ ] line above, then manually start MIRTH after DOcker is running thus
# "sudo docker exec  ddw-gw /docker-entrypoint-initdb.d/service-start.sh "



