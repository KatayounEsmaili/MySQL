SELECT  contact.mobile,contact.phone 
FROM vtigercrm600.vtiger_account as account
 inner join vtigercrm600.vtiger_contactdetails contact on account.accountid=contact.accountid
  where   industry=N'کارخانجات تولیدی غذایی'
  -- group by industry
  and contact.mobile  regexp  '^[0-9]+$' and ( contact.mobile like'09%' or contact.mobile like '9%') 
  limit 10000;