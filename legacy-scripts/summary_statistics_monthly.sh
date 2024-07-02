#!/bin/sh
monthOneDay=`date -d "-1 day" +%Y%m`'01'
monthLastDay=`date -d "-1 day" +%Y%m%d`

#echo == SUMMARY A0X INSERT ... ==
echo $monthOneDay $monthLastDay
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm_new

delete from summary_statistics_monthly where month = substring('$monthOneDay',0,7);

INSERT INTO summary_statistics_monthly
(log_delimiter,month, week, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name,
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt, logcnt)
select 'BA', substring('$monthOneDay',0,7),	'', system_seq, system_name, '', '', '', '', 
		0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
from system_master
where system_seq != '01';

INSERT INTO summary_statistics_monthly
(log_delimiter,month, week, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name,
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt, logcnt)
select 'DN', substring('$monthOneDay',0,7), '', system_seq, system_name, '', '', '', '',
        0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
from system_master
where system_seq != '01';

INSERT INTO summary_statistics_monthly
(log_delimiter,month, week, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt, logcnt)
select 'BS',substring('$monthOneDay',0,7), '', system_seq, system_name, '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
from system_master
where system_seq != '01';

insert into summary_statistics_monthly
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
  , sum(type1) as type1
  , sum(type2) as type2
  , sum(type3) as type3
  , sum(type4) as type4
  , sum(type5) as type5
  , sum(type6) as type6
  , sum(type7) as type7
  , sum(type8) as type8
  , sum(type9) as type9
  , sum(type10) as type10
  , sum(type11) as type11
  , sum(type12) as type12
  , sum(type13) as type13
  , sum(type14) as type14
  , sum(type15) as type15
  , sum(type16) as type16
  , sum(type17) as type17
  , sum(type18) as type18
  , sum(cnt) cnt
  , sum(logCnt) as logCnt
from 
	SUMMARY_STATISTICS
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
order by
	log_delimiter
  , month
  , week
  , system_seq
  , system_name
  , dept_id
  , dept_name
  , emp_user_id
  , emp_user_name;

\q
exit
EOF
echo == SUMMARY A0X FINISH ==
