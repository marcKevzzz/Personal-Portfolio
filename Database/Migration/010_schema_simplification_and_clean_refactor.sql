-- ============================================================================
-- Migration: 010_schema_simplification_and_clean_refactor.sql
-- Description:
-- 1. users_tbl: Remove age and birth_date (keep core account/login data).
-- 2. profile_tbl: Remove age, first_name, last_name. Ensure birth_date and email exist.
-- 3. educations_tbl: Remove year_period and sort_order. Store raw years.
-- 4. experiences_tbl: Remove period_range and sort_order. Store raw years.
-- 5. Drop sort_order from tech_stacks_tbl, skills_tbl, projects_tbl, awards_tbl, hobbies_tbl.
-- 6. Remove unnecessary constant default constraints on user-supplied fields.
-- 7. Rewrite all stored procedures and schema summary view.
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- HELPER: DROP DEFAULT CONSTRAINT AND COLUMN PROCEDURE
-- ============================================================================
CREATE OR ALTER PROCEDURE dbo.sp_DropColumnWithConstraints
    @TableName NVARCHAR(128),
    @ColumnName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM sys.columns c
        JOIN sys.tables t ON c.object_id = t.object_id
        WHERE t.name = @TableName AND c.name = @ColumnName
    )
    BEGIN
        DECLARE @sql NVARCHAR(MAX) = N'';

        -- Drop default constraints on this column
        SELECT @sql += N'ALTER TABLE dbo.' + QUOTENAME(@TableName) + 
                       N' DROP CONSTRAINT ' + QUOTENAME(dc.name) + N'; '
        FROM sys.default_constraints dc
        JOIN sys.tables t ON dc.parent_object_id = t.object_id
        JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
        WHERE t.name = @TableName AND c.name = @ColumnName;

        -- Drop check constraints on this column
        SELECT @sql += N'ALTER TABLE dbo.' + QUOTENAME(@TableName) + 
                       N' DROP CONSTRAINT ' + QUOTENAME(cc.name) + N'; '
        FROM sys.check_constraints cc
        JOIN sys.tables t ON cc.parent_object_id = t.object_id
        JOIN sys.columns c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
        WHERE t.name = @TableName AND c.name = @ColumnName;

        IF LEN(@sql) > 0
        BEGIN
            EXEC sp_executesql @sql;
        END

        SET @sql = N'ALTER TABLE dbo.' + QUOTENAME(@TableName) + N' DROP COLUMN ' + QUOTENAME(@ColumnName) + N';';
        EXEC sp_executesql @sql;
    END
END;
GO

-- ============================================================================
-- 1. USERS_TBL CLEANUP
-- ============================================================================
EXEC dbo.sp_DropColumnWithConstraints 'users_tbl', 'age';
EXEC dbo.sp_DropColumnWithConstraints 'users_tbl', 'birth_date';
EXEC dbo.sp_DropColumnWithConstraints 'users_tbl', 'profile_image';
GO

-- ============================================================================
-- 2. PROFILE_TBL CLEANUP & REFACTOR
-- ============================================================================
EXEC dbo.sp_DropColumnWithConstraints 'profile_tbl', 'age';
EXEC dbo.sp_DropColumnWithConstraints 'profile_tbl', 'first_name';
EXEC dbo.sp_DropColumnWithConstraints 'profile_tbl', 'last_name';
GO

-- Ensure birth_date exists on profile_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'birth_date')
BEGIN
    ALTER TABLE dbo.profile_tbl ADD birth_date DATE NULL;
END
GO

-- Ensure email exists on profile_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'email')
BEGIN
    ALTER TABLE dbo.profile_tbl ADD email NVARCHAR(150) NULL;
END
GO

-- If profile_tbl has default constraints on user-supplied fields, drop them
DECLARE @dropProfileDefaults NVARCHAR(MAX) = N'';
SELECT @dropProfileDefaults += N'ALTER TABLE dbo.profile_tbl DROP CONSTRAINT ' + QUOTENAME(dc.name) + N'; '
FROM sys.default_constraints dc
JOIN sys.tables t ON dc.parent_object_id = t.object_id
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE t.name = 'profile_tbl' AND c.name IN (
    'hero_subline', 'hero_names', 'role_title', 'focus_area', 'based_in', 
    'avatar_path', 'location_address', 'experience_years', 'email', 'github_url', 'linkedin_url'
);
IF LEN(@dropProfileDefaults) > 0 EXEC sp_executesql @dropProfileDefaults;
GO

-- ============================================================================
-- 3. EDUCATIONS_TBL CLEANUP
-- ============================================================================
EXEC dbo.sp_DropColumnWithConstraints 'educations_tbl', 'year_period';
EXEC dbo.sp_DropColumnWithConstraints 'educations_tbl', 'sort_order';
GO

-- Drop constant default on start_year and is_current
DECLARE @dropEduDefaults NVARCHAR(MAX) = N'';
SELECT @dropEduDefaults += N'ALTER TABLE dbo.educations_tbl DROP CONSTRAINT ' + QUOTENAME(dc.name) + N'; '
FROM sys.default_constraints dc
JOIN sys.tables t ON dc.parent_object_id = t.object_id
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE t.name = 'educations_tbl' AND c.name IN ('start_year', 'is_current');
IF LEN(@dropEduDefaults) > 0 EXEC sp_executesql @dropEduDefaults;
GO

-- ============================================================================
-- 4. EXPERIENCES_TBL CLEANUP
-- ============================================================================
EXEC dbo.sp_DropColumnWithConstraints 'experiences_tbl', 'period_range';
EXEC dbo.sp_DropColumnWithConstraints 'experiences_tbl', 'sort_order';
GO

DECLARE @dropExpDefaults NVARCHAR(MAX) = N'';
SELECT @dropExpDefaults += N'ALTER TABLE dbo.experiences_tbl DROP CONSTRAINT ' + QUOTENAME(dc.name) + N'; '
FROM sys.default_constraints dc
JOIN sys.tables t ON dc.parent_object_id = t.object_id
JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE t.name = 'experiences_tbl' AND c.name IN ('start_year', 'is_current');
IF LEN(@dropExpDefaults) > 0 EXEC sp_executesql @dropExpDefaults;
GO

-- ============================================================================
-- 5. DROP SORT_ORDER FROM ALL REMAINING TABLES
-- ============================================================================
EXEC dbo.sp_DropColumnWithConstraints 'tech_stacks_tbl', 'sort_order';
EXEC dbo.sp_DropColumnWithConstraints 'skills_tbl', 'sort_order';
EXEC dbo.sp_DropColumnWithConstraints 'projects_tbl', 'sort_order';
EXEC dbo.sp_DropColumnWithConstraints 'awards_tbl', 'sort_order';
EXEC dbo.sp_DropColumnWithConstraints 'hobbies_tbl', 'sort_order';
GO

-- ============================================================================
-- 6. DROP TEMPORARY HELPER PROCEDURE
-- ============================================================================
IF OBJECT_ID('dbo.sp_DropColumnWithConstraints', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_DropColumnWithConstraints;
END
GO

-- ============================================================================
-- 7. REWRITE STORED PROCEDURES
-- ============================================================================

-- 7.1 sp_GetUserPortfolioData
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
        ISNULL(p.hero_subline, 'builds interfaces') AS hero_subline,
        ISNULL(p.role_summary, '') AS role_summary,
        ISNULL(p.role_title, 'Web Developer') AS role_title,
        ISNULL(p.focus_area, 'Interfaces & Data Systems') AS focus_area,
        ISNULL(p.based_in, 'Quezon City') AS based_in,
        ISNULL(p.avatar_path, 'Assets/Images/pixelart_portrait.png') AS avatar_path,
        ISNULL(p.location_address, '') AS location_address,
        p.birth_date,
        CASE 
            WHEN p.birth_date IS NOT NULL THEN
                DATEDIFF(YEAR, p.birth_date, GETDATE()) - 
                CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.birth_date, GETDATE()), p.birth_date) > GETDATE() THEN 1 ELSE 0 END
            ELSE 0
        END AS derived_age,
        ISNULL(p.experience_years, 1) AS experience_years,
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

-- 7.2 sp_SaveProfile
CREATE OR ALTER PROCEDURE dbo.sp_SaveProfile
    @user_id INT,
    @hero_subline NVARCHAR(150),
    @hero_names NVARCHAR(500),
    @role_summary NVARCHAR(MAX),
    @role_title NVARCHAR(150),
    @focus_area NVARCHAR(150),
    @based_in NVARCHAR(150),
    @avatar_path NVARCHAR(255),
    @location_address NVARCHAR(255),
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

-- 7.3 sp_UpdateUserDetails (Account Settings: Name & Password only)
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

-- 7.4 sp_SaveTechStack
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

-- 7.5 sp_SaveSkill
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

-- 7.6 sp_SaveExperience (Raw years, no period_range string)
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

-- 7.7 sp_SaveProject
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

-- 7.8 sp_SaveEducation (Raw years, no year_period string)
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

-- 7.9 sp_SaveAward
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

-- 7.10 sp_SaveHobby
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

-- 7.11 vw_DatabaseSchemaSummary (Cleaned up view without sysdiagrams)
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

-- 7.12 sp_GetDatabaseSchemaSummary
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
