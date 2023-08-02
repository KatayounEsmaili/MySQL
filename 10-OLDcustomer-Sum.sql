
SELECT  count(distinct(accounts.accountid)) as NewCustomers
,floor(sum(ifnull(inv.total,0))) as total
FROM vtiger_invoice inv inner join  vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join  vtiger_users users on crm.smownerid=users.id
inner join  vtiger_account accounts on accounts.accountid=inv.accountid
where crm.deleted=0 and inv.invoicestatus not like 'Cancelled' 
and  crm.createdtime between @startdate and @finishdate
  and inv.invoicestatus not like '%مرجو%' 
  and  users.user_name like  CONCAT ('%', @username, '%') 
 and    accounts.accountid  in
 (select accounts2.accountid fROM  vtiger_invoice inv2 
 inner join  vtiger_crmentity crm2 on crm2.crmid=inv2.invoiceid
 inner join  vtiger_account accounts2 on accounts2.accountid=inv2.accountid
where crm2.deleted=0 and inv2.invoicestatus not like 'Cancelled' 
and  crm2.createdtime < @startdate 
and inv2.invoicestatus not like '%مرجو%' 
  );
