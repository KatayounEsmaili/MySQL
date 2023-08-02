

select 
sum(countwon)/sum(count) as convertionrate from 
(
SELECT  sum(if ( potential.isconvertedfromlead=false,1,0)) as count
,sum(if (potential.sales_stage like '%Closed Won%',1,0)) as countwon
FROM   vtiger_potential potential 
inner join vtiger_crmentity crm on crm.crmid=potential.potentialid 
inner join  vtiger_users users on crm.smownerid=users.id
 where
 crm.createdtime between @startdate and @finishdate
 and  crm.deleted=0 
  and  users.user_name like  CONCAT ('%', @username, '%')
 union 
 SELECT count(*) as count,0 as countwon
 FROM  vtiger_leaddetails leads
 inner join  vtiger_crmentity crm on crm.crmid=leads.leadid 
inner join  vtiger_users users on crm.smownerid=users.id
 where  crm.createdtime between @startdate and @finishdate
 and  crm.deleted=0 
  and  users.user_name like  CONCAT ('%', @username, '%') 
 ) as subquery;
