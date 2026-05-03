/*
  Tables: Party → Unit → Part → User → Inward (header + lines + outward history)
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

-- One-time on existing DB (if index was created without the filter): drop and recreate
-- so multiple blank challan numbers per party are allowed.
-- DROP INDEX IF EXISTS UX_inward_challan_party_challan_active ON dbo.tbl_inward_challan;
-- CREATE UNIQUE INDEX UX_inward_challan_party_challan_active
--     ON dbo.tbl_inward_challan (party_id, challan_no)
--     WHERE status = 1 AND LEN(LTRIM(RTRIM(challan_no))) > 0;
