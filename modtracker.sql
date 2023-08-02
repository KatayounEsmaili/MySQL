-- declare  @currentdate as  date;
-- set @currentdate:=current_date();
-- set @lastmonthdate:=current_date()-30;
-- select @currentdate,@lastmonthdate;
-- select current_date();


SELECT crm.smownerid ,users.last_name,sum(ifnull(modtdetail.postvalue,0)-ifnull(modtdetail.prevalue,0))  as total
FROM vtigercrm600.vtiger_invoice inv inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=inv.invoiceid 
inner join vtigercrm600.vtiger_users users on crm.smownerid=users.id
inner join vtigercrm600.vtiger_modtracker_basic modt on crm.crmid=modt.crmid
inner join vtigercrm600.vtiger_modtracker_detail modtdetail on modtdetail.id=modt.id
where crm.deleted=0 and modt.module='invoice' and modtdetail.fieldname='received'
 and modt.changedon between  '2021-02-20 00:00:00' and '2021-03-20 00:00:00'
 and ((ifnull(modtdetail.postvalue,0)-ifnull(modtdetail.prevalue,0)>0) or modtdetail.prevalue is null )
  and inv.invoicestatus not like '%مرجو%'
group by crm.smownerid
order by total;
-- having  modtdetail.postvalue-modtdetail.prevalue>0;
/* 
select * from
 vtigercrm600.vtiger_crmentity crm2 
 inner join vtigercrm600.vtiger_inventoryproductrel pdetail on crm2.crmid=pdetail.
*/