USE [WebCentre];
GO
EXEC Web.proc_AddCommentUpdateStatus '03c34660ff5843c5a8c6c93d71bd5e88', 'Тест1', 6, 0

EXEC Web.proc_HistoryProduct '03c34660ff5843c5a8c6c93d71bd5e88'
