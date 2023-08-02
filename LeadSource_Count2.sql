SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00';



select
crm.smownerid,concat(users.first_name,' ',users.last_name) as name,
  sum( case when potential.leadsource ='Existing Customer' then 1 else 0 end )  as Existing_Customer 
  , sum( case when potential.leadsource ='Employee' then 1 else 0 end )  as Employee 
  , sum( case when potential.leadsource ='Trade Show' then 1 else 0 end )  as Trade_Show 
  , sum( case when potential.leadsource ='Web Site' then 1 else 0 end )  as Web_Site 
  , sum( case when potential.leadsource ='Word of mouth' then 1 else 0 end )  as Word_of_mouth 
  , sum( case when potential.leadsource ='Advertisement' then 1 else 0 end )  as Advertisement 
  , sum( case when potential.leadsource ='Social networks' then 1 else 0 end )  as Social_networks 
  , sum( case when potential.leadsource ='Tenders' then 1 else 0 end )  as Tenders ,
sum( case when potential.leadsource is null or potential.leadsource=''  then 1 else 0 end ) as NoSource
FROM vtigercrm600.vtiger_users  users 
inner join vtigercrm600.vtiger_crmentity crm on crm.smownerid=users.id
inner join vtigercrm600.vtiger_invoice invoice on crm.crmid=invoice.invoiceid
left outer join vtigercrm600.vtiger_salesorder salesorder 
on salesorder.salesorderid=invoice.salesorderid
left outer join vtigercrm600.vtiger_potential potential on salesorder.potentialid=potential.potentialid

where crm.deleted=0 and invoice.invoicestatus not like '%مرجو%'
 and invoice.accountid!=1089
and crm.createdtime between @startdate  and  @finishdate
group by crm.smownerid;

 