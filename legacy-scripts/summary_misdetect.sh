#예외처리 DB 마감처리
#스크립트 실행 후 실제 로그가 예외처리 작업을 하며 삭제 되므로 신중하게 설정할것
#모든 마감스크립트중 가장 먼저 실행되어야함 
#!/bin/sh
now=`date -d "-1 day" +%Y%m%d`
echo == SUMMARY A0X INSERT ... ==
su - postgres << EOF
PGPASSWORD=psm123 psql -p5432 psm -Upsm

with decodedata as (
select
	biz_log_result_seq ,
	log_seq ,
	convert_from(decrypt(decode(RESULT_CONTENT, 'hex'),(select cast( key as bytea ) from t_encryptkey limit 1), 'aes'), 'UTF8') as RESULT_CONTENT ,
	result_type
from
	biz_log_result_$now ) 
, deleteseq as(
	select
		biz_log_result_seq
	from
		decodedata blr
	left join misdetect_summary ms on
		blr.result_type::integer = ms.privacy_type
	where
		ms.misdetect_type = '1'
		and ms.use_yn = 'Y'
		and blr.result_content between ms.range_to and ms.range_from)
delete from
	biz_log_result_$now blr using deleteseq ds
where
	blr.biz_log_result_seq = ds.biz_log_result_seq;

--문자포함 예외처리 데이터 삭제--
with decodedata as (
select
	biz_log_result_seq ,
	log_seq ,
	convert_from(decrypt(decode(RESULT_CONTENT, 'hex'),(select cast( key as bytea ) from t_encryptkey limit 1), 'aes'), 'UTF8') as RESULT_CONTENT ,
	result_type
from
	biz_log_result_$now )
, deleteseq as(
	select
		biz_log_result_seq
	from
		decodedata blr
	left join misdetect_summary ms on
		blr.result_type::integer = ms.privacy_type
	where
		ms.misdetect_type = '2'
		and ms.use_yn = 'Y'
		and blr.result_content like '%' || ms.result_content || '%')
delete from
	biz_log_result_$now blr using deleteseq ds
where
	blr.biz_log_result_seq = ds.biz_log_result_seq;

--정규식 예외처리 데이터 삭제--
with decodedata as (
select
	biz_log_result_seq ,
	log_seq ,
	convert_from(decrypt(decode(RESULT_CONTENT, 'hex'),(select cast( key as bytea ) from t_encryptkey limit 1), 'aes'), 'UTF8') as RESULT_CONTENT ,
	result_type
from
	biz_log_result_$now )
, deleteseq as(
	select
		biz_log_result_seq
	from
		decodedata blr
	left join misdetect_summary ms on
		blr.result_type::integer = ms.privacy_type
	where
		ms.misdetect_type = '3'
		and ms.use_yn = 'Y'
		and blr.result_content ~ ms.result_content)
delete from
	biz_log_result_$now blr using deleteseq ds
where
	blr.biz_log_result_seq = ds.biz_log_result_seq;

--예외처리 결과 biz_log_summary 반영--
update biz_log_summary_$now bls set result_type = 
(SELECT array_to_string(array_agg(result_type),',') from biz_log_result_$now blr where blr.log_seq = bls.log_seq);

--null값 처리된 biz_log_summary 데이터 삭제--
delete from biz_log_summary_$now where result_type is null;

 \q
exit
EOF
echo == SUMMARY A0X FINISH ==

