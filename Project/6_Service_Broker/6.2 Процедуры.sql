USE WebCentre
ALTER DATABASE WebCentre SET SINGLE_USER WITH ROLLBACK IMMEDIATE
ALTER DATABASE WebCentre SET ENABLE_BROKER
ALTER DATABASE WebCentre SET MULTI_USER

--�� ������ ��������������� �� ����� ����������� ������!!!
ALTER AUTHORIZATION    
   ON DATABASE::WebCentre TO [sa];

--�������� ��� ����� �������� �������� ��� ������������� ������������ ����� �������� ����� ���������� 
--�� � ����������(���������� ������� �������, ��� ���� �� ����� ��������)
ALTER DATABASE WebCentre SET TRUSTWORTHY ON;

-- 1. �������� �������
CREATE QUEUE NotificationQueue;

-- 2. �������� ����� ���������
CREATE MESSAGE TYPE [//Web/RequestMessage]
VALIDATION = WELL_FORMED_XML;

-- 3. �������� ���������
CREATE CONTRACT [//Web/NotificationContract]
(
    [//Web/RequestMessage] SENT BY INITIATOR
);

-- 4. �������� �������
CREATE SERVICE [NotificationService]
ON QUEUE NotificationQueue 
([//Web/NotificationContract]);

--����������� ������������ ��� ������� ������ � ����������. API �������� �������� ���������:

CREATE PROCEDURE Web.proc_SendNotification
    @RequestId INT,
    @SenderId INT,
    @EventType NVARCHAR(50) --��� ������� (�� ��������� ��� �����������)
AS
BEGIN
    -- ��������� ������� � �������
    INSERT INTO Web.NotificationEvents (RequestId, SenderId, EventType)
    VALUES (@RequestId, @SenderId, @EventType);

    -- ��������� ��������� � ������� Service Broker
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

/*--������ ��������� ��� ��������� ��������� �� �������--*/
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
        -- �������� ��������� �� �������
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

        -- ������ XML
        SET @XmlBody = TRY_CAST(@MessageBody AS XML);

        IF @XmlBody IS NOT NULL
        BEGIN
            -- ��������� RequestId �� XML
            SET @RequestId = @XmlBody.value('(/RequestId/text())[1]', 'INT');
        END
        ELSE
        BEGIN
            -- �������� ������
            INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
            VALUES ('������������ ������ XML', @MessageBody);
            COMMIT TRANSACTION;
            CONTINUE;
        END

        -- ���� RequestId �������
        IF @RequestId IS NOT NULL
        BEGIN
		
		-- �������� ��� �������
		SELECT @EventType = a.EventType
		FROM Web.NotificationEvents a
		WHERE a.RequestId = @RequestId;

            -- �������� email ���������, email ������������� ��������� � ������ ������
            DECLARE @ManagerEmail NVARCHAR(255), @CustomerEmail NVARCHAR(255),@RecipientEmail NVARCHAR(255);
            SELECT	@ManagerEmail = m.EMail1,
					@CustomerEmail = c.Email
            FROM Web.RequestHead rh
            LEFT JOIN BSJobs.admin.Customers m ON rh.id_customer = m.Id
            LEFT JOIN [WebCentre].[Application].[Users] c ON rh.Creator = c.id
            WHERE rh.id = @RequestId;

	-- �������� ���������� �� ���� �������
			SET @RecipientEmail = CASE 
				WHEN @EventType = 'CustomerNotify' THEN @ManagerEmail
				WHEN @EventType = 'ExecutorNotify' THEN @CustomerEmail
				ELSE NULL 
			END;

    -- �������� ������ ������
	DECLARE @SubjectTemplate NVARCHAR(255), @BodyTemplate NVARCHAR(MAX)
	SELECT	@SubjectTemplate = Subject,
			@BodyTemplate = Body
	FROM	Web.EmailTemplates
	WHERE	EventType = @EventType;

	-- �������� ������������
	DECLARE @Subject NVARCHAR(255), @Body NVARCHAR(MAX)
	SET @Subject = REPLACE(@SubjectTemplate, '{OrderId}', @RequestId);
	SET @Body = REPLACE(@BodyTemplate, '{OrderId}', @RequestId);


            -- ���������� ������ ����� Database Mail
            BEGIN TRY
                EXEC msdb.dbo.sp_send_dbmail
                    @profile_name = 'PDA',
                    @recipients = @RecipientEmail,
                    @subject = @Subject,
                    @body = @Body;

                -- �������� ������� ��� ������������
                UPDATE Web.NotificationEvents 
                SET IsProcessed = 1 
                WHERE RequestId = @RequestId;
            END TRY
            BEGIN CATCH
                -- �������� ������
                INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
                VALUES (ERROR_MESSAGE(), @MessageBody);
            END CATCH
        END
		ELSE
            BEGIN
                -- �������� ������, ���� ���������� �� ���������
                INSERT INTO Web.ErrorLogs (ErrorMessage, EventData)
                VALUES (
                    CONCAT('����������� ��� ������� ��� ����������: ', @EventType),
                    @MessageBody
                );
            END
        -- ��������� ������
        END CONVERSATION @ConversationHandle;
        COMMIT TRANSACTION;
    END
END;
------------------------------------------------------------------------------
/*--��������� �������--*/

ALTER QUEUE NotificationQueue
WITH STATUS = ON --OFF=������� �� ��������(������ ���� ���������� ��������)
                                          ,RETENTION = OFF --ON=��� ����������� ��������� �������� � ������� �� ��������� �������
										  ,POISON_MESSAGE_HANDLING (STATUS = OFF) --ON=����� 5 ������ ������� ����� ���������
	                                      ,ACTIVATION (STATUS = ON --OFF=������� �� ���������� ���������(� PROCEDURE_NAME)(������ �� ����� ����������� ��(�������� ���������), �� � ������� ���������)  
										              ,PROCEDURE_NAME = Web.proc_ProcessNotificationQueue
													  ,MAX_QUEUE_READERS = 1 --���������� �������(�������� ������������ ���������) ��� ��������� ���������(0-32767)
													                         --(0=���� �� ��������� ���������)(������ �� ����� ����������� ��(�������� ���������), ��� ������ ���������) 
													  ,EXECUTE AS OWNER --������ �� ����� ������� ���������� ��(�������� ���������)
													  ) 