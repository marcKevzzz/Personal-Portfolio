-- ============================================================================
-- Migration: 006_add_user_activity_and_login_metrics.sql
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Adds user engagement columns (last_login_at, login_count),
--              creates user_logins_tbl for DAU/MAU audit logging, and creates sp_RecordUserLogin
-- Target Databases: personal_portfolio_db (Local SQLEXPRESS) / db68942 (Remote)
-- Created: 2026-09-20
-- ============================================================================

-- Select active database according to Web.config connection string
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

-- 1. Add engagement tracking columns to users_tbl if not already present
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'last_login_at')
BEGIN
    ALTER TABLE dbo.users_tbl ADD last_login_at DATETIME NULL;
    PRINT 'Added last_login_at column to users_tbl.';
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'login_count')
BEGIN
    ALTER TABLE dbo.users_tbl ADD login_count INT NOT NULL CONSTRAINT DF_users_login_count DEFAULT 0;
    PRINT 'Added login_count column to users_tbl.';
END
GO

-- 2. Create user_logins_tbl for DAU/MAU activity audit logging
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_logins_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.user_logins_tbl (
        login_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        login_time DATETIME NOT NULL DEFAULT GETDATE(),
        ip_address NVARCHAR(100) NULL,
        user_agent NVARCHAR(500) NULL,
        CONSTRAINT FK_user_logins_users FOREIGN KEY (user_id) REFERENCES users_tbl(user_id) ON DELETE CASCADE
    );
    PRINT 'Created user_logins_tbl.';
END
GO

-- 3. Stored Procedure: sp_RecordUserLogin
IF OBJECT_ID('dbo.sp_RecordUserLogin', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RecordUserLogin;
GO
CREATE PROCEDURE dbo.sp_RecordUserLogin
    @UserId INT,
    @IpAddress NVARCHAR(100) = NULL,
    @UserAgent NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Update last login timestamp and increment login count in users_tbl
    UPDATE users_tbl
    SET last_login_at = GETDATE(),
        login_count = ISNULL(login_count, 0) + 1
    WHERE user_id = @UserId;

    -- Insert audit log for historical DAU/MAU analytics
    IF OBJECT_ID('dbo.user_logins_tbl', 'U') IS NOT NULL
    BEGIN
        INSERT INTO user_logins_tbl (user_id, login_time, ip_address, user_agent)
        VALUES (@UserId, GETDATE(), @IpAddress, @UserAgent);
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO
