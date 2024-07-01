#!/bin/sh
now=`date -d "-1 day" +%Y%m%d`
#now=20200211
echo == SUMMARY A0X INSERT ... ==
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm -p 5432

delete from summary_time where proc_date = '$now';

with recursive summary_time_default as(
  select 0 as time_num
  union all
  select time_num+1 from summary_time_default where time_num < 23
),
summary_time_view as(
  select 'BA', '$now', '', '', '', '', '', '', LPAD(std.time_num::text, 2, '0') as proc_time, 0
  from summary_time_default std
  union
  select 'DN', '$now', '', '', '', '', '', '', LPAD(std.time_num::text, 2, '0') as proc_time, 0
  from summary_time_default std
  union
  select 'BS', '$now', '', '', '', '', '', '', LPAD(std.time_num::text, 2, '0') as proc_time, 0
  from summary_time_default std
)
INSERT INTO summary_time (log_delimiter, proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, proc_time, cnt)
select * from summary_time_view order by proc_time desc;

with BLS as (
select *,
		(select system_name from system_master where system_seq = a.system_seq )		
from biz_log_summary_$now a
where
    1=1
and emp_user_name != '' and emp_user_name != 'null'
),
BLR as (
select log_seq,count(*) as cnt 
from biz_log_result_$now b
join regular_expression_mng rem
on b.result_type = rem.privacy_type 
group by log_seq
)
insert into summary_time
select 'BA' as log_delimiter,
	bls.proc_date,
	bls.system_seq,
	bls.system_name,
	bls.dept_id,
	bls.dept_name,
	bls.emp_user_id,
	bls.emp_user_name,
	substring(bls.proc_time, 1, 2) as proc_time,
	sum(blr.cnt)
from BLS, BLR
where bls.log_seq = blr.log_seq
group by bls.proc_date, bls.system_seq, bls.system_name, bls.dept_id, bls.dept_name, bls.emp_user_id, bls.emp_user_name, substring(bls.proc_time, 1, 2);

with DL as (
  select *,
         (select system_name 
            from system_master
           where system_seq = a.system_seq)
    from download_log a where proc_date = '$now'
     and emp_user_name != '' and emp_user_name != 'null'
),
DLR as (
  select log_seq, rem.result_type_order as result_type, count(*) as cnt 
  from download_log_result blrr
  join regular_expression_mng rem
  on blrr.result_type = rem.privacy_type
  where proc_date = '$now'
  group by log_seq, rem.result_type_order
)
insert into summary_time
select 'DN' as log_delimiter,
	dl.proc_date,
	dl.system_seq,
	dl.system_name,
	dl.dept_id,
	dl.dept_name,
	dl.emp_user_id,
	dl.emp_user_name,
	substring(dl.proc_time, 1, 2) proc_time,
	sum(dlr.cnt)
from DL, DLR
where DL.log_seq = DLR.log_seq
group by dl.proc_date, dl.system_seq, dl.system_name, dl.dept_id, dl.dept_name, dl.emp_user_id, dl.emp_user_name, substring(dl.proc_time, 1, 2);

with BLS as (
select *,
		(select system_name from system_master where system_seq = a.system_seq )		
from
     biz_log_summary_$now a 
where 
     1=1
and (emp_user_name = '' or emp_user_name = 'null')
),
BLR as (
select log_seq,count(*) as cnt from 
biz_log_result_$now b
join regular_expression_mng rem
on b.result_type = rem.privacy_type 
group by log_seq
)
insert into summary_time
select 'BS' as log_delimiter,
	bls.proc_date,
	bls.system_seq,
	bls.system_name,
	bls.dept_id,
	bls.dept_name,
	bls.emp_user_id,
	bls.emp_user_name,
	substring(bls.proc_time, 1, 2) proc_time,
	sum(blr.cnt)
from BLS, BLR
where bls.log_seq = blr.log_seq
group by bls.proc_date, bls.system_seq, bls.system_name, bls.dept_id, bls.dept_name, bls.emp_user_id, bls.emp_user_name, substring(bls.proc_time, 1, 2);

\q
exit
EOF
echo == SUMMARY A0X FINISH ==

