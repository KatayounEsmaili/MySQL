SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';



select
-- crm.smownerid,concat(users.first_name,' ',users.last_name) as name,
  floor(sum( case when potential.leadsource ='Existing Customer' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Existing_Customer 
  , floor(sum( case when potential.leadsource ='Employee' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Employee 
  , floor(sum( case when potential.leadsource ='Trade Show' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Trade_Show 
  , floor(sum( case when potential.leadsource ='Web Site' then ifnull(potential.amount,0) else 0 end )) *100/sum(ifnull(potential.amount,0)) as Web_Site 
  , floor(sum( case when potential.leadsource ='Word of mouth' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Word_of_mouth 
  , floor(sum( case when potential.leadsource ='Advertisement' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Advertisement 
  , floor(sum( case when potential.leadsource ='Social networks' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Social_networks 
  , floor(sum( case when potential.leadsource ='Tenders' then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0))  as Tenders 
  -- ,floor(sum( case when potential.leadsource is null or potential.leadsource=''   then ifnull(potential.amount,0) else 0 end ))*100/sum(ifnull(potential.amount,0)) as NoSource
FROM vtigercrm600.vtiger_users  users 
inner join vtigercrm600.vtiger_crmentity crm on crm.smownerid=users.id
 inner join vtigercrm600.vtiger_potential potential on crm.crmid =potential.potentialid
where crm.deleted=0 
and crm.createdtime between @startdate  and  @finishdate 
and users.user_name like  CONCAT ('%', @username, '%')
and (potential.sales_stage='Closed Lost' or potential.sales_stage=N'فیک - بیهوده' )


 