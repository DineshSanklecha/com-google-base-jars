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
select CUSTT,CUSTTYP,CSTNAME,CSTDOB,CSTGENDER,CSTSENIOR,CSTNRE,CSTCONSTI,CSTSTAT,CSTPAN,CSTADDR1,CSTADDR2,CSTADDR3,CSTCITY,CSTSTATE,CSTCNTRY,CSTPIN,CSTMOTHER,CSTNREMOB,CSTCOMMU from
(
select orgkey CUSTT,
'RETAIL' CUSTTYP,
substr(name,1,25) CSTNAME,
cust_dob CSTDOB,
GENDER CSTGENDER,
SENIORCITIZEN CSTSENIOR,
CUSTOMERNREFLG CSTNRE,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='CONSTITUTION_CODE' and categories.VALUE=(select CONSTITUTION_CODE from crmuser.accounts where orgkey=a.orgkey)) CSTCONSTI,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='CUSTOMER_STATUS' and categories.VALUE=(select STATUS_CODE from crmuser.accounts where orgkey=a.orgkey)) CSTSTAT ,
(select referencenumber from crmuser.entitydocument where orgkey=a.orgkey and ENTITYTYPE='CIFRetCust' and DOCCODE='PANGIR' and rownum=1) CSTPAN,
(select ADDRESS_LINE1 from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR1,
(select ADDRESS_LINE2 from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR2,
(select ADDRESS_LINE3 from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR3,
(select trim(category_lang.localetext) from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='CITY' and categories.VALUE=(select city from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTCITY,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='STATE' and categories.VALUE=(select state from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTSTATE,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='COUNTRY' and categories.VALUE=(select country from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTCNTRY,
(select zip from crmuser.address where orgkey=a.orgkey and ADDRESSCATEGORY='Mailing' and (end_date is null or (end_date>='31-12-2099'))  and rownum=1) CSTPIN,
(select MOTHER_NAME from cad where customer_id=a.orgkey) CSTMOTHER ,
(select NRE_MOB from cad where customer_id=a.orgkey) CSTNREMOB,
(select (select ref_desc from tbaadm.rct where ref_rec_type = '13' and ref_code = crmuser.accounts.CUST_COMMUNITY) community from crmuser.accounts where orgkey=a.orgkey) CSTCOMMU
from crmuser.accounts a where primary_sol_id = '&&1'
and exists (select 1 from crmuser.audittrail b where b.auditedid = a.accountid
and BODATEMODIFIED >= trunc(sysdate) - 2
)
UNION
select corp_key CUSTT,
'CORPORATE' CUSTTYP,
substr(corporate_name,1,25) CSTNAME,
date_of_incorporation CSTDOB,
NULL CSTGENDER,
NULL CSTSENIOR,
NULL CSTNRE,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='LEGAL_ENTITY' and categories.VALUE= (select LEGALENTITY_TYPE from crmuser.corporate where corp_key= a.corp_key)) CSTCONSTI,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='CORP_STATUS' and categories.VALUE=(select corporate.status from crmuser.corporate where corp_key= a.corp_key)) CSTSTAT,
(select referencenumber from crmuser.entitydocument where orgkey=a.corp_key  and ENTITYTYPE='CIFCorpCust' and DOCCODE='PAN' and rownum=1) CSTPAN,
(select ADDRESS_LINE1 from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR1,
(select ADDRESS_LINE2 from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR2,
(select ADDRESS_LINE3 from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTADDR3,
(select trim(category_lang.localetext) from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='CITY' and  categories.VALUE=(select city from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTCITY,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='STATE' and categories.VALUE=(select state from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTSTATE,
(select category_lang.localetext from crmuser.category_lang,crmuser.categories where category_lang.CATEGORYID=categories.CATEGORYID and categories.CATEGORYTYPE='COUNTRY' and  categories.VALUE=(select country from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1)) CSTCNTRY,
(select zip from crmuser.address where orgkey=a.corp_key and ADDRESSCATEGORY='Registered' and (end_date is null or (end_date>='31-12-2099')) and rownum=1) CSTPIN,
NULL CSTMOTHER,
NULL CSTNREMOB,
NULL CSTCOMMU
from crmuser.corporate a where primary_service_center = '&&1'
and exists (select 1 from crmuser.audittrail b where b.auditedid = a.corp_id
and BODATEMODIFIED >= trunc(sysdate) - 2
)
)
)
select CUSTT,CUSTTYP,CSTNAME,CSTDOB,CSTGENDER,CSTSENIOR,CSTNRE,CSTCONSTI,CSTSTAT,CSTPAN,CSTADDR1,CSTADDR2,CSTADDR3,CSTCITY,CSTSTATE,CSTCNTRY,CSTPIN,CSTMOTHER,CSTNREMOB,CSTCOMMU,
(select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'CELLPH' and rownum < 2) CELLPH,
(Select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'HOMEPH1' and rownum < 2) HOMEPH1,
(select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'COMMPH1' and rownum < 2) COMMPH1,
(select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'COMMPH2' and rownum < 2) COMMPH2,
(select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                      and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'NREMobile' and rownum < 2) NREPH,
(select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PHONEEMAILTYPE = 'WORKPH1' and rownum < 2) WORKPH1,
(Select PHONENO from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'PHONE' and PREFERREDFLAG='Y' and rownum < 2) PREFCONTACT,
(Select EMAIL from crmuser.phoneemail p where p.orgkey = a.CUSTT
                        and PHONEOREMAIL = 'EMAIL' and PREFERREDFLAG='Y' and rownum < 2) PREFMAIL 
from a;

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
		dbms_output.put_line(lrec.CUSTT||'|'||lrec.CUSTTYP||'|'||lrec.CSTNAME||'|'||lrec.CSTDOB||'|'||lrec.CSTGENDER||'|'||lrec.CSTSENIOR||'|'||lrec.CSTNRE||'|'||lrec.CSTCONSTI||'|'||lrec.CSTSTAT||'|'||lrec.CSTPAN||'|'||lrec.CSTADDR1||'|'||lrec.CSTADDR2||'|'||lrec.CSTADDR3||'|'||lrec.CSTCITY||'|'||lrec.CSTSTATE||'|'||lrec.CSTCNTRY||'|'||lrec.CSTPIN||'|'||lrec.CSTMOTHER||'|'||lrec.CSTNREMOB||'|'||lrec.CSTCOMMU||'|'||lrec.CELLPH||'|'||lrec.HOMEPH1||'|'||lrec.COMMPH1||'|'||lrec.COMMPH2||'|'||lrec.NREPH||'|'||lrec.WORKPH1||'|'||lrec.PREFCONTACT||'|'||lrec.PREFMAIL);
	--dbms_output.put_line(lrec.acid||'|'||lrec.foracid||'|'||lrec.acct_name||'|'||lrec.acct_opn_date||'|'||lrec.acct_cls_flg||'|'||lrec.acct_cls_date||'|'||lrec.frez_code||'|'||lrec.frezReasoncode||'|'||lrec.schm_type||'|'||lrec.schm_code||'|'||lrec.schmdesc||'|'||lrec.cbtval||'|'||lrec.modeofoperation);
			
end;

end loop;

close LockDet;

end loop;
close s1;

END;

/
spool off;
exit
