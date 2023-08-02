SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00';


 DROP TEMPORARY TABLE IF EXISTS
   temp_table;
   
 CREATE TEMPORARY TABLE temp_table (
    item_name nvarchar(2000)
);

 set @X='';
 INSERT INTO temp_table (item_name)
 select    @X:=concat(@X,' sum( case when potential.leadsource =','''',leadsource,'''' ,' then 1 else 0 end )  as ', replace(leadsource,' ','_'),  ' ,'  ) 
 FROM  vtigercrm600.vtiger_leadsource ;

 -- SET @X =LEFT(@X,length(,@X)-1) ;com_vtiger_workflowtasks_entitymethod
 -- select @X;

-- set @cmd=' ';
 set @cmd = concat(
' 
select
crm.smownerid,concat(users.first_name,'' '',users.last_name) as name,
 ', @X ,'
sum( case when potential.leadsource is null  then 1 else 0 end ) as NoSource
FROM vtigercrm600.vtiger_users  users 
inner join vtigercrm600.vtiger_crmentity crm on crm.smownerid=users.id
inner join vtigercrm600.vtiger_invoice invoice on crm.crmid=invoice.invoiceid
left outer join vtigercrm600.vtiger_salesorder salesorder 
on salesorder.salesorderid=invoice.salesorderid
left outer join vtigercrm600.vtiger_potential potential on salesorder.potentialid=potential.potentialid

where crm.deleted=0 and invoice.invoicestatus not like ''%مرجو%''
 and invoice.accountid!=1089
and crm.createdtime between ''', @startdate,'''  and   ''', @finishdate, ''' 
group by crm.smownerid;
');
-- select @cmd;
PREPARE stmt FROM @cmd;
EXECUTE stmt;

