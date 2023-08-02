

SELECT  floor(avg(ifnull(inv.pre_tax_total,0))) as total-- ,modt.module,modt.changedon,inv.balance,modtdetail.postvalue,modtdetail.prevalue,modtdetail.fieldname-- max(modt.changedon)
FROM vtigercrm600.vtiger_invoice inv inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join vtigercrm600.vtiger_users users on crm.smownerid=users.id
where crm.deleted=0 and inv.invoicestatus not like 'Cancelled' 
and  crm.createdtime between @startdate and @finishdate
  and inv.invoicestatus not like '%مرجو%' 
  and  users.user_name like  CONCAT ('%', @username, '%') 
  ;
