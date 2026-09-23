-- ============================================================================
-- Migration: 015_add_missing_stored_procedures.sql
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Adds final remaining stored procedures to completely eliminate
--              raw SQL queries from the application:
--              - sp_RecordUserLogin
--              - sp_DeleteUser
--              - sp_GetProfileContactInfo
--              - sp_UpdateAdminCredentials
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. sp_RecordUserLogin
CREATE OR ALTER PROCEDURE dbo.sp_RecordUserLogin
    @UserId INT,
    @IpAddress NVARCHAR(100) = NULL,
    @UserAgent NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.users_tbl
    SET last_login_at = GETDATE(),
        login_count = ISNULL(login_count, 0) + 1
    WHERE user_id = @UserId;

    IF OBJECT_ID('dbo.user_logins_tbl', 'U') IS NOT NULL
    BEGIN
        INSERT INTO dbo.user_logins_tbl (user_id, login_time, ip_address, user_agent)
        VALUES (@UserId, GETDATE(), @IpAddress, @UserAgent);
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 2. sp_DeleteUser
CREATE OR ALTER PROCEDURE dbo.sp_DeleteUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.users_tbl WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 3. sp_GetProfileContactInfo
CREATE OR ALTER PROCEDURE dbo.sp_GetProfileContactInfo
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT email, github_url, linkedin_url
    FROM dbo.profile_tbl
    WHERE user_id = @user_id;
END;
GO

-- 4. sp_UpdateAdminCredentials
CREATE OR ALTER PROCEDURE dbo.sp_UpdateAdminCredentials
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @email NVARCHAR(150),
    @password_hash NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @password_hash IS NOT NULL AND LEN(@password_hash) > 0
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            email = @email,
            password_hash = @password_hash
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            email = @email
        WHERE user_id = @user_id;
    END

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO
