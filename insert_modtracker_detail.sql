use vtigercrm600;
set @counter:=1;
SELECT @id:=max(id) FROM vtiger_modtracker_basic ;
-- set @id:=@id+1;
set @id2=@id;

 insert into vtiger_modtracker_basic (id,crmid,module,whodid,changedon,status) 
(SELECT  @id:=@id+1,inv1.invoiceid,'Invoice',crm1.smownerid,cast('2020-02-20 01:00:00' as datetime),2
FROM vtigercrm600.vtiger_invoice inv1 inner join vtigercrm600.vtiger_crmentity crm1 on crm1.crmid=inv1.invoiceid 
where crm1.deleted=0 
 and inv1.balance=0
  and crm1.createdtime < '2020-02-21'
  and inv1.invoicestatus not like N'%مرجو%'
  -- and modtdetail1.postvalue<>0
  and inv1.invoiceid not in (
  select inv2.invoiceid 
  FROM vtiger_invoice inv2 inner join vtigercrm600.vtiger_crmentity crm2 on crm2.crmid=inv2.invoiceid 
inner join vtigercrm600.vtiger_modtracker_basic modt1 on crm2.crmid=modt1.crmid
inner join vtigercrm600.vtiger_modtracker_detail modtdetail1 on modtdetail1.id=modt1.id
where crm2.deleted=0 and modt1.module='invoice' and modtdetail1.fieldname='balance'
and crm2.createdtime < '2020-02-21'
and modtdetail1.postvalue=0
  )
   group by inv1.invoiceid
   );
   
     insert into vtiger_modtracker_detail (id,fieldname,prevalue,postvalue)
   (SELECT  id,'balance',0,0 FROM vtiger_modtracker_basic where id>@id2 and changedon between '2020-02-20' and '2020-02-21');
   