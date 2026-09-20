-- ============================================================================
-- Migration: 005_portfolio_stored_procedures.sql
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Complete MSSQL stored procedures aligned with Database/Schema/schema.md
--              Includes User Management, Activity Tracking (DAU/MAU/Last Login),
--              Password Resets, Public Showcase Collections, and Dashboard Telemetry
-- Target Databases: personal_portfolio_db (Local SQLEXPRESS) / db68942 (Remote databaseasp.net)
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

-- ============================================================================
-- 0. SCHEMA PREREQUISITES & TRACKING COLUMNS
-- ============================================================================

-- Ensure profile_image column exists on users_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'profile_image')
BEGIN
    ALTER TABLE dbo.users_tbl ADD profile_image NVARCHAR(500) NULL;
END
GO

-- Ensure last_login_at column exists on users_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'last_login_at')
BEGIN
    ALTER TABLE dbo.users_tbl ADD last_login_at DATETIME NULL;
END
GO

-- Ensure login_count column exists on users_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'login_count')
BEGIN
    ALTER TABLE dbo.users_tbl ADD login_count INT NOT NULL CONSTRAINT DF_users_login_count DEFAULT 0;
END
GO

-- Ensure user_logins_tbl exists for DAU/MAU activity audit logging
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
END
GO

-- Ensure password_resets_tbl exists and has all required schema columns (self-healing)
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
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'reset_token')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD reset_token NVARCHAR(256) NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'expires_at')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD expires_at DATETIME NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'reason')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD reason NVARCHAR(500) NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'status')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD status NVARCHAR(50) NULL CONSTRAINT DF_pw_resets_status DEFAULT 'pending';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'user_id')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD user_id INT NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'email')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD email NVARCHAR(150) NOT NULL DEFAULT '';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.password_resets_tbl') AND name = 'created_at')
    BEGIN
        ALTER TABLE dbo.password_resets_tbl ADD created_at DATETIME NULL CONSTRAINT DF_pw_resets_created DEFAULT GETDATE();
    END
-- Clean up any legacy â€” character encoding artifacts across all portfolio tables
IF OBJECT_ID('dbo.experiences_tbl', 'U') IS NOT NULL
BEGIN
    UPDATE experiences_tbl 
    SET period_range = REPLACE(period_range, 'â€”', '—'),
        description_text = REPLACE(description_text, 'â€”', '—'),
        role_title = REPLACE(role_title, 'â€”', '—'),
        company_name = REPLACE(company_name, 'â€”', '—')
    WHERE period_range LIKE '%â€”%' OR description_text LIKE '%â€”%' OR role_title LIKE '%â€”%' OR company_name LIKE '%â€”%';
END
GO

IF OBJECT_ID('dbo.educations_tbl', 'U') IS NOT NULL
BEGIN
    UPDATE educations_tbl 
    SET year_period = REPLACE(year_period, 'â€”', '—'),
        title = REPLACE(title, 'â€”', '—'),
        subtitle = REPLACE(subtitle, 'â€”', '—'),
        institution_name = REPLACE(institution_name, 'â€”', '—')
    WHERE year_period LIKE '%â€”%' OR title LIKE '%â€”%' OR subtitle LIKE '%â€”%' OR institution_name LIKE '%â€”%';
END
GO

IF OBJECT_ID('dbo.profile_tbl', 'U') IS NOT NULL
BEGIN
    UPDATE profile_tbl 
    SET role_summary = REPLACE(role_summary, 'â€”', '—'),
        hero_names = REPLACE(hero_names, 'â€”', '—'),
        hero_subline = REPLACE(hero_subline, 'â€”', '—')
    WHERE role_summary LIKE '%â€”%' OR hero_names LIKE '%â€”%' OR hero_subline LIKE '%â€”%';
END
GO

IF OBJECT_ID('dbo.awards_tbl', 'U') IS NOT NULL
BEGIN
    UPDATE awards_tbl 
    SET award_year = REPLACE(award_year, 'â€”', '—'),
        title = REPLACE(title, 'â€”', '—'),
        subtitle = REPLACE(subtitle, 'â€”', '—'),
        organization_name = REPLACE(organization_name, 'â€”', '—')
    WHERE award_year LIKE '%â€”%' OR title LIKE '%â€”%' OR subtitle LIKE '%â€”%' OR organization_name LIKE '%â€”%';
END
GO

IF OBJECT_ID('dbo.projects_tbl', 'U') IS NOT NULL
BEGIN
    UPDATE projects_tbl 
    SET title = REPLACE(title, 'â€”', '—'),
        tags = REPLACE(tags, 'â€”', '—')
    WHERE title LIKE '%â€”%' OR tags LIKE '%â€”%';
END
GO



-- ============================================================================
-- 1. USERS & AUTHENTICATION STORED PROCEDURES (users_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetAllUsers', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAllUsers;
GO
CREATE PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;
    SELECT user_id, first_name, last_name, email, password_hash, user_role, is_active, 
           profile_image, last_login_at, ISNULL(login_count, 0) AS login_count, created_at
    FROM users_tbl
    ORDER BY created_at DESC;
END;
GO

IF OBJECT_ID('dbo.sp_GetUserByEmail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetUserByEmail;
GO
CREATE PROCEDURE dbo.sp_GetUserByEmail
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 user_id, first_name, last_name, email, password_hash, user_role, is_active, 
                 profile_image, last_login_at, ISNULL(login_count, 0) AS login_count, created_at
    FROM users_tbl
    WHERE LOWER(email) = LOWER(@Email);
END;
GO

IF OBJECT_ID('dbo.sp_GetUserById', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetUserById;
GO
CREATE PROCEDURE dbo.sp_GetUserById
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 user_id, first_name, last_name, email, password_hash, user_role, is_active, 
                 profile_image, last_login_at, ISNULL(login_count, 0) AS login_count, created_at
    FROM users_tbl
    WHERE user_id = @UserId;
END;
GO

IF OBJECT_ID('dbo.sp_CreateUser', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CreateUser;
GO
CREATE PROCEDURE dbo.sp_CreateUser
    @FirstName NVARCHAR(150),
    @LastName NVARCHAR(150),
    @Email NVARCHAR(150),
    @PasswordHash NVARCHAR(256),
    @UserRole NVARCHAR(50) = 'User',
    @IsActive BIT = 1,
    @ProfileImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM users_tbl WHERE LOWER(email) = LOWER(@Email))
    BEGIN
        SELECT -1 AS UserId; -- Email already registered
        RETURN;
    END

    INSERT INTO users_tbl (first_name, last_name, email, password_hash, user_role, is_active, profile_image, login_count, created_at)
    VALUES (@FirstName, @LastName, @Email, @PasswordHash, @UserRole, @IsActive, @ProfileImage, 0, GETDATE());

    SELECT SCOPE_IDENTITY() AS UserId;
END;
GO

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

    -- Update last login timestamp and increment login count
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

IF OBJECT_ID('dbo.sp_UpdateUserProfile', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateUserProfile;
GO
CREATE PROCEDURE dbo.sp_UpdateUserProfile
    @UserId INT,
    @FirstName NVARCHAR(150),
    @LastName NVARCHAR(150),
    @Email NVARCHAR(150) = NULL,
    @ProfileImage NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE users_tbl
    SET first_name = @FirstName,
        last_name = @LastName,
        email = ISNULL(@Email, email),
        profile_image = ISNULL(@ProfileImage, profile_image)
    WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_UpdateUserPassword', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateUserPassword;
GO
CREATE PROCEDURE dbo.sp_UpdateUserPassword
    @UserId INT,
    @PasswordHash NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE users_tbl
    SET password_hash = @PasswordHash
    WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_UpdateUserStatus', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateUserStatus;
GO
CREATE PROCEDURE dbo.sp_UpdateUserStatus
    @UserId INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE users_tbl
    SET is_active = @IsActive
    WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_UpdateUserRole', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateUserRole;
GO
CREATE PROCEDURE dbo.sp_UpdateUserRole
    @UserId INT,
    @UserRole NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE users_tbl
    SET user_role = @UserRole
    WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_DeleteUser', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteUser;
GO
CREATE PROCEDURE dbo.sp_DeleteUser
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Delete foreign key dependencies
    DELETE FROM password_resets_tbl WHERE user_id = @UserId;
    DELETE FROM user_logins_tbl WHERE user_id = @UserId;
    DELETE FROM users_tbl WHERE user_id = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 2. PASSWORD RESETS STORED PROCEDURES (password_resets_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetPasswordResets', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetPasswordResets;
GO
CREATE PROCEDURE dbo.sp_GetPasswordResets
    @StatusFilter NVARCHAR(50) = 'ALL'
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.reset_id, r.user_id, r.email, r.reset_token, r.reason, r.status, r.expires_at, r.created_at,
           u.first_name, u.last_name, u.user_role, u.is_active, u.profile_image
    FROM password_resets_tbl r
    LEFT JOIN users_tbl u ON r.user_id = u.user_id
    WHERE (@StatusFilter = 'ALL' OR r.status = @StatusFilter)
    ORDER BY r.created_at DESC;
END;
GO

IF OBJECT_ID('dbo.sp_RequestPasswordReset', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RequestPasswordReset;
GO
CREATE PROCEDURE dbo.sp_RequestPasswordReset
    @Email NVARCHAR(150),
    @Reason NVARCHAR(500) = NULL,
    @ResetToken NVARCHAR(256) = NULL,
    @ExpiresAt DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT;
    SELECT TOP 1 @UserId = user_id FROM users_tbl WHERE LOWER(email) = LOWER(@Email);

    -- Check if a pending reset request already exists for this email
    IF EXISTS (SELECT 1 FROM password_resets_tbl WHERE LOWER(email) = LOWER(@Email) AND status = 'pending')
    BEGIN
        SELECT 0 AS ResetId; -- Already requested
        RETURN;
    END

    INSERT INTO password_resets_tbl (user_id, email, reset_token, reason, status, expires_at, created_at)
    VALUES (@UserId, @Email, @ResetToken, @Reason, 'pending', @ExpiresAt, GETDATE());

    SELECT SCOPE_IDENTITY() AS ResetId;
END;
GO

IF OBJECT_ID('dbo.sp_ApprovePasswordReset', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ApprovePasswordReset;
GO
CREATE PROCEDURE dbo.sp_ApprovePasswordReset
    @ResetId INT,
    @Status NVARCHAR(50) = 'password_removed'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE password_resets_tbl
    SET status = @Status
    WHERE reset_id = @ResetId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_RejectPasswordReset', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RejectPasswordReset;
GO
CREATE PROCEDURE dbo.sp_RejectPasswordReset
    @ResetId INT,
    @Status NVARCHAR(50) = 'expired'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE password_resets_tbl
    SET status = @Status
    WHERE reset_id = @ResetId;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

IF OBJECT_ID('dbo.sp_GetActivePasswordResetByEmail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetActivePasswordResetByEmail;
GO
CREATE PROCEDURE dbo.sp_GetActivePasswordResetByEmail
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1 reset_id, user_id, email, reset_token, reason, status, expires_at, created_at
    FROM password_resets_tbl
    WHERE LOWER(email) = LOWER(@Email) AND status IN ('pending', 'password_removed')
    ORDER BY created_at DESC;
END;
GO

-- ============================================================================
-- 3. PUBLIC PROFILE & HERO STORED PROCEDURES (profile_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetProfile', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetProfile;
GO
CREATE PROCEDURE dbo.sp_GetProfile
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 *
    FROM profile_tbl
    ORDER BY profile_id DESC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveProfile', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveProfile;
GO
CREATE PROCEDURE dbo.sp_SaveProfile
    @FirstName NVARCHAR(150),
    @LastName NVARCHAR(150),
    @HeroSubline NVARCHAR(150) = 'buildsinterfaces',
    @HeroNames NVARCHAR(500) = 'Kevs,Marc Kevin,Software Engineer',
    @RoleSummary NVARCHAR(MAX) = NULL,
    @RoleTitle NVARCHAR(150) = 'Web Developer',
    @FocusArea NVARCHAR(150) = 'Interfaces & Data Systems',
    @BasedIn NVARCHAR(150) = 'Quezon City',
    @AvatarPath NVARCHAR(255) = 'Assets/Images/pixelart_portrait.png',
    @LocationAddress NVARCHAR(255) = 'B2 L6 Emerald St. Novaliches Proper, Q.C.',
    @Age INT = 19,
    @ExperienceYears INT = 3,
    @Email NVARCHAR(150) = 'delmundo.marckevin.ferolino@gmail.com',
    @GithubUrl NVARCHAR(255) = 'https://github.com/marcKevzzz',
    @LinkedinUrl NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM profile_tbl)
    BEGIN
        DECLARE @TargetId INT;
        SELECT TOP 1 @TargetId = profile_id FROM profile_tbl ORDER BY profile_id DESC;

        UPDATE profile_tbl
        SET first_name = @FirstName,
            last_name = @LastName,
            hero_subline = @HeroSubline,
            hero_names = @HeroNames,
            role_summary = @RoleSummary,
            role_title = @RoleTitle,
            focus_area = @FocusArea,
            based_in = @BasedIn,
            avatar_path = @AvatarPath,
            location_address = @LocationAddress,
            age = @Age,
            experience_years = @ExperienceYears,
            email = @Email,
            github_url = @GithubUrl,
            linkedin_url = @LinkedinUrl,
            updated_at = GETDATE()
        WHERE profile_id = @TargetId;

        SELECT @TargetId AS ProfileId;
    END
    ELSE
    BEGIN
        INSERT INTO profile_tbl (
            first_name, last_name, hero_subline, hero_names, role_summary,
            role_title, focus_area, based_in, avatar_path, location_address,
            age, experience_years, email, github_url, linkedin_url, updated_at
        )
        VALUES (
            @FirstName, @LastName, @HeroSubline, @HeroNames, @RoleSummary,
            @RoleTitle, @FocusArea, @BasedIn, @AvatarPath, @LocationAddress,
            @Age, @ExperienceYears, @Email, @GithubUrl, @LinkedinUrl, GETDATE()
        );

        SELECT SCOPE_IDENTITY() AS ProfileId;
    END
END;
GO

-- ============================================================================
-- 4. TECH STACKS STORED PROCEDURES (tech_stacks_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetTechStacks', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetTechStacks;
GO
CREATE PROCEDURE dbo.sp_GetTechStacks
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT tech_id, group_name, label, icon_path, sort_order, is_active
    FROM tech_stacks_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY group_name, sort_order, tech_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveTechStack', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveTechStack;
GO
CREATE PROCEDURE dbo.sp_SaveTechStack
    @TechId INT = 0,
    @GroupName NVARCHAR(100),
    @Label NVARCHAR(100),
    @IconPath NVARCHAR(255),
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @TechId > 0 AND EXISTS (SELECT 1 FROM tech_stacks_tbl WHERE tech_id = @TechId)
    BEGIN
        UPDATE tech_stacks_tbl
        SET group_name = @GroupName,
            label = @Label,
            icon_path = @IconPath,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE tech_id = @TechId;

        SELECT @TechId AS TechId;
    END
    ELSE
    BEGIN
        INSERT INTO tech_stacks_tbl (group_name, label, icon_path, sort_order, is_active)
        VALUES (@GroupName, @Label, @IconPath, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS TechId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteTechStack', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteTechStack;
GO
CREATE PROCEDURE dbo.sp_DeleteTechStack
    @TechId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM tech_stacks_tbl WHERE tech_id = @TechId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 5. SKILLS STORED PROCEDURES (skills_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetSkills', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetSkills;
GO
CREATE PROCEDURE dbo.sp_GetSkills
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT skill_id, skill_name, proficiency_val, sort_order, is_active
    FROM skills_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, skill_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveSkill', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveSkill;
GO
CREATE PROCEDURE dbo.sp_SaveSkill
    @SkillId INT = 0,
    @SkillName NVARCHAR(150),
    @ProficiencyVal INT = 80,
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    -- Ensure proficiency is between 0 and 100
    IF @ProficiencyVal < 0 SET @ProficiencyVal = 0;
    IF @ProficiencyVal > 100 SET @ProficiencyVal = 100;

    IF @SkillId > 0 AND EXISTS (SELECT 1 FROM skills_tbl WHERE skill_id = @SkillId)
    BEGIN
        UPDATE skills_tbl
        SET skill_name = @SkillName,
            proficiency_val = @ProficiencyVal,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE skill_id = @SkillId;

        SELECT @SkillId AS SkillId;
    END
    ELSE
    BEGIN
        INSERT INTO skills_tbl (skill_name, proficiency_val, sort_order, is_active)
        VALUES (@SkillName, @ProficiencyVal, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS SkillId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteSkill', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteSkill;
GO
CREATE PROCEDURE dbo.sp_DeleteSkill
    @SkillId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM skills_tbl WHERE skill_id = @SkillId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 6. EXPERIENCES STORED PROCEDURES (experiences_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetExperiences', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetExperiences;
GO
CREATE PROCEDURE dbo.sp_GetExperiences
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT exp_id, role_title, company_name, period_range, description_text, tags, sort_order, is_active
    FROM experiences_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, exp_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveExperience', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveExperience;
GO
CREATE PROCEDURE dbo.sp_SaveExperience
    @ExpId INT = 0,
    @RoleTitle NVARCHAR(150),
    @CompanyName NVARCHAR(150),
    @PeriodRange NVARCHAR(100),
    @DescriptionText NVARCHAR(MAX) = NULL,
    @Tags NVARCHAR(255) = NULL,
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @ExpId > 0 AND EXISTS (SELECT 1 FROM experiences_tbl WHERE exp_id = @ExpId)
    BEGIN
        UPDATE experiences_tbl
        SET role_title = @RoleTitle,
            company_name = @CompanyName,
            period_range = @PeriodRange,
            description_text = @DescriptionText,
            tags = @Tags,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE exp_id = @ExpId;

        SELECT @ExpId AS ExpId;
    END
    ELSE
    BEGIN
        INSERT INTO experiences_tbl (role_title, company_name, period_range, description_text, tags, sort_order, is_active)
        VALUES (@RoleTitle, @CompanyName, @PeriodRange, @DescriptionText, @Tags, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS ExpId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteExperience', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteExperience;
GO
CREATE PROCEDURE dbo.sp_DeleteExperience
    @ExpId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM experiences_tbl WHERE exp_id = @ExpId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 7. PROJECTS STORED PROCEDURES (projects_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetProjects', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetProjects;
GO
CREATE PROCEDURE dbo.sp_GetProjects
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT project_id, title, image_path, project_url, tags, sort_order, is_active
    FROM projects_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, project_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveProject', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveProject;
GO
CREATE PROCEDURE dbo.sp_SaveProject
    @ProjectId INT = 0,
    @Title NVARCHAR(150),
    @ImagePath NVARCHAR(255),
    @ProjectUrl NVARCHAR(255) = NULL,
    @Tags NVARCHAR(255) = NULL,
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @ProjectId > 0 AND EXISTS (SELECT 1 FROM projects_tbl WHERE project_id = @ProjectId)
    BEGIN
        UPDATE projects_tbl
        SET title = @Title,
            image_path = @ImagePath,
            project_url = @ProjectUrl,
            tags = @Tags,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE project_id = @ProjectId;

        SELECT @ProjectId AS ProjectId;
    END
    ELSE
    BEGIN
        INSERT INTO projects_tbl (title, image_path, project_url, tags, sort_order, is_active)
        VALUES (@Title, @ImagePath, @ProjectUrl, @Tags, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS ProjectId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteProject', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteProject;
GO
CREATE PROCEDURE dbo.sp_DeleteProject
    @ProjectId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM projects_tbl WHERE project_id = @ProjectId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 8. EDUCATIONS STORED PROCEDURES (educations_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetEducations', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetEducations;
GO
CREATE PROCEDURE dbo.sp_GetEducations
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT edu_id, year_period, title, subtitle, institution_name, sort_order, is_active
    FROM educations_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, edu_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveEducation', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveEducation;
GO
CREATE PROCEDURE dbo.sp_SaveEducation
    @EduId INT = 0,
    @YearPeriod NVARCHAR(100),
    @Title NVARCHAR(150),
    @Subtitle NVARCHAR(150),
    @InstitutionName NVARCHAR(200),
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @EduId > 0 AND EXISTS (SELECT 1 FROM educations_tbl WHERE edu_id = @EduId)
    BEGIN
        UPDATE educations_tbl
        SET year_period = @YearPeriod,
            title = @Title,
            subtitle = @Subtitle,
            institution_name = @InstitutionName,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE edu_id = @EduId;

        SELECT @EduId AS EduId;
    END
    ELSE
    BEGIN
        INSERT INTO educations_tbl (year_period, title, subtitle, institution_name, sort_order, is_active)
        VALUES (@YearPeriod, @Title, @Subtitle, @InstitutionName, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS EduId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteEducation', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteEducation;
GO
CREATE PROCEDURE dbo.sp_DeleteEducation
    @EduId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM educations_tbl WHERE edu_id = @EduId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 9. AWARDS STORED PROCEDURES (awards_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetAwards', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetAwards;
GO
CREATE PROCEDURE dbo.sp_GetAwards
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT award_id, award_year, title, subtitle, organization_name, sort_order, is_active
    FROM awards_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, award_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveAward', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveAward;
GO
CREATE PROCEDURE dbo.sp_SaveAward
    @AwardId INT = 0,
    @AwardYear NVARCHAR(50),
    @Title NVARCHAR(150),
    @Subtitle NVARCHAR(150),
    @OrganizationName NVARCHAR(200),
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @AwardId > 0 AND EXISTS (SELECT 1 FROM awards_tbl WHERE award_id = @AwardId)
    BEGIN
        UPDATE awards_tbl
        SET award_year = @AwardYear,
            title = @Title,
            subtitle = @Subtitle,
            organization_name = @OrganizationName,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE award_id = @AwardId;

        SELECT @AwardId AS AwardId;
    END
    ELSE
    BEGIN
        INSERT INTO awards_tbl (award_year, title, subtitle, organization_name, sort_order, is_active)
        VALUES (@AwardYear, @Title, @Subtitle, @OrganizationName, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS AwardId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteAward', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteAward;
GO
CREATE PROCEDURE dbo.sp_DeleteAward
    @AwardId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM awards_tbl WHERE award_id = @AwardId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 10. HOBBIES STORED PROCEDURES (hobbies_tbl)
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetHobbies', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetHobbies;
GO
CREATE PROCEDURE dbo.sp_GetHobbies
    @ActiveOnly BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT hobby_id, hobby_name, sort_order, is_active
    FROM hobbies_tbl
    WHERE (@ActiveOnly = 0 OR is_active = 1 OR is_active IS NULL)
    ORDER BY sort_order, hobby_id ASC;
END;
GO

IF OBJECT_ID('dbo.sp_SaveHobby', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_SaveHobby;
GO
CREATE PROCEDURE dbo.sp_SaveHobby
    @HobbyId INT = 0,
    @HobbyName NVARCHAR(150),
    @SortOrder INT = 0,
    @IsActive BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @HobbyId > 0 AND EXISTS (SELECT 1 FROM hobbies_tbl WHERE hobby_id = @HobbyId)
    BEGIN
        UPDATE hobbies_tbl
        SET hobby_name = @HobbyName,
            sort_order = @SortOrder,
            is_active = @IsActive
        WHERE hobby_id = @HobbyId;

        SELECT @HobbyId AS HobbyId;
    END
    ELSE
    BEGIN
        INSERT INTO hobbies_tbl (hobby_name, sort_order, is_active)
        VALUES (@HobbyName, @SortOrder, @IsActive);

        SELECT SCOPE_IDENTITY() AS HobbyId;
    END
END;
GO

IF OBJECT_ID('dbo.sp_DeleteHobby', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_DeleteHobby;
GO
CREATE PROCEDURE dbo.sp_DeleteHobby
    @HobbyId INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM hobbies_tbl WHERE hobby_id = @HobbyId;
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

-- ============================================================================
-- 11. STATISTIC REPORTS & DASHBOARD STORED PROCEDURE
-- ============================================================================

IF OBJECT_ID('dbo.sp_GetDashboardStatistics', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_GetDashboardStatistics;
GO
CREATE PROCEDURE dbo.sp_GetDashboardStatistics
AS
BEGIN
    SET NOCOUNT ON;

    -- Result Set 1: Comprehensive Counts, Engagement & KPIs
    SELECT
        (SELECT COUNT(*) FROM projects_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalActiveProjects,
        (SELECT COUNT(*) FROM projects_tbl) AS TotalProjects,
        (SELECT COUNT(*) FROM tech_stacks_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalTechStacks,
        (SELECT COUNT(DISTINCT group_name) FROM tech_stacks_tbl) AS TotalTechCategories,
        (SELECT COUNT(*) FROM skills_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalSkills,
        (SELECT COUNT(*) FROM experiences_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalExperiences,
        (SELECT COUNT(*) FROM educations_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalEducations,
        (SELECT COUNT(*) FROM awards_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalAwards,
        (SELECT COUNT(*) FROM hobbies_tbl WHERE is_active = 1 OR is_active IS NULL) AS TotalHobbies,
        
        -- User Accounts Overview Metrics
        (SELECT COUNT(*) FROM users_tbl) AS TotalUsers,
        (SELECT COUNT(*) FROM users_tbl WHERE is_active = 1) AS ActiveUsers,
        (SELECT COUNT(*) FROM users_tbl WHERE is_active = 0) AS InactiveUsers,
        (SELECT COUNT(*) FROM users_tbl WHERE user_role = 'Admin') AS AdminUsers,
        (SELECT COUNT(*) FROM users_tbl WHERE created_at >= CAST(GETDATE() AS DATE)) AS SignUpsToday,
        (SELECT COUNT(*) FROM users_tbl WHERE created_at >= DATEADD(DAY, -7, GETDATE())) AS SignUpsThisWeek,
        (SELECT COUNT(*) FROM users_tbl WHERE created_at >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)) AS SignUpsThisMonth,
        
        -- User Activity & Engagement Metrics (DAU, MAU, Total Logins)
        (SELECT ISNULL(SUM(login_count), 0) FROM users_tbl) AS TotalLogins,
        (SELECT COUNT(DISTINCT user_id) FROM users_tbl WHERE last_login_at >= CAST(GETDATE() AS DATE)) AS DailyActiveUsers,
        (SELECT COUNT(DISTINCT user_id) FROM users_tbl WHERE last_login_at >= DATEADD(DAY, -30, GETDATE())) AS MonthlyActiveUsers,

        -- System & Content
        (SELECT COUNT(*) FROM password_resets_tbl WHERE status = 'pending') AS PendingPasswordResets,
        (SELECT ISNULL(MAX(experience_years), 3) FROM profile_tbl) AS ExperienceYears,
        GETDATE() AS ReportGeneratedAt;

    -- Result Set 2: Tech Stacks by Group Category
    SELECT ISNULL(group_name, 'General') AS Category, COUNT(*) AS ItemCount
    FROM tech_stacks_tbl
    WHERE is_active = 1 OR is_active IS NULL
    GROUP BY group_name
    ORDER BY ItemCount DESC;

    -- Result Set 3: Recent Users with Activity, Last Login & Logins Count
    SELECT TOP 10 user_id, first_name, last_name, email, user_role, is_active, 
                  profile_image, last_login_at, ISNULL(login_count, 0) AS login_count, created_at
    FROM users_tbl
    ORDER BY created_at DESC;

    -- Result Set 4: Pending Password Resets
    SELECT TOP 5 r.reset_id, r.user_id, r.email, r.reason, r.status, r.created_at,
                 u.first_name, u.last_name, u.user_role
    FROM password_resets_tbl r
    LEFT JOIN users_tbl u ON r.user_id = u.user_id
    WHERE r.status = 'pending'
    ORDER BY r.created_at DESC;
END;
GO
