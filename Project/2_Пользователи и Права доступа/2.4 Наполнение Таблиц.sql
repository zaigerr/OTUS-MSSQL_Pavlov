Use WebCentre;
GO
/*--наполняю таблицу [Application].ApprovalState --*/

INSERT INTO [Application].[ApprovalState] ([status],[description])
VALUES	 (0,'Не утвержден'), (1,'Внесение изменений')
		,(2, 'Утверждён'), (3, 'Архив')
		,(4, 'Ожидает согласования')

------------------------------------------
/*--Добавляю группы--*/
INSERT INTO [Application].Users (email, username, [role], subject_type, [status])
values ('designer','designer', 0, 1, 0),('customer','customer', 1, 1, 0),('manager','manager', 2, 1, 0),('admin','admin', 3, 1, 0)

/*вызываю процедуру для создания пользователя*/
exec [Application].proc_CreateWebUsers 'zaigerr74@gmail.com', 'Ивакина Инна', 'password', 2

/*--Добавляю права группам admin и designer на всех контрагентов справочника--*/
;With temp as (select 3 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;With temp as (select 0 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;WITH del_dubl AS (SELECT ROW_NUMBER() OVER (PARTITION BY id_users,id_customers order by id_users) as rnm from [Application].AccessUsers)
delete del_dubl where rnm>1

/*--Добавляю права пользователям к контрагентам*/
exec [Application].proc_AccessWebUsers 6,2511