
--بررسی جهت وجود بانک اطلاعاتی و حذف آن
IF DB_ID('CRMDW')>0
BEGIN
	ALTER DATABASE CRMDW SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE  CRMDW 
END
GO
--ایجاد بانک اطلاعاتی

CREATE DATABASE CRMDW 
	ON  PRIMARY
	(
		NAME=CRMDW_Primary,FILENAME='G:\DataBase\CRMDW\CRMDW_Primary.mdf',SIZE=100MB
	),
	FILEGROUP FG_Dimension
	(
		NAME=Dimension_Invoice,FILENAME='G:\DataBase\CRMDW\Dimension_Invoice.ndf',SIZE=1GB,FILEGROWTH=1GB
	),
	(
		NAME=Dimension_Customers,FILENAME='G:\DataBase\CRMDW\Dimension_Customers.ndf',SIZE=1GB,FILEGROWTH=1GB
	),
	(
		NAME=Dimension_Users,FILENAME='G:\DataBase\CRMDW\Dimension_Users.ndf',SIZE=100MB,FILEGROWTH=100MB
	),
	(
		NAME=Dimension_Date,FILENAME='G:\DataBase\CRMDW\Dimension_Date.ndf',SIZE=100MB,FILEGROWTH=100MB
	),
	FILEGROUP FG_Fact
	(
		NAME=Fact_Invoice,FILENAME='G:\DataBase\CRMDW\Fact_Invoice.ndf',SIZE=1GB,FILEGROWTH=1GB
	),
	(
		NAME=Fact_Customers,FILENAME='G:\DataBase\CRMDW\Fact_Customers.ndf',SIZE=1GB,FILEGROWTH=1GB
	),
	(
		NAME=Fact_Users,FILENAME='G:\DataBase\CRMDW\Users.ndf',SIZE=100MB,FILEGROWTH=100MB
	),
	(
		NAME=Fact_Date,FILENAME='G:\DataBase\CRMDW\Fact_Date.ndf',SIZE=100MB,FILEGROWTH=100MB
	)
	LOG ON
	(
		NAME=CRMDW_Log,FILENAME='G:\DataBase\CRMDW\CRMDW_Log.LDF'--,SIZE=1GB,FILEGROWTH=512MB
	)
GO
--تنظیم نحوه رشد دیتا فایل ها

USE CRMDW
GO
--بررسی تعداد دیتا فایل ها + ظرفیت آنها
SELECT
    DB_NAME() AS [db_name],
    mf.name AS logical_name,
    fg.name as [filegroup_name],
	CAST((mf.Size /128.0) AS DECIMAL(10,2)) AS [SizeMB],
    fg.is_autogrow_all_files
FROM sys.database_files AS mf
JOIN sys.filegroups AS fg
    ON mf.data_space_id = fg.data_space_id
GO
--پاک کردن جدول و ایجاد آن

--بررسی تعداد دیتا فایل ها + ظرفیت آنها
SELECT
    DB_NAME() AS [db_name],
    mf.name AS logical_name,
    fg.name as [filegroup_name],
	CAST((mf.Size /128.0) AS DECIMAL(10,2)) AS [SizeMB],
    fg.is_autogrow_all_files
FROM sys.database_files AS mf
JOIN sys.filegroups AS fg
    ON mf.data_space_id = fg.data_space_id
GO
--بررسی ظرفیت پرشده دیتا فایل ها
SELECT
    name AS logical_name,
    size / 128 AS size_mb,
    CAST(FILEPROPERTY(name, 'SpaceUsed') * 100. / size AS DECIMAL(5, 2)) AS [%_free]
FROM sys.database_files
WHERE type_desc = 'ROWS'
GO
--درج دیتا در جدول

--بررسی تعداد دیتا فایل ها + ظرفیت آنها
SELECT
    DB_NAME() AS [db_name],
    mf.name AS logical_name,
    fg.name as [filegroup_name],
	CAST((mf.Size /128.0) AS DECIMAL(10,2)) AS [SizeMB],
    fg.is_autogrow_all_files
FROM sys.database_files AS mf
JOIN sys.filegroups AS fg
    ON mf.data_space_id = fg.data_space_id
GO
--بررسی ظرفیت پرشده دیتا فایل ها
SELECT
    name AS logical_name,
    size / 128 AS size_mb,
    CAST(FILEPROPERTY(name, 'SpaceUsed') * 100. / size AS DECIMAL(5, 2)) AS [%_free]
FROM sys.database_files
WHERE type_desc = 'ROWS'
GO
