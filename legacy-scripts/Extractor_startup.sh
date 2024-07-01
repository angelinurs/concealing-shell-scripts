#!/bin/sh
#extractor agent start
AGENT_PATH="/usr/local/PSM/agent/extractor"

JAVA_CMD="/usr/bin/java"
JAVA_OPTS="-XshowSettings:all -Dpsm.engine.name=EXTRACTOR"
PSM_ENGINE_LOG="${AGENT_PATH}/logs/PSMExtractor.log"
PROCDATE=`date -d "-1 day" +%Y%m%d`


cd ${AGENT_PATH}
nohup ${JAVA_CMD} ${JAVA_OPTS} \
		-jar ExtractorSgg.jar EXTRACTOR ${PROCDATE}\
		>> ${PSM_ENGINE_LOG} 2>&1 


#일마감
now=`date -d "-1 day" +%Y%m%d`
#now=20200527
echo == SUMMARY A0X INSERT ... ==
su - postgres << EOF
PGPASSWORD=psm123 psql -p5432 -Upsm psm

DELETE FROM summary_abnormal WHERE PROC_DATE = '$now';

INSERT INTO summary_abnormal
(proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, scenario1, scenario2, scenario3, scenario4, scenario5, cnt, logcnt)
values ('$now', '', '', '', '', '', '', 0, 0, 0, 0, 0, 0, 0);

INSERT INTO summary_abnormal
(proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, scenario1, scenario2, scenario3, scenario4, scenario5, cnt, logcnt)
select '$now', system_seq, system_name, '', '', '', '', 0, 0, 0, 0, 0, 0, 0
from system_master
where system_seq != '01';

INSERT INTO summary_abnormal
(proc_date, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, scenario1, scenario2, scenario3, scenario4, scenario5, cnt, logcnt)
select occr_dt, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name
, sum(sn1) as tot_sn1
, sum(sn2) as tot_sn2
, sum(sn3) as tot_sn3
, sum(sn4) as tot_sn4
, sum(sn5) as tot_sn5
, sum(t_n_count) as tot_n_count
, sum(t_rule_cnt) as tot_rule_cnt
from (
	select occr_dt
		, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name
		, scen_seq
		, (case when scen_seq = 1000 then count(emp_detail_seq) else 0 end) as sn1 
		, (case when scen_seq = 2000 then count(emp_detail_seq) else 0 end) as sn2 
		, (case when scen_seq = 3000 then count(emp_detail_seq) else 0 end) as sn3 
		, (case when scen_seq = 4000 then count(emp_detail_seq) else 0 end) as sn4 
		, (case when scen_seq = 5000 then count(emp_detail_seq) else 0 end) as sn5 
		, count(emp_detail_seq) as t_n_count
		, sum(rule_cnt) as t_rule_cnt
	from (
		select distinct ms.occr_dt
			, ms.system_seq, sm.system_name, ms.dept_id, ms.dept_name, ms.emp_user_id, ms.emp_user_name
			, rt.scen_seq
			, rt.rule_seq
			, dt.emp_detail_seq
			, rule_cnt
		from emp_detail ms 
			left join rule_biz dt
				on ms.emp_detail_seq = dt.emp_detail_seq 
			left join system_master sm
				--on dt.system_seq = sm.system_seq 
				on ms.system_seq = sm.system_seq 
			left join ruletbl rt 
				on rt.rule_seq = ms.rule_cd
		where ms.occr_dt = '$now'
	) rs
	group by occr_dt, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name, scen_seq
) rs
group by occr_dt, system_seq, system_name, dept_id, dept_name, emp_user_id, emp_user_name;

\q
exit
EOF
echo == SUMMARY A0X FINISH ==

