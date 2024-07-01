#!/bin/sh

dateTale=$(date -d "$now + 7 day" +%Y%m%d)
now=`date +%Y%m%d`

export PGPASSWORD=psm123

while [ "$now" -lt "$dateTale" ]
do
  echo $now;

  psql -p5432 -U psm psm << EOF
    CREATE TABLE biz_log_summary_$now PARTITION OF biz_log_summary FOR VALUES IN ('$now');
    CREATE TABLE biz_log_result_$now PARTITION OF biz_log_result FOR VALUES IN ('$now');
	create table sql_result_$now partition of sql_result for values from ('$now 000000') to ('$now 235959');
    create table log_sql_$now partition of log_sql for values from ('$now 000000') to ('$now 235959');
    create table rule_biz_$now partition of rule_biz for values in ('$now');
	create table download_log_$now partition of download_log for values in ('$now');
	create table download_log_result_$now partition of download_log_result for values in ('$now');
  \q
  exit
EOF

  now=$(date -d "$now + 1 day" +%Y%m%d)
done
