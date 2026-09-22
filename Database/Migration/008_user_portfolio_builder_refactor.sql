-- ============================================================================
-- Migration: 008_user_portfolio_builder_refactor.sql
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description:
--   1. Adds 'age' column to users_tbl
--   2. Removes 'profile_image' column from users_tbl
--   3. Makes profile_tbl independent of first_name, last_name, email, age
--   4. Updates stored procedures:
--      - sp_GetUserPortfolioData: joins users_tbl to fetch first_name, last_name, age, email
--      - sp_SaveProfile: updates presentation fields only
--      - sp_UpdateUserDetails: updates first_name, last_name, age, and optional password
--      - sp_GetDashboardStats: multi-user portfolio creation analytics
--      - sp_GetUserPortfolioReports: status and content counts per user
-- ============================================================================

USE personal_portfolio_db;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. ADD 'age' TO users_tbl IF NOT EXISTS
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'age')
BEGIN
    ALTER TABLE dbo.users_tbl ADD age INT NULL;
END
GO

-- If user 1 has no age, set default 19
UPDATE dbo.users_tbl SET age = 19 WHERE user_id = 1 AND age IS NULL;
GO

-- 2. DROP 'profile_image' FROM users_tbl IF EXISTS
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'profile_image')
BEGIN
    ALTER TABLE dbo.users_tbl DROP COLUMN profile_image;
END
GO

-- 3. ENSURE profile_tbl COLUMNS ARE NULLABLE (since they are now sourced from users_tbl)
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'first_name')
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN first_name NVARCHAR(150) NULL;
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'last_name')
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN last_name NVARCHAR(150) NULL;
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'email')
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN email NVARCHAR(150) NULL;
END
GO

-- 4. CREATE OR ALTER sp_GetUserPortfolioData
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Profile with first_name, last_name, email, and age directly from users_tbl
    SELECT 
        ISNULL(p.profile_id, 0) AS profile_id,
        u.user_id,
        u.first_name,
        u.last_name,
        ISNULL(p.hero_names, u.first_name + ',' + u.last_name) AS hero_names,
        ISNULL(p.role_summary, '') AS role_summary,
        ISNULL(p.role_title, 'Web Developer') AS role_title,
        ISNULL(p.focus_area, 'Interfaces & Data Systems') AS focus_area,
        ISNULL(p.based_in, 'Quezon City') AS based_in,
        ISNULL(p.avatar_path, 'Assets/Images/pixelart_portrait.png') AS avatar_path,
        ISNULL(p.location_address, '') AS location_address,
        p.birth_date,
        ISNULL(u.age, ISNULL(p.age, 19)) AS derived_age,
        ISNULL(p.experience_years, 1) AS experience_years,
        u.email,
        ISNULL(p.github_url, '') AS github_url,
        ISNULL(p.linkedin_url, '') AS linkedin_url,
        ISNULL(p.updated_at, u.created_at) AS updated_at,
        u.user_role,
        u.is_active
    FROM dbo.users_tbl u
    LEFT JOIN dbo.profile_tbl p ON u.user_id = p.user_id
    WHERE u.user_id = @user_id;

    -- 2. Tech Stack
    SELECT tech_id, user_id, group_name, label, icon_path, sort_order, is_active
    FROM dbo.tech_stacks_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, tech_id ASC;

    -- 3. Skills
    SELECT skill_id, user_id, skill_name, proficiency_val, sort_order, is_active
    FROM dbo.skills_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, skill_id ASC;

    -- 4. Experiences
    SELECT exp_id, user_id, role_title, company_name, start_year, end_year, is_current,
           CASE 
               WHEN is_current = 1 OR end_year IS NULL THEN CAST(start_year AS NVARCHAR(10)) + ' — Present'
               ELSE CAST(start_year AS NVARCHAR(10)) + ' — ' + CAST(end_year AS NVARCHAR(10))
           END AS period_display,
           description_text, tags, sort_order, is_active
    FROM dbo.experiences_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY start_year DESC, exp_id DESC;

    -- 5. Projects
    SELECT project_id, user_id, title, image_path, project_url, tags, sort_order, is_active
    FROM dbo.projects_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, project_id ASC;

    -- 6. Educations
    SELECT edu_id, user_id, start_year, end_year, is_current,
           CASE 
               WHEN is_current = 1 OR end_year IS NULL THEN CAST(start_year AS NVARCHAR(10)) + ' — Present'
               ELSE CAST(start_year AS NVARCHAR(10)) + ' — ' + CAST(end_year AS NVARCHAR(10))
           END AS year_display,
           title, subtitle, institution_name, sort_order, is_active
    FROM dbo.educations_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY start_year DESC, edu_id DESC;

    -- 7. Awards
    SELECT award_id, user_id, award_year, title, subtitle, organization_name, sort_order, is_active
    FROM dbo.awards_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, award_id ASC;

    -- 8. Hobbies
    SELECT hobby_id, user_id, hobby_name, hobby_description, sort_order, is_active
    FROM dbo.hobbies_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, hobby_id ASC;
END;
GO

-- 5. CREATE OR ALTER sp_SaveProfile (Presentation attributes only)
CREATE OR ALTER PROCEDURE dbo.sp_SaveProfile
    @user_id INT,
    @hero_names NVARCHAR(500),
    @role_summary NVARCHAR(MAX) = NULL,
    @role_title NVARCHAR(150) = 'Web Developer',
    @focus_area NVARCHAR(150) = 'Interfaces & Data Systems',
    @based_in NVARCHAR(150) = 'Quezon City',
    @avatar_path NVARCHAR(255) = NULL,
    @location_address NVARCHAR(255) = NULL,
    @experience_years INT = 1,
    @github_url NVARCHAR(255) = NULL,
    @linkedin_url NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.profile_tbl WHERE user_id = @user_id)
    BEGIN
        UPDATE dbo.profile_tbl
        SET hero_names = @hero_names,
            role_summary = @role_summary,
            role_title = @role_title,
            focus_area = @focus_area,
            based_in = @based_in,
            avatar_path = @avatar_path,
            location_address = @location_address,
            experience_years = @experience_years,
            github_url = @github_url,
            linkedin_url = @linkedin_url,
            updated_at = GETDATE()
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.profile_tbl
        (
            user_id, hero_names, role_summary, role_title, focus_area, based_in,
            avatar_path, location_address, experience_years, github_url, linkedin_url, updated_at
        )
        VALUES
        (
            @user_id, @hero_names, @role_summary, @role_title, @focus_area, @based_in,
            @avatar_path, @location_address, @experience_years, @github_url, @linkedin_url, GETDATE()
        );
    END
END;
GO

-- 6. CREATE OR ALTER sp_UpdateUserDetails
CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserDetails
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @age INT = NULL,
    @password_hash NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @password_hash IS NOT NULL AND LEN(@password_hash) > 0
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            age = @age,
            password_hash = @password_hash
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            age = @age
        WHERE user_id = @user_id;
    END
END;
GO

-- 7. CREATE OR ALTER sp_GetDashboardStats
CREATE OR ALTER PROCEDURE dbo.sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TotalUsers INT, @ActiveUsers INT, @InactiveUsers INT, @AdminUsers INT;
    DECLARE @SignUpsToday INT, @SignUpsThisWeek INT, @SignUpsThisMonth INT;
    DECLARE @TotalLogins INT, @DailyActiveUsers INT, @MonthlyActiveUsers INT;
    DECLARE @PendingPasswordResets INT;
    DECLARE @TotalProjects INT, @TotalSkills INT, @TotalTechStacks INT;
    DECLARE @TotalExperiences INT, @TotalEducations INT, @TotalAwards INT, @TotalHobbies INT;
    DECLARE @TotalPortfolios INT, @ConfiguredPortfolios INT;

    SELECT @TotalUsers = COUNT(1) FROM dbo.users_tbl WHERE user_role != 'Admin';
    SELECT @ActiveUsers = COUNT(1) FROM dbo.users_tbl WHERE is_active = 1 AND user_role != 'Admin';
    SELECT @InactiveUsers = COUNT(1) FROM dbo.users_tbl WHERE is_active = 0 AND user_role != 'Admin';
    SELECT @AdminUsers = COUNT(1) FROM dbo.users_tbl WHERE user_role = 'Admin';

    SELECT @SignUpsToday = COUNT(1) FROM dbo.users_tbl WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE);
    SELECT @SignUpsThisWeek = COUNT(1) FROM dbo.users_tbl WHERE created_at >= DATEADD(DAY, -7, GETDATE());
    SELECT @SignUpsThisMonth = COUNT(1) FROM dbo.users_tbl WHERE created_at >= DATEADD(DAY, -30, GETDATE());

    SELECT @TotalLogins = ISNULL(SUM(login_count), 0) FROM dbo.users_tbl;
    SELECT @DailyActiveUsers = COUNT(DISTINCT user_id) FROM dbo.user_logins_tbl WHERE login_time >= DATEADD(DAY, -1, GETDATE());
    SELECT @MonthlyActiveUsers = COUNT(DISTINCT user_id) FROM dbo.user_logins_tbl WHERE login_time >= DATEADD(DAY, -30, GETDATE());

    SELECT @PendingPasswordResets = COUNT(1) FROM dbo.password_resets_tbl WHERE status = 'pending';

    SELECT @TotalProjects = COUNT(1) FROM dbo.projects_tbl;
    SELECT @TotalSkills = COUNT(1) FROM dbo.skills_tbl;
    SELECT @TotalTechStacks = COUNT(1) FROM dbo.tech_stacks_tbl;
    SELECT @TotalExperiences = COUNT(1) FROM dbo.experiences_tbl;
    SELECT @TotalEducations = COUNT(1) FROM dbo.educations_tbl;
    SELECT @TotalAwards = COUNT(1) FROM dbo.awards_tbl;
    SELECT @TotalHobbies = COUNT(1) FROM dbo.hobbies_tbl;

    SELECT @TotalPortfolios = COUNT(1) FROM dbo.profile_tbl;
    SELECT @ConfiguredPortfolios = COUNT(DISTINCT user_id) FROM dbo.projects_tbl;

    SELECT 
        @TotalUsers AS TotalUsers,
        @ActiveUsers AS ActiveUsers,
        @InactiveUsers AS InactiveUsers,
        @AdminUsers AS AdminUsers,
        @SignUpsToday AS SignUpsToday,
        @SignUpsThisWeek AS SignUpsThisWeek,
        @SignUpsThisMonth AS SignUpsThisMonth,
        @TotalLogins AS TotalLogins,
        @DailyActiveUsers AS DailyActiveUsers,
        @MonthlyActiveUsers AS MonthlyActiveUsers,
        @PendingPasswordResets AS PendingPasswordResets,
        @TotalProjects AS TotalProjects,
        @TotalSkills AS TotalSkills,
        @TotalTechStacks AS TotalTechStacks,
        @TotalExperiences AS TotalExperiences,
        @TotalEducations AS TotalEducations,
        @TotalAwards AS TotalAwards,
        @TotalHobbies AS TotalHobbies,
        @TotalPortfolios AS TotalPortfolios,
        @ConfiguredPortfolios AS ConfiguredPortfolios,
        CASE WHEN @TotalUsers > 0 THEN (@TotalPortfolios * 100) / @TotalUsers ELSE 0 END AS PortfolioCreationRate;
END;
GO

-- 8. CREATE OR ALTER sp_GetUserPortfolioReports
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioReports
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.user_id AS UserId,
        u.first_name AS FirstName,
        u.last_name AS LastName,
        RTRIM(LTRIM(u.first_name + ' ' + u.last_name)) AS FullName,
        u.email AS Email,
        u.is_active AS IsActive,
        u.created_at AS CreatedAt,
        u.last_login_at AS LastLoginAt,
        ISNULL(u.login_count, 0) AS LoginCount,
        CASE WHEN p.profile_id IS NOT NULL THEN 1 ELSE 0 END AS HasProfile,
        ISNULL(p.role_title, 'Not Set') AS RoleTitle,
        p.updated_at AS LastProfileUpdate,
        (SELECT COUNT(1) FROM dbo.projects_tbl WHERE user_id = u.user_id) AS ProjectsCount,
        (SELECT COUNT(1) FROM dbo.skills_tbl WHERE user_id = u.user_id) AS SkillsCount,
        (SELECT COUNT(1) FROM dbo.tech_stacks_tbl WHERE user_id = u.user_id) AS TechCount,
        (SELECT COUNT(1) FROM dbo.experiences_tbl WHERE user_id = u.user_id) AS ExperiencesCount,
        CASE 
            WHEN (SELECT COUNT(1) FROM dbo.projects_tbl WHERE user_id = u.user_id) > 0 AND p.profile_id IS NOT NULL THEN 'Configured'
            WHEN p.profile_id IS NOT NULL THEN 'In Progress'
            ELSE 'Not Started'
        END AS PortfolioStatus
    FROM dbo.users_tbl u
    LEFT JOIN dbo.profile_tbl p ON u.user_id = p.user_id
    WHERE u.user_role != 'Admin'
    ORDER BY u.created_at DESC;
END;
GO
