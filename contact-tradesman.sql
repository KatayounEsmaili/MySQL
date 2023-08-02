SELECT  contact.mobile,contact.phone 
FROM vtigercrm600.vtiger_account as account1
 inner join vtigercrm600.vtiger_contactdetails contact on account1.accountid=contact.accountid
   where   industry=N'همکار' and  account1.account_type<>N'همکار تجاری'
    -- group by account1.account_type
   and contact.mobile  regexp  '^[0-9]+$' and ( contact.mobile like'09%' or contact.mobile like '9%') 
  limit 10000;