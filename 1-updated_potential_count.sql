-- تعداد فرصت های تغییر یافته کل توسط یک کارشناس در یک بازه زمانی خاص
SET @startdate = '2020-10-01 00:00:00' , @finishdate = '2021-10-10 00:00:00' ,@username = 'sadooni';
use vtigercrm600;

SELECT  count(distinct(potentialid)) as countpotential
FROM vtiger_potential potential 
inner join vtiger_crmentity crm on crm.crmid=potentialid
inner join vtiger_modtracker_basic modtracker on modtracker.crmid=crm.crmid
inner join vtiger_modtracker_detail modtrackerdetail on modtrackerdetail.id=modtracker.id
inner join  vtiger_users users on users.id=crm.smownerid 

where crm.deleted=0  
and  crm.createdtime < @startdate 
and  modtracker.changedon between @startdate and @finishdate
and  users.user_name = @username

limit 1000;