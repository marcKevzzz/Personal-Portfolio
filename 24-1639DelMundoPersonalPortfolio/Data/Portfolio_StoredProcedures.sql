-- ============================================================================
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Complete MSSQL stored procedures and schema views for Multi-User Portfolio System
-- ============================================================================

USE personal_portfolio_db;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. sp_GetUserPortfolioData
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Profile: birth_date & contact email from profile_tbl; first_name, last_name, login email from users_tbl
    SELECT 
        ISNULL(p.profile_id, 0) AS profile_id,
        u.user_id,
        u.first_name,
        u.last_name,
        ISNULL(p.hero_names, u.first_name + ',' + u.last_name) AS hero_names,
        ISNULL(p.hero_subline, '') AS hero_subline,
        ISNULL(p.role_summary, '') AS role_summary,
        ISNULL(p.role_title, '') AS role_title,
        ISNULL(p.focus_area, '') AS focus_area,
        ISNULL(p.based_in, '') AS based_in,
        ISNULL(p.avatar_path, '') AS avatar_path,
        ISNULL(p.location_address, '') AS location_address,
        p.birth_date,
        CASE 
            WHEN p.birth_date IS NOT NULL THEN
                DATEDIFF(YEAR, p.birth_date, GETDATE()) - 
                CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.birth_date, GETDATE()), p.birth_date) > GETDATE() THEN 1 ELSE 0 END
            ELSE 0
        END AS derived_age,
        ISNULL(p.experience_years, 0) AS experience_years,
        ISNULL(p.email, u.email) AS email,
        ISNULL(p.github_url, '') AS github_url,
        ISNULL(p.linkedin_url, '') AS linkedin_url,
        ISNULL(p.updated_at, u.created_at) AS updated_at,
        u.user_role,
        u.is_active
    FROM dbo.users_tbl u
    LEFT JOIN dbo.profile_tbl p ON u.user_id = p.user_id
    WHERE u.user_id = @user_id;

    -- 2. Tech Stack (ordered by tech_id ASC)
    SELECT tech_id, user_id, group_name, label, icon_path, is_active
    FROM dbo.tech_stacks_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY tech_id ASC;

    -- 3. Skills (ordered by skill_id ASC)
    SELECT skill_id, user_id, skill_name, proficiency_val, is_active
    FROM dbo.skills_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY skill_id ASC;

    -- 4. Experiences (raw years, ordered by start_year DESC, exp_id DESC)
    SELECT exp_id, user_id, role_title, company_name, start_year, end_year, is_current,
           description_text, tags, is_active
    FROM dbo.experiences_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY start_year DESC, exp_id DESC;

    -- 5. Projects (ordered by project_id ASC)
    SELECT project_id, user_id, title, image_path, project_url, tags, is_active
    FROM dbo.projects_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY project_id ASC;

    -- 6. Educations (raw years, ordered by start_year DESC, edu_id DESC)
    SELECT edu_id, user_id, start_year, end_year, is_current,
           title, subtitle, institution_name, is_active
    FROM dbo.educations_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY start_year DESC, edu_id DESC;

    -- 7. Awards (ordered by award_id ASC)
    SELECT award_id, user_id, award_year, title, subtitle, organization_name, is_active
    FROM dbo.awards_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY award_id ASC;

    -- 8. Hobbies (ordered by hobby_id ASC)
    SELECT hobby_id, user_id, hobby_name, hobby_description, is_active
    FROM dbo.hobbies_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY hobby_id ASC;
END;
GO

-- 2. sp_SaveProfile
CREATE OR ALTER PROCEDURE dbo.sp_SaveProfile
    @user_id INT,
    @hero_subline NVARCHAR(150) = 'builds interfaces',
    @hero_names NVARCHAR(500) = NULL,
    @role_summary NVARCHAR(MAX) = NULL,
    @role_title NVARCHAR(150) = 'Web Developer',
    @focus_area NVARCHAR(150) = 'Interfaces & Data Systems',
    @based_in NVARCHAR(150) = 'Quezon City',
    @avatar_path NVARCHAR(255) = 'Assets/Images/pixelart_portrait.png',
    @location_address NVARCHAR(255) = NULL,
    @birth_date DATE = NULL,
    @experience_years INT = 1,
    @email NVARCHAR(150) = NULL,
    @github_url NVARCHAR(255) = NULL,
    @linkedin_url NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.profile_tbl WHERE user_id = @user_id)
    BEGIN
        UPDATE dbo.profile_tbl
        SET hero_subline = @hero_subline,
            hero_names = @hero_names,
            role_summary = @role_summary,
            role_title = @role_title,
            focus_area = @focus_area,
            based_in = @based_in,
            avatar_path = @avatar_path,
            location_address = @location_address,
            birth_date = @birth_date,
            experience_years = @experience_years,
            email = @email,
            github_url = @github_url,
            linkedin_url = @linkedin_url,
            updated_at = GETDATE()
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.profile_tbl
        (
            user_id, hero_subline, hero_names, role_summary, role_title, focus_area, based_in,
            avatar_path, location_address, birth_date, experience_years, email, github_url, linkedin_url, updated_at
        )
        VALUES
        (
            @user_id, @hero_subline, @hero_names, @role_summary, @role_title, @focus_area, @based_in,
            @avatar_path, @location_address, @birth_date, @experience_years, @email, @github_url, @linkedin_url, GETDATE()
        );
    END
END;
GO

-- 3. sp_UpdateUserDetails (Account settings: Name & Password only)
CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserDetails
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @password_hash NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @password_hash IS NOT NULL AND LEN(@password_hash) > 0
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            password_hash = @password_hash
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name
        WHERE user_id = @user_id;
    END
END;
GO

-- 4. Tech Stack Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveTechStack
    @tech_id INT = 0,
    @user_id INT,
    @group_name NVARCHAR(100),
    @label NVARCHAR(100),
    @icon_path NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    IF @tech_id > 0 AND EXISTS (SELECT 1 FROM dbo.tech_stacks_tbl WHERE tech_id = @tech_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.tech_stacks_tbl
        SET group_name = @group_name,
            label = @label,
            icon_path = @icon_path
        WHERE tech_id = @tech_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tech_stacks_tbl (user_id, group_name, label, icon_path, is_active)
        VALUES (@user_id, @group_name, @label, @icon_path, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteTechStack
    @tech_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.tech_stacks_tbl WHERE tech_id = @tech_id AND user_id = @user_id;
END;
GO

-- 5. Skill Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveSkill
    @skill_id INT = 0,
    @user_id INT,
    @skill_name NVARCHAR(150),
    @proficiency_val INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @skill_id > 0 AND EXISTS (SELECT 1 FROM dbo.skills_tbl WHERE skill_id = @skill_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.skills_tbl
        SET skill_name = @skill_name,
            proficiency_val = @proficiency_val
        WHERE skill_id = @skill_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.skills_tbl (user_id, skill_name, proficiency_val, is_active)
        VALUES (@user_id, @skill_name, @proficiency_val, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteSkill
    @skill_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.skills_tbl WHERE skill_id = @skill_id AND user_id = @user_id;
END;
GO

-- 6. Experience Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveExperience
    @exp_id INT = 0,
    @user_id INT,
    @role_title NVARCHAR(150),
    @company_name NVARCHAR(150),
    @start_year INT,
    @end_year INT = NULL,
    @is_current BIT = 0,
    @description_text NVARCHAR(MAX) = NULL,
    @tags NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @exp_id > 0 AND EXISTS (SELECT 1 FROM dbo.experiences_tbl WHERE exp_id = @exp_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.experiences_tbl
        SET role_title = @role_title,
            company_name = @company_name,
            start_year = @start_year,
            end_year = @end_year,
            is_current = @is_current,
            description_text = @description_text,
            tags = @tags
        WHERE exp_id = @exp_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.experiences_tbl (user_id, role_title, company_name, start_year, end_year, is_current, description_text, tags, is_active)
        VALUES (@user_id, @role_title, @company_name, @start_year, @end_year, @is_current, @description_text, @tags, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteExperience
    @exp_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.experiences_tbl WHERE exp_id = @exp_id AND user_id = @user_id;
END;
GO

-- 7. Project Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveProject
    @project_id INT = 0,
    @user_id INT,
    @title NVARCHAR(150),
    @image_path NVARCHAR(255),
    @project_url NVARCHAR(255) = NULL,
    @tags NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @project_id > 0 AND EXISTS (SELECT 1 FROM dbo.projects_tbl WHERE project_id = @project_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.projects_tbl
        SET title = @title,
            image_path = @image_path,
            project_url = @project_url,
            tags = @tags
        WHERE project_id = @project_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.projects_tbl (user_id, title, image_path, project_url, tags, is_active)
        VALUES (@user_id, @title, @image_path, @project_url, @tags, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteProject
    @project_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.projects_tbl WHERE project_id = @project_id AND user_id = @user_id;
END;
GO

-- 8. Education Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveEducation
    @edu_id INT = 0,
    @user_id INT,
    @title NVARCHAR(150),
    @subtitle NVARCHAR(150),
    @institution_name NVARCHAR(200),
    @start_year INT,
    @end_year INT = NULL,
    @is_current BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @edu_id > 0 AND EXISTS (SELECT 1 FROM dbo.educations_tbl WHERE edu_id = @edu_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.educations_tbl
        SET title = @title,
            subtitle = @subtitle,
            institution_name = @institution_name,
            start_year = @start_year,
            end_year = @end_year,
            is_current = @is_current
        WHERE edu_id = @edu_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.educations_tbl (user_id, title, subtitle, institution_name, start_year, end_year, is_current, is_active)
        VALUES (@user_id, @title, @subtitle, @institution_name, @start_year, @end_year, @is_current, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteEducation
    @edu_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.educations_tbl WHERE edu_id = @edu_id AND user_id = @user_id;
END;
GO

-- 9. Award Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveAward
    @award_id INT = 0,
    @user_id INT,
    @award_year NVARCHAR(50),
    @title NVARCHAR(150),
    @subtitle NVARCHAR(150),
    @organization_name NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    IF @award_id > 0 AND EXISTS (SELECT 1 FROM dbo.awards_tbl WHERE award_id = @award_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.awards_tbl
        SET award_year = @award_year,
            title = @title,
            subtitle = @subtitle,
            organization_name = @organization_name
        WHERE award_id = @award_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.awards_tbl (user_id, award_year, title, subtitle, organization_name, is_active)
        VALUES (@user_id, @award_year, @title, @subtitle, @organization_name, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteAward
    @award_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.awards_tbl WHERE award_id = @award_id AND user_id = @user_id;
END;
GO

-- 10. Hobby Procedures
CREATE OR ALTER PROCEDURE dbo.sp_SaveHobby
    @hobby_id INT = 0,
    @user_id INT,
    @hobby_name NVARCHAR(150),
    @hobby_description NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @hobby_id > 0 AND EXISTS (SELECT 1 FROM dbo.hobbies_tbl WHERE hobby_id = @hobby_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.hobbies_tbl
        SET hobby_name = @hobby_name,
            hobby_description = @hobby_description
        WHERE hobby_id = @hobby_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.hobbies_tbl (user_id, hobby_name, hobby_description, is_active)
        VALUES (@user_id, @hobby_name, @hobby_description, 1);
    END
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_DeleteHobby
    @hobby_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.hobbies_tbl WHERE hobby_id = @hobby_id AND user_id = @user_id;
END;
GO

-- 11. User Management & Analytics
CREATE OR ALTER PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.user_id AS UserId,
        u.first_name AS FirstName,
        u.last_name AS LastName,
        u.email AS Email,
        u.user_role AS UserRole,
        u.is_active AS IsActive,
        u.created_at AS CreatedAt,
        u.last_login_at AS LastLoginAt,
        ISNULL(u.login_count, 0) AS LoginCount,
        CASE WHEN p.profile_id IS NOT NULL THEN 1 ELSE 0 END AS HasProfile,
        p.birth_date AS BirthDate,
        ISNULL(p.role_title, 'Not Set') AS RoleTitle
    FROM dbo.users_tbl u
    LEFT JOIN dbo.profile_tbl p ON u.user_id = p.user_id
    ORDER BY u.created_at DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ToggleUserStatus
    @user_id INT,
    @is_active BIT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.users_tbl
    SET is_active = @is_active
    WHERE user_id = @user_id;

    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_ResetUserPassword
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @user_email NVARCHAR(150);
    SELECT @user_email = email FROM dbo.users_tbl WHERE user_id = @user_id;

    IF @user_email IS NOT NULL
    BEGIN
        INSERT INTO dbo.password_resets_tbl (user_id, email, status, reason, created_at)
        VALUES (@user_id, @user_email, 'password_removed', 'Admin password reset', GETDATE());

        SELECT 1 AS success;
    END
    ELSE
    BEGIN
        SELECT 0 AS success;
    END
END;
GO

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

-- 12. Database Schema Summary View & Stored Procedure
CREATE OR ALTER VIEW dbo.vw_DatabaseSchemaSummary
AS
SELECT 
    t.TABLE_NAME AS TableName,
    c.COLUMN_NAME AS ColumnName,
    c.ORDINAL_POSITION AS OrdinalPosition,
    c.DATA_TYPE + 
        CASE 
            WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL AND c.CHARACTER_MAXIMUM_LENGTH > 0 
                THEN '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ')'
            WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 
                THEN '(MAX)'
            WHEN c.NUMERIC_PRECISION IS NOT NULL AND c.DATA_TYPE IN ('decimal', 'numeric')
                THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR(10)) + ')'
            ELSE ''
        END AS DataTypeDefinition,
    c.IS_NULLABLE AS IsNullable,
    c.COLUMN_DEFAULT AS DefaultValue,
    CASE 
        WHEN pk.COLUMN_NAME IS NOT NULL THEN 'YES' 
        ELSE 'NO' 
    END AS IsPrimaryKey,
    CASE 
        WHEN fk.COLUMN_NAME IS NOT NULL THEN 'YES' 
        ELSE 'NO' 
    END AS IsForeignKey,
    ISNULL(fk.REFERENCED_TABLE_NAME, '') AS ReferencedTable,
    ISNULL(fk.REFERENCED_COLUMN_NAME, '') AS ReferencedColumn
FROM INFORMATION_SCHEMA.TABLES t
JOIN INFORMATION_SCHEMA.COLUMNS c 
    ON t.TABLE_NAME = c.TABLE_NAME AND t.TABLE_SCHEMA = c.TABLE_SCHEMA
LEFT JOIN (
    SELECT ku.TABLE_SCHEMA, ku.TABLE_NAME, ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = ku.TABLE_SCHEMA
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA AND c.TABLE_NAME = pk.TABLE_NAME AND c.COLUMN_NAME = pk.COLUMN_NAME
LEFT JOIN (
    SELECT 
        kcu.TABLE_SCHEMA,
        kcu.TABLE_NAME,
        kcu.COLUMN_NAME,
        ccu.TABLE_NAME AS REFERENCED_TABLE_NAME,
        ccu.COLUMN_NAME AS REFERENCED_COLUMN_NAME
    FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
        ON rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME AND rc.CONSTRAINT_SCHEMA = kcu.CONSTRAINT_SCHEMA
    JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
        ON rc.UNIQUE_CONSTRAINT_NAME = ccu.CONSTRAINT_NAME AND rc.UNIQUE_CONSTRAINT_SCHEMA = ccu.CONSTRAINT_SCHEMA
) fk ON c.TABLE_SCHEMA = fk.TABLE_SCHEMA AND c.TABLE_NAME = fk.TABLE_NAME AND c.COLUMN_NAME = fk.COLUMN_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE' AND t.TABLE_NAME <> 'sysdiagrams';
GO

CREATE OR ALTER PROCEDURE dbo.sp_GetDatabaseSchemaSummary
    @TableName NVARCHAR(128) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @TableName IS NOT NULL AND LEN(@TableName) > 0
    BEGIN
        SELECT * FROM dbo.vw_DatabaseSchemaSummary 
        WHERE TableName = @TableName 
        ORDER BY TableName, OrdinalPosition;
    END
    ELSE
    BEGIN
        SELECT * FROM dbo.vw_DatabaseSchemaSummary 
        ORDER BY TableName, OrdinalPosition;
    END
END;
GO
