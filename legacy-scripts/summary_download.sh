#!/bin/sh
now=`date -d "-1 day" +%Y%m%d`
#now=$1
echo == SUMMARY A0X INSERT ... ==
<< EOF
PGPASSWORD=psm123 psql -Upsm -d psm

DELETE FROM SUMMARY_DOWNLOAD WHERE PROC_DATE = '$now';

INSERT INTO SUMMARY_DOWNLOAD
(log_delimiter,proc_date, system_seq, file_ext, file_ext_cnt)
values ('DN','$now', '', '', 0);


insert into summary_download
select 
'DN',
A.proc_date,
A.system_seq ,
A.file_extension as file_ext,
coalesce(sum(a.ext_cnt),0) as file_ext_cnt
from (
select
    a.proc_date,
    a.system_seq,
    regexp_replace(file_name, E'\\\\.[^.]+$', '') as file_name,
    split_part(file_name,'.', 2) as file_extension,
    count(distinct a.log_seq) as ext_cnt
from download_log a
join download_log_result b
on a.log_seq = b.log_seq 
join regular_expression_mng rem
on b.result_type = rem.privacy_type
where a.proc_date = '$now'
and b.proc_date = '$now'
and rem.use_flag = 'Y'
and rem.result_type_order <= '18'
and (a.emp_user_name != '' and a.emp_user_name != 'null' and a.emp_user_name is not null)
group by a.proc_date, a.system_seq, file_name, file_extension) A
group by  A.file_extension, A.system_seq, A.proc_date;

\q
exit
EOF
echo == SUMMARY A0X FINISH ==

