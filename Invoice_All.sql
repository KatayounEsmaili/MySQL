SET @startdate = '2020-03-21 00:00:00' , @finishdate = '2021-03-21 00:00:00' ,@username = 'owjinia';
use vtigercrm600;

SELECT   floor(sum(ifnull(inv.pre_tax_total,0))) as total
FROM vtiger_invoice inv inner join  vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join  vtiger_users users on crm.smownerid=users.id
where crm.deleted=0 and inv.invoicestatus not like 'Cancelled' 
and  crm.createdtime between @startdate and @finishdate
  and inv.invoicestatus not like '%مرجو%' 
  and  users.user_name like  CONCAT ('%', @username, '%') 
  order by inv.invoiceid 
  limit 550;