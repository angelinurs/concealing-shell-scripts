#!/bin/bash

# HOSTNAME=localhost
# USERNAME=user1
# DATABASE=db1
# PORT=5431

FILE=$1
echo "${FILE}"

HOSTNAME=`cat ${FILE} | grep HOSTNAME | awk  -F'=' '{print $2}'`
USERNAME=`cat ${FILE} | grep USERNAME | awk  -F'=' '{print $2}'`
DATABASE=`cat ${FILE} | grep DATABASE | awk  -F'=' '{print $2}'`
PORT=`cat ${FILE} | grep PORT | awk  -F'=' '{print $2}'`

export PGPASSWORD=dlwltjxl1!

psql -h $HOSTNAME -p $PORT -U $USERNAME -d $DATABASE <<EOF
\x
select * from pg_catalog.pg_user;

\q
EOF