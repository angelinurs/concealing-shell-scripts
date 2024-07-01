#!/bin/sh
now=`date -d "-1 day" +%Y%m%d`
#now=20200211
echo == SUMMARY A0X INSERT ... ==
su - postgres << EOF
PGPASSWORD=psm123 psql -Upsm -d psm -p 5432

DELETE FROM SUMMARY_REQTYPE WHERE PROC_DATE = '$now';

INSERT INTO SUMMARY_REQTYPE
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
 req_type, cnt,logcnt)
values ('BA','$now', '', '', '', '', '', '', '', 0,0);

INSERT INTO SUMMARY_REQTYPE
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
 req_type, cnt,logcnt)
values ('BS','$now', '', '', '', '', '', '', '', 0,0);

INSERT INTO SUMMARY_REQTYPE
(log_delimiter,proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, 
 req_type, cnt,logcnt)
values ('DN','$now', '', '', '', '', '', '', '', 0,0);

 with summary_result as(
         select 
               log_seq
         from biz_log_result_$now blr
         join regular_expression_mng rem
         on blr.result_type = rem.privacy_type
         and rem.use_flag = 'Y'
         AND rem.result_type_order <= '18'
      )
         insert into summary_reqtype
         select
             'BA' as log_delimiter,
             bls.proc_date,
             bls.system_seq,
             (select system_name from system_master where system_seq = bls.system_seq ),
             bls.dept_id,
             bls.dept_name,
             bls.emp_user_id,
             bls.emp_user_name,
             bls.req_type,
             count(blr.log_seq) as cnt,
             count(distinct blr.log_seq) as logcnt
         from
             biz_log_summary_$now bls
         join summary_result blr
         on bls.log_seq = blr.log_seq
         and emp_user_name != ''
         and emp_user_name != 'null'
        group by log_delimiter, bls.proc_date, system_seq, dept_id, dept_name, emp_user_id, emp_user_name, req_type;

with summary_result as(
      select 
          log_seq
      from 
         download_log_result dlr 
      join regular_expression_mng rem
      on dlr.result_type = rem.privacy_type
      where 
          proc_date = '$now'
          and rem.use_flag = 'Y'
          AND rem.result_type_order <= '18'
)
insert into summary_reqtype
select
   'DN' as log_delimiter,
    dl.proc_date,
    dl.system_seq,
    (select system_name from system_master where system_seq = dl.system_seq ),
    dl.dept_id,
    dl.dept_name,
    dl.emp_user_id,
    dl.emp_user_name,
    dl.req_type,
    count(dlr.log_seq) as cnt,
    count(distinct dlr.log_seq) as logcnt
from
    download_log dl
join summary_result dlr
on dl.log_seq = dlr.log_seq
where 
     proc_date = '$now'
     and emp_user_name != ''
     and emp_user_name != 'null'
group by 
     log_delimiter, dl.proc_date, system_seq, dept_id, dept_name, emp_user_id, emp_user_name, req_type;


with summary_result as(
select 
    log_seq
from 
    biz_log_result_$now blr
join regular_expression_mng rem
on blr.result_type = rem.privacy_type
and rem.use_flag = 'Y'
AND rem.result_type_order <=  '18'
)
insert into summary_reqtype
select
    'BS' as log_delimiter,
     bls.proc_date,
     bls.system_seq,
     (select system_name from system_master where system_seq = bls.system_seq ),
     bls.dept_id,
     bls.dept_name,
     bls.emp_user_id,
     bls.emp_user_name,
     bls.req_type,
     count(blr.log_seq) as cnt,
     count(distinct blr.log_seq) as logcnt
from
     biz_log_summary_$now bls
     join summary_result blr
     on bls.log_seq = blr.log_seq
where 
     1=1
     AND (bls.emp_user_name != '' and bls.emp_user_name != 'null' and bls.emp_user_name is not null)
group by 
     log_delimiter, bls.proc_date, system_seq, dept_id, dept_name, emp_user_id, emp_user_name, req_type;


\q
exit
EOF
echo == SUMMARY A0X FINISH ==

