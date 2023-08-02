
SELECT count(distinct(potentialid)) as countpotential
FROM vtiger_potential potential 
inner join  vtiger_modcomments comments on comments.related_to=potential.potentialid
inner join vtiger_crmentity crm on crm.crmid=comments.modcommentsid
inner join vtiger_modtracker_basic modtracker on modtracker.crmid=crm.crmid
inner join  vtiger_users users on users.id=crm.smownerid 
where crm.deleted=0  
and  crm.createdtime between @startdate and @finishdate
and  users.user_name like  CONCAT ('%', @username, '%') 

;
