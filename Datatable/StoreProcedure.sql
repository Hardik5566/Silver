/*
  Stored procedures: Party, Jobwork party, Jobwork challan, Jobwork invoice, Staff expense, Account outstanding, Account ledger, Unit, Part, User, Inward/Outward, Invoice, Account transaction.
  Run after: Function.sql, Table.sql
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/* ==================== PARTY ==================== */

IF OBJECT_ID('dbo.ins_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_party_sp;
GO
CREATE PROCEDURE dbo.ins_party_sp
    @name NVARCHAR(100),
    @contact_person NVARCHAR(100) = NULL,
    @mobile_no NVARCHAR(15) = NULL,
    @address NVARCHAR(MAX) = NULL,
    @gst_no NVARCHAR(20) = NULL,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_name = @name AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate party name.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_party_master (party_name, contact_person, mobile_no, address, gst_no, status, create_by, create_date)
        VALUES (@name, @contact_person, @mobile_no, @address, @gst_no, 1, @by, dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS ID;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* --------------------- Outward history list (dashboard + report) --------------------- */
IF OBJECT_ID('dbo.dis_outward_history_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_outward_history_sp;
GO
CREATE PROCEDURE dbo.dis_outward_history_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @party_id NVARCHAR(50) = N'0'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @pid BIGINT = CAST(ISNULL(NULLIF(LTRIM(RTRIM(@party_id)), N''), N'0') AS BIGINT);

    SELECT
        oh.outward_history_id,
        oh.outward_date,
        ISNULL(NULLIF(LTRIM(RTRIM(oh.slip_no)), N''), N'—') AS slip_no,
        h.challan_no,
        h.inward_date,
        p.party_name,
        pm.part_name,
        oh.qty_out,
        oh.remarks
    FROM dbo.tbl_outward_history AS oh
    INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id AND d.status = 1
    INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = h.party_id AND p.status = 1
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
    WHERE oh.status = 1
      AND CAST(oh.outward_date AS DATE) BETWEEN @f AND @t
      AND (@pid = 0 OR p.party_id = @pid)
    ORDER BY oh.outward_date DESC, oh.outward_history_id DESC;
END
GO

IF OBJECT_ID('dbo.upd_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_party_sp;
GO
CREATE PROCEDURE dbo.upd_party_sp
    @id BIGINT,
    @name NVARCHAR(100),
    @contact_person NVARCHAR(100) = NULL,
    @mobile_no NVARCHAR(15) = NULL,
    @address NVARCHAR(MAX) = NULL,
    @gst_no NVARCHAR(20) = NULL,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_name = @name AND party_id <> @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate party name.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_party_master
        SET party_name = @name, contact_person = @contact_person, mobile_no = @mobile_no, address = @address, gst_no = @gst_no,
            modify_by = @by, modify_date = dbo.get_date()
        WHERE party_id = @id;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_party_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_party_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_party_by_id_sp
    @id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT party_id, party_name, contact_person, mobile_no, address, gst_no, status, create_date
    FROM dbo.tbl_party_master
    WHERE party_id = @id AND status = 1;
END
GO

IF OBJECT_ID('dbo.dis_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_party_sp;
GO
CREATE PROCEDURE dbo.dis_party_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT party_id, party_name, contact_person, mobile_no, address, gst_no, create_date
    FROM dbo.tbl_party_master
    WHERE status = 1
    ORDER BY party_id DESC;
END
GO

IF OBJECT_ID('dbo.dlt_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_party_sp;
GO
CREATE PROCEDURE dbo.dlt_party_sp
    @id BIGINT,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_party_master
        SET status = 0, delete_by = @by, delete_date = dbo.get_date()
        WHERE party_id = @id;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== JOBWORK PARTY ==================== */

IF OBJECT_ID('dbo.ins_jobwork_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_jobwork_party_sp;
GO
CREATE PROCEDURE dbo.ins_jobwork_party_sp
    @name NVARCHAR(100),
    @contact_person NVARCHAR(100) = NULL,
    @mobile_no NVARCHAR(15) = NULL,
    @address NVARCHAR(MAX) = NULL,
    @gst_no NVARCHAR(20) = NULL,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE party_name = @name AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate jobwork party name.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_jobwork_party (party_name, contact_person, mobile_no, address, gst_no, status, create_by, create_date)
        VALUES (@name, @contact_person, @mobile_no, @address, @gst_no, 1, @by, dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS ID;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_jobwork_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_jobwork_party_sp;
GO
CREATE PROCEDURE dbo.upd_jobwork_party_sp
    @id BIGINT,
    @name NVARCHAR(100),
    @contact_person NVARCHAR(100) = NULL,
    @mobile_no NVARCHAR(15) = NULL,
    @address NVARCHAR(MAX) = NULL,
    @gst_no NVARCHAR(20) = NULL,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE party_name = @name AND jobwork_party_id <> @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate jobwork party name.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_jobwork_party
        SET party_name = @name, contact_person = @contact_person, mobile_no = @mobile_no, address = @address, gst_no = @gst_no,
            modify_by = @by, modify_date = dbo.get_date()
        WHERE jobwork_party_id = @id AND status = 1;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_jobwork_party_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_jobwork_party_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_jobwork_party_by_id_sp
    @id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT jobwork_party_id, party_name, contact_person, mobile_no, address, gst_no, status, create_date
    FROM dbo.tbl_jobwork_party
    WHERE jobwork_party_id = @id AND status = 1;
END
GO

IF OBJECT_ID('dbo.dis_jobwork_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_party_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_party_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT jobwork_party_id, party_name, contact_person, mobile_no, address, gst_no, create_date
    FROM dbo.tbl_jobwork_party
    WHERE status = 1
    ORDER BY jobwork_party_id DESC;
END
GO

IF OBJECT_ID('dbo.dlt_jobwork_party_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_jobwork_party_sp;
GO
CREATE PROCEDURE dbo.dlt_jobwork_party_sp
    @id BIGINT,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_jobwork_party
        SET status = 0, delete_by = @by, delete_date = dbo.get_date()
        WHERE jobwork_party_id = @id;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== JOBWORK PART (separate from tbl_part_master) ==================== */

IF OBJECT_ID('dbo.ins_jobwork_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_jobwork_part_sp;
GO
CREATE PROCEDURE dbo.ins_jobwork_part_sp
    @jobwork_party_id NVARCHAR(50),
    @part_name NVARCHAR(250),
    @unit_id NVARCHAR(50),
    @rate NVARCHAR(50),
    @tax_per NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jwp BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @jwp AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork party not found or inactive.' AS Message;
            RETURN;
        END
        IF EXISTS (
            SELECT 1 FROM dbo.tbl_jobwork_part_master
            WHERE jobwork_party_id = @jwp AND part_name = @part_name AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate part name for this jobwork party.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_jobwork_part_master (jobwork_party_id, part_name, unit_id, rate, tax_per, status, create_by, create_date)
        VALUES (
            @jwp, @part_name,
            NULLIF(CAST(NULLIF(LTRIM(RTRIM(@unit_id)), N'') AS BIGINT), 0),
            CAST(@rate AS DECIMAL(18, 2)), CAST(@tax_per AS DECIMAL(18, 2)),
            1, @uid, dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS jobwork_part_id;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_jobwork_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_jobwork_part_sp;
GO
CREATE PROCEDURE dbo.upd_jobwork_part_sp
    @jobwork_part_id NVARCHAR(50),
    @jobwork_party_id NVARCHAR(50),
    @part_name NVARCHAR(250),
    @unit_id NVARCHAR(50),
    @rate NVARCHAR(50),
    @tax_per NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jid BIGINT = CAST(@jobwork_part_id AS BIGINT);
        DECLARE @jwp BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        IF EXISTS (
            SELECT 1 FROM dbo.tbl_jobwork_part_master
            WHERE jobwork_party_id = @jwp AND part_name = @part_name AND jobwork_part_id <> @jid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate part name for this jobwork party.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_jobwork_part_master
        SET jobwork_party_id = @jwp, part_name = @part_name,
            unit_id = NULLIF(CAST(NULLIF(LTRIM(RTRIM(@unit_id)), N'') AS BIGINT), 0),
            rate = CAST(@rate AS DECIMAL(18, 2)), tax_per = CAST(@tax_per AS DECIMAL(18, 2)),
            modify_by = @uid, modify_date = dbo.get_date()
        WHERE jobwork_part_id = @jid AND status = 1;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_jobwork_part_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_jobwork_part_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_jobwork_part_by_id_sp
    @id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT jobwork_part_id, jobwork_party_id, part_name, unit_id, rate, tax_per
    FROM dbo.tbl_jobwork_part_master
    WHERE jobwork_part_id = CAST(@id AS BIGINT) AND status = 1;
END
GO

IF OBJECT_ID('dbo.dis_jobwork_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_part_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_part_sp
    @jobwork_party_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @jw BIGINT = CAST(@jobwork_party_id AS BIGINT);
    SELECT
        j.jobwork_part_id,
        jp.party_name AS jobwork_party_name,
        j.part_name,
        u.unit_name,
        j.rate,
        j.tax_per,
        j.jobwork_party_id,
        j.unit_id
    FROM dbo.tbl_jobwork_part_master j
    INNER JOIN dbo.tbl_jobwork_party jp ON jp.jobwork_party_id = j.jobwork_party_id
    LEFT JOIN dbo.tbl_unit u ON u.unit_id = j.unit_id AND u.status = 1
    WHERE (@jw = 0 OR j.jobwork_party_id = @jw) AND j.status = 1
    ORDER BY jp.party_name, j.part_name;
END
GO

IF OBJECT_ID('dbo.dlt_jobwork_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_jobwork_part_sp;
GO
CREATE PROCEDURE dbo.dlt_jobwork_part_sp
    @id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jid BIGINT = CAST(@id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        UPDATE dbo.tbl_jobwork_part_master
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE jobwork_part_id = @jid AND status = 1;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== JOBWORK CHALLAN (send + multipart lines; challan_no auto JWC-{id}) ==================== */

IF OBJECT_ID('dbo.dis_active_jobwork_challan_list_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_active_jobwork_challan_list_sp;
GO
CREATE PROCEDURE dbo.dis_active_jobwork_challan_list_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ROW_NUMBER() OVER (ORDER BY h.challan_date DESC, h.jobwork_challan_id DESC) AS sr,
        h.jobwork_challan_id,
        h.challan_date,
        h.challan_no,
        jp.party_name AS jobwork_party_name,
        ISNULL(x.item_list, N'') AS item_list,
        ISNULL(x.items_returned, N'') AS items_returned,
        ISNULL(x.items_pending, N'') AS items_pending,
        ISNULL(x.total_qty_sent, 0) AS total_qty_sent,
        ISNULL(x.total_qty_returned, 0) AS total_qty_returned,
        ISNULL(x.total_qty_pending, 0) AS total_qty_pending
    FROM dbo.tbl_jobwork_challan AS h
    INNER JOIN dbo.tbl_jobwork_party AS jp ON jp.jobwork_party_id = h.jobwork_party_id AND jp.status = 1
    LEFT JOIN (
        SELECT
            d.jobwork_challan_id,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × ' + CAST(d2.qty_sent AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND d2.status = 1
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS item_list,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × ' + CAST(d2.qty_perfect_done + d2.qty_reject_done AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND d2.status = 1
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS items_returned,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × '
                    + CAST(d2.qty_sent - d2.qty_perfect_done - d2.qty_reject_done AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND d2.status = 1
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS items_pending,
            SUM(d.qty_sent) AS total_qty_sent,
            SUM(d.qty_perfect_done + d.qty_reject_done) AS total_qty_returned,
            SUM(d.qty_sent - d.qty_perfect_done - d.qty_reject_done) AS total_qty_pending
        FROM dbo.tbl_jobwork_challan_detail AS d
        INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id AND jwm.status = 1
        WHERE d.status = 1
        GROUP BY d.jobwork_challan_id
    ) AS x ON x.jobwork_challan_id = h.jobwork_challan_id
    WHERE h.status = 1
      AND ISNULL(x.total_qty_pending, 0) > 0
    ORDER BY h.challan_date DESC, h.jobwork_challan_id DESC;
END
GO

IF OBJECT_ID('dbo.get_jobwork_challan_for_edit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.get_jobwork_challan_for_edit_sp;
GO
CREATE PROCEDURE dbo.get_jobwork_challan_for_edit_sp
    @jobwork_challan_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@jobwork_challan_id AS BIGINT);

    SELECT h.jobwork_challan_id, h.jobwork_party_id, h.challan_no, h.challan_date, h.remarks
    FROM dbo.tbl_jobwork_challan AS h
    WHERE h.jobwork_challan_id = @id AND h.status = 1;

    SELECT
        d.jobwork_detail_id,
        d.jobwork_part_id,
        jwm.part_name,
        u.unit_name,
        d.qty_sent,
        d.qty_perfect_done,
        d.qty_reject_done,
        d.qty_sent - d.qty_perfect_done - d.qty_reject_done AS qty_pending,
        d.rate_at_time,
        jwm.tax_per
    FROM dbo.tbl_jobwork_challan_detail AS d
    INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id
    LEFT JOIN dbo.tbl_unit AS u ON u.unit_id = jwm.unit_id AND u.status = 1
    WHERE d.jobwork_challan_id = @id AND d.status = 1
    ORDER BY d.jobwork_detail_id;
END
GO

IF OBJECT_ID('dbo.sel_jobwork_lines_for_return_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_jobwork_lines_for_return_sp;
GO
CREATE PROCEDURE dbo.sel_jobwork_lines_for_return_sp
    @jobwork_challan_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@jobwork_challan_id AS BIGINT);

    SELECT
        d.jobwork_detail_id,
        d.jobwork_part_id,
        jwm.part_name,
        d.qty_sent,
        d.qty_perfect_done,
        d.qty_reject_done,
        d.qty_sent - d.qty_perfect_done - d.qty_reject_done AS qty_pending
    FROM dbo.tbl_jobwork_challan_detail AS d
    INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id
    WHERE d.jobwork_challan_id = @id AND d.status = 1
      AND d.qty_sent > d.qty_perfect_done + d.qty_reject_done
    ORDER BY d.jobwork_detail_id;
END
GO

IF OBJECT_ID('dbo.ins_jobwork_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_jobwork_challan_sp;
GO
CREATE PROCEDURE dbo.ins_jobwork_challan_sp
    @jobwork_party_id NVARCHAR(50),
    @challan_date NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50),
    @part_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX),
    @rates NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jwp BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @d DATE = CAST(@challan_date AS DATE);
        DECLARE @tmpNo NVARCHAR(50) = N'~' + REPLACE(CONVERT(NVARCHAR(36), NEWID()), N'-', N'');
        DECLARE @hid BIGINT;
        DECLARE @finalNo NVARCHAR(50);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @jwp AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork party not found or inactive.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO dbo.tbl_jobwork_challan (jobwork_party_id, challan_no, challan_date, remarks, status, create_by, create_date)
        VALUES (@jwp, @tmpNo, @d, @remarks, 1, @uid, dbo.get_date());

        SET @hid = SCOPE_IDENTITY();
        SET @finalNo = N'JWC-' + CAST(@hid AS VARCHAR(20));

        UPDATE dbo.tbl_jobwork_challan
        SET challan_no = @finalNo
        WHERE jobwork_challan_id = @hid;

        DECLARE @p NVARCHAR(MAX) = @part_ids;
        DECLARE @q NVARCHAR(MAX) = @qtys;
        DECLARE @r NVARCHAR(MAX) = ISNULL(@rates, N'');
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50), @segR NVARCHAR(50);
        DECLARE @jwPartId BIGINT, @qty INT, @rate DECIMAL(18, 2);

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @segR = CASE WHEN LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0
                THEN LEFT(@r, CHARINDEX(N',', @r) - 1) ELSE N'0' END;

            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);
            IF LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0 SET @r = SUBSTRING(@r, CHARINDEX(N',', @r) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @jwPartId = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);
            SET @rate = CAST(@segR AS DECIMAL(18, 2));

            IF @qty <= 0 CONTINUE;

            IF NOT EXISTS (
                SELECT 1 FROM dbo.tbl_jobwork_part_master
                WHERE jobwork_part_id = @jwPartId AND jobwork_party_id = @jwp AND status = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Part does not belong to this jobwork party or inactive.' AS Message;
                RETURN;
            END

            INSERT INTO dbo.tbl_jobwork_challan_detail (
                jobwork_challan_id, jobwork_part_id, qty_sent, qty_perfect_done, qty_reject_done, rate_at_time,
                status, create_by, create_date)
            VALUES (@hid, @jwPartId, @qty, 0, 0, @rate, 1, @uid, dbo.get_date());
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_challan_detail WHERE jobwork_challan_id = @hid AND status = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'Add at least one line with quantity.' AS Message;
            RETURN;
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Saved.' AS Message, @hid AS jobwork_challan_id, @finalNo AS challan_no;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_jobwork_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_jobwork_challan_sp;
GO
CREATE PROCEDURE dbo.upd_jobwork_challan_sp
    @jobwork_challan_id NVARCHAR(50),
    @jobwork_party_id NVARCHAR(50),
    @challan_date NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50),
    @part_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX),
    @rates NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id BIGINT = CAST(@jobwork_challan_id AS BIGINT);
        DECLARE @jwp BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @d DATE = CAST(@challan_date AS DATE);
        DECLARE @p NVARCHAR(MAX), @q NVARCHAR(MAX), @r NVARCHAR(MAX);
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50), @segR NVARCHAR(50);
        DECLARE @jwPartId BIGINT, @qty INT, @rate DECIMAL(18, 2);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_challan WHERE jobwork_challan_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork challan not found.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @jwp AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork party not found or inactive.' AS Message;
            RETURN;
        END

        DECLARE @has_ret BIT = CASE WHEN EXISTS (
            SELECT 1 FROM dbo.tbl_jobwork_return_history AS rh
            INNER JOIN dbo.tbl_jobwork_challan_detail AS d ON d.jobwork_detail_id = rh.jobwork_detail_id
            WHERE d.jobwork_challan_id = @id AND rh.status = 1) THEN 1 ELSE 0 END;

        IF @has_ret = 1
        BEGIN
            UPDATE dbo.tbl_jobwork_challan
            SET challan_date = @d, remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
            WHERE jobwork_challan_id = @id;
            SELECT 'True' AS Success, N'Updated header only (returns exist — lines locked).' AS Message, @id AS jobwork_challan_id;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_jobwork_challan
        SET jobwork_party_id = @jwp, challan_date = @d, remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
        WHERE jobwork_challan_id = @id;

        DELETE FROM dbo.tbl_jobwork_challan_detail WHERE jobwork_challan_id = @id;

        SET @p = @part_ids;
        SET @q = @qtys;
        SET @r = ISNULL(@rates, N'');

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @segR = CASE WHEN LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0
                THEN LEFT(@r, CHARINDEX(N',', @r) - 1) ELSE N'0' END;

            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);
            IF LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0 SET @r = SUBSTRING(@r, CHARINDEX(N',', @r) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @jwPartId = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);
            SET @rate = CAST(@segR AS DECIMAL(18, 2));

            IF @qty <= 0 CONTINUE;

            IF NOT EXISTS (
                SELECT 1 FROM dbo.tbl_jobwork_part_master
                WHERE jobwork_part_id = @jwPartId AND jobwork_party_id = @jwp AND status = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Part does not belong to this jobwork party or inactive.' AS Message;
                RETURN;
            END

            INSERT INTO dbo.tbl_jobwork_challan_detail (
                jobwork_challan_id, jobwork_part_id, qty_sent, qty_perfect_done, qty_reject_done, rate_at_time,
                status, create_by, create_date)
            VALUES (@id, @jwPartId, @qty, 0, 0, @rate, 1, @uid, dbo.get_date());
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_challan_detail WHERE jobwork_challan_id = @id AND status = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'Add at least one line with quantity.' AS Message;
            RETURN;
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Updated.' AS Message, @id AS jobwork_challan_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_jobwork_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_jobwork_challan_sp;
GO
CREATE PROCEDURE dbo.dlt_jobwork_challan_sp
    @jobwork_challan_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id BIGINT = CAST(@jobwork_challan_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF EXISTS (
            SELECT 1 FROM dbo.tbl_jobwork_return_history AS rh
            INNER JOIN dbo.tbl_jobwork_challan_detail AS d ON d.jobwork_detail_id = rh.jobwork_detail_id
            WHERE d.jobwork_challan_id = @id AND rh.status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Cannot delete — return history exists. Reverse returns first.' AS Message;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM dbo.tbl_jobwork_challan_detail
            WHERE jobwork_challan_id = @id AND status = 1 AND (qty_perfect_done > 0 OR qty_reject_done > 0))
        BEGIN
            SELECT 'False' AS Success, N'Cannot delete — quantity already returned on lines.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_jobwork_challan_detail
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE jobwork_challan_id = @id;

        UPDATE dbo.tbl_jobwork_challan
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE jobwork_challan_id = @id;

        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.ins_jobwork_return_line_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_jobwork_return_line_sp;
GO
CREATE PROCEDURE dbo.ins_jobwork_return_line_sp
    @jobwork_detail_id NVARCHAR(50),
    @qty_perfect NVARCHAR(50),
    @qty_reject NVARCHAR(50),
    @slip_no NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @did BIGINT = CAST(@jobwork_detail_id AS BIGINT);
        DECLARE @qp INT = CAST(ISNULL(@qty_perfect, N'0') AS INT);
        DECLARE @qr INT = CAST(ISNULL(@qty_reject, N'0') AS INT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF @qp < 0 OR @qr < 0 OR (@qp + @qr) <= 0
        BEGIN
            SELECT 'False' AS Success, N'Enter positive perfect and/or reject qty.' AS Message;
            RETURN;
        END

        DECLARE @pend INT;
        SELECT @pend = d.qty_sent - d.qty_perfect_done - d.qty_reject_done
        FROM dbo.tbl_jobwork_challan_detail AS d
        INNER JOIN dbo.tbl_jobwork_challan AS h ON h.jobwork_challan_id = d.jobwork_challan_id
        WHERE d.jobwork_detail_id = @did AND d.status = 1 AND h.status = 1;

        IF @pend IS NULL
        BEGIN
            SELECT 'False' AS Success, N'Line not found.' AS Message;
            RETURN;
        END

        IF (@qp + @qr) > @pend
        BEGIN
            SELECT 'False' AS Success, N'Qty exceeds pending balance.' AS Message;
            RETURN;
        END

        INSERT INTO dbo.tbl_jobwork_return_history (jobwork_detail_id, qty_perfect, qty_reject, slip_no, remarks, status, create_by, create_date)
        VALUES (@did, @qp, @qr, NULLIF(LTRIM(RTRIM(@slip_no)), N''), @remarks, 1, @uid, dbo.get_date());

        UPDATE dbo.tbl_jobwork_challan_detail
        SET qty_perfect_done = qty_perfect_done + @qp, qty_reject_done = qty_reject_done + @qr, modify_by = @uid, modify_date = dbo.get_date()
        WHERE jobwork_detail_id = @did;

        SELECT 'True' AS Success, N'Receive saved.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_jobwork_return_history_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_jobwork_return_history_sp;
GO
CREATE PROCEDURE dbo.dlt_jobwork_return_history_sp
    @jobwork_return_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @hid BIGINT = CAST(@jobwork_return_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        DECLARE @did BIGINT;
        DECLARE @qp INT;
        DECLARE @qr INT;
        SELECT @did = jobwork_detail_id, @qp = qty_perfect, @qr = qty_reject
        FROM dbo.tbl_jobwork_return_history
        WHERE jobwork_return_id = @hid AND status = 1;

        IF @did IS NULL
        BEGIN
            SELECT 'False' AS Success, N'Already removed.' AS Message;
            RETURN;
        END

        DECLARE @curP INT;
        DECLARE @curR INT;
        SELECT @curP = qty_perfect_done, @curR = qty_reject_done
        FROM dbo.tbl_jobwork_challan_detail
        WHERE jobwork_detail_id = @did AND status = 1;

        IF @curP IS NULL
        BEGIN
            SELECT 'False' AS Success, N'Challan line not found.' AS Message;
            RETURN;
        END

        IF @curP < @qp OR @curR < @qr
        BEGIN
            SELECT 'False' AS Success, N'Cannot reverse — returned qty on line is lower than this history row.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_jobwork_return_history
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE jobwork_return_id = @hid AND status = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'Already removed.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_jobwork_challan_detail
        SET qty_perfect_done = qty_perfect_done - @qp, qty_reject_done = qty_reject_done - @qr, modify_by = @uid, modify_date = dbo.get_date()
        WHERE jobwork_detail_id = @did AND status = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'Challan line not updated.' AS Message;
            RETURN;
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Reversed.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dis_jobwork_return_history_by_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_return_history_by_challan_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_return_history_by_challan_sp
    @jobwork_challan_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@jobwork_challan_id AS BIGINT);

    SELECT
        rh.jobwork_return_id,
        rh.return_date,
        rh.slip_no,
        jwm.part_name,
        rh.qty_perfect,
        rh.qty_reject,
        rh.remarks
    FROM dbo.tbl_jobwork_return_history AS rh
    INNER JOIN dbo.tbl_jobwork_challan_detail AS d ON d.jobwork_detail_id = rh.jobwork_detail_id
    INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id
    WHERE d.jobwork_challan_id = @id AND rh.status = 1
    ORDER BY rh.return_date DESC, rh.jobwork_return_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_jobwork_challan_report_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_challan_report_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_challan_report_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @jobwork_party_id NVARCHAR(50) = N'0',
    @include_deleted INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @jw BIGINT = CAST(@jobwork_party_id AS BIGINT);

    SELECT
        ROW_NUMBER() OVER (ORDER BY h.challan_date DESC, h.jobwork_challan_id DESC) AS sr,
        h.jobwork_challan_id,
        h.challan_date,
        h.challan_no,
        jp.party_name AS jobwork_party_name,
        CASE
            WHEN h.status <> 1 THEN N'Closed'
            WHEN ISNULL(x.total_qty_pending, 0) <= 0 THEN N'Closed'
            ELSE N'Active'
        END AS challan_status,
        ISNULL(x.item_list, N'') AS item_list,
        ISNULL(x.items_returned, N'') AS items_returned,
        ISNULL(x.items_pending, N'') AS items_pending,
        ISNULL(x.total_qty_sent, 0) AS total_qty_sent,
        ISNULL(x.total_qty_returned, 0) AS total_qty_returned,
        ISNULL(x.total_qty_pending, 0) AS total_qty_pending
    FROM dbo.tbl_jobwork_challan AS h
    INNER JOIN dbo.tbl_jobwork_party AS jp ON jp.jobwork_party_id = h.jobwork_party_id AND jp.status = 1
    LEFT JOIN (
        SELECT
            d.jobwork_challan_id,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × ' + CAST(d2.qty_sent AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND (@include_deleted = 1 OR d2.status = 1)
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS item_list,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × ' + CAST(d2.qty_perfect_done + d2.qty_reject_done AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND (@include_deleted = 1 OR d2.status = 1)
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS items_returned,
            STUFF((
                SELECT N' | ' + CAST(jwm2.part_name AS NVARCHAR(200)) + N' × '
                    + CAST(d2.qty_sent - d2.qty_perfect_done - d2.qty_reject_done AS VARCHAR(20))
                FROM dbo.tbl_jobwork_challan_detail AS d2
                INNER JOIN dbo.tbl_jobwork_part_master AS jwm2 ON jwm2.jobwork_part_id = d2.jobwork_part_id AND jwm2.status = 1
                WHERE d2.jobwork_challan_id = d.jobwork_challan_id AND (@include_deleted = 1 OR d2.status = 1)
                ORDER BY d2.jobwork_detail_id
                FOR XML PATH(N''), TYPE
            ).value(N'.[1]', N'NVARCHAR(MAX)'), 1, 3, N'') AS items_pending,
            SUM(d.qty_sent) AS total_qty_sent,
            SUM(d.qty_perfect_done + d.qty_reject_done) AS total_qty_returned,
            SUM(d.qty_sent - d.qty_perfect_done - d.qty_reject_done) AS total_qty_pending
        FROM dbo.tbl_jobwork_challan_detail AS d
        INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id AND jwm.status = 1
        WHERE (@include_deleted = 1 OR d.status = 1)
        GROUP BY d.jobwork_challan_id
    ) AS x ON x.jobwork_challan_id = h.jobwork_challan_id
    WHERE CAST(h.challan_date AS DATE) BETWEEN @f AND @t
      AND (@jw = 0 OR h.jobwork_party_id = @jw)
      AND (@include_deleted = 1 OR h.status = 1)
    ORDER BY h.challan_date DESC, h.jobwork_challan_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_jobwork_receive_history_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_receive_history_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_receive_history_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @jobwork_party_id NVARCHAR(50) = N'0'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @jw BIGINT = CAST(ISNULL(NULLIF(LTRIM(RTRIM(@jobwork_party_id)), N''), N'0') AS BIGINT);

    SELECT
        rh.jobwork_return_id,
        rh.return_date,
        ISNULL(NULLIF(LTRIM(RTRIM(rh.slip_no)), N''), N'—') AS slip_no,
        h.challan_no,
        h.challan_date,
        jp.party_name AS jobwork_party_name,
        jwm.part_name,
        rh.qty_perfect,
        rh.qty_reject,
        rh.remarks
    FROM dbo.tbl_jobwork_return_history AS rh
    INNER JOIN dbo.tbl_jobwork_challan_detail AS d ON d.jobwork_detail_id = rh.jobwork_detail_id AND d.status = 1
    INNER JOIN dbo.tbl_jobwork_challan AS h ON h.jobwork_challan_id = d.jobwork_challan_id AND h.status = 1
    INNER JOIN dbo.tbl_jobwork_party AS jp ON jp.jobwork_party_id = h.jobwork_party_id AND jp.status = 1
    INNER JOIN dbo.tbl_jobwork_part_master AS jwm ON jwm.jobwork_part_id = d.jobwork_part_id AND jwm.status = 1
    WHERE rh.status = 1
      AND CAST(rh.return_date AS DATE) BETWEEN @f AND @t
      AND (@jw = 0 OR h.jobwork_party_id = @jw)
    ORDER BY rh.return_date DESC, rh.jobwork_return_id DESC;
END
GO

IF OBJECT_ID('dbo.sel_unit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_unit_sp;
GO
CREATE PROCEDURE dbo.sel_unit_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT unit_id, unit_name, create_date
    FROM dbo.tbl_unit
    WHERE status = 1
    ORDER BY unit_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_unit', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_unit;
GO
CREATE PROCEDURE dbo.dis_unit
AS
BEGIN
    SET NOCOUNT ON;
    SELECT unit_id, unit_name
    FROM dbo.tbl_unit
    WHERE status = 1;
END
GO

IF OBJECT_ID('dbo.ins_unit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_unit_sp;
GO
CREATE PROCEDURE dbo.ins_unit_sp
    @unit_name NVARCHAR(250),
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @unit_name IS NULL OR LTRIM(RTRIM(@unit_name)) = N''
        BEGIN
            SELECT 'False' AS Success, N'Unit name required.' AS Message;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM dbo.tbl_unit WHERE unit_name = @unit_name AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate unit name.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_unit (unit_name, status, create_by, create_date)
        VALUES (@unit_name, 1, @by, dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS ID;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_unit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_unit_sp;
GO
CREATE PROCEDURE dbo.upd_unit_sp
    @unit_id BIGINT,
    @unit_name NVARCHAR(250),
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @unit_name IS NULL OR LTRIM(RTRIM(@unit_name)) = N''
        BEGIN
            SELECT 'False' AS Success, N'Unit name required.' AS Message;
            RETURN;
        END
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_unit WHERE unit_id = @unit_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM dbo.tbl_unit WHERE unit_name = @unit_name AND unit_id <> @unit_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate unit name.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_unit
        SET unit_name = @unit_name, modify_by = @by, modify_date = dbo.get_date()
        WHERE unit_id = @unit_id;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_unit_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_unit_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_unit_by_id_sp
    @id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT unit_id, unit_name
    FROM dbo.tbl_unit
    WHERE unit_id = @id AND status = 1;
END
GO

IF OBJECT_ID('dbo.dlt_unit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_unit_sp;
GO
CREATE PROCEDURE dbo.dlt_unit_sp
    @id BIGINT,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_unit WHERE unit_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM dbo.tbl_part_master WHERE unit_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Unit is used on parts.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_unit
        SET status = 0, delete_by = @by, delete_date = dbo.get_date()
        WHERE unit_id = @id;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== PART ==================== */

IF OBJECT_ID('dbo.ins_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_part_sp;
GO
CREATE PROCEDURE dbo.ins_part_sp
    @party_id NVARCHAR(50),
    @part_name NVARCHAR(250),
    @unit_id NVARCHAR(50),
    @rate NVARCHAR(50),
    @tax_per NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (
            SELECT 1 FROM dbo.tbl_part_master
            WHERE party_id = CAST(@party_id AS INT) AND part_name = @part_name AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate part for this party.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_part_master (party_id, part_name, unit_id, rate, tax_per, status, create_by, create_date)
        VALUES (
            CAST(@party_id AS INT), @part_name, CAST(@unit_id AS INT),
            CAST(@rate AS DECIMAL(18, 2)), CAST(@tax_per AS DECIMAL(18, 2)),
            1, CAST(@by AS INT), dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS ID;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_part_sp;
GO
CREATE PROCEDURE dbo.upd_part_sp
    @part_id NVARCHAR(50),
    @party_id NVARCHAR(50),
    @part_name NVARCHAR(250),
    @unit_id NVARCHAR(50),
    @rate NVARCHAR(50),
    @tax_per NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF EXISTS (
            SELECT 1 FROM dbo.tbl_part_master
            WHERE part_name = @part_name AND party_id = CAST(@party_id AS INT)
              AND part_id <> CAST(@part_id AS BIGINT) AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Duplicate part for this party.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_part_master
        SET party_id = CAST(@party_id AS INT), part_name = @part_name, unit_id = CAST(@unit_id AS INT),
            rate = CAST(@rate AS DECIMAL(18, 2)), tax_per = CAST(@tax_per AS DECIMAL(18, 2)),
            modify_by = CAST(@by AS INT), modify_date = dbo.get_date()
        WHERE part_id = CAST(@part_id AS BIGINT);
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dis_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_part_sp;
GO
CREATE PROCEDURE dbo.dis_part_sp
    @party_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @p_id INT = CAST(@party_id AS INT);
    SELECT
        p.part_id,
        pm.party_name,
        p.part_name,
        u.unit_name,
        p.rate,
        p.tax_per,
        p.party_id,
        p.unit_id
    FROM dbo.tbl_part_master p
    INNER JOIN dbo.tbl_party_master pm ON p.party_id = pm.party_id
    INNER JOIN dbo.tbl_unit u ON p.unit_id = u.unit_id
    WHERE (@p_id = 0 OR p.party_id = @p_id) AND p.status = 1
    ORDER BY pm.party_name, p.part_name;
END
GO

IF OBJECT_ID('dbo.sel_part_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_part_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_part_by_id_sp
    @id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT part_id, party_id, part_name, unit_id, rate, tax_per
    FROM dbo.tbl_part_master
    WHERE part_id = CAST(@id AS BIGINT);
END
GO

IF OBJECT_ID('dbo.dlt_part_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_part_sp;
GO
CREATE PROCEDURE dbo.dlt_part_sp
    @id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.tbl_part_master
    SET status = 0, delete_by = CAST(@by AS INT), delete_date = dbo.get_date()
    WHERE part_id = CAST(@id AS BIGINT);
    SELECT 'True' AS Success, N'Deleted.' AS Message;
END
GO

/* ==================== USER ==================== */

IF OBJECT_ID('dbo.ins_user_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_user_sp;
GO
CREATE PROCEDURE dbo.ins_user_sp
    @full_name NVARCHAR(150),
    @mobile_no NVARCHAR(15),
    @email NVARCHAR(150) = NULL,
    @password NVARCHAR(200),
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @mobile_no = LTRIM(RTRIM(@mobile_no));
        SET @email = NULLIF(LTRIM(RTRIM(@email)), N'');
        IF @full_name IS NULL OR LTRIM(RTRIM(@full_name)) = N''
        BEGIN
            SELECT 'False' AS Success, N'Name required.' AS Message;
            RETURN;
        END
        IF @mobile_no = N''
        BEGIN
            SELECT 'False' AS Success, N'Mobile required.' AS Message;
            RETURN;
        END
        IF @password IS NULL OR LTRIM(RTRIM(@password)) = N''
        BEGIN
            SELECT 'False' AS Success, N'Password required.' AS Message;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE mobile_no = @mobile_no AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Mobile already registered.' AS Message;
            RETURN;
        END
        IF @email IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE email = @email AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Email already registered.' AS Message;
            RETURN;
        END
        INSERT INTO dbo.tbl_user_master (full_name, mobile_no, email, password_hash, status, create_by, create_date)
        VALUES (@full_name, @mobile_no, @email, HASHBYTES('SHA2_256', CAST(@password AS NVARCHAR(200))), 1, @by, dbo.get_date());
        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS user_id;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_user_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_user_sp;
GO
CREATE PROCEDURE dbo.upd_user_sp
    @user_id BIGINT,
    @full_name NVARCHAR(150),
    @mobile_no NVARCHAR(15),
    @email NVARCHAR(150) = NULL,
    @password NVARCHAR(200) = NULL,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SET @mobile_no = LTRIM(RTRIM(@mobile_no));
        SET @email = NULLIF(LTRIM(RTRIM(@email)), N'');
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @user_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        IF EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE mobile_no = @mobile_no AND user_id <> @user_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Mobile in use.' AS Message;
            RETURN;
        END
        IF @email IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE email = @email AND user_id <> @user_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Email in use.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_user_master
        SET full_name = @full_name,
            mobile_no = @mobile_no,
            email = @email,
            password_hash = CASE
                WHEN @password IS NOT NULL AND LTRIM(RTRIM(@password)) <> N''
                THEN HASHBYTES('SHA2_256', CAST(@password AS NVARCHAR(200)))
                ELSE password_hash
            END,
            modify_by = @by,
            modify_date = dbo.get_date()
        WHERE user_id = @user_id AND status = 1;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_user_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_user_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_user_by_id_sp
    @user_id BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT user_id, full_name, mobile_no, email, status, create_date
    FROM dbo.tbl_user_master
    WHERE user_id = @user_id AND status = 1;
END
GO

IF OBJECT_ID('dbo.dis_user_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_user_sp;
GO
CREATE PROCEDURE dbo.dis_user_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT user_id, full_name, mobile_no, email, create_date
    FROM dbo.tbl_user_master
    WHERE status = 1
    ORDER BY user_id DESC;
END
GO

/* --------------------- Dashboard counts --------------------- */
IF OBJECT_ID('dbo.sel_dashboard_counts_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_dashboard_counts_sp;
GO
CREATE PROCEDURE dbo.sel_dashboard_counts_sp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today DATE = CAST(dbo.get_date() AS DATE);
    DECLARE @monthStart DATE = DATEFROMPARTS(YEAR(@today), MONTH(@today), 1);
    DECLARE @monthEnd DATE = DATEADD(DAY, 1, EOMONTH(@today));

    SELECT
        /* Masters */
        (SELECT COUNT(1) FROM dbo.tbl_party_master WHERE status = 1) AS total_party,
        (SELECT COUNT(1) FROM dbo.tbl_part_master WHERE status = 1) AS total_part,
        (SELECT COUNT(1) FROM dbo.tbl_jobwork_party WHERE status = 1) AS total_jobwork_party,
        (SELECT COUNT(1) FROM dbo.tbl_jobwork_part_master WHERE status = 1) AS total_jobwork_part,

        /* Inward — active (stock still to dispatch) */
        (SELECT COUNT(DISTINCT h.inward_id)
            FROM dbo.tbl_inward_challan h
            INNER JOIN dbo.tbl_inward_challan_details d ON d.inward_id = h.inward_id
            WHERE h.status = 1 AND d.status = 1 AND (d.qty_inward - d.qty_out_done) > 0) AS total_active_challan,
        (SELECT ISNULL(SUM(CAST(d.qty_inward - d.qty_out_done AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1 AND (d.qty_inward - d.qty_out_done) > 0) AS total_active_item_qty,

        /* Inward — received */
        (SELECT COUNT(1)
            FROM dbo.tbl_inward_challan
            WHERE status = 1 AND CAST(inward_date AS DATE) = @today) AS today_challan_received,
        (SELECT ISNULL(SUM(CAST(d.qty_inward AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1 AND CAST(h.inward_date AS DATE) = @today) AS today_item_received,
        (SELECT COUNT(1)
            FROM dbo.tbl_inward_challan
            WHERE status = 1 AND inward_date >= @monthStart AND inward_date < @monthEnd) AS month_challan_received,
        (SELECT ISNULL(SUM(CAST(d.qty_inward AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1 AND h.inward_date >= @monthStart AND h.inward_date < @monthEnd) AS month_item_received,

        /* Outward — dispatched */
        (SELECT COUNT(DISTINCT CASE
                    WHEN LTRIM(RTRIM(ISNULL(oh.slip_no, N''))) <> N'' THEN LTRIM(RTRIM(oh.slip_no))
                    ELSE N'ROW-' + CAST(oh.outward_history_id AS NVARCHAR(50))
                END)
            FROM dbo.tbl_outward_history oh
            WHERE oh.status = 1 AND CAST(oh.outward_date AS DATE) = @today) AS today_outward_challan,
        (SELECT ISNULL(SUM(CAST(oh.qty_out AS BIGINT)), 0)
            FROM dbo.tbl_outward_history oh
            WHERE oh.status = 1 AND CAST(oh.outward_date AS DATE) = @today) AS today_outward_item,
        (SELECT COUNT(DISTINCT CASE
                    WHEN LTRIM(RTRIM(ISNULL(oh.slip_no, N''))) <> N'' THEN LTRIM(RTRIM(oh.slip_no))
                    ELSE N'ROW-' + CAST(oh.outward_history_id AS NVARCHAR(50))
                END)
            FROM dbo.tbl_outward_history oh
            WHERE oh.status = 1 AND oh.outward_date >= @monthStart AND oh.outward_date < @monthEnd) AS month_outward_challan,
        (SELECT ISNULL(SUM(CAST(oh.qty_out AS BIGINT)), 0)
            FROM dbo.tbl_outward_history oh
            WHERE oh.status = 1 AND oh.outward_date >= @monthStart AND oh.outward_date < @monthEnd) AS month_outward_item,

        /* Jobwork — active (pending return from jobworker) */
        (SELECT COUNT(DISTINCT h.jobwork_challan_id)
            FROM dbo.tbl_jobwork_challan h
            INNER JOIN dbo.tbl_jobwork_challan_detail d ON d.jobwork_challan_id = h.jobwork_challan_id
            WHERE h.status = 1 AND d.status = 1 AND d.qty_sent > d.qty_perfect_done + d.qty_reject_done) AS jw_active_challan,
        (SELECT ISNULL(SUM(CAST(d.qty_sent - d.qty_perfect_done - d.qty_reject_done AS BIGINT)), 0)
            FROM dbo.tbl_jobwork_challan_detail d
            INNER JOIN dbo.tbl_jobwork_challan h ON h.jobwork_challan_id = d.jobwork_challan_id
            WHERE d.status = 1 AND h.status = 1 AND d.qty_sent > d.qty_perfect_done + d.qty_reject_done) AS jw_active_pending_qty,
        /* Jobwork — sent (new challans) */
        (SELECT COUNT(1)
            FROM dbo.tbl_jobwork_challan
            WHERE status = 1 AND CAST(challan_date AS DATE) = @today) AS jw_today_challan_sent,
        (SELECT ISNULL(SUM(CAST(d.qty_sent AS BIGINT)), 0)
            FROM dbo.tbl_jobwork_challan_detail d
            INNER JOIN dbo.tbl_jobwork_challan h ON h.jobwork_challan_id = d.jobwork_challan_id
            WHERE d.status = 1 AND h.status = 1 AND CAST(h.challan_date AS DATE) = @today) AS jw_today_qty_sent,
        (SELECT COUNT(1)
            FROM dbo.tbl_jobwork_challan
            WHERE status = 1 AND challan_date >= @monthStart AND challan_date < @monthEnd) AS jw_month_challan_sent,
        (SELECT ISNULL(SUM(CAST(d.qty_sent AS BIGINT)), 0)
            FROM dbo.tbl_jobwork_challan_detail d
            INNER JOIN dbo.tbl_jobwork_challan h ON h.jobwork_challan_id = d.jobwork_challan_id
            WHERE d.status = 1 AND h.status = 1 AND h.challan_date >= @monthStart AND h.challan_date < @monthEnd) AS jw_month_qty_sent,
        /* Jobwork — received back */
        (SELECT COUNT(1)
            FROM dbo.tbl_jobwork_return_history
            WHERE status = 1 AND CAST(return_date AS DATE) = @today) AS jw_today_receive_moves,
        (SELECT ISNULL(SUM(CAST(rh.qty_perfect + rh.qty_reject AS BIGINT)), 0)
            FROM dbo.tbl_jobwork_return_history rh
            WHERE rh.status = 1 AND CAST(rh.return_date AS DATE) = @today) AS jw_today_receive_qty,
        (SELECT COUNT(1)
            FROM dbo.tbl_jobwork_return_history
            WHERE status = 1 AND return_date >= @monthStart AND return_date < @monthEnd) AS jw_month_receive_moves,
        (SELECT ISNULL(SUM(CAST(rh.qty_perfect + rh.qty_reject AS BIGINT)), 0)
            FROM dbo.tbl_jobwork_return_history rh
            WHERE rh.status = 1 AND rh.return_date >= @monthStart AND rh.return_date < @monthEnd) AS jw_month_receive_qty,

        /* Party: sum(debit - credit). Jobwork: sum(debit - credit) per account balance. */
        (SELECT ISNULL(SUM(pb.balance), 0)
            FROM (
                SELECT
                    SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END)
                    - SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END) AS balance
                FROM dbo.tbl_account_transaction AS t
                INNER JOIN dbo.tbl_party_master AS p ON p.party_id = t.account_id
                WHERE t.account_type = N'PARTY' AND t.status = 1
                GROUP BY t.account_id
            ) AS pb
            WHERE pb.balance <> 0) AS total_debit,
        (SELECT ISNULL(SUM(jb.balance), 0)
            FROM (
                SELECT
                    SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END)
                    - SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END) AS balance
                FROM dbo.tbl_account_transaction AS t
                INNER JOIN dbo.tbl_jobwork_party AS jp ON jp.jobwork_party_id = t.account_id
                WHERE t.account_type = N'JOBWORK' AND t.status = 1
                GROUP BY t.account_id
            ) AS jb
            WHERE jb.balance <> 0) AS total_credit;
END
GO

/* --------------------- Dashboard trend (Last 30 days IN vs OUT) --------------------- */
IF OBJECT_ID('dbo.sel_dashboard_trend_30days_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_dashboard_trend_30days_sp;
GO
CREATE PROCEDURE dbo.sel_dashboard_trend_30days_sp
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @today DATE = CAST(dbo.get_date() AS DATE);
    DECLARE @start DATE = DATEADD(DAY, -29, @today);

    ;WITH d AS (
        SELECT @start AS dt
        UNION ALL
        SELECT DATEADD(DAY, 1, dt) FROM d WHERE dt < @today
    )
    SELECT
        d.dt,
        CONVERT(NVARCHAR(10), d.dt, 103) AS date_label,
        ISNULL(inx.in_qty, 0) AS in_qty,
        ISNULL(outx.out_qty, 0) AS out_qty
    FROM d
    OUTER APPLY (
        SELECT SUM(CAST(dd.qty_inward AS BIGINT)) AS in_qty
        FROM dbo.tbl_inward_challan h
        INNER JOIN dbo.tbl_inward_challan_details dd ON dd.inward_id = h.inward_id AND dd.status = 1
        WHERE h.status = 1 AND CAST(h.inward_date AS DATE) = d.dt
    ) inx
    OUTER APPLY (
        SELECT SUM(CAST(oh.qty_out AS BIGINT)) AS out_qty
        FROM dbo.tbl_outward_history oh
        WHERE oh.status = 1 AND CAST(oh.outward_date AS DATE) = d.dt
    ) outx
    ORDER BY d.dt ASC
    OPTION (MAXRECURSION 100);
END
GO

IF OBJECT_ID('dbo.dlt_user_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_user_sp;
GO
CREATE PROCEDURE dbo.dlt_user_sp
    @user_id BIGINT,
    @by INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @user_id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Not found.' AS Message;
            RETURN;
        END
        UPDATE dbo.tbl_user_master
        SET status = 0, delete_by = @by, delete_date = dbo.get_date()
        WHERE user_id = @user_id;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.user_login_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.user_login_sp;
GO
CREATE PROCEDURE dbo.user_login_sp
    @login_key NVARCHAR(150),
    @password NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET @login_key = LTRIM(RTRIM(@login_key));
    IF @login_key = N'' OR @password IS NULL OR LTRIM(RTRIM(@password)) = N''
        RETURN;

    DECLARE @h VARBINARY(32) = HASHBYTES('SHA2_256', CAST(@password AS NVARCHAR(200)));

    SELECT TOP 1 user_id, full_name, mobile_no, email
    FROM dbo.tbl_user_master
    WHERE status = 1
      AND password_hash = @h
      AND (mobile_no = @login_key OR (email IS NOT NULL AND LOWER(email) = LOWER(@login_key)));
END
GO

/* ==================== INWARD CHALLAN + OUTWARD HISTORY ==================== */

IF OBJECT_ID('dbo.dis_active_inward_list_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_active_inward_list_sp;
GO
alter PROCEDURE dbo.dis_active_inward_list_sp
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        ROW_NUMBER() OVER (ORDER BY h.inward_date DESC, h.inward_id DESC) AS sr,
        h.inward_id,
        h.inward_date,
        h.challan_no,
        p.party_name,
        ISNULL(x.item_list, N'') AS item_list,
        ISNULL(x.items_out, N'') AS items_out,
        ISNULL(x.items_pending, N'') AS items_pending,
        ISNULL(x.total_qty_in, 0) AS total_qty_in,
        ISNULL(x.total_qty_out, 0) AS total_qty_out,
        ISNULL(x.total_qty_pending, 0) AS total_qty_pending
    FROM dbo.tbl_inward_challan AS h
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = h.party_id AND p.status = 1
    LEFT JOIN (
        SELECT
            d.inward_id,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_inward AS VARCHAR(20)), N' | ') AS item_list,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_out_done AS VARCHAR(20)), N' | ') AS items_out,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_inward - d.qty_out_done AS VARCHAR(20)), N' | ') AS items_pending,
            SUM(d.qty_inward) AS total_qty_in,
            SUM(d.qty_out_done) AS total_qty_out,
            SUM(d.qty_inward - d.qty_out_done) AS total_qty_pending
        FROM dbo.tbl_inward_challan_details AS d
        INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
        WHERE d.status = 1
        GROUP BY d.inward_id
    ) AS x ON x.inward_id = h.inward_id
    WHERE h.status = 1
      /* Active list = still has pending qty to dispatch; fully closed challans appear only in report/history */
      AND ISNULL(x.total_qty_pending, 0) > 0
    ORDER BY h.inward_date DESC, h.inward_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_inward_report_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_inward_report_sp;
GO
CREATE PROCEDURE dbo.dis_inward_report_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @party_id NVARCHAR(50) = N'0',
    @include_deleted INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);

    SELECT
        ROW_NUMBER() OVER (ORDER BY h.inward_date DESC, h.inward_id DESC) AS sr,
        h.inward_id,
        h.inward_date,
        h.challan_no,
        p.party_name,
        /* Active = header live AND still has pending qty; Closed = deleted header OR fully dispatched (nothing due) */
        CASE
            WHEN h.status <> 1 THEN N'Closed'
            WHEN ISNULL(x.total_qty_pending, 0) <= 0 THEN N'Closed'
            ELSE N'Active'
        END AS challan_status,
        ISNULL(x.item_list, N'') AS item_list,
        ISNULL(x.items_out, N'') AS items_out,
        ISNULL(x.items_pending, N'') AS items_pending,
        ISNULL(x.total_qty_in, 0) AS total_qty_in,
        ISNULL(x.total_qty_out, 0) AS total_qty_out,
        ISNULL(x.total_qty_pending, 0) AS total_qty_pending
    FROM dbo.tbl_inward_challan AS h
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = h.party_id
    LEFT JOIN (
        SELECT
            d.inward_id,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_inward AS VARCHAR(20)), N' | ') AS item_list,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_out_done AS VARCHAR(20)), N' | ') AS items_out,
            STRING_AGG(CAST(pm.part_name AS NVARCHAR(200)) + N' × ' + CAST(d.qty_inward - d.qty_out_done AS VARCHAR(20)), N' | ') AS items_pending,
            SUM(d.qty_inward) AS total_qty_in,
            SUM(d.qty_out_done) AS total_qty_out,
            SUM(d.qty_inward - d.qty_out_done) AS total_qty_pending
        FROM dbo.tbl_inward_challan_details AS d
        INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id
        WHERE (@include_deleted = 1 OR d.status = 1)
        GROUP BY d.inward_id
    ) AS x ON x.inward_id = h.inward_id
    WHERE CAST(h.inward_date AS DATE) BETWEEN @f AND @t
      AND (@pid = 0 OR h.party_id = @pid)
      AND (@include_deleted = 1 OR h.status = 1)
    ORDER BY h.inward_date DESC, h.inward_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_inward_monthly_report_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_inward_monthly_report_sp;
GO
CREATE PROCEDURE dbo.dis_inward_monthly_report_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @party_id BIGINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @pid BIGINT = @party_id;

    /* One row per calendar day in [@f, @t]; days with no inward show zeros. */
    ;WITH days AS (
        SELECT @f AS d
        UNION ALL
        SELECT DATEADD(DAY, 1, d) FROM days WHERE d < @t
    ),
    agg AS (
        SELECT
            CAST(h.inward_date AS DATE) AS dt,
            COUNT(DISTINCT h.party_id) AS total_party_inward,
            COUNT(DISTINCT d.part_id) AS total_uniq_item_inward,
            SUM(CAST(d.qty_inward AS BIGINT)) AS total_qty_inward,
            SUM(CAST(d.qty_inward AS DECIMAL(18, 2)) * ISNULL(d.rate_at_time, 0)) AS total_amount
        FROM dbo.tbl_inward_challan AS h
        INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_id = h.inward_id AND d.status = 1
        WHERE h.status = 1
          AND CAST(h.inward_date AS DATE) BETWEEN @f AND @t
          AND (@pid = 0 OR h.party_id = @pid)
        GROUP BY CAST(h.inward_date AS DATE)
    )
    SELECT
        days.d AS report_date,
        ISNULL(a.total_party_inward, 0) AS total_party_inward,
        ISNULL(a.total_uniq_item_inward, 0) AS total_uniq_item_inward,
        ISNULL(a.total_qty_inward, 0) AS total_qty_inward,
        ISNULL(a.total_amount, 0) AS total_amount
    FROM days
    LEFT JOIN agg AS a ON a.dt = days.d
    ORDER BY days.d
    OPTION (MAXRECURSION 400);
END
GO


IF OBJECT_ID('dbo.dis_jobwork_monthly_report_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_monthly_report_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_monthly_report_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @jobwork_party_id BIGINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @jpid BIGINT = @jobwork_party_id;

    /* One row per calendar day in [@f, @t]; days with no jobwork show zeros. */
    ;WITH days AS (
        SELECT @f AS d
        UNION ALL
        SELECT DATEADD(DAY, 1, d) FROM days WHERE d < @t
    ),
    agg AS (
        SELECT
            CAST(h.challan_date AS DATE) AS dt,
            COUNT(DISTINCT h.jobwork_party_id) AS total_party_jobwork,
            COUNT(DISTINCT d.jobwork_part_id) AS total_uniq_part_jobwork,
            SUM(CAST(d.qty_sent AS BIGINT)) AS total_qty_sent,
            SUM(CAST(d.qty_sent AS DECIMAL(18, 2)) * ISNULL(d.rate_at_time, 0)) AS total_amount
        FROM dbo.tbl_jobwork_challan AS h
        INNER JOIN dbo.tbl_jobwork_challan_detail AS d ON d.jobwork_challan_id = h.jobwork_challan_id AND d.status = 1
        WHERE h.status = 1
          AND CAST(h.challan_date AS DATE) BETWEEN @f AND @t
          AND (@jpid = 0 OR h.jobwork_party_id = @jpid)
        GROUP BY CAST(h.challan_date AS DATE)
    )
    SELECT
        days.d AS report_date,
        ISNULL(a.total_party_jobwork, 0) AS total_party_jobwork,
        ISNULL(a.total_uniq_part_jobwork, 0) AS total_uniq_part_jobwork,
        ISNULL(a.total_qty_sent, 0) AS total_qty_sent,
        ISNULL(a.total_amount, 0) AS total_amount
    FROM days
    LEFT JOIN agg AS a ON a.dt = days.d
    ORDER BY days.d
    OPTION (MAXRECURSION 400);
END
GO

IF OBJECT_ID('dbo.get_inward_for_edit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.get_inward_for_edit_sp;
GO
CREATE PROCEDURE dbo.get_inward_for_edit_sp
    @inward_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);

    SELECT h.inward_id, h.party_id, h.challan_no, h.inward_date, h.remarks
    FROM dbo.tbl_inward_challan AS h
    WHERE h.inward_id = @id AND h.status = 1;

    SELECT
        d.inward_detail_id,
        d.part_id,
        pm.part_name,
        d.qty_inward,
        d.qty_out_done,
        d.qty_inward - d.qty_out_done AS qty_pending,
        d.rate_at_time
    FROM dbo.tbl_inward_challan_details AS d
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id
    WHERE d.inward_id = @id AND d.status = 1
    ORDER BY d.inward_detail_id;
END
GO

IF OBJECT_ID('dbo.sel_inward_lines_for_out_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_inward_lines_for_out_sp;
GO
CREATE PROCEDURE dbo.sel_inward_lines_for_out_sp
    @inward_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);

    SELECT
        d.inward_detail_id,
        d.part_id,
        pm.part_name,
        d.qty_inward,
        d.qty_out_done,
        d.qty_inward - d.qty_out_done AS qty_pending
    FROM dbo.tbl_inward_challan_details AS d
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id
    WHERE d.inward_id = @id AND d.status = 1 AND d.qty_inward > d.qty_out_done
    ORDER BY d.inward_detail_id;
END
GO

IF OBJECT_ID('dbo.ins_inward_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_inward_challan_sp;
GO
CREATE PROCEDURE dbo.ins_inward_challan_sp
    @party_id NVARCHAR(50),
    @challan_no NVARCHAR(50),
    @inward_date NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50),
    @part_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX),
    @rates NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @d DATE = CAST(@inward_date AS DATE);
        DECLARE @cn NVARCHAR(50) = LTRIM(RTRIM(ISNULL(@challan_no, N'')));

        BEGIN TRANSACTION;

        INSERT INTO dbo.tbl_inward_challan (party_id, challan_no, inward_date, remarks, status, create_by, create_date)
        VALUES (@pid, @cn, @d, @remarks, 1, @uid, dbo.get_date());

        DECLARE @hid BIGINT = SCOPE_IDENTITY();
        DECLARE @p NVARCHAR(MAX) = @part_ids;
        DECLARE @q NVARCHAR(MAX) = @qtys;
        DECLARE @r NVARCHAR(MAX) = ISNULL(@rates, N'');
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50), @segR NVARCHAR(50);
        DECLARE @partId BIGINT, @qty INT, @rate DECIMAL(18, 2);

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @segR = CASE WHEN LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0
                THEN LEFT(@r, CHARINDEX(N',', @r) - 1) ELSE N'0' END;

            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);
            IF LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0 SET @r = SUBSTRING(@r, CHARINDEX(N',', @r) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @partId = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);
            SET @rate = CAST(@segR AS DECIMAL(18, 2));

            IF @qty <= 0 CONTINUE;

            IF NOT EXISTS (
                SELECT 1 FROM dbo.tbl_part_master
                WHERE part_id = @partId AND CAST(party_id AS BIGINT) = @pid AND status = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Part does not belong to party or inactive.' AS Message;
                RETURN;
            END

            INSERT INTO dbo.tbl_inward_challan_details (inward_id, part_id, qty_inward, qty_out_done, rate_at_time, status, create_by, create_date)
            VALUES (@hid, @partId, @qty, 0, @rate, 1, @uid, dbo.get_date());
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Saved.' AS Message, @hid AS inward_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_inward_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_inward_challan_sp;
GO
CREATE PROCEDURE dbo.upd_inward_challan_sp
    @inward_id NVARCHAR(50),
    @party_id NVARCHAR(50),
    @challan_no NVARCHAR(50),
    @inward_date NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50),
    @part_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX),
    @rates NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);
        DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @d DATE = CAST(@inward_date AS DATE);
        DECLARE @cn NVARCHAR(50) = LTRIM(RTRIM(ISNULL(@challan_no, N'')));
        DECLARE @p NVARCHAR(MAX), @q NVARCHAR(MAX), @r NVARCHAR(MAX);
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50), @segR NVARCHAR(50);
        DECLARE @partId BIGINT, @qty INT, @rate DECIMAL(18, 2);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_inward_challan WHERE inward_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Inward not found.' AS Message;
            RETURN;
        END

        IF LEN(@cn) > 0
        BEGIN
            IF EXISTS (
                SELECT 1 FROM dbo.tbl_inward_challan
                WHERE party_id = @pid AND challan_no = @cn AND status = 1 AND inward_id <> @id)
            BEGIN
                SELECT 'False' AS Success, N'Duplicate challan number for this party.' AS Message;
                RETURN;
            END
        END

        DECLARE @has_out BIT = CASE WHEN EXISTS (
            SELECT 1 FROM dbo.tbl_outward_history AS oh
            INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id
            WHERE d.inward_id = @id AND oh.status = 1) THEN 1 ELSE 0 END;

        IF @has_out = 1
        BEGIN
            DECLARE @hdrParty BIGINT;
            SELECT @hdrParty = party_id FROM dbo.tbl_inward_challan WHERE inward_id = @id;

            DECLARE @newLines TABLE (
                part_id BIGINT NOT NULL,
                qty INT NOT NULL,
                rate DECIMAL(18, 2) NOT NULL
            );

            SET @p = @part_ids;
            SET @q = @qtys;
            SET @r = ISNULL(@rates, N'');

            WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
            BEGIN
                SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
                SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
                SET @segR = CASE WHEN LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0
                    THEN LEFT(@r, CHARINDEX(N',', @r) - 1) ELSE N'0' END;

                SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
                SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);
                IF LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0 SET @r = SUBSTRING(@r, CHARINDEX(N',', @r) + 1, 8000);

                IF LTRIM(RTRIM(@segP)) = N'' BREAK;

                SET @partId = CAST(@segP AS BIGINT);
                SET @qty = CAST(@segQ AS INT);
                SET @rate = CAST(@segR AS DECIMAL(18, 2));

                IF @qty <= 0 CONTINUE;

                IF NOT EXISTS (
                    SELECT 1 FROM dbo.tbl_part_master
                    WHERE part_id = @partId AND CAST(party_id AS BIGINT) = @hdrParty AND status = 1)
                BEGIN
                    SELECT 'False' AS Success, N'Part does not belong to party or inactive.' AS Message;
                    RETURN;
                END

                INSERT INTO @newLines (part_id, qty, rate) VALUES (@partId, @qty, @rate);
            END

            IF EXISTS (
                SELECT 1
                FROM dbo.tbl_inward_challan_details AS d
                INNER JOIN @newLines AS n ON n.part_id = d.part_id
                WHERE d.inward_id = @id AND d.status = 1 AND n.qty < d.qty_out_done)
            BEGIN
                SELECT 'False' AS Success, N'Quantity cannot be less than already outward qty.' AS Message;
                RETURN;
            END

            IF EXISTS (
                SELECT 1
                FROM dbo.tbl_inward_challan_details AS d
                WHERE d.inward_id = @id AND d.status = 1 AND d.qty_out_done > 0
                    AND NOT EXISTS (SELECT 1 FROM @newLines AS n WHERE n.part_id = d.part_id))
            BEGIN
                SELECT 'False' AS Success, N'Cannot remove a line that has outward qty.' AS Message;
                RETURN;
            END

            BEGIN TRANSACTION;

            UPDATE dbo.tbl_inward_challan
            SET challan_no = @cn, inward_date = @d, remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
            WHERE inward_id = @id;

            UPDATE d
            SET qty_inward = n.qty,
                rate_at_time = n.rate,
                modify_by = @uid,
                modify_date = dbo.get_date()
            FROM dbo.tbl_inward_challan_details AS d
            INNER JOIN @newLines AS n ON n.part_id = d.part_id
            WHERE d.inward_id = @id AND d.status = 1;

            INSERT INTO dbo.tbl_inward_challan_details (inward_id, part_id, qty_inward, qty_out_done, rate_at_time, status, create_by, create_date)
            SELECT @id, n.part_id, n.qty, 0, n.rate, 1, @uid, dbo.get_date()
            FROM @newLines AS n
            WHERE NOT EXISTS (
                SELECT 1 FROM dbo.tbl_inward_challan_details AS d
                WHERE d.inward_id = @id AND d.part_id = n.part_id AND d.status = 1);

            DELETE d
            FROM dbo.tbl_inward_challan_details AS d
            WHERE d.inward_id = @id AND d.status = 1 AND d.qty_out_done = 0
                AND NOT EXISTS (SELECT 1 FROM @newLines AS n WHERE n.part_id = d.part_id);

            COMMIT TRANSACTION;
            SELECT 'True' AS Success, N'Updated.' AS Message, @id AS inward_id;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_inward_challan
        SET party_id = @pid, challan_no = @cn, inward_date = @d, remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
        WHERE inward_id = @id;

        DELETE FROM dbo.tbl_inward_challan_details WHERE inward_id = @id;

        SET @p = @part_ids;
        SET @q = @qtys;
        SET @r = ISNULL(@rates, N'');

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @segR = CASE WHEN LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0
                THEN LEFT(@r, CHARINDEX(N',', @r) - 1) ELSE N'0' END;

            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);
            IF LEN(@r) > 0 AND CHARINDEX(N',', @r) > 0 SET @r = SUBSTRING(@r, CHARINDEX(N',', @r) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @partId = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);
            SET @rate = CAST(@segR AS DECIMAL(18, 2));

            IF @qty <= 0 CONTINUE;

            IF NOT EXISTS (
                SELECT 1 FROM dbo.tbl_part_master
                WHERE part_id = @partId AND CAST(party_id AS BIGINT) = @pid AND status = 1)
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Part does not belong to party or inactive.' AS Message;
                RETURN;
            END

            INSERT INTO dbo.tbl_inward_challan_details (inward_id, part_id, qty_inward, qty_out_done, rate_at_time, status, create_by, create_date)
            VALUES (@id, @partId, @qty, 0, @rate, 1, @uid, dbo.get_date());
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Updated.' AS Message, @id AS inward_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_inward_challan_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_inward_challan_sp;
GO
alter PROCEDURE dbo.dlt_inward_challan_sp
    @inward_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_inward_challan WHERE inward_id = @id AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Challan not found or already deleted.' AS Message;
            RETURN;
        END

        /* Soft-delete all outward rows for this challan (no need to reverse outward first). */
        UPDATE oh
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        FROM dbo.tbl_outward_history AS oh
        INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id
        WHERE d.inward_id = @id AND oh.status = 1;

        UPDATE dbo.tbl_inward_challan_details
        SET qty_out_done = 0,
            status = 0,
            delete_by = @uid,
            delete_date = dbo.get_date(),
            modify_by = @uid,
            modify_date = dbo.get_date()
        WHERE inward_id = @id AND status = 1;

        UPDATE dbo.tbl_inward_challan
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE inward_id = @id;

        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.ins_outward_line_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_outward_line_sp;
GO
CREATE PROCEDURE dbo.ins_outward_line_sp
    @inward_detail_id NVARCHAR(50),
    @qty_out NVARCHAR(50),
    @slip_no NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @did BIGINT = CAST(@inward_detail_id AS BIGINT);
        DECLARE @q INT = CAST(@qty_out AS INT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF @q <= 0
        BEGIN
            SELECT 'False' AS Success, N'Qty must be positive.' AS Message;
            RETURN;
        END

        DECLARE @pend INT;
        SELECT @pend = d.qty_inward - d.qty_out_done
        FROM dbo.tbl_inward_challan_details AS d
        INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id
        WHERE d.inward_detail_id = @did AND d.status = 1 AND h.status = 1;

        IF @pend IS NULL
        BEGIN
            SELECT 'False' AS Success, N'Line not found.' AS Message;
            RETURN;
        END

        IF @q > @pend
        BEGIN
            SELECT 'False' AS Success, N'Qty exceeds pending balance.' AS Message;
            RETURN;
        END

        INSERT INTO dbo.tbl_outward_history (inward_detail_id, qty_out, slip_no, remarks, status, create_by, create_date)
        VALUES (@did, @q, NULLIF(LTRIM(RTRIM(@slip_no)), N''), @remarks, 1, @uid, dbo.get_date());

        UPDATE dbo.tbl_inward_challan_details
        SET qty_out_done = qty_out_done + @q, modify_by = @uid, modify_date = dbo.get_date()
        WHERE inward_detail_id = @did;

        SELECT 'True' AS Success, N'Outward saved.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_outward_for_edit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_outward_for_edit_sp;
GO
CREATE PROCEDURE dbo.sel_outward_for_edit_sp
    @outward_history_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @hid BIGINT = CAST(@outward_history_id AS BIGINT);

    SELECT
        oh.outward_history_id,
        oh.outward_date,
        ISNULL(oh.slip_no, N'') AS slip_no,
        oh.qty_out,
        ISNULL(oh.remarks, N'') AS remarks,
        h.challan_no,
        p.party_name,
        pm.part_name,
        d.qty_inward - d.qty_out_done AS qty_pending,
        oh.qty_out + (d.qty_inward - d.qty_out_done) AS qty_max
    FROM dbo.tbl_outward_history AS oh
    INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id AND d.status = 1
    INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = h.party_id AND p.status = 1
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
    WHERE oh.outward_history_id = @hid AND oh.status = 1;
END
GO

IF OBJECT_ID('dbo.upd_outward_history_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_outward_history_sp;
GO
CREATE PROCEDURE dbo.upd_outward_history_sp
    @outward_history_id NVARCHAR(50),
    @qty_out NVARCHAR(50),
    @slip_no NVARCHAR(50),
    @remarks NVARCHAR(MAX),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @hid BIGINT = CAST(@outward_history_id AS BIGINT);
        DECLARE @newq INT = CAST(@qty_out AS INT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF @newq <= 0
        BEGIN
            SELECT 'False' AS Success, N'Qty must be positive.' AS Message;
            RETURN;
        END

        DECLARE @did BIGINT;
        DECLARE @oldq INT;
        SELECT @did = inward_detail_id, @oldq = qty_out
        FROM dbo.tbl_outward_history
        WHERE outward_history_id = @hid AND status = 1;

        IF @did IS NULL
        BEGIN
            SELECT 'False' AS Success, N'History row not found.' AS Message;
            RETURN;
        END

        DECLARE @pend INT;
        SELECT @pend = qty_inward - qty_out_done FROM dbo.tbl_inward_challan_details WHERE inward_detail_id = @did;

        DECLARE @delta INT = @newq - @oldq;
        IF @delta > @pend
        BEGIN
            SELECT 'False' AS Success, N'Qty exceeds pending balance.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_outward_history
        SET qty_out = @newq, slip_no = NULLIF(LTRIM(RTRIM(@slip_no)), N''), remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
        WHERE outward_history_id = @hid;

        UPDATE dbo.tbl_inward_challan_details
        SET qty_out_done = qty_out_done + @delta, modify_by = @uid, modify_date = dbo.get_date()
        WHERE inward_detail_id = @did;

        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_outward_history_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_outward_history_sp;
GO
CREATE PROCEDURE dbo.dlt_outward_history_sp
    @outward_history_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @hid BIGINT = CAST(@outward_history_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        DECLARE @did BIGINT;
        DECLARE @q INT;
        SELECT @did = inward_detail_id, @q = qty_out
        FROM dbo.tbl_outward_history
        WHERE outward_history_id = @hid AND status = 1;

        IF @did IS NULL
        BEGIN
            SELECT 'False' AS Success, N'Already removed.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_outward_history
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE outward_history_id = @hid;

        UPDATE dbo.tbl_inward_challan_details
        SET qty_out_done = qty_out_done - @q, modify_by = @uid, modify_date = dbo.get_date()
        WHERE inward_detail_id = @did;

        SELECT 'True' AS Success, N'Reversed.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dis_outward_history_by_inward_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_outward_history_by_inward_sp;
GO
CREATE PROCEDURE dbo.dis_outward_history_by_inward_sp
    @inward_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);

    SELECT
        oh.outward_history_id,
        oh.outward_date,
        oh.slip_no,
        pm.part_name,
        oh.qty_out,
        oh.remarks
    FROM dbo.tbl_outward_history AS oh
    INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id
    WHERE d.inward_id = @id AND oh.status = 1
    ORDER BY oh.outward_date DESC, oh.outward_history_id DESC;
END
GO

/* ==================== INVOICE ==================== */

IF OBJECT_ID('dbo.sel_inward_lines_for_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_inward_lines_for_invoice_sp;
GO
CREATE PROCEDURE dbo.sel_inward_lines_for_invoice_sp
    @party_id NVARCHAR(50),
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @inward_id NVARCHAR(50) = N'0'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @iid BIGINT = CAST(ISNULL(NULLIF(LTRIM(RTRIM(@inward_id)), N''), N'0') AS BIGINT);

    SELECT
        d.inward_detail_id,
        h.inward_id,
        h.challan_no,
        h.inward_date,
        d.part_id,
        pm.part_name,
        d.qty_inward,
        ISNULL(x.qty_invoiced_so_far, 0) AS qty_invoiced_so_far,
        d.qty_inward - ISNULL(x.qty_invoiced_so_far, 0) AS qty_available_for_invoice,
        COALESCE(d.rate_at_time, pm.rate) AS suggest_rate,
        pm.tax_per AS suggest_tax_per
    FROM dbo.tbl_inward_challan_details AS d
    INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
    LEFT JOIN (
        SELECT
            id.inward_detail_id,
            SUM(id.qty_invoiced) AS qty_invoiced_so_far
        FROM dbo.tbl_invoice_detail AS id
        INNER JOIN dbo.tbl_invoice AS i ON i.invoice_id = id.invoice_id AND i.status = 1
        WHERE id.status = 1
        GROUP BY id.inward_detail_id
    ) AS x ON x.inward_detail_id = d.inward_detail_id
    WHERE d.status = 1
      AND h.party_id = @pid
      AND CAST(h.inward_date AS DATE) BETWEEN @f AND @t
      AND (@iid = 0 OR h.inward_id = @iid)
    ORDER BY h.inward_date, h.inward_id, d.inward_detail_id;
END
GO

IF OBJECT_ID('dbo.sel_inward_challan_invoice_status_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_inward_challan_invoice_status_sp;
GO
CREATE PROCEDURE dbo.sel_inward_challan_invoice_status_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @party_id NVARCHAR(50) = N'0'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);

    ;WITH line_inv AS (
        SELECT
            d.inward_id,
            d.inward_detail_id,
            d.qty_inward,
            ISNULL(SUM(id.qty_invoiced), 0) AS qty_invoiced
        FROM dbo.tbl_inward_challan_details AS d
        INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
        LEFT JOIN dbo.tbl_invoice_detail AS id
            ON id.inward_detail_id = d.inward_detail_id AND id.status = 1
        LEFT JOIN dbo.tbl_invoice AS i ON i.invoice_id = id.invoice_id AND i.status = 1
        WHERE d.status = 1
          AND CAST(h.inward_date AS DATE) BETWEEN @f AND @t
          AND (@pid = 0 OR h.party_id = @pid)
        GROUP BY d.inward_id, d.inward_detail_id, d.qty_inward
    ),
    challan_agg AS (
        SELECT
            inward_id,
            MAX(CASE WHEN qty_invoiced > 0 THEN 1 ELSE 0 END) AS has_billed,
            MAX(CASE WHEN qty_invoiced < qty_inward THEN 1 ELSE 0 END) AS has_open_line
        FROM line_inv
        GROUP BY inward_id
    )
    SELECT
        h.inward_id,
        h.challan_no,
        h.inward_date,
        h.party_id,
        p.party_name,
        CASE
            WHEN ISNULL(a.has_billed, 0) = 0 THEN N'None'
            WHEN ISNULL(a.has_open_line, 0) = 1 THEN N'Partial'
            ELSE N'Full'
        END AS invoice_status
    FROM dbo.tbl_inward_challan AS h
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = h.party_id
    LEFT JOIN challan_agg AS a ON a.inward_id = h.inward_id
    WHERE h.status = 1
      AND CAST(h.inward_date AS DATE) BETWEEN @f AND @t
      AND (@pid = 0 OR h.party_id = @pid);
END
GO

IF OBJECT_ID('dbo.dis_invoice_list_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_invoice_list_sp;
GO
CREATE PROCEDURE dbo.dis_invoice_list_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50),
    @party_id NVARCHAR(50) = N'0'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);

    SELECT
        ROW_NUMBER() OVER (ORDER BY i.invoice_date DESC, i.invoice_id DESC) AS sr,
        i.invoice_id,
        i.invoice_no,
        i.invoice_date,
        i.invoice_kind,
        i.party_id,
        p.party_name,
        i.sub_total,
        i.tax_total,
        i.grand_total,
        i.create_date
    FROM dbo.tbl_invoice AS i
    INNER JOIN dbo.tbl_party_master AS p ON p.party_id = i.party_id
    WHERE i.status = 1
      AND CAST(i.invoice_date AS DATE) BETWEEN @f AND @t
      AND (@pid = 0 OR i.party_id = @pid)
    ORDER BY i.invoice_date DESC, i.invoice_id DESC;
END
GO

IF OBJECT_ID('dbo.get_invoice_for_edit_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.get_invoice_for_edit_sp;
GO
get_invoice_for_edit_sp 1
CREATE PROCEDURE dbo.get_invoice_for_edit_sp
    @invoice_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @id BIGINT = CAST(@invoice_id AS BIGINT);

    SELECT
        i.invoice_id,
        i.party_id,
        i.invoice_kind,
        i.invoice_no,
        i.invoice_date,
        i.sub_total,
        i.tax_total,
        i.grand_total,
        i.remarks
    FROM dbo.tbl_invoice AS i
    WHERE i.invoice_id = @id AND i.status = 1;

    SELECT
        d.invoice_detail_id,
        d.inward_detail_id,
        d.part_id,
        pm.part_name,
        d.qty_invoiced,
        d.rate,
        d.tax_per,
        d.taxable_amount,
        d.tax_amount,
        d.line_total,
        h.inward_id,
        h.challan_no,
        h.inward_date,
        det.qty_inward,
        ISNULL(inv_all.qty_sum, 0) AS qty_invoiced_so_far,
        det.qty_inward - (ISNULL(inv_all.qty_sum, 0) - d.qty_invoiced) AS qty_can_bill_max
    FROM dbo.tbl_invoice_detail AS d
    INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id
    INNER JOIN dbo.tbl_inward_challan_details AS det ON det.inward_detail_id = d.inward_detail_id AND det.status = 1
    INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = det.inward_id AND h.status = 1
    LEFT JOIN (
        SELECT
            id3.inward_detail_id,
            SUM(id3.qty_invoiced) AS qty_sum
        FROM dbo.tbl_invoice_detail AS id3
        INNER JOIN dbo.tbl_invoice AS iv3 ON iv3.invoice_id = id3.invoice_id AND iv3.status = 1
        WHERE id3.status = 1
        GROUP BY id3.inward_detail_id
    ) AS inv_all ON inv_all.inward_detail_id = d.inward_detail_id
    WHERE d.invoice_id = @id AND d.status = 1
    ORDER BY d.invoice_detail_id;
END
GO

IF OBJECT_ID('dbo.ins_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_invoice_sp;
GO
CREATE PROCEDURE dbo.ins_invoice_sp
    @party_id NVARCHAR(50),
    @invoice_kind NVARCHAR(20),
    @invoice_date NVARCHAR(50),
    @remarks NVARCHAR(MAX) = NULL,
    @by NVARCHAR(50),
    @inward_detail_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @kind NVARCHAR(20) = UPPER(LTRIM(RTRIM(@invoice_kind)));
        DECLARE @invDate DATETIME = CAST(@invoice_date AS DATETIME);
        DECLARE @d DATE = CAST(@invDate AS DATE);
        DECLARE @invNo NVARCHAR(50);
        DECLARE @pfx NVARCHAR(30);
        DECLARE @nx INT;

        IF @kind NOT IN (N'GST', N'NON_GST')
        BEGIN
            SELECT 'False' AS Success, N'invoice_kind must be GST or NON_GST.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_id = @pid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Party not found.' AS Message;
            RETURN;
        END

        SET @pfx = N'INV-' + SUBSTRING(CONVERT(VARCHAR(8), @d, 112), 1, 6) + N'-';

        ;WITH nums AS (
            SELECT TRY_CAST(SUBSTRING(invoice_no, LEN(@pfx) + 1, 8) AS INT) AS n
            FROM dbo.tbl_invoice
            WHERE status = 1
              AND invoice_no LIKE @pfx + N'%'
              AND LEN(invoice_no) > LEN(@pfx)
        )
        SELECT @nx = ISNULL(MAX(n), 0) + 1 FROM nums;

        SET @invNo = @pfx + RIGHT(N'00000' + CAST(@nx AS VARCHAR(12)), 5);

        IF EXISTS (SELECT 1 FROM dbo.tbl_invoice WHERE invoice_no = @invNo AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Could not assign unique invoice number. Retry.' AS Message;
            RETURN;
        END

        DECLARE @sub DECIMAL(18, 2) = 0;
        DECLARE @tax DECIMAL(18, 2) = 0;
        DECLARE @grand DECIMAL(18, 2) = 0;

        BEGIN TRANSACTION;

        INSERT INTO dbo.tbl_invoice (
            party_id, invoice_kind, invoice_no, invoice_date, period_from, period_to,
            doc_status, sub_total, tax_total, grand_total, remarks, status, create_by, create_date)
        VALUES (
            @pid, @kind, @invNo, @invDate, NULL, NULL,
            N'Draft', 0, 0, 0, @remarks, 1, @uid, dbo.get_date());

        DECLARE @invid BIGINT = SCOPE_IDENTITY();

        DECLARE @p NVARCHAR(MAX) = @inward_detail_ids;
        DECLARE @q NVARCHAR(MAX) = @qtys;
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50);
        DECLARE @did BIGINT, @qty INT;
        DECLARE @rate DECIMAL(18, 2);
        DECLARE @taxper DECIMAL(18, 2);
        DECLARE @taxable DECIMAL(18, 2);
        DECLARE @taxamt DECIMAL(18, 2);
        DECLARE @linet DECIMAL(18, 2);
        DECLARE @qtyIn INT;
        DECLARE @already INT;
        DECLARE @partId BIGINT;

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @did = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);

            IF @qty <= 0 CONTINUE;

            SELECT
                @qtyIn = d.qty_inward,
                @partId = d.part_id,
                @rate = COALESCE(d.rate_at_time, pm.rate),
                @taxper = CASE WHEN @kind = N'NON_GST' THEN 0 ELSE pm.tax_per END
            FROM dbo.tbl_inward_challan_details AS d
            INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
            INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
            WHERE d.inward_detail_id = @did AND d.status = 1 AND h.party_id = @pid;

            IF @qtyIn IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Inward line not found or wrong party.' AS Message;
                RETURN;
            END

            SELECT @already = ISNULL(SUM(id.qty_invoiced), 0)
            FROM dbo.tbl_invoice_detail AS id
            INNER JOIN dbo.tbl_invoice AS iv ON iv.invoice_id = id.invoice_id
            WHERE id.inward_detail_id = @did AND id.status = 1 AND iv.status = 1;

            IF @already + @qty > @qtyIn
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Invoice qty exceeds inward qty for a line.' AS Message;
                RETURN;
            END

            SET @taxable = ROUND(@rate * @qty, 2);
            SET @taxamt = CASE WHEN @kind = N'NON_GST' THEN 0 ELSE ROUND(@taxable * @taxper / 100.0, 2) END;
            SET @linet = @taxable + @taxamt;

            INSERT INTO dbo.tbl_invoice_detail (
                invoice_id, inward_detail_id, part_id, qty_invoiced, rate, tax_per,
                taxable_amount, tax_amount, line_total, status, create_by, create_date)
            VALUES (
                @invid, @did, @partId, @qty, @rate, @taxper,
                @taxable, @taxamt, @linet, 1, @uid, dbo.get_date());

            SET @sub = @sub + @taxable;
            SET @tax = @tax + @taxamt;
            SET @grand = @grand + @linet;
            SET @qtyIn = NULL;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_invoice_detail WHERE invoice_id = @invid AND status = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'At least one invoice line is required.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_invoice
        SET sub_total = @sub, tax_total = @tax, grand_total = @grand, modify_by = @uid, modify_date = dbo.get_date()
        WHERE invoice_id = @invid;

        INSERT INTO dbo.tbl_account_transaction (
            txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
            ref_no, note, payment_mode, source_type, source_id,
            status, create_by, create_date
        )
        VALUES (
            @d, N'PARTY_INVOICE', N'PARTY', @pid, NULL, N'D', @grand,
            @invNo, @remarks, NULL, N'INVOICE', @invid,
            1, @uid, dbo.get_date()
        );

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Saved.' AS Message, @invid AS invoice_id, @invNo AS invoice_no;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_invoice_sp;
GO
CREATE PROCEDURE dbo.upd_invoice_sp
    @invoice_id NVARCHAR(50),
    @party_id NVARCHAR(50),
    @invoice_kind NVARCHAR(20),
    @invoice_date NVARCHAR(50),
    @remarks NVARCHAR(MAX) = NULL,
    @by NVARCHAR(50),
    @inward_detail_ids NVARCHAR(MAX),
    @qtys NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @invid BIGINT = CAST(@invoice_id AS BIGINT);
        DECLARE @pid BIGINT = CAST(@party_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @kind NVARCHAR(20) = UPPER(LTRIM(RTRIM(@invoice_kind)));
        DECLARE @invDate DATETIME = CAST(@invoice_date AS DATETIME);
        DECLARE @d DATE = CAST(@invDate AS DATE);
        DECLARE @invNo NVARCHAR(50);

        IF @kind NOT IN (N'GST', N'NON_GST')
        BEGIN
            SELECT 'False' AS Success, N'invoice_kind must be GST or NON_GST.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_invoice WHERE invoice_id = @invid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Invoice not found.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_id = @pid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Party not found.' AS Message;
            RETURN;
        END

        SELECT @invNo = invoice_no FROM dbo.tbl_invoice WHERE invoice_id = @invid;

        DECLARE @sub DECIMAL(18, 2) = 0;
        DECLARE @tax DECIMAL(18, 2) = 0;
        DECLARE @grand DECIMAL(18, 2) = 0;

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_invoice_detail
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE invoice_id = @invid AND status = 1;

        UPDATE dbo.tbl_invoice
        SET
            party_id = @pid,
            invoice_kind = @kind,
            invoice_date = @invDate,
            period_from = NULL,
            period_to = NULL,
            doc_status = N'Draft',
            remarks = @remarks,
            modify_by = @uid,
            modify_date = dbo.get_date()
        WHERE invoice_id = @invid;

        DECLARE @p NVARCHAR(MAX) = @inward_detail_ids;
        DECLARE @q NVARCHAR(MAX) = @qtys;
        DECLARE @segP NVARCHAR(50), @segQ NVARCHAR(50);
        DECLARE @did BIGINT, @qty INT;
        DECLARE @rate DECIMAL(18, 2);
        DECLARE @taxper DECIMAL(18, 2);
        DECLARE @taxable DECIMAL(18, 2);
        DECLARE @taxamt DECIMAL(18, 2);
        DECLARE @linet DECIMAL(18, 2);
        DECLARE @qtyIn INT;
        DECLARE @already INT;
        DECLARE @partId BIGINT;

        WHILE LEN(@p) > 0 AND CHARINDEX(N',', @p) > 0
        BEGIN
            SET @segP = LEFT(@p, CHARINDEX(N',', @p) - 1);
            SET @segQ = LEFT(@q, CHARINDEX(N',', @q) - 1);
            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            SET @q = SUBSTRING(@q, CHARINDEX(N',', @q) + 1, 8000);

            IF LTRIM(RTRIM(@segP)) = N'' BREAK;

            SET @did = CAST(@segP AS BIGINT);
            SET @qty = CAST(@segQ AS INT);

            IF @qty <= 0 CONTINUE;

            SELECT
                @qtyIn = d.qty_inward,
                @partId = d.part_id,
                @rate = COALESCE(d.rate_at_time, pm.rate),
                @taxper = CASE WHEN @kind = N'NON_GST' THEN 0 ELSE pm.tax_per END
            FROM dbo.tbl_inward_challan_details AS d
            INNER JOIN dbo.tbl_inward_challan AS h ON h.inward_id = d.inward_id AND h.status = 1
            INNER JOIN dbo.tbl_part_master AS pm ON pm.part_id = d.part_id AND pm.status = 1
            WHERE d.inward_detail_id = @did AND d.status = 1 AND h.party_id = @pid;

            IF @qtyIn IS NULL
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Inward line not found or wrong party.' AS Message;
                RETURN;
            END

            SELECT @already = ISNULL(SUM(id.qty_invoiced), 0)
            FROM dbo.tbl_invoice_detail AS id
            INNER JOIN dbo.tbl_invoice AS iv ON iv.invoice_id = id.invoice_id
            WHERE id.inward_detail_id = @did AND id.status = 1 AND iv.status = 1;

            IF @already + @qty > @qtyIn
            BEGIN
                ROLLBACK TRANSACTION;
                SELECT 'False' AS Success, N'Invoice qty exceeds inward qty for a line.' AS Message;
                RETURN;
            END

            SET @taxable = ROUND(@rate * @qty, 2);
            SET @taxamt = CASE WHEN @kind = N'NON_GST' THEN 0 ELSE ROUND(@taxable * @taxper / 100.0, 2) END;
            SET @linet = @taxable + @taxamt;

            INSERT INTO dbo.tbl_invoice_detail (
                invoice_id, inward_detail_id, part_id, qty_invoiced, rate, tax_per,
                taxable_amount, tax_amount, line_total, status, create_by, create_date)
            VALUES (
                @invid, @did, @partId, @qty, @rate, @taxper,
                @taxable, @taxamt, @linet, 1, @uid, dbo.get_date());

            SET @sub = @sub + @taxable;
            SET @tax = @tax + @taxamt;
            SET @grand = @grand + @linet;
            SET @qtyIn = NULL;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_invoice_detail WHERE invoice_id = @invid AND status = 1)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 'False' AS Success, N'At least one invoice line is required.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_invoice
        SET sub_total = @sub, tax_total = @tax, grand_total = @grand, modify_by = @uid, modify_date = dbo.get_date()
        WHERE invoice_id = @invid;

        UPDATE dbo.tbl_account_transaction
        SET
            txn_date = @d,
            account_id = @pid,
            amount = @grand,
            ref_no = @invNo,
            note = @remarks,
            modify_by = @uid,
            modify_date = dbo.get_date()
        WHERE source_type = N'INVOICE'
          AND source_id = @invid
          AND status = 1;

        IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO dbo.tbl_account_transaction (
                txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
                ref_no, note, payment_mode, source_type, source_id,
                status, create_by, create_date
            )
            VALUES (
                @d, N'PARTY_INVOICE', N'PARTY', @pid, NULL, N'D', @grand,
                @invNo, @remarks, NULL, N'INVOICE', @invid,
                1, @uid, dbo.get_date()
            );
        END

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Updated.' AS Message, @invid AS invoice_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_invoice_sp;
GO
CREATE PROCEDURE dbo.dlt_invoice_sp
    @invoice_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @invid BIGINT = CAST(@invoice_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_invoice WHERE invoice_id = @invid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Invoice not found.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_invoice_detail
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE invoice_id = @invid AND status = 1;

        UPDATE dbo.tbl_invoice
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE invoice_id = @invid;

        UPDATE dbo.tbl_account_transaction
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE source_type = N'INVOICE' AND source_id = @invid AND status = 1;

        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO



/* ==================== JOBWORK INVOICE ==================== */

IF OBJECT_ID('dbo.dis_jobwork_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_jobwork_invoice_sp;
GO
CREATE PROCEDURE dbo.dis_jobwork_invoice_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);

    SELECT
        ROW_NUMBER() OVER (ORDER BY j.invoice_date DESC, j.jobwork_invoice_id DESC) AS sr,
        j.jobwork_invoice_id,
        j.jobwork_party_id,
        p.party_name,
        j.invoice_date,
        j.invoice_no,
        j.total_amount
    FROM dbo.tbl_jobwork_invoice AS j
    INNER JOIN dbo.tbl_jobwork_party AS p
        ON p.jobwork_party_id = j.jobwork_party_id AND p.status = 1
    WHERE j.status = 1
      AND j.invoice_date BETWEEN @f AND @t
    ORDER BY j.invoice_date DESC, j.jobwork_invoice_id DESC;
END
GO

IF OBJECT_ID('dbo.sel_jobwork_invoice_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_jobwork_invoice_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_jobwork_invoice_by_id_sp
    @jobwork_invoice_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @jid BIGINT = CAST(@jobwork_invoice_id AS BIGINT);

    SELECT
        jobwork_invoice_id,
        jobwork_party_id,
        invoice_date,
        invoice_no,
        total_amount
    FROM dbo.tbl_jobwork_invoice
    WHERE jobwork_invoice_id = @jid AND status = 1;
END
GO

IF OBJECT_ID('dbo.ins_jobwork_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_jobwork_invoice_sp;
GO
CREATE PROCEDURE dbo.ins_jobwork_invoice_sp
    @jobwork_party_id NVARCHAR(50),
    @invoice_date NVARCHAR(50),
    @invoice_no NVARCHAR(50) = NULL,
    @total_amount NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jpid BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @d DATE = CAST(@invoice_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@total_amount AS DECIMAL(18, 2));
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @invNo NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@invoice_no)), N'');

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @jpid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork party not found.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO dbo.tbl_jobwork_invoice (
            jobwork_party_id, invoice_date, invoice_no, total_amount,
            status, create_by, create_date
        )
        VALUES (@jpid, @d, @invNo, @amt, 1, @uid, dbo.get_date());

        DECLARE @jid BIGINT = SCOPE_IDENTITY();

        INSERT INTO dbo.tbl_account_transaction (
            txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
            ref_no, note, payment_mode, source_type, source_id,
            status, create_by, create_date
        )
        VALUES (
            @d, N'JW_INVOICE', N'JOBWORK', @jpid, NULL, N'C', @amt,
            @invNo, NULL, NULL, N'JW_INVOICE', @jid,
            1, @uid, dbo.get_date()
        );

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Saved.' AS Message, @jid AS jobwork_invoice_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_jobwork_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_jobwork_invoice_sp;
GO
CREATE PROCEDURE dbo.upd_jobwork_invoice_sp
    @jobwork_invoice_id NVARCHAR(50),
    @jobwork_party_id NVARCHAR(50),
    @invoice_date NVARCHAR(50),
    @invoice_no NVARCHAR(50) = NULL,
    @total_amount NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jid BIGINT = CAST(@jobwork_invoice_id AS BIGINT);
        DECLARE @jpid BIGINT = CAST(@jobwork_party_id AS BIGINT);
        DECLARE @d DATE = CAST(@invoice_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@total_amount AS DECIMAL(18, 2));
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @invNo NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@invoice_no)), N'');

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_invoice WHERE jobwork_invoice_id = @jid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork invoice not found.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @jpid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork party not found.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_jobwork_invoice
        SET
            jobwork_party_id = @jpid,
            invoice_date = @d,
            invoice_no = @invNo,
            total_amount = @amt,
            modify_by = @uid,
            modify_date = dbo.get_date()
        WHERE jobwork_invoice_id = @jid AND status = 1;

        UPDATE dbo.tbl_account_transaction
        SET
            txn_date = @d,
            account_id = @jpid,
            amount = @amt,
            ref_no = @invNo,
            modify_by = @uid,
            modify_date = dbo.get_date()
        WHERE source_type = N'JW_INVOICE'
          AND source_id = @jid
          AND status = 1;

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_jobwork_invoice_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_jobwork_invoice_sp;
GO
CREATE PROCEDURE dbo.dlt_jobwork_invoice_sp
    @jobwork_invoice_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @jid BIGINT = CAST(@jobwork_invoice_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_invoice WHERE jobwork_invoice_id = @jid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Jobwork invoice not found.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_jobwork_invoice
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE jobwork_invoice_id = @jid;

        UPDATE dbo.tbl_account_transaction
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE source_type = N'JW_INVOICE' AND source_id = @jid AND status = 1;

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== STAFF EXPENSE (MY EXPENSE) ==================== */

IF OBJECT_ID('dbo.dis_staff_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_staff_expense_sp;
GO
CREATE PROCEDURE dbo.dis_staff_expense_sp
    @user_id NVARCHAR(50),
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);

    SELECT
        ROW_NUMBER() OVER (ORDER BY e.expense_date DESC, e.staff_expense_id DESC) AS sr,
        e.staff_expense_id,
        e.user_id,
        e.expense_date,
        e.ref_no,
        e.note,
        e.amount
    FROM dbo.tbl_staff_expense AS e
    WHERE e.status = 1
      AND e.user_id = @uid
      AND e.expense_date BETWEEN @f AND @t
    ORDER BY e.expense_date DESC, e.staff_expense_id DESC;
END
GO

IF OBJECT_ID('dbo.dis_my_staff_account_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_my_staff_account_sp;
GO
CREATE PROCEDURE dbo.dis_my_staff_account_sp
    @user_id NVARCHAR(50),
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);
    DECLARE @name NVARCHAR(150);
    DECLARE @opening DECIMAL(18, 2) = 0;
    DECLARE @periodDebit DECIMAL(18, 2) = 0;
    DECLARE @periodCredit DECIMAL(18, 2) = 0;
    DECLARE @closing DECIMAL(18, 2) = 0;

    SELECT @name = u.full_name
    FROM dbo.tbl_user_master AS u
    WHERE u.user_id = @uid AND u.status = 1;

    IF @name IS NULL
    BEGIN
        SELECT N'False' AS Success, N'User not found.' AS Message;
        RETURN;
    END

    SELECT @opening = ISNULL(SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END), 0)
    FROM dbo.tbl_account_transaction AS t
    WHERE t.account_type = N'STAFF'
      AND t.account_id = @uid
      AND t.status = 1
      AND t.txn_date < @f;

    SELECT
        @periodDebit = ISNULL(SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END), 0),
        @periodCredit = ISNULL(SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END), 0)
    FROM dbo.tbl_account_transaction AS t
    WHERE t.account_type = N'STAFF'
      AND t.account_id = @uid
      AND t.status = 1
      AND t.txn_date BETWEEN @f AND @t;

    SELECT @closing = ISNULL(SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END), 0)
    FROM dbo.tbl_account_transaction AS t
    WHERE t.account_type = N'STAFF'
      AND t.account_id = @uid
      AND t.status = 1
      AND t.txn_date <= @t;

    SELECT
        N'True' AS Success,
        @uid AS user_id,
        @name AS user_name,
        N'Payable' AS balance_label,
        @opening AS opening_balance,
        @periodDebit AS period_debit,
        @periodCredit AS period_credit,
        @closing AS closing_balance;

    ;WITH all_lines AS (
        SELECT
            t.txn_id,
            t.txn_date,
            t.txn_type,
            CASE t.txn_type
                WHEN N'STAFF_EXPENSE' THEN N'Staff expense'
                WHEN N'STAFF_PAY' THEN N'Payment received'
                ELSE t.txn_type
            END AS txn_type_label,
            t.ref_no,
            t.note,
            t.payment_mode,
            CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END AS debit_amt,
            CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END AS credit_amt,
            CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END AS line_effect,
            CASE WHEN t.txn_type = N'STAFF_EXPENSE' THEN t.source_id ELSE NULL END AS staff_expense_id,
            CASE WHEN t.txn_type = N'STAFF_EXPENSE' THEN 1 ELSE 0 END AS can_edit
        FROM dbo.tbl_account_transaction AS t
        WHERE t.account_type = N'STAFF'
          AND t.account_id = @uid
          AND t.status = 1
    ),
    running AS (
        SELECT
            a.*,
            SUM(a.line_effect) OVER (ORDER BY a.txn_date ASC, a.txn_id ASC ROWS UNBOUNDED PRECEDING) AS running_balance
        FROM all_lines AS a
    )
    SELECT
        x.sr,
        x.is_opening,
        x.txn_date,
        x.txn_type,
        x.txn_type_label,
        x.ref_no,
        x.note,
        x.payment_mode,
        x.debit_amt,
        x.credit_amt,
        x.running_balance,
        x.staff_expense_id,
        x.can_edit
    FROM (
        SELECT
            0 AS sort_key,
            0 AS txn_id,
            0 AS sr,
            1 AS is_opening,
            @f AS txn_date,
            N'OPENING' AS txn_type,
            N'Opening balance' AS txn_type_label,
            NULL AS ref_no,
            NULL AS note,
            NULL AS payment_mode,
            CAST(0 AS DECIMAL(18, 2)) AS debit_amt,
            CAST(0 AS DECIMAL(18, 2)) AS credit_amt,
            @opening AS running_balance,
            CAST(NULL AS BIGINT) AS staff_expense_id,
            0 AS can_edit
        UNION ALL
        SELECT
            1 AS sort_key,
            r.txn_id,
            ROW_NUMBER() OVER (ORDER BY r.txn_date ASC, r.txn_id ASC) AS sr,
            0 AS is_opening,
            r.txn_date,
            r.txn_type,
            r.txn_type_label,
            r.ref_no,
            r.note,
            r.payment_mode,
            r.debit_amt,
            r.credit_amt,
            r.running_balance,
            r.staff_expense_id,
            r.can_edit
        FROM running AS r
        WHERE r.txn_date BETWEEN @f AND @t
    ) AS x
    ORDER BY x.sort_key ASC, x.txn_date ASC, x.txn_id ASC;
END
GO

IF OBJECT_ID('dbo.sel_staff_expense_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_staff_expense_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_staff_expense_by_id_sp
    @staff_expense_id NVARCHAR(50),
    @user_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @eid BIGINT = CAST(@staff_expense_id AS BIGINT);
    DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);

    SELECT
        staff_expense_id,
        user_id,
        expense_date,
        ref_no,
        note,
        amount
    FROM dbo.tbl_staff_expense
    WHERE staff_expense_id = @eid
      AND user_id = @uid
      AND status = 1;
END
GO

IF OBJECT_ID('dbo.ins_staff_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_staff_expense_sp;
GO
CREATE PROCEDURE dbo.ins_staff_expense_sp
    @user_id NVARCHAR(50),
    @expense_date NVARCHAR(50),
    @ref_no NVARCHAR(50) = NULL,
    @note NVARCHAR(500) = NULL,
    @amount NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
        DECLARE @d DATE = CAST(@expense_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@amount AS DECIMAL(18, 2));
        DECLARE @byUid INT = CAST(@by AS INT);
        DECLARE @ref NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@ref_no)), N'');

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @uid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'User not found.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO dbo.tbl_staff_expense (
            user_id, expense_date, ref_no, note, amount,
            status, create_by, create_date
        )
        VALUES (
            @uid, @d, @ref, NULLIF(LTRIM(RTRIM(@note)), N''), @amt,
            1, @byUid, dbo.get_date()
        );

        DECLARE @eid BIGINT = SCOPE_IDENTITY();

        INSERT INTO dbo.tbl_account_transaction (
            txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
            ref_no, note, payment_mode, source_type, source_id,
            status, create_by, create_date
        )
        VALUES (
            @d, N'STAFF_EXPENSE', N'STAFF', @uid, NULL, N'C', @amt,
            @ref, NULLIF(LTRIM(RTRIM(@note)), N''), NULL, N'STAFF_EXPENSE', @eid,
            1, @byUid, dbo.get_date()
        );

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Saved.' AS Message, @eid AS staff_expense_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.upd_staff_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_staff_expense_sp;
GO
CREATE PROCEDURE dbo.upd_staff_expense_sp
    @staff_expense_id NVARCHAR(50),
    @user_id NVARCHAR(50),
    @expense_date NVARCHAR(50),
    @ref_no NVARCHAR(50) = NULL,
    @note NVARCHAR(500) = NULL,
    @amount NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @eid BIGINT = CAST(@staff_expense_id AS BIGINT);
        DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
        DECLARE @d DATE = CAST(@expense_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@amount AS DECIMAL(18, 2));
        DECLARE @byUid INT = CAST(@by AS INT);
        DECLARE @ref NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@ref_no)), N'');

        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_staff_expense
            WHERE staff_expense_id = @eid AND user_id = @uid AND status = 1
        )
        BEGIN
            SELECT 'False' AS Success, N'Expense not found.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_staff_expense
        SET
            expense_date = @d,
            ref_no = @ref,
            note = NULLIF(LTRIM(RTRIM(@note)), N''),
            amount = @amt,
            modify_by = @byUid,
            modify_date = dbo.get_date()
        WHERE staff_expense_id = @eid AND user_id = @uid AND status = 1;

        UPDATE dbo.tbl_account_transaction
        SET
            txn_date = @d,
            amount = @amt,
            ref_no = @ref,
            note = NULLIF(LTRIM(RTRIM(@note)), N''),
            modify_by = @byUid,
            modify_date = dbo.get_date()
        WHERE source_type = N'STAFF_EXPENSE'
          AND source_id = @eid
          AND status = 1;

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_staff_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_staff_expense_sp;
GO
CREATE PROCEDURE dbo.dlt_staff_expense_sp
    @staff_expense_id NVARCHAR(50),
    @user_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @eid BIGINT = CAST(@staff_expense_id AS BIGINT);
        DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
        DECLARE @byUid INT = CAST(@by AS INT);

        IF NOT EXISTS (
            SELECT 1 FROM dbo.tbl_staff_expense
            WHERE staff_expense_id = @eid AND user_id = @uid AND status = 1
        )
        BEGIN
            SELECT 'False' AS Success, N'Expense not found.' AS Message;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE dbo.tbl_staff_expense
        SET status = 0, delete_by = @byUid, delete_date = dbo.get_date()
        WHERE staff_expense_id = @eid AND user_id = @uid;

        UPDATE dbo.tbl_account_transaction
        SET status = 0, delete_by = @byUid, delete_date = dbo.get_date()
        WHERE source_type = N'STAFF_EXPENSE' AND source_id = @eid AND status = 1;

        COMMIT TRANSACTION;
        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== EXPENSE TRACKER ==================== */

IF OBJECT_ID('dbo.dis_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_expense_sp;
GO
CREATE PROCEDURE dbo.dis_expense_sp
    @from_date NVARCHAR(50),
    @to_date NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @f DATE = CAST(@from_date AS DATE);
    DECLARE @t DATE = CAST(@to_date AS DATE);

    SELECT
        ROW_NUMBER() OVER (ORDER BY e.expense_date DESC, e.expense_id DESC) AS sr,
        e.expense_id,
        e.expense_date,
        e.user_id,
        ISNULL(um.full_name, N'—') AS user_name,
        e.amount,
        e.payment_mode,
        e.note
    FROM dbo.tbl_expense AS e
    LEFT JOIN dbo.tbl_user_master AS um ON um.user_id = e.user_id AND um.status = 1
    WHERE e.status = 1
      AND e.expense_date BETWEEN @f AND @t
    ORDER BY e.expense_date DESC, e.expense_id DESC;
END
GO

IF OBJECT_ID('dbo.ins_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_expense_sp;
GO
CREATE PROCEDURE dbo.ins_expense_sp
    @user_id NVARCHAR(50),
    @expense_date NVARCHAR(50),
    @amount NVARCHAR(50),
    @note NVARCHAR(500),
    @payment_mode NVARCHAR(20),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
        DECLARE @d DATE = CAST(@expense_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@amount AS DECIMAL(18, 2));
        DECLARE @pm NVARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@payment_mode, N''))));
        DECLARE @byUid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @uid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'User not found or inactive.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        IF @pm NOT IN (N'CASH', N'ONLINE')
        BEGIN
            SELECT 'False' AS Success, N'Payment mode must be Cash or Online.' AS Message;
            RETURN;
        END

        DECLARE @pmOut NVARCHAR(20) = CASE WHEN @pm = N'CASH' THEN N'Cash' ELSE N'Online' END;

        INSERT INTO dbo.tbl_expense (user_id, expense_date, amount, note, payment_mode, status, create_by, create_date)
        VALUES (@uid, @d, @amt, NULLIF(LTRIM(RTRIM(@note)), N''), @pmOut, 1, @byUid, dbo.get_date());

        SELECT 'True' AS Success, N'Saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS expense_id;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.sel_expense_by_id_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sel_expense_by_id_sp;
GO
CREATE PROCEDURE dbo.sel_expense_by_id_sp
    @expense_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @eid BIGINT = CAST(@expense_id AS BIGINT);
    SELECT expense_id, user_id, expense_date, amount, note, payment_mode
    FROM dbo.tbl_expense
    WHERE expense_id = @eid AND status = 1;
END
GO

IF OBJECT_ID('dbo.upd_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.upd_expense_sp;
GO
CREATE PROCEDURE dbo.upd_expense_sp
    @expense_id NVARCHAR(50),
    @user_id NVARCHAR(50),
    @expense_date NVARCHAR(50),
    @amount NVARCHAR(50),
    @note NVARCHAR(500),
    @payment_mode NVARCHAR(20),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @eid BIGINT = CAST(@expense_id AS BIGINT);
        DECLARE @uid BIGINT = CAST(@user_id AS BIGINT);
        DECLARE @d DATE = CAST(@expense_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@amount AS DECIMAL(18, 2));
        DECLARE @pm NVARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@payment_mode, N''))));
        DECLARE @byUid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_expense WHERE expense_id = @eid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Expense not found.' AS Message;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @uid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'User not found or inactive.' AS Message;
            RETURN;
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        IF @pm NOT IN (N'CASH', N'ONLINE')
        BEGIN
            SELECT 'False' AS Success, N'Payment mode must be Cash or Online.' AS Message;
            RETURN;
        END

        DECLARE @pmOut NVARCHAR(20) = CASE WHEN @pm = N'CASH' THEN N'Cash' ELSE N'Online' END;

        UPDATE dbo.tbl_expense
        SET user_id = @uid, expense_date = @d, amount = @amt,
            note = NULLIF(LTRIM(RTRIM(@note)), N''), payment_mode = @pmOut,
            modify_by = @byUid, modify_date = dbo.get_date()
        WHERE expense_id = @eid AND status = 1;

        SELECT 'True' AS Success, N'Updated.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

IF OBJECT_ID('dbo.dlt_expense_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dlt_expense_sp;
GO
CREATE PROCEDURE dbo.dlt_expense_sp
    @expense_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @eid BIGINT = CAST(@expense_id AS BIGINT);
        DECLARE @byUid INT = CAST(@by AS INT);

        IF NOT EXISTS (SELECT 1 FROM dbo.tbl_expense WHERE expense_id = @eid AND status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Expense not found.' AS Message;
            RETURN;
        END
		
        UPDATE dbo.tbl_expense
        SET status = 0, delete_by = @byUid, delete_date = dbo.get_date()
        WHERE expense_id = @eid;

        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* ==================== ACCOUNT OUTSTANDING ==================== */

IF OBJECT_ID('dbo.dis_account_outstanding_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_account_outstanding_sp;
GO
CREATE PROCEDURE dbo.dis_account_outstanding_sp
    @account_type NVARCHAR(20) = NULL,
    @search NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @type NVARCHAR(20) = UPPER(NULLIF(LTRIM(RTRIM(ISNULL(@account_type, N''))), N''));
    DECLARE @q NVARCHAR(100) = NULLIF(LTRIM(RTRIM(ISNULL(@search, N''))), N'');

    IF @type = N'ALL'
        SET @type = NULL;

    ;WITH balances AS (
        SELECT
            N'PARTY' AS account_type,
            N'Party' AS account_type_label,
            t.account_id,
            p.party_name AS account_name,
            SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END) AS debit_total,
            SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END) AS credit_total,
            SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE -t.amount END) AS balance,
            N'Receivable' AS balance_label
        FROM dbo.tbl_account_transaction AS t
        INNER JOIN dbo.tbl_party_master AS p ON p.party_id = t.account_id
        WHERE t.account_type = N'PARTY' AND t.status = 1
        GROUP BY t.account_id, p.party_name

        UNION ALL

        SELECT
            N'JOBWORK',
            N'Jobwork',
            t.account_id,
            jp.party_name,
            SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END),
            SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END),
            SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE -t.amount END),
            N'Payable'
        FROM dbo.tbl_account_transaction AS t
        INNER JOIN dbo.tbl_jobwork_party AS jp ON jp.jobwork_party_id = t.account_id
        WHERE t.account_type = N'JOBWORK' AND t.status = 1
        GROUP BY t.account_id, jp.party_name

        UNION ALL

        SELECT
            N'STAFF',
            N'Staff',
            t.account_id,
            u.full_name,
            SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END),
            SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END),
            SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END),
            N'Payable'
        FROM dbo.tbl_account_transaction AS t
        INNER JOIN dbo.tbl_user_master AS u ON u.user_id = t.account_id
        WHERE t.account_type = N'STAFF' AND t.status = 1
        GROUP BY t.account_id, u.full_name
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY b.account_type, b.account_name) AS sr,
        b.account_type,
        b.account_type_label,
        b.account_id,
        b.account_name,
        b.debit_total,
        b.credit_total,
        b.balance,
        CASE
            WHEN b.account_type = N'STAFF' THEN
                CASE WHEN b.balance >= 0 THEN N'Payable' ELSE N'Receivable' END
            ELSE
                CASE WHEN b.balance >= 0 THEN N'Receivable' ELSE N'Payable' END
        END AS balance_label
    FROM balances AS b
    WHERE (@type IS NULL OR b.account_type = @type)
      AND (@q IS NULL OR b.account_name LIKE N'%' + @q + N'%')
      AND b.balance <> 0
    ORDER BY b.account_type, b.account_name;
END
GO

IF OBJECT_ID('dbo.dis_account_ledger_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.dis_account_ledger_sp;
GO
CREATE PROCEDURE dbo.dis_account_ledger_sp
    @account_type NVARCHAR(20),
    @account_id NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @type NVARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@account_type, N''))));
    DECLARE @aid BIGINT = CAST(@account_id AS BIGINT);
    DECLARE @name NVARCHAR(150);
    DECLARE @typeLabel NVARCHAR(20);
    DECLARE @balLabel NVARCHAR(20);
    DECLARE @periodDebit DECIMAL(18, 2) = 0;
    DECLARE @periodCredit DECIMAL(18, 2) = 0;
    DECLARE @closing DECIMAL(18, 2) = 0;

    IF @type NOT IN (N'PARTY', N'JOBWORK', N'STAFF')
    BEGIN
        SELECT N'False' AS Success, N'account_type must be PARTY, JOBWORK or STAFF.' AS Message;
        RETURN;
    END

    IF @type = N'PARTY'
    BEGIN
        SET @typeLabel = N'Party';
        SELECT @name = p.party_name
        FROM dbo.tbl_party_master AS p
        WHERE p.party_id = @aid AND p.status = 1;
    END
    ELSE IF @type = N'JOBWORK'
    BEGIN
        SET @typeLabel = N'Jobwork';
        SELECT @name = jp.party_name
        FROM dbo.tbl_jobwork_party AS jp
        WHERE jp.jobwork_party_id = @aid AND jp.status = 1;
    END
    ELSE
    BEGIN
        SET @typeLabel = N'Staff';
        SELECT @name = u.full_name
        FROM dbo.tbl_user_master AS u
        WHERE u.user_id = @aid AND u.status = 1;
    END

    IF @name IS NULL
    BEGIN
        SELECT N'False' AS Success, N'Account not found.' AS Message;
        RETURN;
    END

    SELECT
        @periodDebit = ISNULL(SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END), 0),
        @periodCredit = ISNULL(SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END), 0)
    FROM dbo.tbl_account_transaction AS t
    WHERE t.account_type = @type AND t.account_id = @aid AND t.status = 1;

    IF @type = N'PARTY'
        SELECT @closing = ISNULL(SUM(CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE -t.amount END), 0)
        FROM dbo.tbl_account_transaction AS t
        WHERE t.account_type = @type AND t.account_id = @aid AND t.status = 1;
    ELSE
        SELECT @closing = ISNULL(SUM(CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END), 0)
        FROM dbo.tbl_account_transaction AS t
        WHERE t.account_type = @type AND t.account_id = @aid AND t.status = 1;

    IF @type = N'PARTY'
        SET @balLabel = CASE WHEN @closing >= 0 THEN N'Receivable' ELSE N'Payable' END;
    ELSE
        SET @balLabel = CASE WHEN @closing >= 0 THEN N'Payable' ELSE N'Receivable' END;

    SELECT
        N'True' AS Success,
        @type AS account_type,
        @typeLabel AS account_type_label,
        @aid AS account_id,
        @name AS account_name,
        @balLabel AS balance_label,
        @periodDebit AS period_debit,
        @periodCredit AS period_credit,
        @closing AS closing_balance;

    ;WITH lines AS (
        SELECT
            t.txn_id,
            t.txn_date,
            t.txn_type,
            CASE t.txn_type
                WHEN N'PARTY_INVOICE' THEN N'Party invoice'
                WHEN N'PARTY_PAY' THEN N'Party payment'
                WHEN N'PARTY_ADJUST' THEN N'Party due / adjustment'
                WHEN N'JW_INVOICE' THEN N'Jobwork invoice'
                WHEN N'JW_PAY' THEN N'Jobwork payment'
                WHEN N'JW_ADJUST' THEN N'Jobwork due / adjustment'
                WHEN N'STAFF_EXPENSE' THEN N'Staff expense'
                WHEN N'STAFF_PAY' THEN N'Staff payment'
                WHEN N'STAFF_ADJUST' THEN N'Staff due / adjustment'
                WHEN N'OPENING' THEN N'Previous due / opening'
                WHEN N'OWNER_EXPENSE' THEN N'Owner expense'
                ELSE t.txn_type
            END AS txn_type_label,
            t.ref_no,
            t.note,
            CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE 0 END AS debit_amt,
            CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE 0 END AS credit_amt,
            CASE
                WHEN @type = N'PARTY' THEN CASE WHEN t.dr_cr = N'D' THEN t.amount ELSE -t.amount END
                ELSE CASE WHEN t.dr_cr = N'C' THEN t.amount ELSE -t.amount END
            END AS line_effect
        FROM dbo.tbl_account_transaction AS t
        WHERE t.account_type = @type
          AND t.account_id = @aid
          AND t.status = 1
    )
    SELECT
        ROW_NUMBER() OVER (ORDER BY l.txn_date ASC, l.txn_id ASC) AS sr,
        l.txn_date,
        l.txn_type,
        l.txn_type_label,
        l.ref_no,
        l.note,
        l.debit_amt,
        l.credit_amt,
        SUM(l.line_effect) OVER (ORDER BY l.txn_date ASC, l.txn_id ASC ROWS UNBOUNDED PRECEDING) AS running_balance
    FROM lines AS l
    ORDER BY l.txn_date ASC, l.txn_id ASC;
END
GO

IF OBJECT_ID('dbo.ins_ledger_payment_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.ins_ledger_payment_sp;
GO
alter PROCEDURE dbo.ins_ledger_payment_sp
    @account_type NVARCHAR(20),
    @account_id NVARCHAR(50),
    @payment_date NVARCHAR(50),
    @ref_no NVARCHAR(50) = NULL,
    @note NVARCHAR(500) = NULL,
    @amount NVARCHAR(50),
    @payment_mode NVARCHAR(20) = NULL,
    @dr_cr NVARCHAR(1) = NULL,
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @type NVARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@account_type, N''))));
        DECLARE @aid BIGINT = CAST(@account_id AS BIGINT);
        DECLARE @d DATE = CAST(@payment_date AS DATE);
        DECLARE @amt DECIMAL(18, 2) = CAST(@amount AS DECIMAL(18, 2));
        DECLARE @uid INT = CAST(@by AS INT);
        DECLARE @ref NVARCHAR(50) = NULLIF(LTRIM(RTRIM(@ref_no)), N'');
        DECLARE @pm NVARCHAR(20) = UPPER(LTRIM(RTRIM(ISNULL(@payment_mode, N''))));
        DECLARE @drCrIn NVARCHAR(1) = UPPER(LTRIM(RTRIM(ISNULL(@dr_cr, N''))));
        DECLARE @txnType NVARCHAR(30);
        DECLARE @drCr CHAR(1);
        DECLARE @pmOut NVARCHAR(20) = NULL;
        DECLARE @isPayment BIT = 0;

        IF @type NOT IN (N'PARTY', N'JOBWORK', N'STAFF')
        BEGIN
            SELECT 'False' AS Success, N'account_type must be PARTY, JOBWORK or STAFF.' AS Message;
            RETURN;
        END

        IF @type = N'PARTY'
        BEGIN
            SET @drCr = N'C';
            IF @drCrIn IN (N'D', N'C') SET @drCr = @drCrIn;
            SET @txnType = CASE WHEN @drCr = N'D' THEN N'PARTY_ADJUST' ELSE N'PARTY_PAY' END;
            SET @isPayment = CASE WHEN @drCr = N'C' THEN 1 ELSE 0 END;
            IF NOT EXISTS (SELECT 1 FROM dbo.tbl_party_master WHERE party_id = @aid AND status = 1)
            BEGIN
                SELECT 'False' AS Success, N'Party not found.' AS Message;
                RETURN;
            END
        END
        ELSE IF @type = N'JOBWORK'
        BEGIN
            SET @drCr = N'D';
            IF @drCrIn IN (N'D', N'C') SET @drCr = @drCrIn;
            SET @txnType = CASE WHEN @drCr = N'D' THEN N'JW_PAY' ELSE N'JW_ADJUST' END;
            SET @isPayment = CASE WHEN @drCr = N'D' THEN 1 ELSE 0 END;
            IF NOT EXISTS (SELECT 1 FROM dbo.tbl_jobwork_party WHERE jobwork_party_id = @aid AND status = 1)
            BEGIN
                SELECT 'False' AS Success, N'Jobwork party not found.' AS Message;
                RETURN;
            END
        END
        ELSE
        BEGIN
            SET @drCr = N'D';
            IF @drCrIn IN (N'D', N'C') SET @drCr = @drCrIn;
            SET @txnType = CASE WHEN @drCr = N'D' THEN N'STAFF_PAY' ELSE N'STAFF_ADJUST' END;
            SET @isPayment = CASE WHEN @drCr = N'D' THEN 1 ELSE 0 END;
            IF NOT EXISTS (SELECT 1 FROM dbo.tbl_user_master WHERE user_id = @aid AND status = 1)
            BEGIN
                SELECT 'False' AS Success, N'Staff not found.' AS Message;
                RETURN;
            END
        END

        IF @amt <= 0
        BEGIN
            SELECT 'False' AS Success, N'Amount must be greater than zero.' AS Message;
            RETURN;
        END

        IF @isPayment = 1
        BEGIN
            IF @pm NOT IN (N'CASH', N'ONLINE')
            BEGIN
                SELECT 'False' AS Success, N'Payment mode must be Cash or Online.' AS Message;
                RETURN;
            END
            SET @pmOut = CASE WHEN @pm = N'CASH' THEN N'Cash' ELSE N'Online' END;
        END

        INSERT INTO dbo.tbl_account_transaction (
            txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
            ref_no, note, payment_mode, source_type, source_id,
            status, create_by, create_date
        )
        VALUES (
            @d, @txnType, @type, @aid, NULL, @drCr, @amt,
            @ref, NULLIF(LTRIM(RTRIM(@note)), N''), @pmOut, N'MANUAL', NULL,
            1, @uid, dbo.get_date()
        );

        SELECT 'True' AS Success, N'Ledger entry saved.' AS Message, CAST(SCOPE_IDENTITY() AS BIGINT) AS txn_id;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO

/* Backfill tbl_account_transaction for invoices saved before ledger sync existed. */
IF OBJECT_ID('dbo.sync_missing_invoice_account_txn_sp', 'P') IS NOT NULL DROP PROCEDURE dbo.sync_missing_invoice_account_txn_sp;
GO
CREATE PROCEDURE dbo.sync_missing_invoice_account_txn_sp
    @invoice_nos NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @filter TABLE (invoice_no NVARCHAR(50) NOT NULL PRIMARY KEY);
    DECLARE @p NVARCHAR(MAX) = LTRIM(RTRIM(ISNULL(@invoice_nos, N'')));
    DECLARE @seg NVARCHAR(50);

    IF LEN(@p) > 0
    BEGIN
        IF RIGHT(@p, 1) <> N',' SET @p = @p + N',';
        WHILE CHARINDEX(N',', @p) > 0
        BEGIN
            SET @seg = LTRIM(RTRIM(LEFT(@p, CHARINDEX(N',', @p) - 1)));
            SET @p = SUBSTRING(@p, CHARINDEX(N',', @p) + 1, 8000);
            IF LEN(@seg) > 0 AND NOT EXISTS (SELECT 1 FROM @filter WHERE invoice_no = @seg)
                INSERT INTO @filter (invoice_no) VALUES (@seg);
        END
    END

    INSERT INTO dbo.tbl_account_transaction (
        txn_date, txn_type, account_type, account_id, title, dr_cr, amount,
        ref_no, note, payment_mode, source_type, source_id,
        status, create_by, create_date
    )
    SELECT
        CAST(i.invoice_date AS DATE),
        N'PARTY_INVOICE',
        N'PARTY',
        i.party_id,
        NULL,
        N'D',
        i.grand_total,
        i.invoice_no,
        i.remarks,
        NULL,
        N'INVOICE',
        i.invoice_id,
        1,
        COALESCE(i.create_by, 1),
        COALESCE(i.create_date, dbo.get_date())
    FROM dbo.tbl_invoice AS i
    WHERE i.status = 1
      AND NOT EXISTS (
        SELECT 1
        FROM dbo.tbl_account_transaction AS t
        WHERE t.source_type = N'INVOICE'
          AND t.source_id = i.invoice_id
          AND t.status = 1)
      AND (
        NOT EXISTS (SELECT 1 FROM @filter)
        OR EXISTS (SELECT 1 FROM @filter AS f WHERE f.invoice_no = i.invoice_no)
      );

    SELECT
        N'True' AS Success,
        CAST(@@ROWCOUNT AS NVARCHAR(20)) + N' party invoice ledger row(s) created.' AS Message;
END
GO
