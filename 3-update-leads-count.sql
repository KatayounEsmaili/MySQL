
select 
count(distinct(leads.leadid)) as leadscount
 FROM  vtiger_leaddetails leads
inner join  vtiger_crmentity crm on crm.crmid=leads.leadid 
inner join  vtiger_users users on crm.smownerid=users.id
inner join vtiger_modtracker_basic modtracker on modtracker.crmid=crm.crmid
where  crm.createdtime < @startdate 
and modtracker.changedon between  @startdate and @finishdate
and  crm.deleted=0 
and  users.user_name= @username
;
