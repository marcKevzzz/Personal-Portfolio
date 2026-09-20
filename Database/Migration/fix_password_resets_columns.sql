-- ============================================================================
-- Script: fix_password_resets_columns.sql
-- Description: Quick fix to restore missing columns (reset_token, expires_at, etc.) on password_resets_tbl
-- ============================================================================

IF DB_ID('personal_portfolio_db') IS NOT NULL
    USE [personal_portfolio_db];
ELSE IF DB_ID('db68942') IS NOT NULL
    USE [db68942];
ELSE IF DB_ID('PortfolioDB') IS NOT NULL
    USE [PortfolioDB];
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Create table if it was completely dropped
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[password_resets_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.password_resets_tbl (
        reset_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NULL,
        email NVARCHAR(150) NOT NULL,
        reset_token NVARCHAR(256) NULL,
        reason NVARCHAR(500) NULL,
        status NVARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'password_removed', 'used', 'expired')),
        expires_at DATETIME NULL,
        created_at DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_password_resets_user FOREIGN KEY (user_id) REFERENCES users_tbl(user_id) ON DELETE CASCADE
    );
    PRINT 'Created password_resets_tbl with full schema.';
END
ELSE
BEGIN
    -- 2. Restore missing columns if table exists
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'reset_token')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD reset_token NVARCHAR(256) NULL;
        PRINT 'Added reset_token to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'expires_at')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD expires_at DATETIME NULL;
        PRINT 'Added expires_at to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'reason')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD reason NVARCHAR(500) NULL;
        PRINT 'Added reason to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'status')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD status NVARCHAR(50) NULL CONSTRAINT DF_pw_resets_status DEFAULT 'pending';
        PRINT 'Added status to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'user_id')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD user_id INT NULL;
        PRINT 'Added user_id to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'email')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD email NVARCHAR(150) NOT NULL DEFAULT '';
        PRINT 'Added email to password_resets_tbl.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'created_at')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD created_at DATETIME NULL CONSTRAINT DF_pw_resets_created DEFAULT GETDATE();
        PRINT 'Added created_at to password_resets_tbl.';
    END
END
GO
