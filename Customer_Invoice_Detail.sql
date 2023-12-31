
select 
min(year(crm2.createdtime)) as minyear,
p.accountid as accountid,
act.accountname,
p.total as total
from 
(
SELECT 
invoice.accountid

,sum(invoice.total) as total
 FROM vtigercrm600.vtiger_salesorder invoice
inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=invoice.salesorderid
where crm.deleted=0 and invoice.sostatus not like '%Cancelled%'
and invoice.accountid!=4195 and invoice.accountid!=1089
and crm.createdtime between @startdate and @finishdate
-- and invoice.accountid=1591
  group by invoice.accountid
  ) as p 
  inner join vtigercrm600.vtiger_salesorder invoice2
inner join vtigercrm600.vtiger_crmentity crm2 on crm2.crmid=invoice2.salesorderid
inner join vtigercrm600.vtiger_account act on act.accountid=p.accountid
where p.accountid=invoice2.accountid
-- and p.accountid=1591
 group by p.accountid
 
