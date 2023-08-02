using System;
using System.Collections.Generic;
using System.Globalization;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace OPP.DA.LeaderBoard
{
    public class TotalInvoice
    {

        public decimal Total { get; set; }
        public decimal Received { get; set; }
        public decimal Balance { get; set; }

        public static async Task<TotalInvoice> GetSalesAsync(int userid, DateTime fromdate, DateTime untildate)
        {
            TotalInvoice res = null;

            var connString = Config.GetReult("crmConnection");
            //"Server=crm.opp.com;port=33307;User ID=admin;Password=crm*admin;Database=vtigercrm600;";

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"SELECT sum(i.total) as total,sum(i.received) as received ,sum(i.balance) as balance ,sum(i.pre_tax_total) as pre_tax_total
                                            FROM vtiger_crmentity as e
                                            inner join vtiger_invoice as i
                                            on e.crmid=i.invoiceid
                                            where e.createdtime>@fromdate and e.createdtime<@untildate and e.smownerid=@userid and e.deleted=0 and (i.invoicestatus='تسویه کامل' or i.invoicestatus='مانده');";
                    MySqlParameter p = new MySqlParameter("@fromdate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untildate", untildate);
                    cmd.Parameters.Add(p);


                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        res = new TotalInvoice()
                        {
                            Total = reader["total"] != System.DBNull.Value ? (decimal)reader["total"] : 0,
                            Balance = reader["balance"] != System.DBNull.Value ? (decimal)reader["balance"] : 0,
                            // Received = reader["received"] != System.DBNull.Value ? (decimal)reader["received"] : 0,
                        };

                        // decimal pre_tax_total=reader["pre_tax_total"] != System.DBNull.Value ? (decimal)reader["pre_tax_total"] : 0;
                        // decimal tax=res.Total- pre_tax_total;

                        // res.Received -= tax;

                    }

                    reader.Close();

                }

            }


            res.Received = await GetSalesLiquidityAsync(userid, fromdate, untildate);
            return res;
        }


        public static async Task<Invoice[]> GetSalesInvoicesAsync(int userid, DateTime fromdate, DateTime untildate)
        {
            List<Invoice> list = new List<Invoice>();
            var connString = Config.GetReult("crmConnection");

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"SELECT invoice_no,i.total as total,i.received as received ,i.balance as balance ,i.invoiceid as id,i.subject as subject
                                            FROM vtiger_crmentity as e
                                            inner join vtiger_invoice as i
                                            on e.crmid=i.invoiceid
                                            where e.createdtime>@fromdate and e.createdtime<@untildate and e.smownerid=@userid and e.deleted=0 and (i.invoicestatus='تسویه کامل' or i.invoicestatus='مانده')
                                            order by e.createdtime desc;";
                    MySqlParameter p = new MySqlParameter("@fromdate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untildate", untildate);
                    cmd.Parameters.Add(p);


                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var inv = new Invoice()
                        {
                            ID = reader["id"] != System.DBNull.Value ? (int)reader["id"] : 0,
                            Subject = reader["subject"] != System.DBNull.Value ? (string)reader["subject"] : "",
                            Name = reader["invoice_no"] != System.DBNull.Value ? (string)reader["invoice_no"] : "",
                            Total = reader["total"] != System.DBNull.Value ? (decimal)reader["total"] : 0,
                            Balance = reader["balance"] != System.DBNull.Value ? (decimal)reader["balance"] : 0,
                            Received = reader["received"] != System.DBNull.Value ? (decimal)reader["received"] : 0,
                        };

                        // decimal tax = reader["tax"] != System.DBNull.Value ? (decimal)reader["tax"] : 0;

                        // inv.Received-=tax;

                        // if(inv.Received<0)
                        //     inv.Received=0;

                        list.Add(inv);
                    }

                    reader.Close();

                }

            }

            return list.ToArray();
        }

        public static async Task<Invoice[]> GetSalesRemainBalanceAsync(int userid)
        {
            List<Invoice> res = new List<Invoice>();
            var connString = Config.GetReult("crmConnection");

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"SELECT i.invoice_no as invoice_no, i.total as total ,i.received as received , i.balance as balance ,i.subject as subject,i.invoiceid as id
                                            FROM vtiger_crmentity as e
                                            inner join vtiger_invoice as i
                                            on e.crmid=i.invoiceid
                                            where  e.smownerid=@userid and e.deleted=0 and i.balance<>0 and i.invoicestatus not like '%مرجوع%'
                                            order by e.createdtime desc;;";
                    MySqlParameter p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var inv = new Invoice()
                        {
                            ID = reader["id"] != System.DBNull.Value ? (int)reader["id"] : 0,
                            Subject = reader["subject"] != System.DBNull.Value ? (string)reader["subject"] : "",
                            Name = reader["invoice_no"] != System.DBNull.Value ? (string)reader["invoice_no"] : "",
                            Total = reader["total"] != System.DBNull.Value ? (decimal)reader["total"] : 0,
                            Balance = reader["balance"] != System.DBNull.Value ? (decimal)reader["balance"] : 0,
                            Received = reader["received"] != System.DBNull.Value ? (decimal)reader["received"] : 0,
                        };

                        res.Add(inv);
                    }

                    reader.Close();

                }

            }

            return res.ToArray();
        }


        private static async Task<decimal> GetSalesLiquidityAsync(int userid, DateTime fromdate, DateTime untildate)
        {
            var connString = Config.GetReult("crmConnection");
            decimal res = 0;
            using (var conn = new MySqlConnection(connString))
            {

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();

                    cmd.Connection = conn;
                    cmd.CommandText = @"select sum(b/(1+tax_percentage)) as sum_balance_no_tax, sum(b) as sum_balance from (
                                                    SELECT  IFNULL(d.postvalue,0)-IFNULL( d.prevalue,0)  as b, ( i.total - i.pre_tax_total)/i.pre_tax_total as tax_percentage  FROM 
                                                    vtiger_modtracker_detail as d inner join
                                                    vtiger_modtracker_basic as b on
                                                    b.id=d.id inner join
                                                    vtiger_crmentity as e on
                                                    b.crmid=e.crmid inner join
                                                    vtiger_invoice as i on
                                                    e.crmid=i.invoiceid
                                                   where b.module='invoice' and d.fieldname='received'   and changedon >@fromDate  and 
                                                     ( IFNULL(d.postvalue,0)<>IFNULL( d.prevalue,0)+0.0 )
                                                             and changedon <@untilDate  and  b.status!=1   and e.smownerid=@userid
                                                    ) as x ;    
                    ";
                    // cmd.CommandText = @" select sum(b) as __s from( 
                    //                                 SELECT  IFNULL(d.postvalue,0)-IFNULL( d.prevalue,0)  as b FROM 
                    //                                 vtiger_modtracker_detail as d inner join
                    //                                 vtiger_modtracker_basic as b on
                    //                                 b.id=d.id inner join
                    //                                 vtiger_crmentity as e on
                    //                                 b.crmid=e.crmid 
                    //                                 where b.module='invoice' and d.fieldname='received' and changedon >@fromDate  and 
                    //                                  ( IFNULL(d.postvalue,0)<>IFNULL( d.prevalue,0)+0.0 )
                    //                                         and changedon <@untilDate and  b.status!=1  and e.smownerid=@userid
                    //                                 ) as x ;";
                    MySqlParameter p = new MySqlParameter("@fromDate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untilDate", untildate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        res = (decimal)(reader["sum_balance_no_tax"] != System.DBNull.Value ? (double)reader["sum_balance_no_tax"] : 0);
                    }

                    reader.Close();
                    conn.Close();
                }

                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();
                    cmd.Connection = conn;

                    cmd.CommandText = @"SELECT sum(i.received) as __s
                                            FROM vtiger_modtracker_basic as b
                                            inner join vtiger_invoice as i
                                            on b.crmid=i.invoiceid 
                                            inner join vtiger_crmentity as e
                                            on e.crmid=i.invoiceid
                                            where b.changedon>@fromDate and b.changedon<@untilDate and e.smownerid=@userid and e.deleted=1 and b.status=1
                                             ";

                    // cmd.CommandText = @"SELECT  sum(i.received) as __s
                    //                         FROM vtiger_crmentity as e
                    //                         inner join vtiger_invoice as i
                    //                         on e.crmid=i.invoiceid
                    //                         where e.createdtime>@fromDate and e.createdtime<@untilDate and e.smownerid=@userid and e.deleted=1;";

                    MySqlParameter p = new MySqlParameter("@fromDate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untilDate", untildate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);
                    var dltInvreader = await cmd.ExecuteReaderAsync();

                    decimal deletedInvoice = 0;

                    if (await dltInvreader.ReadAsync())
                    {
                        deletedInvoice = dltInvreader["__s"] != System.DBNull.Value ? (decimal)dltInvreader["__s"] : 0;
                    }

                    dltInvreader.Close();

                    res -= deletedInvoice;
                }
            }
            return (decimal)res;
        }

        public static async Task<InvoiceDetail[]> GetSalesLiquidityInvoicesAsync(int userid, DateTime fromdate, DateTime untildate)
        {
            var connString = Config.GetReult("crmConnection");
            List<InvoiceDetail> list = new List<InvoiceDetail>();

            using (var conn = new MySqlConnection(connString))
            {

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();

                    cmd.Connection = conn;
                    cmd.CommandText = @" SELECT   invoice_no,IFNULL(d.postvalue,0) postvalue, IFNULL( d.prevalue,0)  as  prevalue ,
                                                        e.crmid as id,i.subject as subject,b.changedon as changedon , 
                                                         (i.total/i.pre_tax_total) as tax_percentage
                                                        FROM 
                                                    vtiger_modtracker_detail as d inner join
                                                    vtiger_modtracker_basic as b on
                                                    b.id=d.id inner join
                                                    vtiger_crmentity as e on
                                                    b.crmid=e.crmid inner join vtiger_invoice as i on
                                                    i.invoiceid=e.crmid
                                                    where b.module='invoice' and d.fieldname='received' and b.changedon >@fromDate and 
                                                    ( IFNULL(d.postvalue,0)<>IFNULL( d.prevalue,0)+0.0 )
                                                            and b.changedon <@untilDate and  b.status!=1  and e.smownerid=@userid
                                                    order by b.changedon desc;";
                    MySqlParameter p = new MySqlParameter("@fromDate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untilDate", untildate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var inv_detail =
                        new InvoiceDetail()
                        {
                            ID = reader["id"] != System.DBNull.Value ? (int)reader["id"] : 0,
                            Subject = reader["subject"] != System.DBNull.Value ? (string)reader["subject"] : "",
                            Name = reader["invoice_no"] != System.DBNull.Value ? (string)reader["invoice_no"] : "",
                            PostValue = (decimal)(reader["postvalue"] != System.DBNull.Value ? double.Parse(reader["postvalue"].ToString()) : 0),
                            PreValue = (decimal)(reader["prevalue"] != System.DBNull.Value ? double.Parse(reader["prevalue"].ToString()) : 0),
                            Tax_percentage = (decimal)(reader["tax_percentage"] != System.DBNull.Value ? double.Parse(reader["tax_percentage"].ToString()) : 0),

                        };
                        try
                        {
                            if (reader["changedon"] != System.DBNull.Value)
                                inv_detail.ChangeDate = DateTime.Parse(reader["changedon"].ToString());
                        }
                        catch { }

                        list.Add(inv_detail);



                    }

                    reader.Close();
                    conn.Close();
                }

                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();
                    cmd.Connection = conn;

                    cmd.CommandText = @"SELECT  i.received as postvalue, i.subject as subject,i.invoiceid as id
                                            FROM vtiger_modtracker_basic as b
                                            inner join vtiger_invoice as i
                                            on b.crmid=i.invoiceid 
                                            inner join vtiger_crmentity as e
                                            on e.crmid=i.invoiceid
                                            where b.changedon>@fromDate and b.changedon<@untilDate and e.smownerid=@userid and e.deleted=1 and b.status=1
                                            order by b.changedon;";

                    // cmd.CommandText = @"SELECT  i.received as postvalue, i.subject as subject,i.invoiceid as id
                    //                         FROM vtiger_crmentity as e
                    //                         inner join vtiger_invoice as i
                    //                         on e.crmid=i.invoiceid 
                    //                         where e.createdtime>@fromDate and e.createdtime<@untilDate and e.smownerid=@userid and e.deleted=1
                    //                         order by e.createdtime;";

                    MySqlParameter p = new MySqlParameter("@fromDate", fromdate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@untilDate", untildate);
                    cmd.Parameters.Add(p);

                    p = new MySqlParameter("@userid", userid);
                    cmd.Parameters.Add(p);
                    var dltInvreader = await cmd.ExecuteReaderAsync();


                    while (await dltInvreader.ReadAsync())
                    {
                        list.Add(new InvoiceDetail()
                        {
                            Deleted = true,
                            ID = dltInvreader["id"] != System.DBNull.Value ? (int)dltInvreader["id"] : 0,
                            Subject = dltInvreader["subject"] != System.DBNull.Value ? (string)dltInvreader["subject"] : "",
                            PreValue = (decimal)(dltInvreader["postvalue"] != System.DBNull.Value ? double.Parse(dltInvreader["postvalue"].ToString()) : 0),
                            PostValue = 0
                        });
                    }

                    dltInvreader.Close();

                }
            }
            return list.ToArray();
        }


        public static async Task<decimal> GetTotalRemainAsync(int userid)
        {
            var connString = Config.GetReult("crmConnection");
            decimal res = 0;
            using (var conn = new MySqlConnection(connString))
            {

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();

                    cmd.Connection = conn;
                    cmd.CommandText = @" SELECT sum(i.balance) as __s 
                                                FROM vtiger_crmentity as e
                                                inner join vtiger_invoice as i
                                                on e.crmid=i.invoiceid
                                                where   e.deleted=0 and balance!=0 and e.smownerid=@userid and i.invoicestatus not like '%مرجوع%'";

                    MySqlParameter p = new MySqlParameter("@userid", userid);

                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        res = (reader["__s"] != System.DBNull.Value ? (decimal)reader["__s"] : 0);
                    }

                    reader.Close();
                    conn.Close();
                }


            }
            return res;
        }



        public static async Task<decimal> GetTotalAccountBalanceAsync(int accountid)
        {
            var connString = Config.GetReult("crmConnection");
            decimal res = 0;
            using (var conn = new MySqlConnection(connString))
            {

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();

                    cmd.Connection = conn;
                    cmd.CommandText = @" SELECT sum(i.balance) as __s 
                                                 FROM vtiger_crmentity as e
                                                inner join vtiger_invoice as i
                                                on e.crmid=i.invoiceid
                                                where   e.deleted=0 and balance!=0 and i.accountid=@accountid and i.invoicestatus not like '%مرجوع%'";
                    MySqlParameter p = new MySqlParameter("@accountid", accountid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        res = (reader["__s"] != System.DBNull.Value ? (decimal)reader["__s"] : 0);
                    }

                    reader.Close();
                    conn.Close();
                }


            }
            return res;
        }


        public static async Task<decimal> GetSubscriptionInquiryAsync(string invoiceno, int days)
        {
            var connString = Config.GetReult("crmConnection");
            decimal quantity = 0;
            bool admin_checked = false;
            int crmid = 0;

            using (var conn = new MySqlConnection(connString))
            {

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    await conn.OpenAsync();

                    cmd.Connection = conn;
                    cmd.CommandText = @"select v.quantity as __q  , cf_867 as admin_checked ,crmid as e.crmid from vtiger_salesorder as i inner join
                                                vtiger_crmentity as e on 
                                                e.crmid=i.salesorderid inner join
                                                vtiger_inventoryproductrel as v on
                                                e.crmid=v.id   inner join
                                                vtiger_service as s on
                                                s.serviceid=v.productid
                                                 inner join
                                                vtiger_salesordercf cf on
                                                cf.salesorderid= e.crmid
                                                where salesorder_no=@invoiceno and 
                                                    s.servicename like '%سامانه ردیابی%'  " +
                                                    "  and ( " +
                                                        "(s.unit_price = v.listprice and " +
                                                        (days == 0 ? "" : " s.qty_per_unit=" + days + " and ") +
                                                         @"v.discount_percent is null and 
                                                         v.discount_amount is null and 
                                                          e.createdtime>'2020-02-20' )	
                                                       or cf_867=1
                                                    )"
                    ;//-- 2020-02-20 time of this change happen on website

                    MySqlParameter p = new MySqlParameter("@invoiceno", invoiceno);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    if (await reader.ReadAsync())
                    {
                        quantity = (reader["__q"] != System.DBNull.Value ? (decimal)reader["__q"] : 0);
                        crmid = (reader["crmid"] != System.DBNull.Value ? (int)reader["crmid"] : 0);
                        admin_checked = (reader["admin_checked"] != System.DBNull.Value ? (int)reader["admin_checked"] > 0 : false);
                    }


                    reader.Close();
                    conn.Close();
                }
            }


            if (admin_checked)
            { // check if the admin check is correctly set by admin
                using (var conn = new MySqlConnection(connString))
                {

                    // Insert some data
                    using (var cmd = new MySqlCommand())
                    {
                        cmd.CommandText = @"select ur.userid, r.roleid,r.rolename as rolename from vtiger_modtracker_basic as b 
                                    inner join  vtiger_modtracker_detail as d
                                    on d.id=b.id 
                                    inner join  vtiger_user2role as ur
                                    on b.whodid=ur.userid 
                                    inner join vtiger_role as r
                                    on ur.roleid=r.roleid
                                    
                                    where  fieldname='cf_867' and postvalue=1 and b.crmid=@crmid
                                    order by b.id desc";



                        MySqlParameter p = new MySqlParameter("@crmid", crmid);
                        cmd.Parameters.Add(p);


                        var reader = await cmd.ExecuteReaderAsync();
                        string rolename = "";
                        if (await reader.ReadAsync())
                        {
                            rolename = (reader["rolename"] != System.DBNull.Value ? (string)reader["rolename"] : "");

                        }


                        if(!string.IsNullOrEmpty(rolename)){
                               string admin_roles = Config.GetReult("admin_roles");

                               if(!string.IsNullOrEmpty(admin_roles)){
                                   
                               }
                        }

                    }
                }
            }

            return quantity;
        }



        public static async Task<Contact[]> GetContactAsync()
        {
            List<Contact> list = new List<Contact>();
            var connString = Config.GetReult("crmConnection");

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"SELECT SUM(i.balance) AS totalBalance ,i.accountid , MAX(e.modifiedtime) AS lastActivity , a.accountname
                        FROM vtiger_invoice AS i INNER JOIN vtiger_crmentity AS e ON e.crmid=i.invoiceid
                        INNER JOIN vtiger_account AS a ON a.accountid=i.accountid
                        WHERE e.deleted=0  AND i.balance<>0 AND i.invoicestatus NOT LIKE '%مرجوع%'
                        GROUP BY i.accountid
                        ORDER BY totalBalance DESC;";

                    var reader = await cmd.ExecuteReaderAsync();
                    var fa_cul = new CultureInfo("fa-IR", true);

                    while (await reader.ReadAsync())
                    {
                        var contactList = new Contact()
                        {
                            AccountId = reader["accountid"] != System.DBNull.Value ? (int)reader["accountid"] : 0,
                            AccountName = reader["accountname"] != System.DBNull.Value ? (string)reader["accountname"] : "",
                            TotalBalance = reader["totalBalance"] != System.DBNull.Value ? (decimal)reader["totalBalance"] : 0,
                        };

                        try
                        {
                            if (reader["lastActivity"] != System.DBNull.Value)
                            {

                                var tmp = DateTime.Parse(reader["lastActivity"].ToString());

                                contactList.LastActivityDate = tmp;

                                contactList.LastActivity = tmp.ToString("yyyy-MM-dd", fa_cul);
                            }
                        }
                        catch { }

                        list.Add(contactList);
                    }

                    reader.Close();

                }

            }
            return list.ToArray();
        }


        public static async Task<Invoice[]> GetInvoiceByAccountAsync(int accountid)
        {
            List<Invoice> res = new List<Invoice>();
            var connString = Config.GetReult("crmConnection");

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandText = @"SELECT i.invoice_no AS invoice_no, i.total AS total ,i.received AS received , i.balance AS balance ,i.subject AS subject,i.invoiceid AS id
                                            FROM vtiger_crmentity AS e
                                            INNER JOIN vtiger_invoice AS i
                                            ON e.crmid=i.invoiceid
                                            WHERE  i.accountid=@accountid AND e.deleted=0 AND i.balance<>0 AND i.invoicestatus NOT LIKE '%مرجوع%'
                                            ORDER BY e.createdtime DESC";
                    MySqlParameter p = new MySqlParameter("@accountid", accountid);
                    cmd.Parameters.Add(p);


                    var reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var inv = new Invoice()
                        {
                            ID = reader["id"] != System.DBNull.Value ? (int)reader["id"] : 0,
                            Subject = reader["subject"] != System.DBNull.Value ? (string)reader["subject"] : "",
                            Name = reader["invoice_no"] != System.DBNull.Value ? (string)reader["invoice_no"] : "",
                            Total = reader["total"] != System.DBNull.Value ? (decimal)reader["total"] : 0,
                            Balance = reader["balance"] != System.DBNull.Value ? (decimal)reader["balance"] : 0,
                            Received = reader["received"] != System.DBNull.Value ? (decimal)reader["received"] : 0,
                        };

                        res.Add(inv);
                    }

                    reader.Close();

                }

            }

            return res.ToArray();
        }


        public static async Task<RFM[]> GetRFMAsync()
        {
            List<RFM> res = new List<RFM>();
            var connString = Config.GetReult("crmConnection");

            using (var conn = new MySqlConnection(connString))
            {
                await conn.OpenAsync();

                // Insert some data
                using (var cmd = new MySqlCommand())
                {
                    cmd.Connection = conn;
                    //all except شخصی 4195
                    cmd.CommandText = @"select acc.accountname as accountname, acc.accountid as accountid,sum(total) as M,count(*) as F, TIMESTAMPDIFF(DAY,curdate(),max(modifiedtime)) as R, acc.account_type from vtiger_invoice as inv
                                            inner join vtiger_account as acc
                                            on inv.accountid=acc.accountid
                                            inner join vtiger_crmentity as en
                                            on en.crmid=inv.invoiceid
                                            where acc.accountid !=4195
                                            group by acc.accountid,acc.accountname";

                    var reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var rfm = new RFM()
                        {
                            AccountID = reader["accountid"] != System.DBNull.Value ? ((int)reader["accountid"]).ToString() : "",
                            AccountName = reader["accountname"] != System.DBNull.Value ? (string)reader["accountname"] : "",
                            Monetry = reader["M"] != System.DBNull.Value ? (decimal)reader["M"] : 0,
                            // Frequency = reader["F"] != System.DBNull.Value ? (long)reader["F"] : 0,
                            Recency = reader["R"] != System.DBNull.Value ? (long)reader["R"] : 0,
                            AccountType = reader["account_type"] != System.DBNull.Value ? (string)reader["account_type"] : "",
                        };

                        res.Add(rfm);
                    }

                    reader.Close();

                    var sett = OPP.DA.LeaderBoard.Config.GetSection<OPP.DA.LeaderBoard.RFM_Setting>("rfm_Setting");


                    cmd.CommandText = @"select acc.accountname as accountname, acc.accountid as accountid,count(*) as F from vtiger_invoice as inv
                                            inner join vtiger_account as acc
                                            on inv.accountid=acc.accountid
                                            inner join vtiger_crmentity as en
                                            on en.crmid=inv.invoiceid
                                            where acc.accountid !=4195 and modifiedtime>@modifiedtime
                                            group by acc.accountid,acc.accountname";

                    MySqlParameter p = new MySqlParameter("@modifiedtime", DateTime.Today.AddDays(sett.frequency_day_check * -1));
                    cmd.Parameters.Add(p);


                    reader = await cmd.ExecuteReaderAsync();

                    while (await reader.ReadAsync())
                    {
                        var rfm = new RFM()
                        {
                            AccountID = reader["accountid"] != System.DBNull.Value ? ((int)reader["accountid"]).ToString() : "",
                            Frequency = reader["F"] != System.DBNull.Value ? (long)reader["F"] : 0,
                        };

                        var rfm_rec = res.Find(i => i.AccountID == rfm.AccountID);

                        rfm_rec.Frequency = rfm.Frequency;
                        //res.Add(rfm);
                    }

                    reader.Close();


                }

            }
            return res.ToArray();
        }



    }
}