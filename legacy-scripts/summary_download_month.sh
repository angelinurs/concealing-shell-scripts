!/bin/sh
monthOneDay=`date -d "-1 day" +%Y%m`'01'
monthLastDay=`date -d "-1 day" +%Y%m%d`

#echo == SUMMARY A0X INSERT ... ==
echo $monthOneDay $monthLastDay
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm_new

delete from summary_download_monthly where month = substring('$monthOneDay',0,7);

insert into summary_download_monthly
select
  log_delimiter
  , substring(proc_date,0,7) as month
  , to_char(to_date(proc_date, 'YYYYMMDD'), 'W') as week
  , system_seq
  , file_ext
  , sum(file_ext_cnt) file_ext_cnt
from 
	summary_download
 where proc_date between '$monthOneDay' and '$monthLastDay'
 and file_ext_cnt > 0
group by log_delimiter, month, week, system_seq, file_ext, file_ext_cnt
order by log_delimiter, month, week, system_seq, file_ext, file_ext_cnt

\q
exit
EOF
echo == SUMMARY A0X FINISH ==
