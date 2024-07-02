#!/bin/sh
monthOneDay=`date -d "-1 day" +%Y%m`'01'
monthLastDay=`date -d "-1 day" +%Y%m%d`

#echo == SUMMARY A0X INSERT ... ==
echo $monthOneDay $monthLastDay
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm_new

delete from summary_time_monthly where month = substring('$monthOneDay',0,7);

insert into summary_time_monthly
select
  log_delimiter
  , substring(proc_date,0,7) as month
  , to_char(to_date(proc_date, 'YYYYMMDD'), 'W') as week
  , system_seq
  , system_name
  , dept_id
  , dept_name
  , emp_user_id
  , emp_user_name
  , proc_time
  , sum(cnt) cnt
from 
	summary_time
 where proc_date between '$monthOneDay' and '$monthLastDay'
group by 	
	log_delimiter
  , month
  , week
  , system_seq
  , system_name
  , dept_id
  , dept_name
  , emp_user_id
  , emp_user_name
  , proc_time
order by
	log_delimiter
  , month
  , week
  , system_seq
  , system_name
  , dept_id
  , dept_name
  , emp_user_id
  , emp_user_name
  , proc_time;

\q
exit
EOF
echo == SUMMARY A0X FINISH ==
