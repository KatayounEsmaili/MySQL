SELECT max(crm.modifiedtime) as LastDate, 'Invoice' as Action FROM vtiger_invoice invoice inner join vtiger_crmentity crm 
on crm.crmid=invoice.invoiceid
where invoice.accountid=95726;

SELECT *
FROM vtiger_salesorder salesorder  inner join vtiger_crmentity crm 
on crm.crmid=salesorder.salesorderid
where salesorder.accountid=95726 and sostatus not like '%Cancelled%';

SELECT crm2.crmid,max(crm2.modifiedtime) FROM vtigercrm600.vtiger_salesorder salesorder  inner join vtiger_crmentity crm2 
on crm2.crmid=salesorder.salesorderid
where salesorder.accountid=95726 and sostatus not like '%Cancelled%'
group by salesorder.accountid
having max(crm2.modifiedtime);

SELECT max(crm.modifiedtime) as LastDate, 'Potential' as Action FROM vtiger_potential potential inner join vtiger_crmentity crm 
on crm.crmid=potential.potentialid
where potential.related_to=95726;

SELECT  max(crm.modifiedtime) as LastDate, 'Comments' as Action FROM vtiger_modcomments comments inner join vtiger_crmentity crm 
on crm.crmid=comments.modcommentsid
where comments.related_to=95726;


SELECT   max(crm.modifiedtime) as LastDate, 'Account' as Action ,account.accountid
FROM vtiger_account account inner join vtiger_crmentity crm 
on crm.crmid=account.accountid
 where account.accountid=95726
group by account.accountid;
