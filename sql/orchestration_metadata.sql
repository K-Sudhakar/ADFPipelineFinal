IF OBJECT_ID('dbo.AdfBackupConfig', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdfBackupConfig
    (
        ConfigId uniqueidentifier NOT NULL CONSTRAINT DF_AdfBackupConfig_ConfigId DEFAULT NEWID(),
        TableSchema sysname NOT NULL,
        TableName sysname NOT NULL,
        TargetFolder nvarchar(400) NOT NULL,
        BackupEnabled bit NOT NULL CONSTRAINT DF_AdfBackupConfig_BackupEnabled DEFAULT (1),
        DeleteEnabled bit NOT NULL CONSTRAINT DF_AdfBackupConfig_DeleteEnabled DEFAULT (0),
        RestoreEnabled bit NOT NULL CONSTRAINT DF_AdfBackupConfig_RestoreEnabled DEFAULT (0),
        FilterColumn sysname NULL,
        UseDateRange bit NOT NULL CONSTRAINT DF_AdfBackupConfig_UseDateRange DEFAULT (0),
        AllowFullDelete bit NOT NULL CONSTRAINT DF_AdfBackupConfig_AllowFullDelete DEFAULT (0),
        BackupMode nvarchar(20) NULL,
        RestoreMode nvarchar(20) NULL,
        IsSequential bit NULL,
        BatchSize int NULL,
        Enabled bit NULL,
        CONSTRAINT PK_AdfBackupConfig PRIMARY KEY CLUSTERED (ConfigId)
    );

    CREATE UNIQUE INDEX UX_AdfBackupConfig_Table ON dbo.AdfBackupConfig (TableSchema, TableName);
END
ELSE
BEGIN
    IF COL_LENGTH('dbo.AdfBackupConfig', 'ConfigId') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD ConfigId uniqueidentifier NOT NULL CONSTRAINT DF_AdfBackupConfig_ConfigId DEFAULT NEWID();
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'DeleteEnabled') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD DeleteEnabled bit NOT NULL CONSTRAINT DF_AdfBackupConfig_DeleteEnabled DEFAULT (0);
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'FilterColumn') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD FilterColumn sysname NULL;
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'UseDateRange') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD UseDateRange bit NOT NULL CONSTRAINT DF_AdfBackupConfig_UseDateRange DEFAULT (0);
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'AllowFullDelete') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD AllowFullDelete bit NOT NULL CONSTRAINT DF_AdfBackupConfig_AllowFullDelete DEFAULT (0);
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'BackupMode') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD BackupMode nvarchar(20) NULL;
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'RestoreMode') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD RestoreMode nvarchar(20) NULL;
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'IsSequential') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD IsSequential bit NULL;
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'BatchSize') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD BatchSize int NULL;
    END

    IF COL_LENGTH('dbo.AdfBackupConfig', 'Enabled') IS NULL
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD Enabled bit NULL;
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.key_constraints
        WHERE [type] = 'PK'
          AND [name] = 'PK_AdfBackupConfig'
          AND [parent_object_id] = OBJECT_ID('dbo.AdfBackupConfig')
    )
    BEGIN
        ALTER TABLE dbo.AdfBackupConfig
        ADD CONSTRAINT PK_AdfBackupConfig PRIMARY KEY CLUSTERED (ConfigId);
    END

    IF NOT EXISTS (
        SELECT 1
        FROM sys.indexes
        WHERE [name] = 'UX_AdfBackupConfig_Table'
          AND [object_id] = OBJECT_ID('dbo.AdfBackupConfig')
    )
    BEGIN
        CREATE UNIQUE INDEX UX_AdfBackupConfig_Table ON dbo.AdfBackupConfig (TableSchema, TableName);
    END
END
GO

IF OBJECT_ID('dbo.AdfOrchestrationRunLog', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdfOrchestrationRunLog
    (
        RunId uniqueidentifier NOT NULL,
        OrchestrationName nvarchar(200) NOT NULL,
        PipelineName nvarchar(200) NOT NULL,
        StepName nvarchar(50) NOT NULL,
        TableSchema sysname NULL,
        TableName sysname NULL,
        Status nvarchar(50) NOT NULL,
        StartTimeUtc datetime2(7) NULL,
        EndTimeUtc datetime2(7) NULL,
        RangeStartUtc datetime2(7) NULL,
        RangeEndUtc datetime2(7) NULL,
        RowsRead bigint NULL,
        RowsCopied bigint NULL,
        RowsDeleted bigint NULL,
        OutputFile nvarchar(400) NULL,
        ErrorCode nvarchar(200) NULL,
        ErrorMessage nvarchar(max) NULL,
        CorrelationId nvarchar(200) NULL,
        InsertedAtUtc datetime2(7) NOT NULL CONSTRAINT DF_AdfOrchestrationRunLog_InsertedAtUtc DEFAULT SYSUTCDATETIME()
    );

    CREATE INDEX IX_AdfOrchestrationRunLog_Run ON dbo.AdfOrchestrationRunLog (RunId, PipelineName, StepName, Status);
END
GO

IF OBJECT_ID('dbo.AdfTableRelationships', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdfTableRelationships
    (
        RelationshipId uniqueidentifier NOT NULL CONSTRAINT DF_AdfTableRelationships_RelationshipId DEFAULT NEWID(),
        ParentSchema sysname NOT NULL,
        ParentTable sysname NOT NULL,
        ParentKeyColumns nvarchar(4000) NOT NULL,
        ChildSchema sysname NOT NULL,
        ChildTable sysname NOT NULL,
        ChildKeyColumns nvarchar(4000) NOT NULL,
        RelationshipName nvarchar(200) NULL,
        IsEnabled bit NOT NULL CONSTRAINT DF_AdfTableRelationships_IsEnabled DEFAULT (1),
        CreatedAtUtc datetime2(7) NOT NULL CONSTRAINT DF_AdfTableRelationships_CreatedAtUtc DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_AdfTableRelationships PRIMARY KEY CLUSTERED (RelationshipId)
    );

    CREATE INDEX IX_AdfTableRelationships_Parent ON dbo.AdfTableRelationships (ParentSchema, ParentTable);
    CREATE INDEX IX_AdfTableRelationships_Child ON dbo.AdfTableRelationships (ChildSchema, ChildTable);
END
GO

IF OBJECT_ID('dbo.AdfTableExecutionOrder', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.AdfTableExecutionOrder
    (
        SchemaName sysname NOT NULL,
        TableName sysname NOT NULL,
        BackupOrderLevel int NOT NULL,
        RestoreOrderLevel int NOT NULL,
        HasParents bit NOT NULL,
        HasChildren bit NOT NULL,
        IsEnabled bit NOT NULL,
        LastComputedUtc datetime2(7) NOT NULL CONSTRAINT DF_AdfTableExecutionOrder_LastComputedUtc DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_AdfTableExecutionOrder PRIMARY KEY CLUSTERED (SchemaName, TableName)
    );
END
GO

IF OBJECT_ID('dbo.usp_AdfRefreshTableExecutionOrder', 'P') IS NULL
BEGIN
    EXEC('
    CREATE PROCEDURE dbo.usp_AdfRefreshTableExecutionOrder
    AS
    BEGIN
        SET NOCOUNT ON;

        ;WITH ActiveTables AS
        (
            SELECT TableSchema, TableName, COALESCE(Enabled, 1) AS IsEnabled
            FROM dbo.AdfBackupConfig
            WHERE COALESCE(Enabled, 1) = 1
        ),
        ActiveRels AS
        (
            SELECT
                ParentSchema,
                ParentTable,
                ChildSchema,
                ChildTable
            FROM dbo.AdfTableRelationships
            WHERE IsEnabled = 1
        ),
        Nodes AS
        (
            SELECT TableSchema AS SchemaName, TableName
            FROM ActiveTables
        ),
        Edges AS
        (
            SELECT
                r.ChildSchema AS ChildSchema,
                r.ChildTable AS ChildTable,
                r.ParentSchema AS ParentSchema,
                r.ParentTable AS ParentTable
            FROM ActiveRels r
            INNER JOIN ActiveTables c
                ON c.TableSchema = r.ChildSchema
               AND c.TableName = r.ChildTable
            INNER JOIN ActiveTables p
                ON p.TableSchema = r.ParentSchema
               AND p.TableName = r.ParentTable
        ),
        Anchor AS
        (
            SELECT
                n.SchemaName,
                n.TableName,
                0 AS BackupOrderLevel
            FROM Nodes n
            LEFT JOIN Edges e
                ON e.ChildSchema = n.SchemaName
               AND e.ChildTable = n.TableName
            WHERE e.ChildSchema IS NULL
        ),
        Levels AS
        (
            SELECT
                a.SchemaName,
                a.TableName,
                a.BackupOrderLevel
            FROM Anchor a

            UNION ALL

            SELECT
                e.ParentSchema AS SchemaName,
                e.ParentTable AS TableName,
                l.BackupOrderLevel + 1 AS BackupOrderLevel
            FROM Levels l
            INNER JOIN Edges e
                ON e.ChildSchema = l.SchemaName
               AND e.ChildTable = l.TableName
        ),
        MaxLevels AS
        (
            SELECT
                n.SchemaName,
                n.TableName,
                COALESCE(MAX(l.BackupOrderLevel), 0) AS BackupOrderLevel
            FROM Nodes n
            LEFT JOIN Levels l
                ON l.SchemaName = n.SchemaName
               AND l.TableName = n.TableName
            GROUP BY n.SchemaName, n.TableName
        ),
        ParentsChildren AS
        (
            SELECT
                n.SchemaName,
                n.TableName,
                CASE WHEN EXISTS (
                    SELECT 1
                    FROM Edges e
                    WHERE e.ChildSchema = n.SchemaName
                      AND e.ChildTable = n.TableName
                ) THEN 1 ELSE 0 END AS HasParents,
                CASE WHEN EXISTS (
                    SELECT 1
                    FROM Edges e
                    WHERE e.ParentSchema = n.SchemaName
                      AND e.ParentTable = n.TableName
                ) THEN 1 ELSE 0 END AS HasChildren
            FROM Nodes n
        )
        MERGE dbo.AdfTableExecutionOrder AS tgt
        USING
        (
            SELECT
                m.SchemaName,
                m.TableName,
                m.BackupOrderLevel,
                (SELECT MAX(BackupOrderLevel) FROM MaxLevels) - m.BackupOrderLevel AS RestoreOrderLevel,
                pc.HasParents,
                pc.HasChildren,
                t.IsEnabled
            FROM MaxLevels m
            INNER JOIN ParentsChildren pc
                ON pc.SchemaName = m.SchemaName
               AND pc.TableName = m.TableName
            INNER JOIN ActiveTables t
                ON t.TableSchema = m.SchemaName
               AND t.TableName = m.TableName
        ) AS src
        ON tgt.SchemaName = src.SchemaName
       AND tgt.TableName = src.TableName
        WHEN MATCHED THEN
            UPDATE SET
                BackupOrderLevel = src.BackupOrderLevel,
                RestoreOrderLevel = src.RestoreOrderLevel,
                HasParents = src.HasParents,
                HasChildren = src.HasChildren,
                IsEnabled = src.IsEnabled,
                LastComputedUtc = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
            INSERT (SchemaName, TableName, BackupOrderLevel, RestoreOrderLevel, HasParents, HasChildren, IsEnabled)
            VALUES (src.SchemaName, src.TableName, src.BackupOrderLevel, src.RestoreOrderLevel, src.HasParents, src.HasChildren, src.IsEnabled)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;
    END
    ');
END
GO
