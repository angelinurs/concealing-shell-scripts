#!/bin/bash

# HOSTNAME=localhost
# USERNAME=user1
# DATABASE=db1
# PORT=5431

KEY="naru"
FILE=$1
echo "${FILE}"

CONTENT=`openssl enc -d -aes-256-cbc -pbkdf2 -a -k naru -in $FILE | awk -F': ' '{print $2}' | xargs`
# echo "${CONTENT}"

# OLD_IFS="$IFS"
# IFS=" "
# STR_ARRAY=( $CONTENT )
# IFS="$OLD_IFS"

IFS=" " read -ra STR_ARRAY <<< "$CONTENT"

# for x in "${STR_ARRAY[@]}"
# do
#     echo "> [$x]"
# done

HOSTNAME="${STR_ARRAY[0]}"
USERNAME="${STR_ARRAY[1]}"
PASSWORD="${STR_ARRAY[2]}"
DATABASE="${STR_ARRAY[3]}"
PORT="${STR_ARRAY[4]}"

export PGPASSWORD=$PASSWORD

psql -h $HOSTNAME -p $PORT -U $USERNAME -d $DATABASE <<EOF
\x
select * from pg_catalog.pg_user;

\q
EOF

