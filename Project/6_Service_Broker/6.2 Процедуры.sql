USE WebCentre
ALTER DATABASE WebCentre SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE WebCentre SET ENABLE_BROKER
ALTER DATABASE WebCentre SET MULTI_USER

--БД должна функционировать от имени технической учетки!!!
ALTER AUTHORIZATION    
   ON DATABASE::WebCentre TO [sa];

--Включите это чтобы доверять сервисам без использования сертификатов когда работаем между различными 
--БД и инстансами(фактически говорим серверу, что этой БД можно доверять)
ALTER DATABASE WebCentre SET TRUSTWORTHY ON;

-- 1. Создание очереди
CREATE QUEUE NotificationQueue;

-- 2. Создание типов сообщений
CREATE MESSAGE TYPE [//Web/RequestMessage]
VALIDATION = WELL_FORMED_XML;

-- 3. Создание контракта
CREATE CONTRACT [//Web/NotificationContract]
(
    [//Web/RequestMessage] SENT BY INITIATOR
);

-- 4. Создание сервиса
CREATE SERVICE [NotificationService]
ON QUEUE NotificationQueue 
([//Web/NotificationContract]);

--Уведомление отправляется при нажатии кнопки в интерфейсе. API вызывает хранимую процедуру:

CREATE PROCEDURE Web.proc_SendNotification
    @RequestId INT,
    @SenderId INT,
    @EventType NVARCHAR(50) --тип события (от заказчика или исполнителя)
AS
BEGIN
    -- Записываю событие в таблицу
    INSERT INTO Web.NotificationEvents (RequestId, SenderId, EventType)
    VALUES (@RequestId, @SenderId, @EventType);

    -- Отправляю сообщение в очередь Service Broker
    DECLARE @MessageBody NVARCHAR(MAX) = '<RequestId>' + CAST(@RequestId AS NVARCHAR) + '</RequestId>';
    DECLARE @DialogHandle UNIQUEIDENTIFIER;

    BEGIN DIALOG CONVERSATION @DialogHandle
    FROM SERVICE NotificationService
    TO SERVICE 'NotificationService'
    ON CONTRACT [//Web/NotificationContract]
    WITH ENCRYPTION = OFF,
	LIFETIME = 3600;

    SEND ON CONVERSATION @DialogHandle
    MESSAGE TYPE  [//Web/RequestMessage] (@MessageBody);
END;

/*--Создаю процедуру для обработки сообщений из очереди--*/
CREATE PROCEDURE Web.proc_ProcessNotificationQueue
AS
BEGIN
    DECLARE @ConversationHandle UNIQUEIDENTIFIER;
    DECLARE @MessageBody NVARCHAR(MAX);
    DECLARE @RequestId INT, @EventType NVARCHAR(50);
    DECLARE @XmlBody XML;

    WHILE (1=1)
    BEGIN
        BEGIN TRANSACTION;
        -- Получаем сообщение из очереди
        WAITFOR (
            RECEIVE TOP(1)
                @ConversationHandle = conversation_handle,
                @MessageBody = message_body
            FROM NotificationQueue
        ), TIMEOUT 5000;

        IF @@ROWCOUNT = 0
        BEGIN
            COMMIT TRANSACTION;
            BREAK;
        END

        -- Парсим XML
        SET @XmlBody = TRY_CAST(@MessageBody AS XML);

        IF @XmlBody IS NOT NULL
        BEGIN
            -- Извлекаем RequestId из XML
            SET @RequestId = @XmlBody.value('(/RequestId/text())[1]', 'INT');
        END
        ELSE
        BEGIN
            -- Логируем ошибку
            INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
            VALUES ('Некорректный формат XML', @MessageBody);
            COMMIT TRANSACTION;
            CONTINUE;
        END

        -- Если RequestId валиден
        IF @RequestId IS NOT NULL
        BEGIN
		
		-- Получаем тип события
		SELECT @EventType = a.EventType
		FROM Web.NotificationEvents a
		WHERE a.RequestId = @RequestId;

            -- Получаем email менеджера, email представителя заказчика и данные заказа
            DECLARE @ManagerEmail NVARCHAR(255), @CustomerEmail NVARCHAR(255),@RecipientEmail NVARCHAR(255);
            SELECT	@ManagerEmail = m.EMail1,
					@CustomerEmail = c.Email
            FROM Web.RequestHead rh
            LEFT JOIN BSJobs.admin.Customers m ON rh.id_customer = m.Id
            LEFT JOIN [WebCentre].[Application].[Users] c ON rh.Creator = c.id
            WHERE rh.id = @RequestId;

	-- Выбираем получателя по типу события
			SET @RecipientEmail = CASE 
				WHEN @EventType = 'CustomerNotify' THEN @ManagerEmail
				WHEN @EventType = 'ExecutorNotify' THEN @CustomerEmail
				ELSE NULL 
			END;

    -- Выбираем шаблон письма
	DECLARE @SubjectTemplate NVARCHAR(255), @BodyTemplate NVARCHAR(MAX)
	SELECT	@SubjectTemplate = Subject,
			@BodyTemplate = Body
	FROM	Web.EmailTemplates
	WHERE	EventType = @EventType;

	-- Заменяем плейсхолдеры
	DECLARE @Subject NVARCHAR(255), @Body NVARCHAR(MAX)
	SET @Subject = REPLACE(@SubjectTemplate, '{OrderId}', @RequestId);
	SET @Body = REPLACE(@BodyTemplate, '{OrderId}', @RequestId);


            -- Отправляем письмо через Database Mail
            BEGIN TRY
                EXEC msdb.dbo.sp_send_dbmail
                    @profile_name = 'PDA',
                    @recipients = @RecipientEmail,
                    @subject = @Subject,
                    @body = @Body;

                -- Помечаем событие как обработанное
                UPDATE Web.NotificationEvents 
                SET IsProcessed = 1 
                WHERE RequestId = @RequestId;
            END TRY
            BEGIN CATCH
                -- Логируем ошибку
                INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
                VALUES (ERROR_MESSAGE(), @MessageBody);
            END CATCH
        END
		ELSE
            BEGIN
                -- Логируем ошибку, если получатель не определен
                INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
                VALUES (
                    CONCAT('Неизвестный тип события или получатель: ', @EventType),
                    @MessageBody
                );
            END
        -- Завершаем диалог
        END CONVERSATION @ConversationHandle;
        COMMIT TRANSACTION;
    END
END;
------------------------------------------------------------------------------
/*--Активация очереди--*/

ALTER QUEUE NotificationQueue
WITH STATUS = ON --OFF=очередь НЕ доступна(ставим если глобальные проблемы)
                                          ,RETENTION = OFF --ON=все завершенные сообщения хранятся в очереди до окончания диалога
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=после 5 ошибок очередь будет отключена
	                                      ,ACTIVATION (STATUS = ON --OFF=очередь не активирует Процедуру(в PROCEDURE_NAME)(ставим на время исправления ХП(хранимая процедура), но с потерей сообщений)  
										              ,PROCEDURE_NAME = Web.proc_ProcessNotificationQueue
													  ,MAX_QUEUE_READERS = 1 --количество потоков(Процедур одновременно вызванных) при обработке сообщений(0-32767)
													                         --(0=тоже не позовется процедура)(ставим на время исправления ХП(хранимой процедуры), без потери сообщений) 
													  ,EXECUTE AS OWNER --учетка от имени которой запустится ХП(хранимая процедура)
													  ) 