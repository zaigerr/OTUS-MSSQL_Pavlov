SELECT [Id]
      ,[Part_id]
      ,[Status_Created]
      ,[Status_Notes]
      ,[Status_User]
      ,[Status_Value]
  FROM [BSJobs].[admin].[BSPartStatusHistory] a
  --where a.Part_id='4028818b79764b4301797a78469700d2'
  order by a.Status_Created desc

INSERT INTO admin.BSPartStatusHistory (Id
		,[Part_id]
      ,[Status_Created]
      ,[Status_Notes]
      ,[Status_User]
      ,[Status_Value])
 VALUES ( (SELECT CONVERT(CHAR(32), REPLACE(CONVERT(varchar(36), NEWID()), '-', '')) AS UniqueID),'4028818b79764b4301797a78469700d2',(SELECT GETDATE()),'',  'Ликольд', 'Готов к prepress')

 SELECT CONVERT(CHAR(32), REPLACE(CONVERT(varchar(36), NEWID()), '-', '')) AS UniqueID

 select * from [BSJobs].[admin].BSPart a
 where [Url] like 'work/%.ai'

 UPDATE [BSJobs].[admin].BSPart set Category1='Не утвержден' where [Url] like 'source/%.ai' and len (Category1)=0--Status_Value='В работе у дизайнера'

 