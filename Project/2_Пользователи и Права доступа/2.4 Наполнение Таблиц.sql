Use WebCentre;
GO
/*--�������� ������� [Application].ApprovalState --*/

INSERT INTO [Application].[ApprovalState] ([status],[description])
VALUES	 (0,'�� ���������'), (1,'�������� ���������')
		,(2, '��������'), (3, '�����')
		,(4, '������� ������������')

------------------------------------------
/*--�������� ������--*/
INSERT INTO [Application].Users (email, username, [role], subject_type, [status])
values ('designer','designer', 0, 1, 0),('customer','customer', 1, 1, 0),('manager','manager', 2, 1, 0),('admin','admin', 3, 1, 0)

/*������� ��������� ��� �������� ������������*/
exec [Application].proc_CreateWebUsers 'zaigerr74@gmail.com', '������� ����', 'password', 2

/*--�������� ����� ������� admin � designer �� ���� ������������ �����������--*/
;With temp as (select 3 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;With temp as (select 0 [role], Id from BSJobs.[admin].Customers)
INSERT INTO [Application].AccessUsers (id_users, id_customers)
Select * from temp 

;WITH del_dubl AS (SELECT ROW_NUMBER() OVER (PARTITION BY id_users,id_customers order by id_users) as rnm from [Application].AccessUsers)
delete del_dubl where rnm>1

/*--�������� ����� ������������� � ������������*/
exec [Application].proc_AccessWebUsers 6,2511