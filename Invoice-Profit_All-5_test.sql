SET @startdate = '2020-03-21 00:00:00' , @finishdate = '2021-03-21 00:00:00' ,@username = 'owjinia';


 select -- subquery.id,
 floor(sum(subquery.productprice)) as productprice,floor(sum(subquery.productprice-subquery.totalprice)) as profitprice
 
   from
   (
SELECT 
 productrel.id,productrel.productid as productid ,
crm.smownerid as smownerid,sum(productrel.quantity*ifnull(productcf.cf_1001,0)) as totalprice,
 case when products.productname is null then service.servicename else products.productname end as prdname,
  case when products.productcategory is null then service.servicecategory else products.productcategory end as prdcategory,
 case when products.productname is null then 'Service' else 'Product' end as type
  
 ,floor(sum(
 case when invoice.discount_amount is not null then 
  (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) -( invoice.discount_amount*( ((((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) /(invoice.pre_tax_total+invoice.discount_amount))))
 else case when invoice.discount_percent then  (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) * (100-invoice.discount_percent)/100
 else (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100)  end end
 )) as productprice
 
FROM vtigercrm600.vtiger_invoice invoice 
inner join vtigercrm600.vtiger_crmentity crm on crm.crmid=invoice.invoiceid
inner join vtigercrm600.vtiger_users users on users.id=crm.smownerid 
inner join vtigercrm600.vtiger_inventoryproductrel productrel on invoiceid=productrel.id
 left outer  join vtigercrm600.vtiger_products products on products.productid=productrel.productid
 left outer join vtigercrm600.vtiger_service service on service.serviceid=productrel.productid
left outer join vtigercrm600.vtiger_productcf productcf on productcf.productid=products.productid
where crm.deleted=0 and invoice.invoicestatus not like 'Cancelled' 
and invoice.invoicestatus not like '%مرجو%' 
and  crm.createdtime between @startdate and @finishdate
and ( products.productid is not null or service.serviceid is not null)
 and  users.user_name like  CONCAT ('%', @username, '%') 
-- and invoiceid=103594
 group by productrel.id  ,case when products.productid is null then service.serviceid else products.productid end

 )  as subquery
   -- group by subquery.id
    having sum(subquery.productprice)>0
   order by subquery.id
 limit 5000
 ;