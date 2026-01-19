CREATE TABLE dbo.TableList (
    tableId INT IDENTITY(1,1) PRIMARY KEY,
    schemaName SYSNAME NOT NULL,
    tableName SYSNAME NOT NULL,
    isActive BIT NOT NULL DEFAULT 1,
    loadingBehavior VARCHAR(20) NOT NULL CHECK (loadingBehavior IN ('FullLoad','DeltaLoad')),
    watermarkColumnName SYSNAME NULL,
    watermarkType VARCHAR(20) NULL CHECK (watermarkType IN ('datetime','numeric')),
    watermarkStartValue NVARCHAR(200) NULL,
    queryOverride NVARCHAR(MAX) NULL,
    partitionSettings NVARCHAR(4000) NULL,
    sinkPathSettings NVARCHAR(4000) NULL,
    restoreEnabled BIT NOT NULL DEFAULT 1,
    restoreBehavior VARCHAR(20) NOT NULL DEFAULT 'TruncateLoad' CHECK (restoreBehavior IN ('TruncateLoad','Upsert')),
    restoreFolderDate VARCHAR(20) NULL,
    restoreFileName NVARCHAR(260) NULL,
    upsertKeyColumns NVARCHAR(4000) NULL
);

CREATE TABLE dbo.WatermarkState (
    tableId INT NOT NULL PRIMARY KEY,
    watermarkValue NVARCHAR(200) NULL,
    lastUpdatedUtc DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_Watermark_TableList FOREIGN KEY (tableId) REFERENCES dbo.TableList(tableId)
);

CREATE TABLE dbo.RunLog (
    runLogId BIGINT IDENTITY(1,1) PRIMARY KEY,
    runId NVARCHAR(64) NOT NULL,
    tableId INT NOT NULL,
    direction VARCHAR(10) NOT NULL CHECK (direction IN ('Backup','Restore')),
    status VARCHAR(20) NOT NULL,
    rowsCopied BIGINT NULL,
    sinkPath NVARCHAR(1000) NULL,
    startUtc DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    endUtc DATETIME2(0) NULL
);
GO

CREATE OR ALTER PROCEDURE dbo.UpdateWatermark
    @tableId INT,
    @newValue NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.WatermarkState AS tgt
    USING (SELECT @tableId AS tableId, @newValue AS watermarkValue) AS src
        ON tgt.tableId = src.tableId
    WHEN MATCHED THEN
        UPDATE SET watermarkValue = src.watermarkValue, lastUpdatedUtc = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN
        INSERT (tableId, watermarkValue, lastUpdatedUtc)
        VALUES (src.tableId, src.watermarkValue, SYSUTCDATETIME());
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_InsertRunLog
    @runId NVARCHAR(64),
    @tableId INT,
    @direction VARCHAR(10),
    @status VARCHAR(20),
    @rowsCopied BIGINT = NULL,
    @sinkPath NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.RunLog (runId, tableId, direction, status, rowsCopied, sinkPath, startUtc, endUtc)
    VALUES (@runId, @tableId, @direction, @status, @rowsCopied, @sinkPath, SYSUTCDATETIME(), SYSUTCDATETIME());
END
GO

CREATE OR ALTER PROCEDURE dbo.usp_TruncateIfFull
    @schemaName SYSNAME,
    @tableName SYSNAME,
    @loadingBehavior VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF @loadingBehavior = 'FullLoad'
    BEGIN
        DECLARE @sql NVARCHAR(MAX) = N'TRUNCATE TABLE [' + @schemaName + N'].[' + @tableName + N'];';
        EXEC sp_executesql @sql;
    END
END
GO
