USE WideWorldImporters
ALTER QUEUE [dbo].InitiatorReportQueueWWI WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ���������(� PROCEDURE_NAME)(������ �� ����� ����������� ��(�������� ���������), �� � ������� ���������)  
										              ,PROCEDURE_NAME = dbo.ConfirmInvoice
													  ,MAX_QUEUE_READERS = 1 --���������� �������(�������� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��(�������� ���������), ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��(�������� ���������)
													  ) 

GO
ALTER QUEUE [dbo].TargetReportQueueWWI WITH STATUS = ON 
                                       ,RETENTION = OFF 
									   ,POISON_MESSAGE_HANDLING (STATUS = OFF)
									   ,ACTIVATION (STATUS = ON 
									               ,PROCEDURE_NAME = dbo.CreateReport
												   ,MAX_QUEUE_READERS = 1
												   ,EXECUTE AS OWNER 
												   ) 

GO