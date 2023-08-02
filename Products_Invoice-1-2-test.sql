
SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ,@username = 'sadooni';
-- select  subquery.prdcategory,sum(subquery.productprice) as productprice-- ,subquery.productid,subquery.type,prdcategory -- ,sum(q.productprice) as suminvoice 
 -- from
-- (
SELECT -- sum(invoice.total)
 productrel.id  ,productrel.productid as productid ,
 crm.smownerid as smownerid,
  case when products.productname is null then service.servicename else products.productname end as prdname,
 case when products.productcategory is null then service.servicecategory else products.productcategory end as prdcategory,
  case when products.productname is null then 'Service' else 'Product' end as type

  
 ,sum(case when productrel.discount_amount is not null then (productrel.quantity*listprice)-productrel.discount_amount 
 else case when productrel.discount_percent is not null then (productrel.quantity*listprice)* (100-productrel.discount_percent) else 
 case when invoice.discount_amount is not null then (productrel.quantity*listprice)-( invoice.discount_amount*( (productrel.quantity*listprice/(invoice.pre_tax_total+invoice.discount_amount))))
 else case when invoice.discount_percent then (productrel.quantity*listprice)* (100-invoice.discount_percent)/100
 else (productrel.quantity*listprice) end end end end)as productprice
 
FROM vtigercrm600.vtiger_invoice invoice 
inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=invoice.invoiceid
inner join vtigercrm600.vtiger_users users on users.id=crm.smownerid 
inner join vtigercrm600.vtiger_inventoryproductrel productrel on invoiceid=productrel.id
 left outer  join vtigercrm600.vtiger_products products on products.productid=productrel.productid
 left outer join vtigercrm600.vtiger_service service on service.serviceid=productrel.productid
 
where crm.deleted=0 and invoice.invoicestatus not like 'Cancelled' 
and invoice.invoicestatus not like '%مرجو%' 
and  crm.createdtime between @startdate and @finishdate
and ( products.productid is not null or service.serviceid is not null)
 and  users.user_name like  CONCAT ('%', @username, '%') 
 -- and productrel.id =134281
 
 group by productrel.id   ,case when products.productid is null then service.serviceid else products.productid end
  -- )as subquery
 -- group by subquery.prdname
 -- having sum(subquery.productprice)>0
 -- order by  sum(subquery.productprice)

limit 10000;