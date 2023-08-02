SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00';



select

  floor(sum( case when potential.leadsource ='Existing Customer' then ifnull(invoice.total,0) else 0 end ))  as Existing_Customer 
  , floor(sum( case when potential.leadsource ='Employee' then ifnull(invoice.total,0) else 0 end ))  as Employee 
  , floor(sum( case when potential.leadsource ='Trade Show' then ifnull(invoice.total,0) else 0 end ))  as Trade_Show 
  , floor(sum( case when potential.leadsource ='Web Site' then ifnull(invoice.total,0) else 0 end ))  as Web_Site 
  , floor(sum( case when potential.leadsource ='Word of mouth' then ifnull(invoice.total,0) else 0 end ))  as Word_of_mouth 
  , floor(sum( case when potential.leadsource ='Advertisement' then ifnull(invoice.total,0) else 0 end ))  as Advertisement 
  , floor(sum( case when potential.leadsource ='Social networks' then ifnull(invoice.total,0) else 0 end ))  as Social_networks 
  , floor(sum( case when potential.leadsource ='Tenders' then ifnull(invoice.total,0) else 0 end ))  as Tenders ,
  floor(sum( case when potential.leadsource is null or potential.leadsource=''   then ifnull(invoice.total,0) else 0 end )) as NoSource
FROM  vtigercrm600.vtiger_crmentity crm 
inner join vtigercrm600.vtiger_invoice invoice on crm.crmid=invoice.invoiceid
left outer join vtigercrm600.vtiger_salesorder salesorder 
on salesorder.salesorderid=invoice.salesorderid
left outer join vtigercrm600.vtiger_potential potential on salesorder.potentialid=potential.potentialid
where crm.deleted=0 and invoice.invoicestatus not like '%مرجو%'
 and invoice.accountid!=1089
and crm.createdtime between @startdate  and  @finishdate
-- group by crm.smownerid;

 