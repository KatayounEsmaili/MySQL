SET @startdate = '2021-02-21 00:00:00' , @finishdate = '2022-03-21 00:00:00' , @accountname=273; -- N'ردیاب جهان گستر اشراق';
use vtigercrm600;
 
 select 
 ac.accountname,
   ifnull(sum(sbq.balance1),0) as balance1,
   ifnull(sum(sbq.balance2),0) as balance2,
   sum(sbq.creditinvoice) as creditinvoice,
   sum(sbq.totalinvoice) as totalinvoice,
  -- (($__unixEpochTo()-$__unixEpochFrom())/(60*60*24)) as duration_days,
   -- (($__unixEpochTo()-$__unixEpochFrom())/(60*60*24))/( sum(sbq.creditinvoice) /(( ifnull(sum(sbq.balance1),0)+ifnull(sum(sbq.balance2),0))/2)) as receivable_turn_over_days,
    sum(sbq.creditinvoice) / sum(sbq.totalinvoice)  as credit_ratio
 from vtiger_account as ac
 inner join 
 ( 
select
  subq2.balance2 as balance1,
  subq1.balance1 as balance2,
  subq3.totalbalance as  creditinvoice,
  subq4.total as totalinvoice,
  subq1.accountid1 as accountid
from
  (
    select
      sum(q1.balance1) as balance1,
      q1.accountid1
    from
      (
        SELECT
          inv1.accountid as accountid1,
          sum(ifnull(modtdetail1.postvalue, 0)) as balance1
        FROM
          vtiger_invoice inv1
          inner join vtiger_crmentity crm1 on crm1.crmid = inv1.invoiceid
          inner join vtiger_modtracker_basic modt1 on crm1.crmid = modt1.crmid
          inner join vtiger_modtracker_detail modtdetail1 on modtdetail1.id = modt1.id
          right outer join vtiger_users users1 on users1.id = crm1.smownerid
        where
          crm1.deleted = 0
          and modt1.module = 'invoice'
          and modtdetail1.fieldname = 'balance'
          and modt1.changedon = (
            select
              max(modt2.changedon)
            from
              vtiger_modtracker_basic modt2
              inner join vtiger_modtracker_detail modtdetail2 on modtdetail2.id = modt2.id
            where
              modt2.crmid = crm1.crmid
              and modt2.changedon between '2020-02-20'
              and  @finishdate
              and modt2.module = 'invoice'
              and modtdetail2.fieldname = 'balance'
          )
          and crm1.createdtime between '2020-02-20'
          and  @finishdate
          and inv1.invoicestatus not like N'%مرجو%'
          and modtdetail1.postvalue <> 0
        group by
          inv1.invoiceid
      ) as q1
    group by
      q1.accountid1
  ) as subq1
  left outer join (
    select
      sum(q2.balance2) as balance2,
      q2.accountid2
    from
      (
        SELECT
          inv2.accountid as accountid2,
          floor(sum(ifnull(modtdetail2.postvalue, 0))) as balance2
        FROM
          vtiger_invoice inv2
          inner join vtiger_crmentity crm2 on crm2.crmid = inv2.invoiceid
          inner join vtiger_modtracker_basic modt2 on crm2.crmid = modt2.crmid
          inner join vtiger_modtracker_detail modtdetail2 on modtdetail2.id = modt2.id
          right outer join vtiger_users users2 on users2.id = crm2.smownerid
        where
          crm2.deleted = 0
          and modt2.module = 'invoice'
          and modtdetail2.fieldname = 'balance'
          and modt2.changedon = (
            select
              max(modt5.changedon)
            from
              vtiger_modtracker_basic modt5
              inner join vtiger_modtracker_detail modtdetail5 on modtdetail5.id = modt5.id
            where
              modt5.crmid = crm2.crmid
              and modt5.changedon between '2020-02-20'
              and   @startdate -- $__timeFrom()
              and modt5.module = 'invoice'
              and modtdetail5.fieldname = 'balance'
          )
          and crm2.createdtime between '2020-02-20'
          and   @startdate-- $__timeFrom()
          and inv2.invoicestatus not like N'%مرجو%'
          and modtdetail2.postvalue <> 0
        group by
          inv2.invoiceid
      ) as q2
    group by
      q2.accountid2
  ) as subq2 on subq1.accountid1 = subq2.accountid2
  left outer join (
    select
      FLOOR(sum(q3.total3)) as totalbalance,
      q3.accountid3
    from
      (
        SELECT
          
          inv4.accountid as accountid3,
          inv4.total as total3
        FROM
          vtiger_invoice inv4
          inner join vtiger_crmentity crm4 on crm4.crmid = inv4.invoiceid
        where
          crm4.deleted = 0
          and crm4.createdtime between   @startdate -- $__timeFrom()
          and @finishdate --  $__timeTo()
          and inv4.invoicestatus not like N'%مرجو%'
          and (
            inv4.balance <> 0
            or (
              (
                select
                  count(*) as cmodtdetal
                from
                  vtiger_modtracker_basic modt4
                  inner join vtiger_modtracker_detail modtdetail4 on modtdetail4.id = modt4.id
                where
                  modt4.module = 'invoice'
                  and modtdetail4.fieldname = 'balance'
                  and modtdetail4.postvalue = 0
                  and crm4.crmid = modt4.crmid
                  and datediff(modt4.changedon, crm4.createdtime) > 7
              ) > 0
            )
          )
        group by
          inv4.invoiceid
      ) as q3
    group by
      q3.accountid3
  ) as subq3 on subq1.accountid1 = subq3.accountid3
  left outer join (
    select
      FLOOR(sum(q4.total4)) as total,
      q4.accountid4
    from
      (

       
       SELECT
          inv5.accountid as accountid4,
          inv5.total as total4 
        FROM
          vtiger_invoice inv5
          inner join vtiger_crmentity crm5 on crm5.crmid = inv5.invoiceid
        where
          crm5.deleted = 0
          and crm5.createdtime between @startdate--  $__timeFrom()
          and  @finishdate 
          and inv5.invoicestatus not like N'%مرجو%'
        group by
          inv5.invoiceid
      ) as q4
    group by
      q4.accountid4
  ) as subq4 on subq1.accountid1 = subq4.accountid4
group by
  subq1.accountid1
  )
  as sbq
  on ac.accountid=sbq.accountid
    where @accountname=''-- '$username'=''
   or ac.accountid=@accountname
   -- group by ac.accountname
  