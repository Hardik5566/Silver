/*
  Stored procedures: Party, Unit, Part, User, Inward/Outward, Invoice.
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

/* ==================== UNIT ==================== */

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

        /* Inward challan */
        (SELECT COUNT(1) FROM dbo.tbl_inward_challan WHERE status = 1) AS total_active_challan,
        (SELECT ISNULL(SUM(CAST(d.qty_inward AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1) AS total_active_item_qty,

        /* Today received */
        (SELECT COUNT(1)
            FROM dbo.tbl_inward_challan
            WHERE status = 1 AND CAST(inward_date AS DATE) = @today) AS today_challan_received,
        (SELECT ISNULL(SUM(CAST(d.qty_inward AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1 AND CAST(h.inward_date AS DATE) = @today) AS today_item_received,

        /* This month received */
        (SELECT COUNT(1)
            FROM dbo.tbl_inward_challan
            WHERE status = 1 AND inward_date >= @monthStart AND inward_date < @monthEnd) AS month_challan_received,
        (SELECT ISNULL(SUM(CAST(d.qty_inward AS BIGINT)), 0)
            FROM dbo.tbl_inward_challan_details d
            INNER JOIN dbo.tbl_inward_challan h ON h.inward_id = d.inward_id
            WHERE d.status = 1 AND h.status = 1 AND h.inward_date >= @monthStart AND h.inward_date < @monthEnd) AS month_item_received;
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
            UPDATE dbo.tbl_inward_challan
            SET challan_no = @cn, inward_date = @d, remarks = @remarks, modify_by = @uid, modify_date = dbo.get_date()
            WHERE inward_id = @id;
            SELECT 'True' AS Success, N'Updated header only (outward exists — lines locked).' AS Message, @id AS inward_id;
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
CREATE PROCEDURE dbo.dlt_inward_challan_sp
    @inward_id NVARCHAR(50),
    @by NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @id BIGINT = CAST(@inward_id AS BIGINT);
        DECLARE @uid INT = CAST(@by AS INT);

        IF EXISTS (
            SELECT 1 FROM dbo.tbl_outward_history AS oh
            INNER JOIN dbo.tbl_inward_challan_details AS d ON d.inward_detail_id = oh.inward_detail_id
            WHERE d.inward_id = @id AND oh.status = 1)
        BEGIN
            SELECT 'False' AS Success, N'Cannot delete — outward history exists. Reverse outward first.' AS Message;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM dbo.tbl_inward_challan_details WHERE inward_id = @id AND status = 1 AND qty_out_done > 0)
        BEGIN
            SELECT 'False' AS Success, N'Cannot delete — qty already issued out on lines.' AS Message;
            RETURN;
        END

        UPDATE dbo.tbl_inward_challan_details
        SET status = 0, delete_by = @uid, delete_date = dbo.get_date()
        WHERE inward_id = @id;

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

        SELECT 'True' AS Success, N'Deleted.' AS Message;
    END TRY
    BEGIN CATCH
        SELECT 'False' AS Success, ERROR_MESSAGE() AS Message;
    END CATCH
END
GO
