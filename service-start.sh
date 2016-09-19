#!/bin/bash

# this must be called by run_ddw_gw  as ROOT

# first create stub mirthdb as user "postgres", to do that run below command as USer "postgres"
su -c "/usr/lib/postgresql/9.2/bin/psql -U postgres -d mirthdb < /docker-entrypoint-initdb.d/mirthdb.sql" postgres


# then start mirth as "root"
cp /usr/local/mirth/conf/mirth.properties /usr/local/mirth/conf/mirth.properties.ori
###cp /usr/local/mirth/conf/mirth.properties.new /usr/local/mirth/conf/mirth.properties

service mcservice start

