/*--Проверяю работу уведомления--*/
exec Web.proc_SendNotification 4,5,'CustomerNotify'


SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce --представление диалогов(постепенно очищается) чтобы ее не переполнять - --НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;
--------------------------------------------
SELECT 
    conversation_handle,
    state_desc,
    is_initiator,
    far_service,
    far_broker_instance
FROM sys.conversation_endpoints;
----------------------------------------
END CONVERSATION 'CFE41999-AA17-F011-8133-F0B07064A9DF' WITH CLEANUP;