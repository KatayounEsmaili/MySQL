select  sum(balance)  as balance ,smownerid,last_name from (
SELECT crm.smownerid ,users.last_name  ,inv.invoice_no,inv.invoiceid,inv.balance
 -- ,crm.createdtime,inv.balance
FROM vtigercrm600.vtiger_invoice inv inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join vtigercrm600.vtiger_users users on crm.smownerid=users.id
inner join vtigercrm600.vtiger_modtracker_basic modt on crm.crmid=modt.crmid
where crm.deleted=0 and modt.module='invoice' 
 and crm.createdtime<= '2021-01-20 00:00:00'  
  and inv.invoicestatus not like '%مرجو%'
   and balance>0
group by   invoiceid
) as subq
group by subq.smownerid;


select  sum(balance)  as balance ,smownerid,last_name from (
SELECT crm.smownerid ,users.last_name  ,inv.invoice_no,inv.invoiceid,inv.balance
 -- ,crm.createdtime,inv.balance
FROM vtigercrm600.vtiger_invoice inv inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join vtigercrm600.vtiger_users users on crm.smownerid=users.id
inner join vtigercrm600.vtiger_modtracker_basic modt on crm.crmid=modt.crmid
where crm.deleted=0 and modt.module='invoice' 
 and crm.createdtime between  '2021-01-20 00:00:00'  and '2021-03-20 00:00:00'
  and inv.invoicestatus not like '%مرجو%'
   and balance>0
group by   invoiceid
) as subq
group by subq.smownerid