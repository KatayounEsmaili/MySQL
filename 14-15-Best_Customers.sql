
SET @startdate = '2020-06-12 00:00:00' , @finishdate = '2021-06-12 00:00:00' ;

use vtigercrm600;

select accountname,count(0) as factors,floor(sum(subquery.productprice)) as productprice,  floor(sum(subquery.productprice-subquery.totalprice)) as profitprice,
 -- floor(sum(subquery.profit)) as profit,
floor(avg(subquery.productprice)) as productprice_avg
,floor(sum(subquery.productprice-subquery.totalprice)) as profit_avg
from 
(
SELECT 
 productrel.id,productrel.productid as productid ,acc.accountname,
crm.smownerid as smownerid,sum(productrel.quantity*ifnull(productcf.cf_1001,0)) as totalprice,
 case when products.productname is null then service.servicename else products.productname end as prdname,
  case when products.productcategory is null then service.servicecategory else products.productcategory end as prdcategory

  ,floor(sum(
 case when invoice.discount_amount is not null then 
  (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) -( invoice.discount_amount*( ((((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) /(invoice.pre_tax_total+invoice.discount_amount))))
 else case when invoice.discount_percent then  (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100) * (100-invoice.discount_percent)/100
 else (((productrel.quantity*listprice)-ifnull(productrel.discount_amount,0))*(100-ifnull(productrel.discount_percent,0))/100)  end end
 )) as productprice
FROM vtiger_invoice invoice 
inner join vtiger_crmentity crm on crm.crmid=invoice.invoiceid
inner join vtiger_users users on users.id=crm.smownerid 
inner join vtiger_account as acc on invoice.accountid=acc.accountid
inner join  vtiger_inventoryproductrel productrel on invoiceid=productrel.id
 left outer  join  vtiger_products products on products.productid=productrel.productid
 left outer join  vtiger_service service on service.serviceid=productrel.productid
left outer join  vtiger_productcf productcf on productcf.productid=products.productid
where crm.deleted=0 and invoice.invoicestatus not like 'Cancelled' 
and invoice.invoicestatus not like '%مرجو%' 
and  crm.createdtime between @startdate and @finishdate
and ( products.productid is not null or service.serviceid is not null)
 group by invoice.invoiceid ,case when products.productid is null then service.serviceid else products.productid end
 ) as subquery
 group by accountname
 having sum(subquery.productprice)>0
 order by sum(subquery.productprice) desc
 limit 10000;