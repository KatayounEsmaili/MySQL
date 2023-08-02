SET @accountid = 95726 ;

SELECT    max(crm.modifiedtime) as LastDate
 FROM vtigercrm600.vtiger_crmentity crm   cross join vtigercrm600.vtiger_account account  
 where account.accountid=@accountid and  
 crm.crmid in
 (
(SELECT crm2.crmid FROM vtigercrm600.vtiger_salesorder salesorder  inner join vtigercrm600.vtiger_crmentity crm2 
on crm2.crmid=salesorder.salesorderid
where salesorder.accountid=95726 and sostatus not like '%Cancelled%'
group by salesorder.accountid
having max(crm2.modifiedtime))
, 
(SELECT crm2.crmid FROM vtigercrm600.vtiger_account account2  inner join vtigercrm600.vtiger_crmentity crm2
on crm2.crmid=account2.accountid
where account2.accountid=95726
group by account2.accountid
having max(crm2.modifiedtime))
,
(SELECT crm2.crmid FROM vtigercrm600.vtiger_invoice invoice  inner join vtigercrm600.vtiger_crmentity crm2 
on crm2.crmid=invoice.invoiceid
where invoice.accountid=95726
group by invoice.accountid
having max(crm2.modifiedtime))
,
(SELECT crm2.crmid FROM vtigercrm600.vtiger_potential potential  inner join vtigercrm600.vtiger_crmentity crm2 
on crm2.crmid=potential.potentialid
where potential.related_to=95726
group by potential.related_to
having max(crm2.modifiedtime))
,
(SELECT crm2.crmid FROM vtigercrm600.vtiger_modcomments comments   inner join vtigercrm600.vtiger_crmentity crm2 
on crm2.crmid=comments.modcommentsid
where comments.related_to=95726
group by comments.related_to
having max(crm2.modifiedtime))
)
 group by account.accountid
;
