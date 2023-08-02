
SET @startdate = '2021-03-21 00:00:00' , @finishdate = '2021-06-21 00:00:00' ,@username = 'mohebbi';
use vtigercrm600;

select 
count(distinct(leads.leadid)) as leads_commentscount
 FROM  vtiger_leaddetails leads
 inner join   vtiger_modcomments mcomments on mcomments.related_to=leads.leadid 
inner join  vtiger_crmentity crm on crm.crmid=mcomments.modcommentsid 
inner join  vtiger_users users on crm.smownerid=users.id
inner join vtiger_modtracker_basic modtracker on modtracker.crmid=crm.crmid
where  crm.createdtime between @startdate and @finishdate
and  crm.deleted=0 
and  users.user_name=@username;