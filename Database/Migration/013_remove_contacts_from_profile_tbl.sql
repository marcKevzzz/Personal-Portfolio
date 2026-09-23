-- ============================================================================
-- Migration 013: Remove Contacts from profile_tbl & Decouple Profile Schema
-- ============================================================================
-- Description:
-- 1. Verifies contacts are migrated from profile_tbl into contacts_tbl.
-- 2. Drops email, github_url, and linkedin_url columns from dbo.profile_tbl.
-- 3. Updates sp_SaveProfile to remove legacy contact parameters.
-- 4. Updates sp_GetUserPortfolioData to exclude legacy profile contact columns.
-- ============================================================================

-- 1. Ensure contacts_tbl exists and has legacy profile contacts before dropping
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'contacts_tbl')
BEGIN
    -- Migrate Email
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'email')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'Email', 'Email', p.email, 'mailto:' + p.email, 1, 1
        FROM dbo.profile_tbl p
        WHERE p.email IS NOT NULL AND RTRIM(LTRIM(p.email)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'Email'
          );
    END

    -- Migrate GitHub URL
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'github_url')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'GitHub', 'GitHub', p.github_url, p.github_url, 2, 1
        FROM dbo.profile_tbl p
        WHERE p.github_url IS NOT NULL AND RTRIM(LTRIM(p.github_url)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'GitHub'
          );
    END

    -- Migrate LinkedIn URL
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'linkedin_url')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'LinkedIn', 'LinkedIn', p.linkedin_url, p.linkedin_url, 3, 1
        FROM dbo.profile_tbl p
        WHERE p.linkedin_url IS NOT NULL AND RTRIM(LTRIM(p.linkedin_url)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'LinkedIn'
          );
    END
END
GO

-- 2. Drop legacy contact columns from dbo.profile_tbl
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'email')
BEGIN
    ALTER TABLE dbo.profile_tbl DROP COLUMN email;
    PRINT 'Dropped column email from dbo.profile_tbl.';
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'github_url')
BEGIN
    ALTER TABLE dbo.profile_tbl DROP COLUMN github_url;
    PRINT 'Dropped column github_url from dbo.profile_tbl.';
END
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'linkedin_url')
BEGIN
    ALTER TABLE dbo.profile_tbl DROP COLUMN linkedin_url;
    PRINT 'Dropped column linkedin_url from dbo.profile_tbl.';
END
GO

-- 3. Update sp_SaveProfile without legacy contact parameters
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
    @experience_years INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.profile_tbl WHERE user_id = @user_id)
    BEGIN
        UPDATE dbo.profile_tbl
        SET hero_subline     = @hero_subline,
            hero_names       = @hero_names,
            role_summary     = @role_summary,
            role_title       = @role_title,
            focus_area       = @focus_area,
            based_in         = @based_in,
            avatar_path      = @avatar_path,
            location_address = @location_address,
            birth_date       = @birth_date,
            experience_years = @experience_years,
            updated_at       = GETDATE()
        WHERE user_id = @user_id;

        SELECT profile_id FROM dbo.profile_tbl WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.profile_tbl (
            user_id, hero_subline, hero_names, role_summary, role_title,
            focus_area, based_in, avatar_path, location_address, birth_date,
            experience_years, created_at, updated_at
        )
        VALUES (
            @user_id, @hero_subline, @hero_names, @role_summary, @role_title,
            @focus_area, @based_in, @avatar_path, @location_address, @birth_date,
            @experience_years, GETDATE(), GETDATE()
        );

        SELECT SCOPE_IDENTITY() AS profile_id;
    END
END;
GO

-- 4. Update sp_GetUserPortfolioData to exclude legacy profile contact columns
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Profile: birth_date from profile_tbl; first_name, last_name, login email from users_tbl
    SELECT 
        ISNULL(p.profile_id, 0) AS profile_id,
        u.user_id,
        u.first_name,
        u.last_name,
        ISNULL(p.hero_names, u.first_name + ',' + u.last_name) AS hero_names,
        ISNULL(p.hero_subline, '') AS hero_subline,
        ISNULL(p.role_summary, '') AS role_summary,
        ISNULL(p.role_title, 'Web Developer') AS role_title,
        ISNULL(p.focus_area, 'Interfaces & Data Systems') AS focus_area,
        ISNULL(p.based_in, 'Quezon City') AS based_in,
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
        u.email AS email,
        CAST('' AS NVARCHAR(255)) AS github_url,
        CAST('' AS NVARCHAR(255)) AS linkedin_url,
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

PRINT 'Migration 013 executed successfully.';
