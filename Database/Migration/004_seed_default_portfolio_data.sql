-- =============================================================
-- Migration: 004_seed_default_portfolio_data.sql
-- Description: Inserts initial default portfolio data extracted from Default.aspx
-- Database: personal_portfolio_db
-- Created: 2026-09-17
-- =============================================================

USE personal_portfolio_db;
GO

SET NOCOUNT ON;

-- 1. PROFILE & HERO SECTION SEED DATA
IF NOT EXISTS (SELECT 1 FROM profile_tbl)
BEGIN
    INSERT INTO profile_tbl (
        first_name,
        last_name,
        hero_subline,
        hero_names,
        role_summary,
        role_title,
        focus_area,
        based_in,
        avatar_path,
        location_address,
        age,
        experience_years,
        email,
        github_url,
        linkedin_url,
        updated_at
    )
    VALUES (
        N'Marc Kevin',
        N'Del Mundo',
        N'builds interfaces',
        N'Kevs,Marc Kevin,Del Mundo',
        N'Web developer working across front-end interfaces and the structured data systems behind them — from motion-driven product pages to large-scale JSON datasets.',
        N'Web Developer',
        N'Interfaces & Data Systems',
        N'Quezon City',
        N'Assets/Images/pixelart_portrait.png',
        N'B2 L6 Emerald St. Novaliches Proper, Q.C.',
        N'19 years old',
        N'3 years of coding',
        N'delmundo.marckevin.ferolino@gmail.com',
        N'https://github.com/marcKevzzz',
        N'https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436',
        GETDATE()
    );
    PRINT 'Inserted default row into profile_tbl.';
END
ELSE
BEGIN
    PRINT 'profile_tbl already has data.';
END
GO

-- 2. TECH STACK SEED DATA (Frontend, 3D & Motion, Backend & Database, Tools & DevOps)
IF NOT EXISTS (SELECT 1 FROM tech_stacks_tbl)
BEGIN
    INSERT INTO tech_stacks_tbl (group_name, label, icon_path, sort_order, is_active)
    VALUES
        -- Frontend
        ('Frontend', 'HTML5', 'Assets/Icons/html5.svg', 1, 1),
        ('Frontend', 'CSS3', 'Assets/Icons/css3.svg', 2, 1),
        ('Frontend', 'JavaScript', 'Assets/Icons/js.svg', 3, 1),
        ('Frontend', 'TypeScript', 'Assets/Icons/typescript.svg', 4, 1),
        ('Frontend', 'Tailwind CSS', 'Assets/Icons/tailwindcss.svg', 5, 1),

        -- 3D & Motion
        ('3D & Motion', 'GSAP', 'Assets/Icons/gsap.svg', 6, 1),
        ('3D & Motion', 'Three.js', 'Assets/Icons/threejs.svg', 7, 1),
        ('3D & Motion', 'Motion', 'Assets/Icons/motion.svg', 8, 1),
        ('3D & Motion', 'Figma', 'Assets/Icons/figma.svg', 9, 1),

        -- Backend & Database
        ('Backend & Database', 'C#', 'Assets/Icons/csharp.svg', 10, 1),
        ('Backend & Database', '.NET Core', 'Assets/Icons/netcore.svg', 11, 1),
        ('Backend & Database', 'Node.js', 'Assets/Icons/nodejs.svg', 12, 1),
        ('Backend & Database', 'PostgreSQL', 'Assets/Icons/postgresql.svg', 13, 1),
        ('Backend & Database', 'MySQL', 'Assets/Icons/mysql.svg', 14, 1),

        -- Tools & DevOps
        ('Tools & DevOps', 'Git', 'Assets/Icons/git.svg', 15, 1),
        ('Tools & DevOps', 'GitHub', 'Assets/Icons/github.svg', 16, 1),
        ('Tools & DevOps', 'VS Code', 'Assets/Icons/vscode.svg', 17, 1),
        ('Tools & DevOps', 'Visual Studio', 'Assets/Icons/visualstudio.svg', 18, 1);

    PRINT 'Inserted 18 tech stack items into tech_stacks_tbl.';
END
ELSE
BEGIN
    PRINT 'tech_stacks_tbl already has data.';
END
GO

-- 3. SKILLS SEED DATA (Matched with Default.aspx Skills section)
IF NOT EXISTS (SELECT 1 FROM skills_tbl)
BEGIN
    INSERT INTO skills_tbl (skill_name, proficiency_val, sort_order, is_active)
    VALUES
        (N'Frontend Development', 92, 1, 1),
        (N'Motion & Interaction', 85, 2, 1),
        (N'Data Structuring', 88, 3, 1),
        (N'3D Web Integration', 70, 4, 1),
        (N'Problem Solving', 85, 5, 1);

    PRINT 'Inserted 5 skills into skills_tbl.';
END
ELSE
BEGIN
    PRINT 'skills_tbl already has data.';
END
GO

-- 4. EXPERIENCE SEED DATA
IF NOT EXISTS (SELECT 1 FROM experiences_tbl)
BEGIN
    INSERT INTO experiences_tbl (role_title, company_name, period_range, description_text, tags, sort_order, is_active)
    VALUES
        (
            N'Front-End Developer',
            N'Prince IT Solution',
            N'AUGUST 2025 — NOVEMBER 2025',
            N'Design and develop responsive web interfaces using React and Tailwind. Collaborate with team members to deliver efficient and visually appealing web solutions.',
            N'React, Tailwind CSS, UI Development, Team Collaboration',
            1,
            1
        ),
        (
            N'Full-Stack Developer',
            N'Teranet Fiber, Q.C.',
            N'MARCH 2024 — APRIL 2024',
            N'Assisted in basic web development, backend tasks, and system support. Gained exposure to network operations and technical support workflows.',
            N'Web Development, Backend Tasks, System Support, Network Operations',
            2,
            1
        );

    PRINT 'Inserted 2 experience entries into experiences_tbl.';
END
ELSE
BEGIN
    PRINT 'experiences_tbl already has data.';
END
GO

-- 5. PROJECTS SEED DATA (Bento grid showcase)
IF NOT EXISTS (SELECT 1 FROM projects_tbl)
BEGIN
    INSERT INTO projects_tbl (title, image_path, project_url, tags, sort_order, is_active)
    VALUES
        (
            N'Samson Dental Center',
            N'Assets/Images/samsondentalcenter.png',
            N'https://github.com/marcKevzzz/SamsonDentalCenterManagementSystem',
            N'HTML5, CSS3, JavaScript, Healthcare UX, Responsive',
            1,
            1
        ),
        (
            N'Review Bot Assistant',
            N'Assets/Images/reviewbot.png',
            N'https://github.com/marcKevzzz/reviewbot',
            N'Chatbot AI, Conversational UI, DOM Scripting',
            2,
            1
        ),
        (
            N'CPU Scheduling Calculator',
            N'Assets/Images/cpu_scheduler.png',
            N'https://github.com/marcKevzzz/cpu-scheduling-calculator',
            N'OS Scheduling, Gantt Chart, Algorithm Visualizer',
            3,
            1
        ),
        (
            N'MLBB Mayhem',
            N'Assets/Images/mlbb_mayhem.png',
            N'https://github.com/marcKevzzz/MLBB-Meyhem',
            N'Esports UI, Draft Simulator, Interactive Gaming',
            4,
            1
        ),
        (
            N'AeroStack Payroll System',
            N'Assets/Images/payroll.png',
            N'https://github.com/marcKevzzz/Payroll-Web-System',
            N'Enterprise UI, Data Analytics, Payroll Engine, DTR Logging',
            5,
            1
        ),
        (
            N'Tower of Hanoi',
            N'Assets/Images/tower_of_hanoi.png',
            N'https://github.com/marcKevzzz/towerOfHanoi',
            N'Game Physics, Leaderboards, Performance Stats',
            6,
            1
        );

    PRINT 'Inserted 6 projects into projects_tbl.';
END
ELSE
BEGIN
    PRINT 'projects_tbl already has data.';
END
GO

-- 6. EDUCATION SEED DATA
IF NOT EXISTS (SELECT 1 FROM educations_tbl)
BEGIN
    INSERT INTO educations_tbl (year_period, title, subtitle, institution_name, sort_order, is_active)
    VALUES
        (
            N'2024 — Present',
            N'Collegiate Level',
            N'Bachelor of Science in Information Technology',
            N'Quezon City University',
            1,
            1
        ),
        (
            N'June — 2024',
            N'Senior High School',
            N'Information and Communication Technology',
            N'Gardner College Diliman',
            2,
            1
        );

    PRINT 'Inserted 2 education entries into educations_tbl.';
END
ELSE
BEGIN
    PRINT 'educations_tbl already has data.';
END
GO

-- 7. AWARDS & RECOGNITIONS SEED DATA
IF NOT EXISTS (SELECT 1 FROM awards_tbl)
BEGIN
    INSERT INTO awards_tbl (award_year, title, subtitle, organization_name, sort_order, is_active)
    VALUES
        (
            N'2026',
            N'DevCup 2026 Competition',
            N'2nd Place QCU',
            N'Quezon City University',
            1,
            1
        ),
        (
            N'2025',
            N'Code Quest 2025',
            N'Certificate of Participation',
            N'Quezon City University',
            2,
            1
        ),
        (
            N'2026',
            N'AWS Learning Club QCU',
            N'Operational Member',
            N'AWS Learning Club',
            3,
            1
        ),
        (
            N'2025',
            N'The Hour of Code',
            N'Certificate of Completion',
            N'ASEAN Youth Organization',
            4,
            1
        );

    PRINT 'Inserted 4 awards into awards_tbl.';
END
ELSE
BEGIN
    PRINT 'awards_tbl already has data.';
END
GO

-- 8. HOBBIES SEED DATA
IF NOT EXISTS (SELECT 1 FROM hobbies_tbl)
BEGIN
    INSERT INTO hobbies_tbl (hobby_name, sort_order, is_active)
    VALUES
        (N'Reading Manhwa, Manhua & Manga', 1, 1),
        (N'Online Games', 2, 1),
        (N'Coding', 3, 1),
        (N'Basketball', 4, 1);

    PRINT 'Inserted 4 hobbies into hobbies_tbl.';
END
ELSE
BEGIN
    PRINT 'hobbies_tbl already has data.';
END
GO

PRINT 'Default portfolio seed data execution completed successfully.';
