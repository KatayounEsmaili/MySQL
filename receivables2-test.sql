SET @startdate = '2021-03-21 00:00:00' , @finishdate = '2022-01-21 00:00:00' ,@username='sadooni',@userid=42;
use vtigercrm600;

select   subq2.balance2  as balance1,subq1.balance1  as balance2 
  , subq3.totalbalance as totalbalance,subq4.total,subq1.smownerid1-- ,subq1.user_name -- where subq3.smownerid= subq.smownerid 
-- group by subq3.smownerid)
-- ,subq1.smow 33wnerid1 
 from 

(
select sum(q1.balance1) as balance1,q1.smownerid1-- ,q1.user_name
from
(
SELECT  crm1.smownerid as smownerid1,-- users1.user_name,
  sum(ifnull(modtdetail1.postvalue,0))  as balance1
FROM  vtiger_invoice inv1 inner join  vtiger_crmentity crm1 on crm1.crmid=inv1.invoiceid 
-- inner join  vtiger_users users on crm.smownerid=users.id
inner join vtiger_modtracker_basic modt1 on crm1.crmid=modt1.crmid
inner join  vtiger_modtracker_detail modtdetail1 on modtdetail1.id=modt1.id
-- inner join  vtiger_users users1 on users1.id=crm1.smownerid
where crm1.deleted=0 and modt1.module='invoice' and modtdetail1.fieldname='balance'
 and modt1.changedon = ( select max( modt2.changedon) from   vtiger_modtracker_basic modt2 
inner join  vtiger_modtracker_detail modtdetail2 on modtdetail2.id=modt2.id
where modt2.crmid=crm1.crmid
 and modt2.changedon < @finishdate
 and modt2.module='invoice' and modtdetail2.fieldname='balance' )
  and crm1.createdtime <  @finishdate
  and inv1.invoicestatus not like N'%مرجو%'
   and modtdetail1.postvalue<>0
   -- and users1.user_name=@username
   and crm1.smownerid=@userid
 group by   inv1.invoiceid,crm1.smownerid
 ) as q1
)  as subq1
left outer join
 (
 select sum(q2.balance2) as balance2 ,q2.smownerid2-- ,q2.user_name
from

(SELECT   crm2.smownerid as smownerid2, -- users2.user_name,
 
   floor(sum(ifnull(modtdetail2.postvalue,0)))  as balance2
FROM  vtiger_invoice inv2 inner join  vtiger_crmentity crm2 on crm2.crmid=inv2.invoiceid 
inner join  vtiger_modtracker_basic modt2 on crm2.crmid=modt2.crmid
inner join  vtiger_modtracker_detail modtdetail2 on modtdetail2.id=modt2.id
-- right outer join  vtiger_users users2 on users2.id=crm2.smownerid
where crm2.deleted=0 and modt2.module='invoice'  and modtdetail2.fieldname='balance'
 and modt2.changedon = ( select max( modt5.changedon) from   vtiger_modtracker_basic modt5 
inner join  vtiger_modtracker_detail modtdetail5 on modtdetail5.id=modt5.id
where modt5.crmid=crm2.crmid
 and modt5.changedon  <    @startdate
 and modt5.module='invoice' and modtdetail5.fieldname='balance' 
 )
  and crm2.createdtime < @startdate
  and inv2.invoicestatus not like N'%مرجو%'
  and modtdetail2.postvalue<>0
 -- and users2.user_name=@username
 and crm2.smownerid=@userid
group by   inv2.invoiceid,crm2.smownerid
) as q2
)  as subq2  on subq1.smownerid1=subq2.smownerid2
 left outer join 
(
  select  FLOOR(sum(q3.total3))  as totalbalance  ,q3.smownerid3-- ,q3.user_name
  from (
SELECT crm4.smownerid  as smownerid3,inv4.total as total3-- ,users3.user_name-- ,modt.module,modt.changedon,inv.balance,modtdetail.postvalue,modtdetail.prevalue,modtdetail.fieldname-- max(modt.changedon)
FROM  vtiger_invoice inv4 inner join  vtiger_crmentity crm4 on crm4.crmid=inv4.invoiceid 
-- right outer join  vtiger_users users3 on users3.id=crm4.smownerid
where crm4.deleted=0 
 and crm4.createdtime between @startdate and @finishdate
  and inv4.invoicestatus not like N'%مرجو%' 
  -- and users3.user_name=@username
  and crm4.smownerid=@userid
and ( inv4.balance<>0
or ((
           select count(*) as cmodtdetal from  vtiger_modtracker_basic modt4
			inner join  vtiger_modtracker_detail modtdetail4 on modtdetail4.id=modt4.id
           where  modt4.module='invoice'   and  modtdetail4.fieldname='balance' and modtdetail4.postvalue=0
           and crm4.crmid=modt4.crmid
             and datediff(modt4.changedon,crm4.createdtime) >7 
            )>0 )
 )
 group by   inv4.invoiceid,crm4.smownerid
  ) as q3
   -- group by q3.smownerid3
 ) as subq3 on subq1.smownerid1=subq3.smownerid3
  left outer join 
(
  select  FLOOR(sum(q4.total4))  as total ,q4.smownerid4-- ,q4.user_name  
  from (
SELECT crm5.smownerid  as smownerid4,inv5.total as total4-- ,users4.user_name-- ,modt.module,modt.changedon,inv.balance,modtdetail.postvalue,modtdetail.prevalue,modtdetail.fieldname-- max(modt.changedon)
FROM  vtiger_invoice inv5 inner join  vtiger_crmentity crm5 on crm5.crmid=inv5.invoiceid
-- right outer join  vtiger_users users4 on users4.id=crm5.smownerid
where crm5.deleted=0 
 and crm5.createdtime between @startdate and @finishdate
  and inv5.invoicestatus not like N'%مرجو%' 
 -- and users4.user_name=@username
 and crm5.smownerid=@userid
 group by   inv5.invoiceid,crm5.smownerid
  ) as q4
    -- group by q4.smownerid4
 )  as subq4 on subq1.smownerid1=subq4.smownerid4;
-- group by  subq1.smownerid1; 