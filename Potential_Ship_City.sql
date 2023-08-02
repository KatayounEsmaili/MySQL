SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00';


SELECT count(*) as count,ships.ship_city
-- potentialname,potential.potentialid,account.accountname,ships.ship_city,ship_state 
FROM vtigercrm600.vtiger_potential potential inner join vtigercrm600.vtiger_crmentity crm
on crm.crmid=potentialid
inner join vtigercrm600.vtiger_account account 
on account.accountid=potential.related_to inner join vtigercrm600.vtiger_accountshipads ships
on account.accountid=ships.accountaddressid 
where crm.createdtime between  @startdate  and   @finishdate
group by ships.ship_city
having count(*)>=2
order by count(*) desc ;
