# Database Schema Documentation

**Database Name:** `personal_portfolio_db`  
**RDBMS:** Microsoft SQL Server (MSSQL / SQL Server Express)  
**Naming Convention:** `snake_case` (lowercase with underscores)

---

## Tables Overview

| Table Name | Description | Primary Key | Foreign Keys |
| :--- | :--- | :--- | :--- |
| [`users_tbl`](#1-users_tbl) | Registered user and administrator accounts & credentials | `user_id` | — |
| [`password_resets_tbl`](#2-password_resets_tbl) | Password reset tokens and admin password removal requests | `reset_id` | `user_id` &rarr; `users_tbl(user_id)` |
| [`profile_tbl`](#3-profile_tbl) | Hero and public personal information configuration | `profile_id` | — |
| [`tech_stacks_tbl`](#4-tech_stacks_tbl) | Technologies, frameworks, and tools with icon badges | `tech_id` | — |
| [`skills_tbl`](#5-skills_tbl) | Technical competencies and animated percentage progress bars | `skill_id` | — |
| [`experiences_tbl`](#6-experiences_tbl) | Work experience history, companies, and roles | `exp_id` | — |
| [`projects_tbl`](#7-projects_tbl) | Portfolio showcase projects, screenshots, and URLs | `project_id` | — |
| [`educations_tbl`](#8-educations_tbl) | Educational degrees, periods, and institutions | `edu_id` | — |
| [`awards_tbl`](#9-awards_tbl) | Competitions, awards, and certificates | `award_id` | — |
| [`hobbies_tbl`](#10-hobbies_tbl) | Personal interests and hobby tags | `hobby_id` | — |

---

## Table Definitions

### 1. `users_tbl`
Stores registered user accounts and administrator authentication credentials.

| Column Name | Data Type | Nullable | Default | Constraints / Enum | Description |
| :--- | :--- | :---: | :--- | :--- | :--- |
| `user_id` | `INT` | No | `IDENTITY(1,1)` | `PRIMARY KEY` | Unique user ID |
| `first_name` | `NVARCHAR(150)` | No | — | — | First name |
| `last_name` | `NVARCHAR(150)` | No | — | — | Last name / surname |
| `email` | `NVARCHAR(150)` | No | — | `UNIQUE` | Unique sign-in email |
| `password_hash` | `NVARCHAR(256)` | No | — | — | SHA-256 hashed password |
| `user_role` | `NVARCHAR(50)` | Yes | `'User'` | `CHECK ('Admin', 'User')` | Role Enum |
| `is_active` | `BIT` | Yes | `1` | — | `1` = Active, `0` = Deactivated |
| `created_at` | `DATETIME` | Yes | `GETDATE()` | — | Registration timestamp |

---

### 2. `password_resets_tbl`
Stores password reset requests, admin removal workflows, and expiration states.

| Column Name | Data Type | Nullable | Default | Constraints / Enum | Description |
| :--- | :--- | :---: | :--- | :--- | :--- |
| `reset_id` | `INT` | No | `IDENTITY(1,1)` | `PRIMARY KEY` | Unique request ID |
| `user_id` | `INT` | Yes | — | `FOREIGN KEY` &rarr; `users_tbl` | References `users_tbl(user_id)` |
| `email` | `NVARCHAR(150)` | No | — | — | Requesting user email |
| `reset_token` | `NVARCHAR(256)` | Yes | — | — | Optional secure reset token |
| `reason` | `NVARCHAR(500)` | Yes | — | — | User reason for reset/removal |
| `status` | `NVARCHAR(50)` | Yes | `'pending'` | `CHECK ('pending', 'approved', 'password_removed', 'used', 'expired')` | Status Enum |
| `expires_at` | `DATETIME` | Yes | — | — | Token expiry timestamp |
| `created_at` | `DATETIME` | Yes | `GETDATE()` | — | Request timestamp |

---

### 3. `profile_tbl`
Single-row configuration table storing the hero section and public profile metadata.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `profile_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `first_name` | `NVARCHAR(150)` | No | `'Marc Kevin'` | First name |
| `last_name` | `NVARCHAR(150)` | No | `'Del Mundo'` | Last name |
| `hero_subline` | `NVARCHAR(150)` | Yes | `'buildsinterfaces'` | Subline heading |
| `hero_names` | `NVARCHAR(500)` | Yes | `'Kevs,Marc Kevin,Software Engineer'` | Comma-delimited aliases/titles |
| `role_summary` | `NVARCHAR(MAX)` | Yes | — | About me / summary paragraph |
| `role_title` | `NVARCHAR(150)` | Yes | `'Web Developer'` | Primary role title |
| `focus_area` | `NVARCHAR(150)` | Yes | `'Interfaces & Data Systems'` | Area of focus |
| `based_in` | `NVARCHAR(150)` | Yes | `'Quezon City'` | City / location |
| `avatar_path` | `NVARCHAR(255)` | Yes | `'Assets/Images/pixelart_portrait.png'` | Profile portrait image path |
| `location_address` | `NVARCHAR(255)` | Yes | `'B2 L6 Emerald St. Novaliches Proper, Q.C.'` | Full address |
| `age` | `INT` | Yes | `19` | Age in years |
| `experience_years` | `INT` | Yes | `3` | Years of experience |
| `email` | `NVARCHAR(150)` | Yes | `'delmundo.marckevin.ferolino@gmail.com'` | Contact email |
| `github_url` | `NVARCHAR(255)` | Yes | `'https://github.com/marcKevzzz'` | GitHub profile URL |
| `linkedin_url` | `NVARCHAR(255)` | Yes | — | LinkedIn profile URL |
| `updated_at` | `DATETIME` | Yes | `GETDATE()` | Last updated timestamp |

---

### 4. `tech_stacks_tbl`
Stores technical stack items grouped by domain category Enum.

| Column Name | Data Type | Nullable | Default | Constraints / Enum | Description |
| :--- | :--- | :---: | :--- | :--- | :--- |
| `tech_id` | `INT` | No | `IDENTITY(1,1)` | `PRIMARY KEY` | Primary Key |
| `group_name` | `NVARCHAR(100)` | No | — | `CHECK ('Frontend', '3D & Motion', 'Backend & Database', 'Tools & DevOps')` | Group Category Enum |
| `label` | `NVARCHAR(100)` | No | — | — | Tech name (e.g. `'HTML5'`, `'C#'`) |
| `icon_path` | `NVARCHAR(255)` | No | — | — | SVG / PNG icon file path |
| `sort_order` | `INT` | Yes | `0` | — | Display sorting order |
| `is_active` | `BIT` | Yes | `1` | — | Visibility toggle |

---

### 5. `skills_tbl`
Stores technical skill competencies and animated percentage progress bars (0–100) exactly matching `Default.aspx`.

| Column Name | Data Type | Nullable | Default | Constraints | Description |
| :--- | :--- | :---: | :--- | :--- | :--- |
| `skill_id` | `INT` | No | `IDENTITY(1,1)` | `PRIMARY KEY` | Primary Key |
| `skill_name` | `NVARCHAR(150)` | No | — | — | Skill title (e.g. `'Frontend Development'`) |
| `proficiency_val` | `INT` | No | — | `CHECK (proficiency_val BETWEEN 0 AND 100)` | Percentage value (0–100) |
| `sort_order` | `INT` | Yes | `0` | — | Display sort order |
| `is_active` | `BIT` | Yes | `1` | — | Visibility toggle |

---

### 6. `experiences_tbl`
Stores employment, freelance, and position history.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `exp_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `role_title` | `NVARCHAR(150)` | No | — | Job title (e.g. `'Front-End Developer'`) |
| `company_name` | `NVARCHAR(150)` | No | — | Company / Organization name |
| `period_range` | `NVARCHAR(100)` | No | — | Date range (e.g. `'AUG 2025 — NOV 2025'`) |
| `description_text`| `NVARCHAR(MAX)` | Yes | — | Responsibilities and impact summary |
| `tags` | `NVARCHAR(255)` | Yes | — | Comma-delimited skill tags (e.g. `'React, Tailwind CSS'`) |
| `sort_order` | `INT` | Yes | `0` | Display sort order |
| `is_active` | `BIT` | Yes | `1` | Visibility toggle |

---

### 7. `projects_tbl`
Stores featured showcase projects.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `project_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `title` | `NVARCHAR(150)` | No | — | Project title |
| `image_path` | `NVARCHAR(255)` | No | — | Screenshot preview path |
| `project_url` | `NVARCHAR(255)` | Yes | — | Live URL or GitHub repo link |
| `tags` | `NVARCHAR(255)` | Yes | — | Comma-delimited technology tags |
| `sort_order` | `INT` | Yes | `0` | Display sort order |
| `is_active` | `BIT` | Yes | `1` | Visibility toggle |

---

### 8. `educations_tbl`
Stores academic degrees, certifications, and educational milestones.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `edu_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `year_period` | `NVARCHAR(100)` | No | — | Period (e.g. `'2024 — Present'`) |
| `title` | `NVARCHAR(150)` | No | — | Degree / Level (e.g. `'Collegiate Level'`) |
| `subtitle` | `NVARCHAR(150)` | No | — | Course / Major (e.g. `'B.S. Information Technology'`) |
| `institution_name`| `NVARCHAR(200)`| No | — | School / University name |
| `sort_order` | `INT` | Yes | `0` | Display sort order |
| `is_active` | `BIT` | Yes | `1` | Visibility toggle |

---

### 9. `awards_tbl`
Stores competition achievements, certificates, and recognitions.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `award_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `award_year` | `NVARCHAR(50)` | No | — | Year / Date (e.g. `'2026'`) |
| `title` | `NVARCHAR(150)` | No | — | Competition / Award title |
| `subtitle` | `NVARCHAR(150)` | No | — | Award rank / category (e.g. `'2nd Place QCU'`) |
| `organization_name`| `NVARCHAR(200)`| No | — | Issuer / Organization name |
| `sort_order` | `INT` | Yes | `0` | Display sort order |
| `is_active` | `BIT` | Yes | `1` | Visibility toggle |

---

### 10. `hobbies_tbl`
Stores personal interests displayed on the landing page.

| Column Name | Data Type | Nullable | Default | Description |
| :--- | :--- | :---: | :--- | :--- |
| `hobby_id` | `INT` | No | `IDENTITY(1,1)` | Primary Key |
| `hobby_name` | `NVARCHAR(150)` | No | — | Hobby / Interest name |
| `sort_order` | `INT` | Yes | `0` | Display sort order |
| `is_active` | `BIT` | Yes | `1` | Visibility toggle |
