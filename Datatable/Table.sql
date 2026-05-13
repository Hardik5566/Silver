/*
  Tables: Party → Jobwork party → Jobwork part (separate from Part master) → Jobwork challan (header + lines + return history)
          → Unit → Part → User → Inward (header + lines + outward history) → Invoice
  Run order: Function.sql → Table.sql → StoreProcedure.sql
*/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE TABLE dbo.tbl_party_master (
    party_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    party_name NVARCHAR(100) NOT NULL,
    contact_person NVARCHAR(100) NULL,
    mobile_no NVARCHAR(15) NULL,
    address NVARCHAR(MAX) NULL,
    gst_no NVARCHAR(20) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE TABLE dbo.tbl_unit (
    unit_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    unit_name NVARCHAR(250) NOT NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE TABLE dbo.tbl_part_master (
    part_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    party_id INT NULL,
    part_name NVARCHAR(250) NOT NULL,
    unit_id INT NULL,
    rate DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    tax_per DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE TABLE dbo.tbl_user_master (
    user_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    full_name NVARCHAR(150) NOT NULL,
    mobile_no NVARCHAR(15) NOT NULL,
    email NVARCHAR(150) NULL,
    password_hash VARBINARY(32) NOT NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE UNIQUE INDEX UX_tbl_user_master_mobile_active
    ON dbo.tbl_user_master (mobile_no) WHERE status = 1;
GO

CREATE UNIQUE INDEX UX_tbl_user_master_email_active
    ON dbo.tbl_user_master (email)
    WHERE status = 1 AND email IS NOT NULL AND LTRIM(RTRIM(email)) <> N'';
GO

/* --------------------- Inward (challan + lines) --------------------- */

CREATE TABLE dbo.tbl_inward_challan (
    inward_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    party_id BIGINT NOT NULL,
    challan_no NVARCHAR(50) NOT NULL,
    inward_date DATETIME NOT NULL,
    remarks NVARCHAR(MAX) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL,
    CONSTRAINT FK_inward_party FOREIGN KEY (party_id) REFERENCES dbo.tbl_party_master (party_id)
);
GO

/* Uniqueness only when challan no is non-blank (multiple blank challans per party allowed). */
CREATE UNIQUE INDEX UX_inward_challan_party_challan_active
    ON dbo.tbl_inward_challan (party_id, challan_no)
    WHERE status = 1 AND LEN(LTRIM(RTRIM(challan_no))) > 0;
GO

CREATE INDEX IX_inward_challan_party_date ON dbo.tbl_inward_challan (party_id, inward_date DESC);
GO

CREATE TABLE dbo.tbl_inward_challan_details (
    inward_detail_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    inward_id BIGINT NOT NULL,
    part_id BIGINT NOT NULL,
    qty_inward INT NOT NULL,
    qty_out_done INT NOT NULL DEFAULT 0,
    rate_at_time DECIMAL(18, 2) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL,
    CONSTRAINT FK_inward_detail_header FOREIGN KEY (inward_id) REFERENCES dbo.tbl_inward_challan (inward_id),
    CONSTRAINT FK_inward_detail_part FOREIGN KEY (part_id) REFERENCES dbo.tbl_part_master (part_id),
    CONSTRAINT CK_inward_detail_qty CHECK (qty_inward > 0 AND qty_out_done >= 0 AND qty_out_done <= qty_inward)
);
GO

CREATE INDEX IX_inward_detail_inward ON dbo.tbl_inward_challan_details (inward_id);
GO

CREATE INDEX IX_inward_detail_part ON dbo.tbl_inward_challan_details (part_id);
GO

/* --------------------- Outward history only (no outward header table) --------------------- */

CREATE TABLE dbo.tbl_outward_history (
    outward_history_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    inward_detail_id BIGINT NOT NULL,
    qty_out INT NOT NULL,
    outward_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    slip_no NVARCHAR(50) NULL,
    remarks NVARCHAR(MAX) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL,
    CONSTRAINT FK_outward_history_inward_line FOREIGN KEY (inward_detail_id) REFERENCES dbo.tbl_inward_challan_details (inward_detail_id),
    CONSTRAINT CK_outward_history_qty CHECK (qty_out > 0)
);
GO

CREATE INDEX IX_outward_history_inward_detail ON dbo.tbl_outward_history (inward_detail_id);
GO

CREATE INDEX IX_outward_history_date ON dbo.tbl_outward_history (outward_date DESC);
GO

/* --------------------- Jobwork (party, send challan, line qty, return history) — tables only, no indexes --------------------- */
/*
  To recreate jobwork tables on an existing database, drop in this order only (child → parent).
  Dropping dbo.tbl_jobwork_challan before dbo.tbl_jobwork_challan_detail causes Msg 3726 (FK).

  1) tbl_jobwork_return_history
  2) tbl_jobwork_challan_detail
  3) tbl_jobwork_challan
  4) tbl_jobwork_part_master
  5) tbl_jobwork_party

  After schema changes to jobwork tables, redeploy jobwork blocks from StoreProcedure.sql (same folder).
*/

CREATE TABLE dbo.tbl_jobwork_party (
    jobwork_party_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    party_name NVARCHAR(100) NOT NULL,
    contact_person NVARCHAR(100) NULL,
    mobile_no NVARCHAR(15) NULL,
    address NVARCHAR(MAX) NULL,
    gst_no NVARCHAR(20) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

/* Jobwork-only item master (not wired to jobwork challan lines until you switch that flow). */

CREATE TABLE dbo.tbl_jobwork_part_master (
    jobwork_part_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    jobwork_party_id BIGINT NOT NULL,
    part_name NVARCHAR(250) NOT NULL,
    unit_id BIGINT NULL,
    rate DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    tax_per DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE TABLE dbo.tbl_jobwork_challan (
    jobwork_challan_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    jobwork_party_id BIGINT NOT NULL,
    challan_no NVARCHAR(50) NOT NULL,
    challan_date DATETIME NOT NULL,
    remarks NVARCHAR(MAX) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL
);
GO

CREATE TABLE dbo.tbl_jobwork_challan_detail (
    jobwork_detail_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    jobwork_challan_id BIGINT NOT NULL,
    jobwork_part_id BIGINT NOT NULL,
    qty_sent INT NOT NULL,
    qty_perfect_done INT NOT NULL DEFAULT 0,
    qty_reject_done INT NOT NULL DEFAULT 0,
    rate_at_time DECIMAL(18, 2) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL,
    CONSTRAINT CK_jobwork_detail_qty CHECK (
        qty_sent > 0
        AND qty_perfect_done >= 0
        AND qty_reject_done >= 0
        AND (qty_perfect_done + qty_reject_done) <= qty_sent
    )
);
GO


CREATE TABLE dbo.tbl_jobwork_return_history (
    jobwork_return_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    jobwork_detail_id BIGINT NOT NULL,
    qty_perfect INT NOT NULL DEFAULT 0,
    qty_reject INT NOT NULL DEFAULT 0,
    return_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    slip_no NVARCHAR(50) NULL,
    remarks NVARCHAR(MAX) NULL,
    status BIT NOT NULL DEFAULT 1,
    create_by INT NULL,
    create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
    modify_by INT NULL,
    modify_date DATETIME NULL,
    delete_by INT NULL,
    delete_date DATETIME NULL,
    CONSTRAINT CK_jobwork_return_qty CHECK (
        qty_perfect >= 0
        AND qty_reject >= 0
        AND (qty_perfect + qty_reject) > 0
    )
);
GO

/* --------------------- Invoice (header + lines, links to inward detail) --------------------- */

IF OBJECT_ID('dbo.tbl_invoice', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_invoice (
        invoice_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        party_id BIGINT NOT NULL,
        invoice_kind NVARCHAR(20) NOT NULL,
        /* GST = tax on lines from part; NON_GST = tax stored as 0 on lines */
        invoice_no NVARCHAR(50) NOT NULL,
        invoice_date DATETIME NOT NULL,
        period_from DATE NULL,
        period_to DATE NULL,
        doc_status NVARCHAR(20) NOT NULL DEFAULT N'Draft',
        /* Draft = editable; Final = block line/header edits via SP */
        sub_total DECIMAL(18, 2) NOT NULL DEFAULT 0,
        tax_total DECIMAL(18, 2) NOT NULL DEFAULT 0,
        grand_total DECIMAL(18, 2) NOT NULL DEFAULT 0,
        remarks NVARCHAR(MAX) NULL,
        status BIT NOT NULL DEFAULT 1,
        create_by INT NULL,
        create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
        modify_by INT NULL,
        modify_date DATETIME NULL,
        delete_by INT NULL,
        delete_date DATETIME NULL,
        CONSTRAINT CK_invoice_kind CHECK (invoice_kind IN (N'GST', N'NON_GST')),
        CONSTRAINT CK_invoice_doc_status CHECK (doc_status IN (N'Draft', N'Final')),
        CONSTRAINT FK_invoice_party FOREIGN KEY (party_id) REFERENCES dbo.tbl_party_master (party_id)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_invoice_no_active' AND object_id = OBJECT_ID(N'dbo.tbl_invoice'))
BEGIN
    CREATE UNIQUE INDEX UX_invoice_no_active
        ON dbo.tbl_invoice (invoice_no)
        WHERE status = 1;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_invoice_party_date' AND object_id = OBJECT_ID(N'dbo.tbl_invoice'))
BEGIN
    CREATE INDEX IX_invoice_party_date ON dbo.tbl_invoice (party_id, invoice_date DESC);
END
GO

IF OBJECT_ID('dbo.tbl_invoice_detail', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_invoice_detail (
        invoice_detail_id BIGINT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        invoice_id BIGINT NOT NULL,
        inward_detail_id BIGINT NOT NULL,
        part_id BIGINT NOT NULL,
        qty_invoiced INT NOT NULL,
        rate DECIMAL(18, 2) NOT NULL,
        tax_per DECIMAL(18, 2) NOT NULL DEFAULT 0,
        taxable_amount DECIMAL(18, 2) NOT NULL,
        tax_amount DECIMAL(18, 2) NOT NULL,
        line_total DECIMAL(18, 2) NOT NULL,
        status BIT NOT NULL DEFAULT 1,
        create_by INT NULL,
        create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
        modify_by INT NULL,
        modify_date DATETIME NULL,
        delete_by INT NULL,
        delete_date DATETIME NULL,
        CONSTRAINT FK_invoice_detail_invoice FOREIGN KEY (invoice_id) REFERENCES dbo.tbl_invoice (invoice_id),
        CONSTRAINT FK_invoice_detail_inward_line FOREIGN KEY (inward_detail_id) REFERENCES dbo.tbl_inward_challan_details (inward_detail_id),
        CONSTRAINT FK_invoice_detail_part FOREIGN KEY (part_id) REFERENCES dbo.tbl_part_master (part_id),
        CONSTRAINT CK_invoice_detail_qty CHECK (qty_invoiced > 0)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_invoice_detail_invoice' AND object_id = OBJECT_ID(N'dbo.tbl_invoice_detail'))
BEGIN
    CREATE INDEX IX_invoice_detail_invoice ON dbo.tbl_invoice_detail (invoice_id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_invoice_detail_inward_line' AND object_id = OBJECT_ID(N'dbo.tbl_invoice_detail'))
BEGIN
    CREATE INDEX IX_invoice_detail_inward_line ON dbo.tbl_invoice_detail (inward_detail_id);
END
GO

-- One-time on existing DB (if index was created without the filter): drop and recreate
-- so multiple blank challan numbers per party are allowed.
-- DROP INDEX IF EXISTS UX_inward_challan_party_challan_active ON dbo.tbl_inward_challan;
-- CREATE UNIQUE INDEX UX_inward_challan_party_challan_active
--     ON dbo.tbl_inward_challan (party_id, challan_no)
--     WHERE status = 1 AND LEN(LTRIM(RTRIM(challan_no))) > 0;

/* Expense tracker (standalone). No FK/CHECK — table only for now. */
IF OBJECT_ID('dbo.tbl_expense', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.tbl_expense (
        expense_id BIGINT IDENTITY(1, 1) NOT NULL,
        user_id BIGINT NOT NULL,
        expense_date DATE NOT NULL,
        amount DECIMAL(18, 2) NOT NULL,
        note NVARCHAR(500) NULL,
        payment_mode NVARCHAR(20) NOT NULL,
        status BIT NOT NULL DEFAULT 1,
        create_by INT NULL,
        create_date DATETIME NOT NULL DEFAULT dbo.get_date(),
        modify_by INT NULL,
        modify_date DATETIME NULL,
        delete_by INT NULL,
        delete_date DATETIME NULL
    );
END
GO
