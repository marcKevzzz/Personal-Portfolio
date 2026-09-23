-- ============================================================================
-- Migration 014: Convert all inline queries to Stored Procedures
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Adds user auth, password reset, and admin stored procedures.
--              Updates sp_SaveProfile to remove hardcoded demo defaults.
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Check if user email exists
CREATE OR ALTER PROCEDURE dbo.sp_CheckUserEmailExists
    @email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(1) AS EmailCount
    FROM dbo.users_tbl
    WHERE LOWER(email) = LOWER(@email);
END;
GO

-- 2. Get user by email (for authentication and lookup)
CREATE OR ALTER PROCEDURE dbo.sp_GetUserByEmail
    @email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 
        user_id, first_name, last_name, email, password_hash, 
        user_role, is_active, created_at, last_login_at, ISNULL(login_count, 0) AS login_count
    FROM dbo.users_tbl
    WHERE LOWER(email) = LOWER(@email);
END;
GO

-- 3. Get user by ID (for profile settings and user loaders)
CREATE OR ALTER PROCEDURE dbo.sp_GetUserById
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 
        user_id, first_name, last_name, email, password_hash, 
        user_role, is_active, created_at, last_login_at, ISNULL(login_count, 0) AS login_count
    FROM dbo.users_tbl
    WHERE user_id = @user_id;
END;
GO

-- 4. Register new user and initialize empty profile atomically
CREATE OR ALTER PROCEDURE dbo.sp_RegisterUser
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @email NVARCHAR(150),
    @password_hash NVARCHAR(256),
    @user_role NVARCHAR(50) = 'User',
    @is_active BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.users_tbl WHERE LOWER(email) = LOWER(@email))
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT -1 AS user_id;
            RETURN;
        END

        INSERT INTO dbo.users_tbl (
            first_name, last_name, email, password_hash, 
            user_role, is_active, created_at, login_count
        )
        VALUES (
            @first_name, @last_name, LOWER(@email), @password_hash, 
            @user_role, @is_active, GETDATE(), 0
        );

        DECLARE @new_user_id INT = SCOPE_IDENTITY();

        DECLARE @hero_names NVARCHAR(300) = @first_name + ',' + @last_name;
        INSERT INTO dbo.profile_tbl (
            user_id, hero_names, hero_subline, role_title, focus_area, based_in, updated_at
        )
        VALUES (
            @new_user_id, @hero_names, '', '', '', '', GETDATE()
        );

        COMMIT TRANSACTION;
        SELECT @new_user_id AS user_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 5. Check pending password reset request by email
CREATE OR ALTER PROCEDURE dbo.sp_GetPendingPasswordResetByEmail
    @email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 reset_id, user_id, email, status, created_at
    FROM dbo.password_resets_tbl
    WHERE LOWER(email) = LOWER(@email) AND status = 'pending'
    ORDER BY created_at DESC;
END;
GO

-- 5b. Get latest password reset by email (any status)
CREATE OR ALTER PROCEDURE dbo.sp_GetLatestPasswordResetByEmail
    @email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 reset_id, user_id, email, status, created_at
    FROM dbo.password_resets_tbl
    WHERE LOWER(email) = LOWER(@email)
    ORDER BY reset_id DESC;
END;
GO

-- 6. Request a password reset
CREATE OR ALTER PROCEDURE dbo.sp_RequestPasswordReset
    @email NVARCHAR(150),
    @reason NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @user_id INT = NULL;
    SELECT TOP 1 @user_id = user_id FROM dbo.users_tbl WHERE LOWER(email) = LOWER(@email);

    INSERT INTO dbo.password_resets_tbl (user_id, email, reason, status, created_at)
    VALUES (@user_id, LOWER(@email), @reason, 'pending', GETDATE());

    SELECT SCOPE_IDENTITY() AS reset_id;
END;
GO

-- 7. Get pending password reset requests for admin dashboard
CREATE OR ALTER PROCEDURE dbo.sp_GetPendingPasswordResets
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        r.reset_id, 
        r.user_id, 
        r.email, 
        r.reset_token, 
        r.reason, 
        r.status, 
        r.created_at,
        u.first_name,
        u.last_name,
        u.user_role
    FROM dbo.password_resets_tbl r
    LEFT JOIN dbo.users_tbl u ON r.user_id = u.user_id
    WHERE r.status = 'pending'
    ORDER BY r.created_at DESC;
END;
GO

-- 8. Approve password reset request (removes password for user)
CREATE OR ALTER PROCEDURE dbo.sp_ApprovePasswordReset
    @reset_id INT,
    @reviewed_by INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.password_resets_tbl
    SET status = 'password_removed'
    WHERE reset_id = @reset_id;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 9. Reject password reset request
CREATE OR ALTER PROCEDURE dbo.sp_RejectPasswordReset
    @reset_id INT,
    @reviewed_by INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.password_resets_tbl
    SET status = 'rejected'
    WHERE reset_id = @reset_id;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 10. Complete password reset with new password
CREATE OR ALTER PROCEDURE dbo.sp_CompletePasswordReset
    @email NVARCHAR(150),
    @password_hash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE dbo.users_tbl
        SET password_hash = @password_hash
        WHERE LOWER(email) = LOWER(@email);

        UPDATE dbo.password_resets_tbl
        SET status = 'used'
        WHERE LOWER(email) = LOWER(@email) AND status = 'password_removed';

        COMMIT TRANSACTION;
        SELECT 1 AS Success;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- 11. Admin direct reset user password
CREATE OR ALTER PROCEDURE dbo.sp_AdminResetUserPassword
    @user_id INT,
    @password_hash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.users_tbl
    SET password_hash = @password_hash
    WHERE user_id = @user_id;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 12. Admin update user names and role
CREATE OR ALTER PROCEDURE dbo.sp_AdminUpdateUser
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @user_role NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.users_tbl
    SET first_name = @first_name,
        last_name = @last_name,
        user_role = @user_role
    WHERE user_id = @user_id;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- 13. Batch avatar map for user directory
CREATE OR ALTER PROCEDURE dbo.sp_GetUsersAvatarMap
AS
BEGIN
    SET NOCOUNT ON;
    SELECT user_id, avatar_path
    FROM dbo.profile_tbl
    WHERE avatar_path IS NOT NULL AND avatar_path <> '';
END;
GO

-- 14. Update sp_SaveProfile without legacy demo defaults
CREATE OR ALTER PROCEDURE dbo.sp_SaveProfile
    @user_id INT,
    @hero_subline NVARCHAR(150) = NULL,
    @hero_names NVARCHAR(500) = NULL,
    @role_summary NVARCHAR(MAX) = NULL,
    @role_title NVARCHAR(150) = NULL,
    @focus_area NVARCHAR(150) = NULL,
    @based_in NVARCHAR(150) = NULL,
    @avatar_path NVARCHAR(255) = NULL,
    @location_address NVARCHAR(255) = NULL,
    @birth_date DATE = NULL,
    @experience_years INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.profile_tbl WHERE user_id = @user_id)
    BEGIN
        UPDATE dbo.profile_tbl
        SET hero_subline     = ISNULL(@hero_subline, hero_subline),
            hero_names       = ISNULL(@hero_names, hero_names),
            role_summary     = @role_summary,
            role_title       = @role_title,
            focus_area       = @focus_area,
            based_in         = @based_in,
            avatar_path      = ISNULL(@avatar_path, avatar_path),
            location_address = @location_address,
            birth_date       = @birth_date,
            experience_years = @experience_years,
            updated_at       = GETDATE()
        WHERE user_id = @user_id;

        SELECT profile_id FROM dbo.profile_tbl WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.profile_tbl
        (
            user_id, hero_subline, hero_names, role_summary, role_title,
            focus_area, based_in, avatar_path, location_address, birth_date,
            experience_years, updated_at
        )
        VALUES
        (
            @user_id, 
            ISNULL(@hero_subline, ''), 
            @hero_names, 
            @role_summary, 
            ISNULL(@role_title, ''),
            ISNULL(@focus_area, ''), 
            ISNULL(@based_in, ''), 
            ISNULL(@avatar_path, ''), 
            @location_address, 
            @birth_date,
            @experience_years, 
            GETDATE()
        );

        SELECT SCOPE_IDENTITY() AS profile_id;
    END
END;
GO
