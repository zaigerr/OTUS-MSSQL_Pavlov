-- 2. �������� ����� ���������
-- � ���� ����� ���� ��������� ��� ���� ���������: "//WWI/Report/RequestMessage" � "//WWI/Report/ReplyMessage". 
-- ������ ��� ��������� ����� ��������� � ������� WELL_FORMED_XML.
USE WideWorldImporters
-- ��� �������
CREATE MESSAGE TYPE
[//WWI/Report/RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- ��� ������
CREATE MESSAGE TYPE
[//WWI/Report/ReplyMessage]
VALIDATION=WELL_FORMED_XML; 