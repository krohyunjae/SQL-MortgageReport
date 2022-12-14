USE [Mortgage]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DECLARE @DropConstraints NVARCHAR(max) = ''
SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
EXECUTE sp_executesql @DropConstraints;
GO
  
-- drop tables
DECLARE @DropTables NVARCHAR(max) = ''
SELECT @DropTables += 'DROP TABLE ' + QUOTENAME(TABLE_SCHEMA) + '.' + QUOTENAME(TABLE_NAME)
FROM INFORMATION_SCHEMA.TABLES
EXECUTE sp_executesql @DropTables;
GO

DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Loan;
DROP TABLE IF EXISTS Member;
DROP TABLE IF EXISTS MemberFinance;
DROP TABLE IF EXISTS #tempmem;
DROP TABLE IF EXISTS #tempaddr;
DROP TABLE IF EXISTS #tempmf;
DROP TABLE IF EXISTS #temploan;


CREATE TABLE [dbo].[Address](
	[addressId] [int] IDENTITY(1,1) NOT NULL,
	[state] [nchar](15) NULL,
	[city] [nchar](30) NULL,
	[streetAddress] [nchar](50) NULL,
	[zipcode] [nchar](10) NULL,
	[fullAddress]  AS ((((((isnull([StreetAddress],'')+',')+' ')+isnull([City],''))+',')+' ')+isnull([State],'')),
 CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
(
	[addressId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loan](
	[loanId] [int] IDENTITY(10000000,1) NOT NULL,
	[memberfinanceId] [int] NOT NULL,
	[date] [date] NOT NULL,
	[purpose] [nvarchar](50) NULL,
	[isJointApplication] [nchar](10) NULL,
	[loanAmount] [money] NULL,
	[paymentTerm] [smallint] NULL,
	[interestRate] [float] NULL,
	[monthlyPayment] [smallmoney] NULL,
	[loanGrade] [nchar](2) NULL,
	[loanStatus] [nchar](10) NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[loanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Member](
	[firstName] [nvarchar](100) NOT NULL,
	[lastName] [nvarchar](100) NOT NULL,
	[fullName]  AS (([firstName]+' ')+[lastName]),
	[ssn] [nvarchar](9) NULL,
	[creditScore] [nvarchar](3) NULL,
	[addressId] [int] NULL,
	[memberId] [int] NOT NULL,
	[email] [nvarchar](50) NULL,
	[contactNumber] [nchar](14) NULL,
	[isMarried] [nchar](10) NULL,
	[age] [tinyint] NULL,
	[gender] [nvarchar](10) NULL,
 CONSTRAINT [PK_Member] PRIMARY KEY CLUSTERED 
(
	[memberId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MemberFinance](
	[memberfinanceId] [int] IDENTITY(1,1) NOT NULL,
	[memberId] [int] NOT NULL,
	[creditScore] [nchar](3) NOT NULL,
	[yearsEmployment] [tinyint] NULL,
	[annualIncome] [money] NULL,
	[incomeVerified] [nchar](10) NULL,
	[dtiRatio] [float] NULL,
	[lengthCreditHistory] [tinyint] NULL,
	[numTotalCreditLines] [smallint] NULL,
	[numOpenCreditLines] [smallint] NULL,
	[numOpenCreditLinesLastYear] [smallint] NULL,
	[revolvingBalance] [float] NULL,
	[revolvingUtilizationRate] [float] NULL,
	[numDeregatoryRec] [smallint] NULL,
	[numDelinquency2Years] [smallint] NULL,
	[numChargeOffLastYear] [smallint] NULL,
	[numInquiries6Mon] [smallint] NULL,
 CONSTRAINT [PK_MemberFinance] PRIMARY KEY CLUSTERED 
(
	[memberfinanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_MemberFinance] FOREIGN KEY([memberfinanceId])
REFERENCES [dbo].[MemberFinance] ([memberfinanceId])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_MemberFinance]
GO
ALTER TABLE [dbo].[Member]  WITH CHECK ADD  CONSTRAINT [FK_Member_Address] FOREIGN KEY([addressId])
REFERENCES [dbo].[Address] ([addressId])
GO
ALTER TABLE [dbo].[Member] CHECK CONSTRAINT [FK_Member_Address]
GO
ALTER TABLE [dbo].[MemberFinance]  WITH CHECK ADD  CONSTRAINT [FK_MemberFinance_Member] FOREIGN KEY([memberId])
REFERENCES [dbo].[Member] ([memberId])
GO
ALTER TABLE [dbo].[MemberFinance] CHECK CONSTRAINT [FK_MemberFinance_Member]
GO

SET IDENTITY_INSERT [dbo].[Address] ON

/* Bulk loading into the address table*/
SELECT  addr.addressId,
		addr.state,
		addr.city,
		addr.streetAddress,
		addr.zipcode
INTO #tempaddr
FROM [dbo].[Address] addr


BULK INSERT #tempaddr FROM 'E:\Workspace2\SQL\Reports\Mortgage\address.dat' WITH (FIRSTROW = 1, ROWTERMINATOR = '\n', FIELDTERMINATOR = '|', ROWS_PER_BATCH = 10000)

INSERT INTO [dbo].[Address](addressId,state,city,streetAddress,zipcode)
	SELECT addr.addressId,
		addr.state,
		addr.city,
		addr.streetAddress,
		addr.zipcode
		FROM #tempaddr addr
SET IDENTITY_INSERT [dbo].[Address] OFF
/* Bulk loading into the member table*/
SELECT  mem.memberId,
		mem.firstName,
		mem.lastName,
		mem.ssn,
		mem.addressId,
		mem.creditScore,
		mem.email,
		mem.contactNumber,
		mem.isMarried,
		mem.age,
		mem.gender
INTO #tempmem
FROM [dbo].[Member] mem 


BULK INSERT #tempmem FROM 'E:\Workspace2\SQL\Reports\Mortgage\member.dat' WITH (FIRSTROW = 1, ROWTERMINATOR = '\n', FIELDTERMINATOR = '|', ROWS_PER_BATCH = 10000)

INSERT INTO [dbo].[Member](memberId, firstName, lastName, ssn, addressId, creditScore, email, contactNumber,isMarried, age, gender)
	SELECT mem.memberId,
		mem.firstName,
		mem.lastName,
		mem.ssn,
		mem.addressId,
		mem.creditScore,
		mem.email,
		mem.contactNumber,
		mem.isMarried,
		mem.age,
		mem.gender
		FROM #tempmem mem
/* Bulk loading into the memberfinance table*/
SET IDENTITY_INSERT [dbo].[MemberFinance] ON
SELECT  mf.memberfinanceId,
		mf.memberId,
		mf.creditScore,
		mf.yearsEmployment,
		mf.annualIncome,
		mf.incomeVerified,
		mf.dtiRatio,
		mf.lengthCreditHistory,
		mf.numOpenCreditLines,
		mf.numOpenCreditLinesLastYear,
		mf.revolvingBalance,
		mf.revolvingUtilizationRate,
		mf.numDeregatoryRec,
		mf.numDelinquency2Years,
		mf.numChargeOffLastYear,
		mf.numInquiries6Mon
INTO #tempmf
FROM [dbo].[MemberFinance] mf 

BULK INSERT #tempmf FROM 'E:\Workspace2\SQL\Reports\Mortgage\memberfinance.dat' WITH (FIRSTROW = 1, ROWTERMINATOR = '\n', FIELDTERMINATOR = '|', ROWS_PER_BATCH = 10000)

INSERT INTO [dbo].[MemberFinance](memberfinanceId,memberId,creditScore,yearsEmployment,annualIncome,incomeVerified,dtiRatio,lengthCreditHistory,numTotalCreditLines,
									numOpencreditLinesLastYear,revolvingBalance,revolvingUtilizationRate,numDeregatoryRec,
									numDelinquency2Years,numChargeOffLastYear,numInquiries6Mon)
	SELECT mf.memberfinanceId,
		mf.memberId,
		mf.creditScore,
		mf.yearsEmployment,
		mf.annualIncome,
		mf.incomeVerified,
		mf.dtiRatio,
		mf.lengthCreditHistory,
		mf.numOpenCreditLines,
		mf.numOpenCreditLinesLastYear,
		mf.revolvingBalance,
		mf.revolvingUtilizationRate,
		mf.numDeregatoryRec,
		mf.numDelinquency2Years,
		mf.numChargeOffLastYear,
		mf.numInquiries6Mon
		FROM #tempmf mf
SET IDENTITY_INSERT [dbo].[MemberFinance] OFF
/* Bulk loading into the loan table*/
SET IDENTITY_INSERT [dbo].[Loan] ON
SELECT  l.loanId,
		l.memberfinanceId,
		l.date,
		l.purpose,
		l.isJointApplication,
		l.loanAmount,
		l.paymentTerm,
		l.interestRate,
		l.monthlyPayment,
		l.loanGrade
INTO #temploan
FROM [dbo].[Loan] l 


BULK INSERT #temploan FROM 'E:\Workspace2\SQL\Reports\Mortgage\loan.dat' WITH (FIRSTROW = 1, ROWTERMINATOR = '\n', FIELDTERMINATOR = '|', ROWS_PER_BATCH = 10000)

INSERT INTO [dbo].[loan](loanId,memberfinanceId,date,purpose,isJointApplication,loanAmount,paymentTerm,interestRate,monthlyPayment,loanGrade)
	SELECT l.loanId,
		l.memberfinanceId,
		l.date,
		l.purpose,
		l.isJointApplication,
		l.loanAmount,
		l.paymentTerm,
		l.interestRate,
		l.monthlyPayment,
		l.loanGrade
		FROM #temploan l
SET IDENTITY_INSERT [dbo].[Loan] OFF
