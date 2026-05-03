/* Required once before Table.sql — dbo.get_date() used by table defaults and SPs */

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.get_date', N'FN') IS NOT NULL
    DROP FUNCTION dbo.get_date;
GO

CREATE FUNCTION dbo.get_date()
RETURNS DATETIME
AS
BEGIN
    RETURN SYSDATETIME();
END
GO
