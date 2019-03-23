IF OBJECT_ID (N'dbo.ufnGetGuidID', N'FN') IS NOT NULL  
    DROP FUNCTION ufnGetGuidID;  
GO  
CREATE OR ALTER FUNCTION dbo.ufnGetGuidID()
RETURNS varchar(38)
AS   
BEGIN  
    DECLARE @ret varchar(38);  
    SELECT @ret = guid_id from dbo.vw_guid_id;
    RETURN @ret;  
END;

