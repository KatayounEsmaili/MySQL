

select s.servicecategory as name ,sum(detail.listprice*detail.quantity) as total ,CONVERT(s.servicecategory USING utf8)  as cat from vtiger_invoice as inv
inner join   vtiger_inventoryproductrel as detail
on detail.id=inv.invoiceid
inner join vtiger_crmentity as en
on en.crmid=inv.invoiceid
inner join vtiger_service as s
on s.serviceid= detail.productid
where en.createdtime between  @startdate and @finishdate and en.deleted=0 and inv.invoicestatus not like N'%مرجوع%'
group by s.servicecategory 
UNION
select s.productcategory   as name ,sum(detail.listprice*detail.quantity) as total ,CONVERT(s.productcategory USING utf8)  as cat from vtiger_invoice as inv
inner join   vtiger_inventoryproductrel as detail
on detail.id=inv.invoiceid
inner join vtiger_crmentity as en
on en.crmid=inv.invoiceid
inner join vtiger_products as s
on s.productid= detail.productid
where en.createdtime between  @startdate and @finishdate and en.deleted=0 and inv.invoicestatus not like N'%مرجوع%'
group by s.productcategory
order by total desc
