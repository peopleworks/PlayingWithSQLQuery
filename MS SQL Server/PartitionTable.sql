
-- Create a Partition Function
CREATE PARTITION FUNCTION ZipIntegerPartitionFunction (INT)
AS RANGE RIGHT FOR VALUES (10000, 20000, 30000, 40000)

-- Create a Partition Scheme
CREATE PARTITION SCHEME ZipIntegerPartitionScheme 
AS PARTITION ZipIntegerPartitionFunction ALL TO ([PRIMARY]) 
GO

-- Verify Partition Scheme
SELECT ps.name,pf.name,boundary_id,value
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON pf.function_id=ps.function_id
INNER JOIN sys.partition_range_values prf ON pf.function_id=prf.function_id

--Alter the Existing Table to Use Partition Scheme
ALTER TABLE dbo.uszips DROP CONSTRAINT PK_uszips
GO
ALTER TABLE dbo.uszips ADD CONSTRAINT PK_uszips PRIMARY KEY NONCLUSTERED  (oid)
   WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
         ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX IX_uszips_oid ON dbo.uszips (oid)
  WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
        ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON ZipIntegerPartitionScheme(oid)
GO

-- Verify Partition Rows 
SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name LIKE '%uszips%'

-- Show data in each Partition
SELECT $PARTITION.ZipIntegerPartitionFunction(oid) AS PartitionNumber, *
FROM uszips


Select * from uszips where zip like '%605'
Select * from uszips where zip = '00624'

---- Staging Table
BEGIN TRANSACTION
USE [ZipCodes]
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE TABLE [dbo].[Staging_uszips](
	[oid] [int] NOT NULL,
	[zip] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lat] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[lng] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[city] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state_id] [varchar](2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[state_name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[zcta] [int] NULL,
	[parent_zcta] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[population] [float](53) NULL,
	[density] [float](53) NULL,
	[county_fips] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[county_name] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[county_weights] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[county_names_all] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[county_fips_all] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[imprecise] [int] NULL,
	[military] [int] NULL,
	[timezone] [varchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[age_median] [float](53) NULL,
	[age_under_10] [float](53) NULL,
	[age_10_to_19] [float](53) NULL,
	[age_20s] [float](53) NULL,
	[age_30s] [float](53) NULL,
	[age_40s] [float](53) NULL,
	[age_50s] [float](53) NULL,
	[age_60s] [float](53) NULL,
	[age_70s] [float](53) NULL,
	[age_over_80] [float](53) NULL,
	[age_over_65] [float](53) NULL,
	[age_18_to_24] [float](53) NULL,
	[age_over_18] [float](53) NULL,
	[male] [float](53) NULL,
	[female] [float](53) NULL,
	[married] [float](53) NULL,
	[divorced] [float](53) NULL,
	[never_married] [float](53) NULL,
	[widowed] [float](53) NULL,
	[family_size] [float](53) NULL,
	[family_dual_income] [float](53) NULL,
	[income_household_median] [float](53) NULL,
	[income_household_under_5] [float](53) NULL,
	[income_household_5_to_10] [float](53) NULL,
	[income_household_10_to_15] [float](53) NULL,
	[income_household_15_to_20] [float](53) NULL,
	[income_household_20_to_25] [float](53) NULL,
	[income_household_25_to_35] [float](53) NULL,
	[income_household_35_to_50] [float](53) NULL,
	[income_household_50_to_75] [float](53) NULL,
	[income_household_75_to_100] [float](53) NULL,
	[income_household_100_to_150] [float](53) NULL,
	[income_household_150_over] [float](53) NULL,
	[income_household_six_figure] [float](53) NULL,
	[income_individual_median] [float](53) NULL,
	[home_ownership] [float](53) NULL,
	[housing_units] [float](53) NULL,
	[home_value] [float](53) NULL,
	[rent_median] [float](53) NULL,
	[rent_burden] [float](53) NULL,
	[education_less_highschool] [float](53) NULL,
	[education_highschool] [float](53) NULL,
	[education_some_college] [float](53) NULL,
	[education_bachelors] [float](53) NULL,
	[education_graduate] [float](53) NULL,
	[education_college_or_above] [float](53) NULL,
	[education_stem_degree] [float](53) NULL,
	[labor_force_participation] [float](53) NULL,
	[unemployment_rate] [float](53) NULL,
	[self_employed] [float](53) NULL,
	[farmer] [float](53) NULL,
	[race_white] [float](53) NULL,
	[race_black] [float](53) NULL,
	[race_asian] [float](53) NULL,
	[race_native] [float](53) NULL,
	[race_pacific] [float](53) NULL,
	[race_other] [float](53) NULL,
	[race_multiple] [float](53) NULL,
	[hispanic] [float](53) NULL,
	[disabled] [float](53) NULL,
	[poverty] [float](53) NULL,
	[limited_english] [float](53) NULL,
	[commute_time] [float](53) NULL,
	[health_uninsured] [float](53) NULL,
	[veteran] [float](53) NULL,
	[charitable_givers] [float](53) NULL,
	[cbsa_fips] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cbsa_name] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[cbsa_metro] [int] NULL,
	[csa_fips] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[csa_name] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[metdiv_fips] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[metdiv_name] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]

USE [ZipCodes]
CREATE CLUSTERED INDEX [Staging_uszips_IX_uszips_oid] ON [dbo].[Staging_uszips]
(
	[oid] ASC
)WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
USE [ZipCodes]
ALTER TABLE [dbo].[Staging_uszips] ADD  CONSTRAINT [Staging_uszips_PK_uszips] PRIMARY KEY NONCLUSTERED 
(
	[oid] ASC
)WITH (PAD_INDEX = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
USE [ZipCodes]
ALTER TABLE [dbo].[Staging_uszips]  WITH CHECK ADD  CONSTRAINT [chk_Staging_uszips_partition_5] CHECK  ([oid]>=N'40000' AND [oid]<N'10000')
ALTER TABLE [dbo].[Staging_uszips] CHECK CONSTRAINT [chk_Staging_uszips_partition_5]
COMMIT TRANSACTION


-- Data compression 
EXEC sys.sp_estimate_data_compression_savings 'dbo', 'uszips', 1, NULL, 'PAGE'