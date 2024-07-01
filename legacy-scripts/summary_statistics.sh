#!/bin/sh
now=`date -d "-1 day" +%Y%m%d`
#now=20200527
echo == SUMMARY A0X INSERT ... ==
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm -p 5432

DELETE FROM SUMMARY_STATISTICS WHERE PROC_DATE = '$now';

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
values ('BA','$now', '', '', '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0);

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
values ('DN','$now', '', '', '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0);

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
values ('BS','$now', '', '', '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0);

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name,
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
select 'BA','$now', system_seq, system_name, '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0
from system_master
where system_seq != '01';

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name,
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
select 'DN','$now', system_seq, system_name, '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0
from system_master 
where system_seq != '01';

INSERT INTO SUMMARY_STATISTICS
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name,
 type1, type2, type3, type4, type5, type6, type7, type8, type9, type10, type11, type12, type13, type14, type15, type16, type17, type18, cnt,logcnt)
select 'BS','$now', system_seq, system_name, '', '', '', '', 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,0
from system_master 
where system_seq != '01';

with BLSt as (
select *,
		(select system_name from system_master where system_seq = a.system_seq )		
from biz_log_summary_$now a
where 1=1
and emp_user_name != '' and emp_user_name != 'null'
),
BLRt as (
	select 
             log_seq, 
             rem.result_type_order as result_type, 
             count(*) as cnt 
	from 
            biz_log_result_$now blrr
	join regular_expression_mng rem
	on blrr.result_type = rem.privacy_type
        where 
            1=1
	and rem.use_flag = 'Y'
        and rem.result_type_order <= '18' 
	group by log_seq, rem.result_type_order
)
insert into summary_statistics
select 'BA' as log_delimiter,
	bls.proc_date,
	bls.system_seq,
	bls.system_name,
	bls.dept_id,
	bls.dept_name,
	bls.emp_user_id,
	bls.emp_user_name,
	sum(
        CASE blr.result_type
            WHEN '1' THEN cnt
            ELSE 0::bigint
        END) AS type1,
	sum(
        CASE blr.result_type
            WHEN '2' THEN cnt
            ELSE 0::bigint
        END) AS type2,
    sum(
        CASE blr.result_type
            WHEN '3' THEN cnt
            ELSE 0::bigint
        END) AS type3,
	sum(
        CASE blr.result_type
            WHEN '4' THEN cnt
            ELSE 0::bigint
        END) AS type4,
    sum(
        CASE blr.result_type
            WHEN '5' THEN cnt
            ELSE 0::bigint
        END) AS type5,
	sum(
        CASE blr.result_type
            WHEN '6' THEN cnt
            ELSE 0::bigint
        END) AS type6,
    sum(
        CASE blr.result_type
            WHEN '7' THEN cnt
            ELSE 0::bigint
        END) AS type7,
	sum(
        CASE blr.result_type
            WHEN '8' THEN cnt
            ELSE 0::bigint
        END) AS type8,
    sum(
        CASE blr.result_type
            WHEN '9' THEN cnt
            ELSE 0::bigint
        END) AS type9,
	sum(
        CASE blr.result_type
            WHEN '10' THEN cnt
            ELSE 0::bigint
        END) AS type10,
    sum(
        CASE blr.result_type
            WHEN '11' THEN cnt
            ELSE 0::bigint
        END) AS type11,
	sum(
        CASE blr.result_type
            WHEN '12' THEN cnt
            ELSE 0::bigint
        END) AS type12,
    sum(
        CASE blr.result_type
            WHEN '13' THEN cnt
            ELSE 0::bigint
        END) AS type13,
	sum(
        CASE blr.result_type
            WHEN '14' THEN cnt
            ELSE 0::bigint
        END) AS type14,
    sum(
        CASE blr.result_type
            WHEN '15' THEN cnt
            ELSE 0::bigint
        END) AS type15,
	sum(
        CASE blr.result_type
            WHEN '16' THEN cnt
            ELSE 0::bigint
        END) AS type16,
    sum(
        CASE blr.result_type
            WHEN '17' THEN cnt
            ELSE 0::bigint
        END) AS type17,
	sum(
        CASE blr.result_type
            WHEN '18' THEN cnt
            ELSE 0::bigint
        END) AS type18,
     sum(cnt) as cnt,
	count(distinct bls.log_seq) as logCnt
from BLSt BLS
join BLRt BLR
on bls.log_seq = blr.log_seq
group by bls.proc_date, bls.system_seq, bls.system_name, bls.dept_id, bls.dept_name, bls.emp_user_id, bls.emp_user_name;

with DLt as (
select *,
        (select system_name from system_master where system_seq = a.system_seq )
from download_log a 
where proc_date = '$now'
and emp_user_name != '' and emp_user_name != 'null'
),
DLRt as (
	select log_seq, rem.result_type_order as result_type, count(*) as cnt 
	from download_log_result blrr
	join regular_expression_mng rem
	on blrr.result_type = rem.privacy_type
	where proc_date = '$now'
        and rem.use_flag = 'Y'
        AND rem.result_type_order <= '18' 
	group by log_seq, rem.result_type_order
)
insert into summary_statistics
select 'DN' as log_delimiter,
    dl.proc_date,
    dl.system_seq,
    dl.system_name,
    dl.dept_id,
    dl.dept_name,
    dl.emp_user_id,
    dl.emp_user_name,
    sum(
        CASE dlr.result_type
            WHEN '1' THEN cnt
            ELSE 0::bigint
        END) AS type1,
    sum(
        CASE dlr.result_type
            WHEN '2' THEN cnt
            ELSE 0::bigint
        END) AS type2,
    sum(
        CASE dlr.result_type
            WHEN '3' THEN cnt
            ELSE 0::bigint
        END) AS type3,
    sum(
        CASE dlr.result_type
            WHEN '4' THEN cnt
            ELSE 0::bigint
        END) AS type4,
    sum(
        CASE dlr.result_type
            WHEN '5' THEN cnt
            ELSE 0::bigint
        END) AS type5,
    sum(
        CASE dlr.result_type
            WHEN '6' THEN cnt
            ELSE 0::bigint
        END) AS type6,
    sum(
        CASE dlr.result_type
            WHEN '7' THEN cnt
            ELSE 0::bigint
        END) AS type7,
    sum(
        CASE dlr.result_type
            WHEN '8' THEN cnt
            ELSE 0::bigint
        END) AS type8,
    sum(
        CASE dlr.result_type
            WHEN '9' THEN cnt
            ELSE 0::bigint
        END) AS type9,
    sum(
        CASE dlr.result_type
            WHEN '10' THEN cnt
            ELSE 0::bigint
        END) AS type10,
    sum(
        CASE dlr.result_type
            WHEN '11' THEN cnt
            ELSE 0::bigint
        END) AS type11,
    sum(
        CASE dlr.result_type
            WHEN '12' THEN cnt
            ELSE 0::bigint
        END) AS type12,
    sum(
        CASE dlr.result_type
            WHEN '13' THEN cnt
            ELSE 0::bigint
        END) AS type13,
    sum(
        CASE dlr.result_type
            WHEN '14' THEN cnt
            ELSE 0::bigint
        END) AS type14,
    sum(
        CASE dlr.result_type
            WHEN '15' THEN cnt
            ELSE 0::bigint
        END) AS type15,
    sum(
        CASE dlr.result_type
            WHEN '16' THEN cnt
            ELSE 0::bigint
        END) AS type16,
    sum(
        CASE dlr.result_type
            WHEN '17' THEN cnt
            ELSE 0::bigint
        END) AS type17,
    sum(
        CASE dlr.result_type
            WHEN '18' THEN cnt
            ELSE 0::bigint
        END) AS type18,
     sum(cnt) as cnt,
	count(distinct dl.log_seq) as logCnt
from DLt DL
join DLRt DLR
on dl.log_seq = dlr.log_seq
group by dl.proc_date, dl.system_seq, dl.system_name, dl.dept_id, dl.dept_name, dl.emp_user_id, dl.emp_user_name;


with BLSt as (
select *,
		(select system_name from system_master where system_seq = a.system_seq )		
from biz_log_summary_$now a 
where 1=1
and (emp_user_name = '' or emp_user_name = 'null' or emp_user_name is null)
),
BLRt as (
	select log_seq, rem.result_type_order as result_type, count(*) as cnt 
	from biz_log_result_$now blrr
	join regular_expression_mng rem
	on blrr.result_type = rem.privacy_type
	where 1=1
	and rem.use_flag = 'Y'
        AND rem.result_type_order <= '18' 
	group by log_seq, rem.result_type_order
)
insert into summary_statistics
select 'BS' as log_delimiter,
	bls.proc_date,
	bls.system_seq,
	bls.system_name,
	bls.dept_id,
	bls.dept_name,
	bls.emp_user_id,
	bls.emp_user_name,
	sum(
        CASE blr.result_type
            WHEN '1' THEN cnt
            ELSE 0::bigint
        END) AS type1,
	sum(
        CASE blr.result_type
            WHEN '2' THEN cnt
            ELSE 0::bigint
        END) AS type2,
    sum(
        CASE blr.result_type
            WHEN '3' THEN cnt
            ELSE 0::bigint
        END) AS type3,
	sum(
        CASE blr.result_type
            WHEN '4' THEN cnt
            ELSE 0::bigint
        END) AS type4,
    sum(
        CASE blr.result_type
            WHEN '5' THEN cnt
            ELSE 0::bigint
        END) AS type5,
	sum(
        CASE blr.result_type
            WHEN '6' THEN cnt
            ELSE 0::bigint
        END) AS type6,
    sum(
        CASE blr.result_type
            WHEN '7' THEN cnt
            ELSE 0::bigint
        END) AS type7,
	sum(
        CASE blr.result_type
            WHEN '8' THEN cnt
            ELSE 0::bigint
        END) AS type8,
    sum(
        CASE blr.result_type
            WHEN '9' THEN cnt
            ELSE 0::bigint
        END) AS type9,
	sum(
        CASE blr.result_type
            WHEN '10' THEN cnt
            ELSE 0::bigint
        END) AS type10,
    sum(
        CASE blr.result_type
            WHEN '11' THEN cnt
            ELSE 0::bigint
        END) AS type11,
	sum(
        CASE blr.result_type
            WHEN '12' THEN cnt
            ELSE 0::bigint
        END) AS type12,
    sum(
        CASE blr.result_type
            WHEN '13' THEN cnt
            ELSE 0::bigint
        END) AS type13,
	sum(
        CASE blr.result_type
            WHEN '14' THEN cnt
            ELSE 0::bigint
        END) AS type14,
    sum(
        CASE blr.result_type
            WHEN '15' THEN cnt
            ELSE 0::bigint
        END) AS type15,
	sum(
        CASE blr.result_type
            WHEN '16' THEN cnt
            ELSE 0::bigint
        END) AS type16,
    sum(
        CASE blr.result_type
            WHEN '17' THEN cnt
            ELSE 0::bigint
        END) AS type17,
	sum(
        CASE blr.result_type
            WHEN '18' THEN cnt
            ELSE 0::bigint
        END) AS type18,
     sum(cnt) as cnt,
	count(distinct bls.log_seq) as logCnt
from BLSt BLS
join BLRt BLR
on bls.log_seq = blr.log_seq
group by bls.proc_date, bls.system_seq, bls.system_name, bls.dept_id, bls.dept_name, bls.emp_user_id, bls.emp_user_name;


\q
exit
EOF
echo == SUMMARY A0X FINISH ==

