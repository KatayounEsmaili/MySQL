select distinct p.mobile from
(SELECT  distinct  leadaddress.mobile  -- count(*),crm.smownerid,users.last_name 
FROM vtigercrm600.vtiger_leadaddress  leadaddress -- inner join 
 -- vtigercrm600.vtiger_crmentity crm on crm.crmid=leadaddress.leadaddressid 
 -- inner join vtigercrm600.vtiger_users users on users.id=crm.smownerid
 where mobile  regexp  '^[0-9]+$' and ( mobile like'09%' or mobile like '9%') 
 -- and mobile <>''
 -- order by leadaddress.mobile 
 union 
 SELECT distinct contact.mobile FROM vtigercrm600.vtiger_contactdetails contact 
 where contact.mobile  regexp  '^[0-9]+$' and ( contact.mobile like'09%' or contact.mobile like '9%') 
 ) as p
 order by mobile
 limit 10000;
--  group by crm.smownerid
-- order by count(*) desc;