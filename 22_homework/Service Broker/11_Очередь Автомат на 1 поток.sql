USE WideWorldImporters
ALTER QUEUE [dbo].InitiatorReportQueueWWI WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует Процедуру(в PROCEDURE_NAME)(ставим на время исправления ХП(хранимая процедура), но с потерей сообщений)  
										              ,PROCEDURE_NAME = dbo.ConfirmInvoice
													  ,MAX_QUEUE_READERS = 1 --количество потоков(Процедур одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП(хранимой процедуры), без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП(хранимая процедура)
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