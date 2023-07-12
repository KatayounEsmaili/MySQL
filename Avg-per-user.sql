  select  sum(total)  as total ,smownerid,last_name from (
SELECT crm.smownerid ,users.last_name  ,inv.invoice_no,inv.invoiceid,inv.total
FROM vtigercrm600.vtiger_invoice inv inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join vtigercrm600.vtiger_users users on crm.smownerid=users.id
where crm.deleted=0 
 and crm.createdtime between '2020-06-12 00:00:00' and '2021-06-12 00:00:00'
  and inv.invoicestatus not like '%مرجو%' 
and ( balance<>0
or ((
           select count(*) as cmodtdetal from vtigercrm600.vtiger_modtracker_basic modt 
			inner join vtigercrm600.vtiger_modtracker_detail modtdetail on modtdetail.id=modt.id
           where  modt.module='invoice'   and  modtdetail.fieldname='balance' and modtdetail.postvalue=0
           and crm.crmid=modt.crmid
             and datediff(modt.changedon,crm.createdtime) >7 
            )>0 )
 )
 group by   invoiceid
  ) as subq
  group by subq.smownerid