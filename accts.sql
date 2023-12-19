set serveroutput on size unlimited
set head off
set pages 0
set trims on
set lines 2000
set feedback on
set verify off
set feedback off
set timi off
spool  IVRDATA_&&1
alter session set current_schema=tbaadm;


DECLARE

solId tbaadm.gam.sol_id%type;


cursor s1 is
	select sol_id from sst where set_id = solId;
solrec s1%rowtype;




cursor LockDet is

with a as
(
select distinct acid,(select foracid from tbaadm.gam where acid=  adt.acid) FORACID,
(select acct_name from tbaadm.gam where acid=  adt.acid) acct_name,
(Select acct_opn_date from tbaadm.gam where acid = adt.acid) acct_opn_date,
(select acct_cls_flg from tbaadm.gam where acid = adt.acid) acct_cls_flg,
(select acct_cls_date from tbaadm.gam where acid = adt.acid) acct_cls_date,
(select NVL((select decode(frez_code,'C','Credit Freeze','D','Debit Freeze','T','Total Freeze')  from tbaadm.gam where acid = adt.acid),'N') from dual) frez_code,
(select ref_desc from tbaadm.rct where ref_rec_type='31' and ref_code=(select frez_reason_code from tbaadm.gam where acid = adt.acid and rownum =1)) frezReasoncode,
(select schm_type from tbaadm.gam where acid = adt.acid) schm_type,
(select schm_code from tbaadm.gam where acid = adt.acid) schm_code, 
(select substr(schm_desc,1,30) from tbaadm.gsp where schm_code=(select schm_code from tbaadm.gam where acid = adt.acid))schmdesc,
(select decode(count(1),'0','N','Y') from tbaadm.cbt where acid=adt.acid) cbtval,
(select ref_desc from tbaadm.rct where ref_rec_type='27' and ref_code=(select MODE_OF_OPER_CODE from tbaadm.gam where acid = adt.acid)) modeofoperation,
(select SOL_ID from tbaadm.gam where acid=  adt.acid) acct_sol,
(select CHQ_ALWD_FLG from tbaadm.gam where acid=  adt.acid) chq_allwd,
(select nvl((select 'Y' from tbaadm.alr where acid=adt.acid and alr.ACCT_LABEL='AADHAAR' and alr.del_flg='N' and alr.entity_cre_flg='Y'),'N') from dual) aadhaar_flg,
(select nvl((select 'Y' from tbaadm.adct where acid=adt.acid and adct.DOCUMENT_CODE='001' and entity_cre_flg='Y' and del_flg='N'),'N') from dual) sms_flg,
(select 'Y' from dual) misscal
from tbaadm.adt where init_sol_id in (select sol_id from tbaadm.sst where set_id = '&&1')
and audit_date > trunc(sysdate)-2
and exists (select 1 from tbaadm.gam where acid = adt.acid and gam.sol_id = solrec.sol_id and gam.acid is not null and schm_type in ('TDA','SBA','CAA','ODA','LAA'))
)
select acid,FORACID,acct_name,acct_opn_date,acct_cls_flg,acct_cls_date,frez_code,frezReasoncode,schm_type,schm_code,schmdesc,cbtval,modeofoperation,acct_sol,chq_allwd,aadhaar_flg,sms_flg,misscal from a;

lrec LockDet%rowtype;


BEGIN

solId := '&1';


open s1;
loop
fetch s1 into solrec;
exit when s1%notfound;


open LockDet;
loop
fetch LockDet into lrec;
exit when LockDet%notfound;


begin
	dbms_output.put_line(lrec.foracid||'|'||lrec.acct_name||'|'||lrec.acct_opn_date||'|'||lrec.acct_cls_flg||'|'||lrec.acct_cls_date||'|'||lrec.frez_code||'|'||lrec.frezReasoncode||'|'||lrec.schm_type||'|'||lrec.schm_code||'|'||lrec.schmdesc||'|'||lrec.cbtval||'|'||lrec.modeofoperation||'|'||lrec.acct_sol||'|'||lrec.chq_allwd||'|'||lrec.aadhaar_flg||'|'||lrec.sms_flg||'|'||lrec.misscal);
			
end;

end loop;

close LockDet;

end loop;
close s1;

END;

/
spool off;
exit
