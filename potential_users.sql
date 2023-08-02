SELECT Count(*) as count , crm.smownerid,users.user_name FROM vtigercrm600.vtiger_potential potential 
inner join vtiger_crmentity crm on crm.crmid=potential.potentialid
inner join vtiger_users users on users.id=crm.smownerid
where potential.amount=0 and crm.createdtime between '2019-03-21 00:00:00' and  '2021-05-21 00:00:00'
group by crm.smownerid ;