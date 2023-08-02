

SELECT count(*) as count,ships.ship_state 
FROM vtigercrm600.vtiger_invoice invoice inner join vtigercrm600.vtiger_crmentity crm
on crm.crmid=invoice.invoiceid
inner join vtigercrm600.vtiger_account account 
on account.accountid=invoice.accountid inner join vtigercrm600.vtiger_accountshipads ships
on account.accountid=ships.accountaddressid 
where crm.createdtime between  @startdate  and   @finishdate
group by ships.ship_state
having count(*)>=2
order by count(*) desc ;
