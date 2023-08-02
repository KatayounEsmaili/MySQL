SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00';


SELECT count(*) as count,ships.ship_state
-- potentialname,potential.potentialid,account.accountname,ships.ship_city,ship_state 
FROM vtigercrm600.vtiger_potential potential inner join vtigercrm600.vtiger_crmentity crm
on crm.crmid=potentialid
inner join vtigercrm600.vtiger_account account 
on account.accountid=potential.related_to inner join vtigercrm600.vtiger_accountshipads ships
on account.accountid=ships.accountaddressid 
where crm.createdtime between  @startdate  and   @finishdate
and potential.sales_stage  like '%Lost%'
group by ships.ship_state
having count(*)>=2
order by count(*) desc ;
