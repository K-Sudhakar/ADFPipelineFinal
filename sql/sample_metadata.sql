INSERT INTO dbo.TableList
(schemaName, tableName, isActive, loadingBehavior, watermarkColumnName, watermarkType, watermarkStartValue, queryOverride, sinkPathSettings, restoreEnabled, restoreBehavior, restoreFolderDate, restoreFileName, upsertKeyColumns)
VALUES
('dbo','SalesOrder',1,'DeltaLoad','ModifiedDate','datetime','2023-01-01T00:00:00',NULL,NULL,1,'TruncateLoad','2024/10/01','SalesOrder_20241001_010101.parquet',NULL);

INSERT INTO dbo.WatermarkState (tableId, watermarkValue)
SELECT tableId, '2023-01-01T00:00:00'
FROM dbo.TableList
WHERE schemaName = 'dbo' AND tableName = 'SalesOrder';
