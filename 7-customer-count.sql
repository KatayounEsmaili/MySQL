SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';
use vtigercrm600;

SELECT  count(distinct(accounts.accountid)) as AllCustomers-- ,modt.module,modt.changedon,inv.balance,modtdetail.postvalue,modtdetail.prevalue,modtdetail.fieldname-- max(modt.changedon)
FROM vtiger_invoice inv inner join  vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join  vtiger_users users on crm.smownerid=users.id
inner join  vtiger_account accounts on accounts.accountid=inv.accountid
where crm.deleted=0 and inv.invoicestatus not like 'Cancelled' 
and  crm.createdtime between @startdate and @finishdate
  and inv.invoicestatus not like '%مرجو%' 
  and  users.user_name like  CONCAT ('%', @username, '%') 
   ;