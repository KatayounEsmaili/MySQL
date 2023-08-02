SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';
use vtigercrm600;
SELECT  sum( case when l.leadsource='Web Site' and
       (e.modifiedtime-e.createdtime<30 or (select count(com.modcommentsid) from vtiger_modcomments com where  com.related_to=e.crmid)<=0  ) then 1 else 0 end ) as count_nocomments
       ,sum( case when l.leadsource='Web Site' then 1 else 0 end ) as count_website
       ,sum( case when  (select count(distinct com2.modcommentsid) from vtiger_modcomments com2 where  com2.related_to=e.crmid)>=1  then 1 else 0 end ) as count_comments
     FROM vtiger_leaddetails as l
INNER JOIN vtiger_crmentity as e on e.crmid=l.leadid
INNER JOIN  vtiger_users as u on e.smownerid= u.id
WHERE
	    e.createdtime>@startdate and e.createdtime<@finishdate  and
     e.deleted=0  and e.description like '000' 
     and 
      (u.user_name =@username or @username='')