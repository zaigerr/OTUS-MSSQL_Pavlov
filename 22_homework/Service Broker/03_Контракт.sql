-- 3. �������� ���������
-- � ���� ����� ���� ��������� �������� "//WWI/Report/Contract", ������� ���������� ���� ���������, ������������ � ����������� � ������ ���������. 
-- �������� ���������, ��� ��� ��������� "//WWI/Report/RequestMessage" ������������ �����������, � ��� ��������� "//WWI/Report/ReplyMessage" ������������ �����.
USE WideWorldImporters
CREATE CONTRACT [//WWI/Report/Contract]
      ([//WWI/Report/RequestMessage] SENT BY INITIATOR,
       [//WWI/Report/ReplyMessage] SENT BY TARGET
      );