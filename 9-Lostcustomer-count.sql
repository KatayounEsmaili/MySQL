SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';
use vtigercrm600;

SELECT count(distinct(accounts.accountid)) as countlost FROM  vtiger_potential potential 
inner join vtiger_account accounts on accounts.accountid=potential.related_to
inner join  vtiger_crmentity crm on crm.crmid=potential.potentialid
inner join  vtiger_users users on crm.smownerid=users.id
where crm.deleted=0 
and  crm.createdtime between @startdate and @finishdate
  and  users.user_name like  CONCAT ('%', @username, '%') 
  and potential.sales_stage in ('Closed Lost','بدون تمایل و سرد','فیک - بیهوده')

limit 1000;