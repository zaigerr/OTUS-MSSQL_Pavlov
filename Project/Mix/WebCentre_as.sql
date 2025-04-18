SELECT TOP (1000) [id_common_propvalue]
      ,[propcode]
      ,[objectid]
      ,[objecttype]
      ,[value]
  FROM [asystem_2018].[dbo].[common_propvalue] a
  where a.propcode=1016 and a.value=67 and a.objecttype=5
