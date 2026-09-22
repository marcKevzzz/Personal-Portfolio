-- ============================================================================
-- Migration: 009_user_birthday_and_schema_view.sql
-- Description: 
-- 1. Adds birth_date DATE to users_tbl and calculates age dynamically.
-- 2. Updates sp_UpdateUserDetails to accept birth_date instead of age.
-- 3. Updates sp_GetUserPortfolioData to return birth_date and calculated age.
-- 4. Creates vw_DatabaseSchemaSummary view and sp_GetDatabaseSchemaSummary
-- ============================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 1. Add birth_date column to users_tbl
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'birth_date')
BEGIN
    ALTER TABLE dbo.users_tbl ADD birth_date DATE NULL;
END
GO

-- Populate birth_date for existing users where missing
UPDATE dbo.users_tbl
SET birth_date = DATEADD(YEAR, -ISNULL(age, 19), CAST(GETDATE() AS DATE))
WHERE birth_date IS NULL;
GO

-- 2. CREATE OR ALTER sp_UpdateUserDetails
CREATE OR ALTER PROCEDURE dbo.sp_UpdateUserDetails
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @birth_date DATE = NULL,
    @password_hash NVARCHAR(256) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate derived age from birth_date if provided
    DECLARE @computed_age INT = NULL;
    IF @birth_date IS NOT NULL
    BEGIN
        SET @computed_age = DATEDIFF(YEAR, @birth_date, GETDATE()) - 
            CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, @birth_date, GETDATE()), @birth_date) > GETDATE() THEN 1 ELSE 0 END;
    END

    IF @password_hash IS NOT NULL AND LEN(@password_hash) > 0
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            birth_date = @birth_date,
            age = ISNULL(@computed_age, age),
            password_hash = @password_hash
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        UPDATE dbo.users_tbl
        SET first_name = @first_name,
            last_name = @last_name,
            birth_date = @birth_date,
            age = ISNULL(@computed_age, age)
        WHERE user_id = @user_id;
    END
END;
GO

-- 3. CREATE OR ALTER sp_GetUserPortfolioData
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

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
        u.birth_date,
        CASE 
            WHEN u.birth_date IS NOT NULL THEN
                DATEDIFF(YEAR, u.birth_date, GETDATE()) - 
                CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, u.birth_date, GETDATE()), u.birth_date) > GETDATE() THEN 1 ELSE 0 END
            WHEN u.age IS NOT NULL THEN u.age
            WHEN p.age IS NOT NULL THEN p.age
            ELSE 19
        END AS derived_age,
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

-- 4. CREATE OR ALTER vw_DatabaseSchemaSummary
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
    -- Primary keys
    SELECT ku.TABLE_SCHEMA, ku.TABLE_NAME, ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku
        ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME AND tc.TABLE_SCHEMA = ku.TABLE_SCHEMA
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA AND c.TABLE_NAME = pk.TABLE_NAME AND c.COLUMN_NAME = pk.COLUMN_NAME
LEFT JOIN (
    -- Foreign keys
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

-- 5. CREATE OR ALTER sp_GetDatabaseSchemaSummary
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
