#!/bin/bash

# this must be called by run_ddw_gw  as ROOT

#first load the DDW channels into the mirthdb as user "postgres"
#su -c "/usr/lib/postgresql/9.0/bin/psql -U postgres -d mirthdb < /docker-entrypoint-initdb.d/mirthdb.sql" postgres

# then start mirth as "root"
#mv /usr/local/mirth/conf/mirth.properties /usr/local/mirth/conf/mirth.properties.ori
#mv /usr/local/mirth/conf/mirth.properties.new /usr/local/mirth/conf/mirth.properties
service mcservice start
