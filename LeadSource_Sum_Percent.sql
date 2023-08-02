SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';



select 
 -- crm.smownerid,concat(users.first_name,' ',users.last_name) as name,
   -- floor(sum(invoice.total)),
  floor(sum( case when potential.leadsource ='Existing Customer' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Existing_Customer 
  , floor(sum( case when potential.leadsource ='Employee' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Employee 
  , floor(sum( case when potential.leadsource ='Trade Show' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Trade_Show 
  , floor(sum( case when potential.leadsource ='Web Site' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Web_Site 
  , floor(sum( case when potential.leadsource ='Word of mouth' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Word_of_mouth 
  , floor(sum( case when potential.leadsource ='Advertisement' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Advertisement 
  , floor(sum( case when potential.leadsource ='Social networks' then ifnull(invoice.total,0) else 0 end )) *100/sum(invoice.total) as Social_networks 
  , floor(sum( case when potential.leadsource ='Tenders' then ifnull(invoice.total,0) else 0 end ))*100/sum(invoice.total)  as Tenders 
  ,floor(sum( case when potential.leadsource is null or potential.leadsource=''  then ifnull(invoice.total,0) else 0 end))*100/sum(invoice.total)  as NoSource
 -- ,floor(sum( case when salesorder.salesorderid is null or potential.potentialid is null  then ifnull(invoice.total,0) else 0 end))*100/sum(invoice.total)  as NoPotential*/
FROM vtigercrm600.vtiger_users  users 
inner join vtigercrm600.vtiger_crmentity crm on crm.smownerid=users.id
inner join vtigercrm600.vtiger_invoice invoice on crm.crmid=invoice.invoiceid
left outer join vtigercrm600.vtiger_salesorder salesorder 
on salesorder.salesorderid=invoice.salesorderid
left outer join vtigercrm600.vtiger_potential potential on salesorder.potentialid=potential.potentialid
where crm.deleted=0 and invoice.invoicestatus not like '%مرجو%'
 and invoice.accountid!=1089
and crm.createdtime between @startdate  and  @finishdate
and users.user_name like  CONCAT ('%', @username, '%')

 -- and potential.leadsource is null 
 -- group by potential.leadsource

 