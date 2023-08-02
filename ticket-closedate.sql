SET @startdate = '2021-03-21 00:00:00' , @finishdate = '2022-03-21 00:00:00' ;
use vtigercrm600;
select q.user_name,avg(diffendservice) as diffendservice,avg(diffClosed) as diffClosed from 
(
SELECT 
users.user_name
,ifnull(datediff(changedonservice,crm.createdtime),0) as diffendservice
,ifnull(datediff(changedonClosed,crm.createdtime),0) as diffClosed 
FROM  vtiger_troubletickets tickets
inner join vtiger_crmentity crm on crm.crmid=tickets.ticketid
 inner join vtiger_users users on users.id=crm.smownerid
inner join (select 
  max(modtracker.changedon )   as changedonservice,modtracker.crmid from vtiger_modtracker_basic modtracker 
inner join vtiger_modtracker_detail modetail on modetail.id=modtracker.id
where modetail.fieldname='ticketstatus' and  modetail.postvalue=N'اتمام سرویس' 
group by modtracker.crmid
)as q on q.crmid=crm.crmid
left outer join (select 
  max(modtracker2.changedon )   as changedonClosed ,modtracker2.crmid from vtiger_modtracker_basic modtracker2 
inner join vtiger_modtracker_detail modetail2 on modetail2.id=modtracker2.id
where modetail2.fieldname='ticketstatus' and  modetail2.postvalue=N'Closed' 
group by modtracker2.crmid
)as q2 on q2.crmid=crm.crmid
where category=N'تعمیرات' 
and crm.createdtime between @startdate and @finishdate

 group by  ticketid
 ) as q 
 group by q.user_name

limit 10000;