-- =============================================================
-- Migration: 002_create_portfolio_tables_and_password_resets.sql
-- Description: Creates password_resets_tbl and all dynamic portfolio content tables with Enum CHECK constraints
-- Created: 2026-09-17
-- =============================================================

USE personal_portfolio_db;
GO

-- 1. PASSWORD RESETS / REMOVAL REQUESTS TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[password_resets_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE password_resets_tbl (
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
GO

-- 2. PROFILE & HERO INFORMATION TABLE (Single row configuration)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[profile_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE profile_tbl (
        profile_id INT IDENTITY(1,1) PRIMARY KEY,
        first_name NVARCHAR(150) NOT NULL DEFAULT 'Marc Kevin',
        last_name NVARCHAR(150) NOT NULL DEFAULT 'Del Mundo',
        hero_subline NVARCHAR(150) DEFAULT 'buildsinterfaces',
        hero_names NVARCHAR(500) DEFAULT 'Kevs,Marc Kevin,Software Engineer',
        role_summary NVARCHAR(MAX) NULL,
        role_title NVARCHAR(150) DEFAULT 'Web Developer',
        focus_area NVARCHAR(150) DEFAULT 'Interfaces & Data Systems',
        based_in NVARCHAR(150) DEFAULT 'Quezon City',
        avatar_path NVARCHAR(255) DEFAULT 'Assets/Images/pixelart_portrait.png',
        location_address NVARCHAR(255) DEFAULT 'B2 L6 Emerald St. Novaliches Proper, Q.C.',
        age NVARCHAR(50) DEFAULT '19 years old',
        experience_years NVARCHAR(50) DEFAULT '3 years of coding',
        email NVARCHAR(150) DEFAULT 'delmundo.marckevin.ferolino@gmail.com',
        github_url NVARCHAR(255) DEFAULT 'https://github.com/marcKevzzz',
        linkedin_url NVARCHAR(255) DEFAULT 'https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436',
        updated_at DATETIME DEFAULT GETDATE()
    );
END
GO

-- 3. TECH STACK TABLE (with Enum Category CHECK Constraint)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tech_stacks_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE tech_stacks_tbl (
        tech_id INT IDENTITY(1,1) PRIMARY KEY,
        group_name NVARCHAR(100) NOT NULL CHECK (group_name IN ('Frontend', '3D & Motion', 'Backend & Database', 'Tools & DevOps')),
        label NVARCHAR(100) NOT NULL,      -- 'HTML5', 'CSS3', 'GSAP', 'C#'
        icon_path NVARCHAR(255) NOT NULL,  -- 'Assets/Icons/html5.svg'
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 4. SKILLS TABLE (Aligned with Default.aspx Skills section)
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[skills_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE skills_tbl (
        skill_id INT IDENTITY(1,1) PRIMARY KEY,
        skill_name NVARCHAR(150) NOT NULL,
        proficiency_val INT NOT NULL CHECK (proficiency_val BETWEEN 0 AND 100), -- 0 to 100 percentage
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 5. EXPERIENCE TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[experiences_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE experiences_tbl (
        exp_id INT IDENTITY(1,1) PRIMARY KEY,
        role_title NVARCHAR(150) NOT NULL,
        company_name NVARCHAR(150) NOT NULL,
        period_range NVARCHAR(100) NOT NULL,       -- 'AUG 2025 — NOV 2025'
        description_text NVARCHAR(MAX) NULL,
        tags NVARCHAR(255) NULL,                   -- Comma-separated: 'React, Tailwind CSS'
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 6. PROJECTS TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[projects_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE projects_tbl (
        project_id INT IDENTITY(1,1) PRIMARY KEY,
        title NVARCHAR(150) NOT NULL,
        image_path NVARCHAR(255) NOT NULL,
        project_url NVARCHAR(255) NULL,
        tags NVARCHAR(255) NULL,                   -- Comma-separated: 'HTML5, CSS3, JavaScript'
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 7. EDUCATION TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[educations_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE educations_tbl (
        edu_id INT IDENTITY(1,1) PRIMARY KEY,
        year_period NVARCHAR(100) NOT NULL,        -- '2024 — Present'
        title NVARCHAR(150) NOT NULL,              -- 'Collegiate Level'
        subtitle NVARCHAR(150) NOT NULL,           -- 'B.S. Information Technology'
        institution_name NVARCHAR(200) NOT NULL,   -- 'Quezon City University'
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 8. AWARDS & RECOGNITIONS TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[awards_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE awards_tbl (
        award_id INT IDENTITY(1,1) PRIMARY KEY,
        award_year NVARCHAR(50) NOT NULL,          -- '2026'
        title NVARCHAR(150) NOT NULL,              -- 'DevCup 2026 Competition'
        subtitle NVARCHAR(150) NOT NULL,           -- '2nd Place QCU'
        organization_name NVARCHAR(200) NOT NULL,  -- 'Quezon City University'
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

-- 9. HOBBIES TABLE
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[hobbies_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE hobbies_tbl (
        hobby_id INT IDENTITY(1,1) PRIMARY KEY,
        hobby_name NVARCHAR(150) NOT NULL,
        sort_order INT DEFAULT 0,
        is_active BIT DEFAULT 1
    );
END
GO

ALTER TABLE users_tbl
ADD CONSTRAINT CK_users_tbl_user_role 
CHECK (user_role IN ('Admin', 'User'));
GO
