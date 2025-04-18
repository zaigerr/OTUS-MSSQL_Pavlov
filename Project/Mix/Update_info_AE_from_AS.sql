;WITH temp as (
			  select a.id_common_ul_directory, LEFT (a.ul_name,72) as ul_name, a.id_ul_main as id_parent,b.id_manager, c.name_manager, d.e_mail  from common_ul_directory (nolock) a
			  outer apply (select n.value id_manager FROM common_propvalue (nolock) n where n.propcode=1016 and n.objecttype=5 and n.objectid=a.id_common_ul_directory) b
			  outer apply (select n.subject_description as name_manager from access_subject (nolock) n  where b.id_manager=n.id_access_subject) c
			  outer apply (select n.value e_mail FROM common_propvalue (nolock) n where n.propcode=24499 and n.objecttype=43 and n.objectid=b.id_manager) d
			  )
--SELECT * from BSJobs.admin.Customers a
--INNER JOIN temp b ON a.Id=b.id_common_ul_directory

UPDATE a set	 a.Contact1=b.name_manager
				,a.EMail1=b.e_mail
				,a.Name=ul_name
				,a.Info1=b.id_parent
FROM BSJobs.admin.Customers a
INNER JOIN temp b ON a.Id=b.id_common_ul_directory

/*--Обновляем description у продуктов на реквизит наименование счета из АС--*/

  UPDATE a set a.Descr=b.descrip
  FROM [BSJobs].[admin].[BSProduct] a
  cross apply (select n.value as descrip from asystem_2018.dbo.common_propvalue n where n.propcode=11573 and n.objecttype=41 and n.objectid = coalesce (a.Category3,1)) b