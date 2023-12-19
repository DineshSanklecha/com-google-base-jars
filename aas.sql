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
select (select foracid from tbaadm.gam where gam.acid=a.acid) foracid,CUST_ID,ACCT_POA_AS_NAME,
decode(ACCT_POA_AS_REC_TYPE,'M','Main Account Holder','J','Joint Holder','A','Authorized Signatory','C','Co-Obligant','D','DSA','G','Guarantor','H','Legal Heir','L','Letter of Authority','P','Power of Attorney','S','Portfolio statement','V','LHV Hirer','OTHERS') ACRRELATIONTYP ,
DEL_FLG,
(select ref_desc from rct where ref_rec_type='04' and ref_code in (select CUST_RELTN_CODE from tbaadm.aas where acid =a.acid and cust_id=a.CUST_ID and rownum=1) and rownum =1) RELTYP from tbaadm.aas a where a.acid in
(
select acid from tbaadm.adt where init_sol_id in (select sol_id from tbaadm.sst where set_id = '&&1')
and audit_date > trunc(sysdate)-2
and exists (select 1 from tbaadm.gam where acid = adt.acid and gam.sol_id = '&&1' and gam.acid is not null and schm_type in ('TDA','SBA','CAA','ODA','LAA')))
)
select foracid,CUST_ID,ACCT_POA_AS_NAME,ACRRELATIONTYP,DEL_FLG,RELTYP from a order by foracid;

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
	dbms_output.put_line(lrec.foracid||'|'||lrec.CUST_ID||'|'||lrec.ACCT_POA_AS_NAME||'|'||lrec.ACRRELATIONTYP||'|'||lrec.DEL_FLG||'|'||lrec.RELTYP);
			
end;

end loop;

close LockDet;

end loop;
close s1;

END;

/
spool off;
exit
