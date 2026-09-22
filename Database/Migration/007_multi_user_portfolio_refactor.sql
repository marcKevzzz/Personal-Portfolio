-- ============================================================================
-- Migration: 007_multi_user_portfolio_refactor.sql
-- Project: 24-1639DelMundoPersonalPortfolio
-- Description: Transforms database into a multi-tenant / multi-user portfolio system.
--              Each registered user owns their portfolio content.
--              - Adds telemetry columns (last_login_at, login_count, user_logins_tbl)
--              - Adds user_id FK across all portfolio tables
--              - Replaces age with birth_date (derived age)
--              - Replaces period_range / year_period with start_year and end_year
--              - Adds hobby_description to hobbies_tbl
--              - Drops hero_kicker / hero_subline
--              - Creates comprehensive MSSQL Stored Procedures for all operations
-- ============================================================================

USE personal_portfolio_db;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ============================================================================
-- 0. TELEMETRY & USER TABLE PREREQUISITES
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'last_login_at')
BEGIN
    ALTER TABLE dbo.users_tbl ADD last_login_at DATETIME NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'login_count')
BEGIN
    ALTER TABLE dbo.users_tbl ADD login_count INT NOT NULL CONSTRAINT DF_users_login_count DEFAULT 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.users_tbl') AND name = 'profile_image')
BEGIN
    ALTER TABLE dbo.users_tbl ADD profile_image NVARCHAR(500) NULL;
END
GO

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

-- Ensure users_tbl has fallback accounts if empty
IF NOT EXISTS (SELECT 1 FROM users_tbl WHERE user_role = 'Admin')
BEGIN
    INSERT INTO users_tbl (first_name, last_name, email, password_hash, user_role, is_active, created_at)
    VALUES (N'Marc Kevin', N'Del Mundo', N'delmundo.marckevin.ferolino@gmail.com', 
            N'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3', N'Admin', 1, GETDATE());
END
GO

-- ============================================================================
-- 1. SCHEMA REFACTORING: ALTER TABLES TO MULTI-USER ARCHITECTURE
-- ============================================================================

-- -------------------------------------------------------------
-- 1.1 profile_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.profile_tbl ADD user_id INT NULL;
    DECLARE @DefUid1 INT;
    SELECT TOP 1 @DefUid1 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.profile_tbl SET user_id = ' + @DefUid1 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.profile_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.profile_tbl ADD CONSTRAINT FK_profile_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
    ALTER TABLE dbo.profile_tbl ADD CONSTRAINT UQ_profile_user UNIQUE (user_id);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.profile_tbl') AND name = 'birth_date')
BEGIN
    ALTER TABLE dbo.profile_tbl ADD birth_date DATE NULL;
    EXEC('UPDATE dbo.profile_tbl SET birth_date = ''2005-03-15'' WHERE birth_date IS NULL;');
END
GO

-- -------------------------------------------------------------
-- 1.2 tech_stacks_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.tech_stacks_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.tech_stacks_tbl ADD user_id INT NULL;
    DECLARE @DefUid2 INT;
    SELECT TOP 1 @DefUid2 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.tech_stacks_tbl SET user_id = ' + @DefUid2 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.tech_stacks_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.tech_stacks_tbl ADD CONSTRAINT FK_tech_stacks_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

-- -------------------------------------------------------------
-- 1.3 skills_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.skills_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.skills_tbl ADD user_id INT NULL;
    DECLARE @DefUid3 INT;
    SELECT TOP 1 @DefUid3 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.skills_tbl SET user_id = ' + @DefUid3 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.skills_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.skills_tbl ADD CONSTRAINT FK_skills_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

-- -------------------------------------------------------------
-- 1.4 experiences_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.experiences_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.experiences_tbl ADD user_id INT NULL;
    DECLARE @DefUid4 INT;
    SELECT TOP 1 @DefUid4 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.experiences_tbl SET user_id = ' + @DefUid4 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.experiences_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.experiences_tbl ADD CONSTRAINT FK_experiences_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.experiences_tbl') AND name = 'start_year')
BEGIN
    ALTER TABLE dbo.experiences_tbl ADD start_year INT NOT NULL CONSTRAINT DF_exp_start_year DEFAULT 2024;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.experiences_tbl') AND name = 'end_year')
BEGIN
    ALTER TABLE dbo.experiences_tbl ADD end_year INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.experiences_tbl') AND name = 'is_current')
BEGIN
    ALTER TABLE dbo.experiences_tbl ADD is_current BIT NOT NULL CONSTRAINT DF_exp_is_current DEFAULT 0;
END
GO

-- -------------------------------------------------------------
-- 1.5 educations_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.educations_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.educations_tbl ADD user_id INT NULL;
    DECLARE @DefUid5 INT;
    SELECT TOP 1 @DefUid5 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.educations_tbl SET user_id = ' + @DefUid5 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.educations_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.educations_tbl ADD CONSTRAINT FK_educations_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.educations_tbl') AND name = 'start_year')
BEGIN
    ALTER TABLE dbo.educations_tbl ADD start_year INT NOT NULL CONSTRAINT DF_edu_start_year DEFAULT 2024;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.educations_tbl') AND name = 'end_year')
BEGIN
    ALTER TABLE dbo.educations_tbl ADD end_year INT NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.educations_tbl') AND name = 'is_current')
BEGIN
    ALTER TABLE dbo.educations_tbl ADD is_current BIT NOT NULL CONSTRAINT DF_edu_is_current DEFAULT 1;
END
GO

-- -------------------------------------------------------------
-- 1.6 projects_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.projects_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.projects_tbl ADD user_id INT NULL;
    DECLARE @DefUid6 INT;
    SELECT TOP 1 @DefUid6 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.projects_tbl SET user_id = ' + @DefUid6 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.projects_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.projects_tbl ADD CONSTRAINT FK_projects_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

-- -------------------------------------------------------------
-- 1.7 awards_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.awards_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.awards_tbl ADD user_id INT NULL;
    DECLARE @DefUid7 INT;
    SELECT TOP 1 @DefUid7 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.awards_tbl SET user_id = ' + @DefUid7 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.awards_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.awards_tbl ADD CONSTRAINT FK_awards_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

-- -------------------------------------------------------------
-- 1.8 hobbies_tbl
-- -------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.hobbies_tbl') AND name = 'user_id')
BEGIN
    ALTER TABLE dbo.hobbies_tbl ADD user_id INT NULL;
    DECLARE @DefUid8 INT;
    SELECT TOP 1 @DefUid8 = user_id FROM users_tbl ORDER BY user_id ASC;
    EXEC('UPDATE dbo.hobbies_tbl SET user_id = ' + @DefUid8 + ' WHERE user_id IS NULL;');
    ALTER TABLE dbo.hobbies_tbl ALTER COLUMN user_id INT NOT NULL;
    ALTER TABLE dbo.hobbies_tbl ADD CONSTRAINT FK_hobbies_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE;
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.hobbies_tbl') AND name = 'hobby_description')
BEGIN
    ALTER TABLE dbo.hobbies_tbl ADD hobby_description NVARCHAR(500) NULL;
END
GO

-- Duplicate seed portfolio items for user 2 if user 2 exists and has no profile
IF EXISTS (SELECT 1 FROM users_tbl WHERE user_id = 2) AND NOT EXISTS (SELECT 1 FROM profile_tbl WHERE user_id = 2)
BEGIN
    INSERT INTO profile_tbl (user_id, first_name, last_name, hero_names, role_summary, role_title, focus_area, based_in, avatar_path, location_address, birth_date, experience_years, email, github_url, linkedin_url, updated_at)
    SELECT 2, first_name, last_name, hero_names, role_summary, role_title, focus_area, based_in, avatar_path, location_address, birth_date, experience_years, email, github_url, linkedin_url, GETDATE()
    FROM profile_tbl WHERE user_id = 1;
END
GO

-- ============================================================================
-- 2. STORED PROCEDURES
-- ============================================================================

-- -------------------------------------------------------------
-- 2.1 sp_GetUserPortfolioData
-- Retrieves all dynamic sections for a single user in multiple result sets
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_GetUserPortfolioData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Profile with calculated age
    SELECT 
        p.profile_id,
        p.user_id,
        p.first_name,
        p.last_name,
        p.hero_names,
        p.role_summary,
        p.role_title,
        p.focus_area,
        p.based_in,
        p.avatar_path,
        p.location_address,
        p.birth_date,
        CASE 
            WHEN p.birth_date IS NOT NULL THEN
                DATEDIFF(YEAR, p.birth_date, GETDATE()) - 
                CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, p.birth_date, GETDATE()), p.birth_date) > GETDATE() THEN 1 ELSE 0 END
            ELSE ISNULL(p.age, 19)
        END AS derived_age,
        p.experience_years,
        p.email,
        p.github_url,
        p.linkedin_url,
        p.updated_at,
        u.user_role,
        u.is_active
    FROM dbo.profile_tbl p
    INNER JOIN dbo.users_tbl u ON p.user_id = u.user_id
    WHERE p.user_id = @user_id;

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

    -- 8. Hobbies (with hobby_description)
    SELECT hobby_id, user_id, hobby_name, hobby_description, sort_order, is_active
    FROM dbo.hobbies_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY sort_order ASC, hobby_id ASC;
END;
GO

-- -------------------------------------------------------------
-- 2.2 sp_SaveProfile
-- Upserts user profile record linked to user_id
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveProfile
    @user_id INT,
    @first_name NVARCHAR(150),
    @last_name NVARCHAR(150),
    @hero_names NVARCHAR(500),
    @role_summary NVARCHAR(MAX) = NULL,
    @role_title NVARCHAR(150) = 'Web Developer',
    @focus_area NVARCHAR(150) = 'Interfaces & Data Systems',
    @based_in NVARCHAR(150) = 'Quezon City',
    @avatar_path NVARCHAR(255) = NULL,
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
        SET first_name = @first_name,
            last_name = @last_name,
            hero_names = @hero_names,
            role_summary = @role_summary,
            role_title = @role_title,
            focus_area = @focus_area,
            based_in = @based_in,
            avatar_path = ISNULL(@avatar_path, avatar_path),
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
        INSERT INTO dbo.profile_tbl (
            user_id, first_name, last_name, hero_names, role_summary, role_title,
            focus_area, based_in, avatar_path, location_address, birth_date,
            experience_years, email, github_url, linkedin_url, updated_at
        )
        VALUES (
            @user_id, @first_name, @last_name, @hero_names, @role_summary, @role_title,
            @focus_area, @based_in, @avatar_path, @location_address, @birth_date,
            @experience_years, @email, @github_url, @linkedin_url, GETDATE()
        );
    END;

    -- Also keep users_tbl first/last name in sync
    UPDATE dbo.users_tbl
    SET first_name = @first_name,
        last_name = @last_name
    WHERE user_id = @user_id;

    SELECT 1 AS success;
END;
GO

-- -------------------------------------------------------------
-- 2.3 TECH STACK PROCEDURES
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveTechStack
    @tech_id INT = 0,
    @user_id INT,
    @group_name NVARCHAR(100),
    @label NVARCHAR(100),
    @icon_path NVARCHAR(255),
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @tech_id > 0 AND EXISTS (SELECT 1 FROM dbo.tech_stacks_tbl WHERE tech_id = @tech_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.tech_stacks_tbl
        SET group_name = @group_name,
            label = @label,
            icon_path = @icon_path,
            sort_order = @sort_order
        WHERE tech_id = @tech_id AND user_id = @user_id;

        SELECT @tech_id AS tech_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tech_stacks_tbl (user_id, group_name, label, icon_path, sort_order, is_active)
        VALUES (@user_id, @group_name, @label, @icon_path, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS tech_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.4 SKILLS PROCEDURES
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveSkill
    @skill_id INT = 0,
    @user_id INT,
    @skill_name NVARCHAR(150),
    @proficiency_val INT,
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @skill_id > 0 AND EXISTS (SELECT 1 FROM dbo.skills_tbl WHERE skill_id = @skill_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.skills_tbl
        SET skill_name = @skill_name,
            proficiency_val = @proficiency_val,
            sort_order = @sort_order
        WHERE skill_id = @skill_id AND user_id = @user_id;

        SELECT @skill_id AS skill_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.skills_tbl (user_id, skill_name, proficiency_val, sort_order, is_active)
        VALUES (@user_id, @skill_name, @proficiency_val, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS skill_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.5 EXPERIENCE PROCEDURES (start_year and end_year)
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveExperience
    @exp_id INT = 0,
    @user_id INT,
    @role_title NVARCHAR(150),
    @company_name NVARCHAR(150),
    @start_year INT,
    @end_year INT = NULL,
    @is_current BIT = 0,
    @description_text NVARCHAR(MAX) = NULL,
    @tags NVARCHAR(255) = NULL,
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @is_current = 1
        SET @end_year = NULL;

    IF @exp_id > 0 AND EXISTS (SELECT 1 FROM dbo.experiences_tbl WHERE exp_id = @exp_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.experiences_tbl
        SET role_title = @role_title,
            company_name = @company_name,
            start_year = @start_year,
            end_year = @end_year,
            is_current = @is_current,
            description_text = @description_text,
            tags = @tags,
            sort_order = @sort_order
        WHERE exp_id = @exp_id AND user_id = @user_id;

        SELECT @exp_id AS exp_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.experiences_tbl (user_id, role_title, company_name, start_year, end_year, is_current, description_text, tags, sort_order, is_active)
        VALUES (@user_id, @role_title, @company_name, @start_year, @end_year, @is_current, @description_text, @tags, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS exp_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.6 PROJECT PROCEDURES
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveProject
    @project_id INT = 0,
    @user_id INT,
    @title NVARCHAR(150),
    @image_path NVARCHAR(255),
    @project_url NVARCHAR(255) = NULL,
    @tags NVARCHAR(255) = NULL,
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @project_id > 0 AND EXISTS (SELECT 1 FROM dbo.projects_tbl WHERE project_id = @project_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.projects_tbl
        SET title = @title,
            image_path = ISNULL(@image_path, image_path),
            project_url = @project_url,
            tags = @tags,
            sort_order = @sort_order
        WHERE project_id = @project_id AND user_id = @user_id;

        SELECT @project_id AS project_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.projects_tbl (user_id, title, image_path, project_url, tags, sort_order, is_active)
        VALUES (@user_id, @title, @image_path, @project_url, @tags, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS project_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.7 EDUCATION PROCEDURES (start_year and end_year)
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveEducation
    @edu_id INT = 0,
    @user_id INT,
    @title NVARCHAR(150),
    @subtitle NVARCHAR(150),
    @institution_name NVARCHAR(200),
    @start_year INT,
    @end_year INT = NULL,
    @is_current BIT = 0,
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @is_current = 1
        SET @end_year = NULL;

    IF @edu_id > 0 AND EXISTS (SELECT 1 FROM dbo.educations_tbl WHERE edu_id = @edu_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.educations_tbl
        SET title = @title,
            subtitle = @subtitle,
            institution_name = @institution_name,
            start_year = @start_year,
            end_year = @end_year,
            is_current = @is_current,
            sort_order = @sort_order
        WHERE edu_id = @edu_id AND user_id = @user_id;

        SELECT @edu_id AS edu_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.educations_tbl (user_id, title, subtitle, institution_name, start_year, end_year, is_current, sort_order, is_active)
        VALUES (@user_id, @title, @subtitle, @institution_name, @start_year, @end_year, @is_current, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS edu_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.8 AWARDS PROCEDURES
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveAward
    @award_id INT = 0,
    @user_id INT,
    @award_year NVARCHAR(50),
    @title NVARCHAR(150),
    @subtitle NVARCHAR(150),
    @organization_name NVARCHAR(200),
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @award_id > 0 AND EXISTS (SELECT 1 FROM dbo.awards_tbl WHERE award_id = @award_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.awards_tbl
        SET award_year = @award_year,
            title = @title,
            subtitle = @subtitle,
            organization_name = @organization_name,
            sort_order = @sort_order
        WHERE award_id = @award_id AND user_id = @user_id;

        SELECT @award_id AS award_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.awards_tbl (user_id, award_year, title, subtitle, organization_name, sort_order, is_active)
        VALUES (@user_id, @award_year, @title, @subtitle, @organization_name, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS award_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.9 HOBBIES PROCEDURES (hobby_name and hobby_description)
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveHobby
    @hobby_id INT = 0,
    @user_id INT,
    @hobby_name NVARCHAR(150),
    @hobby_description NVARCHAR(500) = NULL,
    @sort_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @hobby_id > 0 AND EXISTS (SELECT 1 FROM dbo.hobbies_tbl WHERE hobby_id = @hobby_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.hobbies_tbl
        SET hobby_name = @hobby_name,
            hobby_description = @hobby_description,
            sort_order = @sort_order
        WHERE hobby_id = @hobby_id AND user_id = @user_id;

        SELECT @hobby_id AS hobby_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.hobbies_tbl (user_id, hobby_name, hobby_description, sort_order, is_active)
        VALUES (@user_id, @hobby_name, @hobby_description, @sort_order, 1);

        SELECT SCOPE_IDENTITY() AS hobby_id;
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
    SELECT @@ROWCOUNT AS rows_affected;
END;
GO

-- -------------------------------------------------------------
-- 2.10 USER MANAGEMENT PROCEDURES (Admin supervision)
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.user_id AS UserId,
        u.first_name AS FirstName,
        u.last_name AS LastName,
        u.email AS Email,
        u.user_role AS Role,
        u.is_active AS IsActive,
        u.created_at AS CreatedAt,
        u.last_login_at AS LastLoginAt,
        ISNULL(u.login_count, 0) AS LoginCount,
        CASE WHEN p.profile_id IS NOT NULL THEN 1 ELSE 0 END AS HasProfile,
        p.birth_date AS BirthDate,
        p.role_title AS RoleTitle
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

-- -------------------------------------------------------------
-- 2.11 DASHBOARD TELEMETRY & STATS PROCEDURE
-- -------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        (SELECT COUNT(1) FROM dbo.users_tbl) AS TotalUsers,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE is_active = 1) AS ActiveUsers,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE is_active = 0) AS InactiveUsers,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE user_role = 'Admin') AS AdminUsers,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE CAST(created_at AS DATE) = CAST(GETDATE() AS DATE)) AS SignUpsToday,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE created_at >= DATEADD(DAY, -7, GETDATE())) AS SignUpsThisWeek,
        (SELECT COUNT(1) FROM dbo.users_tbl WHERE created_at >= DATEADD(MONTH, -1, GETDATE())) AS SignUpsThisMonth,
        (SELECT COUNT(1) FROM dbo.user_logins_tbl) AS TotalLogins,
        (SELECT COUNT(DISTINCT user_id) FROM dbo.user_logins_tbl WHERE CAST(login_time AS DATE) = CAST(GETDATE() AS DATE)) AS DailyActiveUsers,
        (SELECT COUNT(DISTINCT user_id) FROM dbo.user_logins_tbl WHERE login_time >= DATEADD(DAY, -30, GETDATE())) AS MonthlyActiveUsers,
        (SELECT COUNT(1) FROM dbo.password_resets_tbl WHERE status = 'pending') AS PendingPasswordResets,
        (SELECT COUNT(1) FROM dbo.projects_tbl) AS TotalProjects,
        (SELECT COUNT(1) FROM dbo.skills_tbl) AS TotalSkills,
        (SELECT COUNT(1) FROM dbo.tech_stacks_tbl) AS TotalTechStacks,
        (SELECT COUNT(1) FROM dbo.experiences_tbl) AS TotalExperiences,
        (SELECT COUNT(1) FROM dbo.educations_tbl) AS TotalEducations,
        (SELECT COUNT(1) FROM dbo.awards_tbl) AS TotalAwards,
        (SELECT COUNT(1) FROM dbo.hobbies_tbl) AS TotalHobbies;
END;
GO

PRINT 'Multi-user portfolio refactoring migration completed successfully.';
