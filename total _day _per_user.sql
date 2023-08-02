SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ;

drop  TEMPORARY TABLE if EXISTS  temp1;
CREATE TEMPORARY TABLE IF NOT EXISTS temp1
 select sum(subq1.balance1) as balance1,subq1.smownerid1 from 
(
SELECT  crm1.smownerid as smownerid1,
  sum(ifnull(modtdetail1.postvalue,0))  as balance1 
FROM vtigercrm600.vtiger_invoice inv1 inner join vtigercrm600.vtiger_crmentity crm1 on crm1.crmid=inv1.invoiceid 
inner join vtigercrm600.vtiger_modtracker_basic modt1 on crm1.crmid=modt1.crmid
inner join vtigercrm600.vtiger_modtracker_detail modtdetail1 on modtdetail1.id=modt1.id
where crm1.deleted=0 and modt1.module='invoice' and modtdetail1.fieldname='balance'
 and modt1.changedon = ( select max( modt2.changedon) from  vtigercrm600.vtiger_modtracker_basic modt2 
inner join vtigercrm600.vtiger_modtracker_detail modtdetail2 on modtdetail2.id=modt2.id
where modt2.crmid=crm1.crmid
 and modt2.changedon<= @finishdate
 and modt2.module='invoice' and modtdetail2.fieldname='balance' )
  and crm1.createdtime<= @finishdate
  and inv1.invoicestatus not like '%مرجو%'
   and inv1.balance<>0
 group by   inv1.invoiceid
) as subq1  
 -- ,(select  id as id ,user_name as user_name from  vtigercrm600.vtiger_users ) as users2 where subq1.smownerid1=users2.id
 group by subq1.smownerid1;
 
 drop  TEMPORARY TABLE if EXISTS  temp2;
 CREATE TEMPORARY TABLE IF NOT EXISTS temp2
select sum(subq2.balance2) as balance2 ,smownerid2  from 
(
 SELECT  crm2.smownerid as smownerid2, 
  sum(ifnull(modtdetail2.postvalue,0))  as balance2
FROM vtigercrm600.vtiger_invoice inv2 inner join vtigercrm600.vtiger_crmentity crm2 on crm2.crmid=inv2.invoiceid 
inner join vtigercrm600.vtiger_modtracker_basic modt2 on crm2.crmid=modt2.crmid
inner join vtigercrm600.vtiger_modtracker_detail modtdetail2 on modtdetail2.id=modt2.id
where crm2.deleted=0 and modt2.module='invoice' and modtdetail2.fieldname='balance'
 and modt2.changedon = ( select max( modt5.changedon) from  vtigercrm600.vtiger_modtracker_basic modt5 
inner join vtigercrm600.vtiger_modtracker_detail modtdetail5 on modtdetail5.id=modt5.id
where modt5.crmid=crm2.crmid
 and modt5.changedon<=   @startdate
 and modt5.module='invoice' and modtdetail5.fieldname='balance' )
  and crm2.createdtime<=  @startdate
  and inv2.invoicestatus not like '%مرجو%'
   and inv2.balance<>0
group by   inv2.invoiceid
) as subq2
  -- ,(select  id as id ,user_name as user_name from  vtigercrm600.vtiger_users ) as users2 where subq2.smownerid2=users2.id
 group by subq2.smownerid2;

drop  TEMPORARY TABLE if EXISTS  temp3;

CREATE TEMPORARY TABLE IF NOT EXISTS temp3
 select sum(subq3.total3) as total3 ,subq3.smownerid3 as  smownerid3 from 
(
SELECT crm4.smownerid  as smownerid3,inv4.total as total3-- ,modt.module,modt.changedon,inv.balance,modtdetail.postvalue,modtdetail.prevalue,modtdetail.fieldname-- max(modt.changedon)
FROM vtigercrm600.vtiger_invoice inv4 inner join vtigercrm600.vtiger_crmentity crm4 on crm4.crmid=inv4.invoiceid 
where crm4.deleted=0 
 and crm4.createdtime between @startdate and @finishdate
  and inv4.invoicestatus not like '%مرجو%' 
and ( inv4.balance<>0
or ((
           select count(*) as cmodtdetal from vtigercrm600.vtiger_modtracker_basic modt4
			inner join vtigercrm600.vtiger_modtracker_detail modtdetail4 on modtdetail4.id=modt4.id
           where  modt4.module='invoice'   and  modtdetail4.fieldname='balance' and modtdetail4.postvalue=0
           and crm4.crmid=modt4.crmid
             and datediff(modt4.changedon,crm4.createdtime) >7 
            )>0 )
 )
 group by   inv4.invoiceid
 ) as subq3
 -- ,(select  id as id ,user_name as user_name from  vtigercrm600.vtiger_users ) as users2 where subq3.smownerid3=users2.id
 group by subq3.smownerid3;
 
 -- select * from temp1;
 -- select * from temp2;
 -- select * from temp3;
 
 select  id as id ,user_name , temp2.balance2 as fromdate_balance ,temp1.balance1 as finishdate_balance ,
 temp3.total3 as total ,temp3.total3/((temp2.balance2+temp1.balance1)/2) as days
 from  vtigercrm600.vtiger_users  users left outer join temp1
 on temp1.smownerid1=users.id
 left outer join temp2 on temp2.smownerid2=users.id
 left outer join temp3 on temp3.smownerid3=users.id
--  where users.title  like '%فروش%' 
 
 ;
 
 
 
 