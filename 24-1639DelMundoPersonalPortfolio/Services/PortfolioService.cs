using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Caching;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Services
{
    public static class PortfolioService
    {
        private const string CacheKey = "PORTFOLIO_DATA_AGGREGATE_CACHE";
        private static readonly object CacheLock = new object();

        /// <summary>
        /// Retrieves the complete portfolio data with server memory caching.
        /// Gracefully falls back to complete default data if the database is unreachable, empty, or has blank columns.
        /// </summary>
        public static PortfolioDataDto GetPortfolioData(bool forceRefresh = false)
        {
            if (!forceRefresh)
            {
                var cached = HttpRuntime.Cache?.Get(CacheKey) as PortfolioDataDto;
                if (cached != null)
                {
                    return cached;
                }
            }

            lock (CacheLock)
            {
                if (!forceRefresh)
                {
                    var cached = HttpRuntime.Cache?.Get(CacheKey) as PortfolioDataDto;
                    if (cached != null)
                    {
                        return cached;
                    }
                }

                PortfolioDataDto data = null;
                try
                {
                    data = FetchFromDatabase();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[PortfolioService] Database fetch error: {ex.Message}");
                }

                // If database failed or returned empty data, use complete default fallback
                if (data == null || data.Profile == null)
                {
                    data = GetDefaultFallbackData();
                }
                else
                {
                    // Ensure each collection has defaults if empty or incomplete
                    EnsureDefaults(data);
                }

                if (HttpRuntime.Cache != null && data != null)
                {
                    HttpRuntime.Cache.Insert(
                        CacheKey,
                        data,
                        null,
                        DateTime.Now.AddMinutes(30),
                        Cache.NoSlidingExpiration,
                        CacheItemPriority.High,
                        null
                    );
                }

                return data;
            }
        }

        /// <summary>
        /// Invalidates the server-side portfolio cache (e.g., after admin edits).
        /// </summary>
        public static void InvalidateCache()
        {
            try
            {
                HttpRuntime.Cache?.Remove(CacheKey);
            }
            catch
            {
                // Ignore cache removal errors
            }
        }

        private static string GetStringWithFallback(DataRow row, string colName, string fallback)
        {
            if (row == null || !row.Table.Columns.Contains(colName) || row[colName] == DBNull.Value)
            {
                return fallback;
            }
            string val = row[colName]?.ToString();
            return string.IsNullOrWhiteSpace(val) ? fallback : val.Trim();
        }

        private static int GetIntWithFallback(DataRow row, string colName, int fallback)
        {
            if (row == null || !row.Table.Columns.Contains(colName) || row[colName] == DBNull.Value)
            {
                return fallback;
            }
            return int.TryParse(row[colName]?.ToString(), out int parsed) ? parsed : fallback;
        }

        private static PortfolioDataDto FetchFromDatabase()
        {
            var result = new PortfolioDataDto();
            var fallback = GetDefaultFallbackData();

            // 1. Profile
            try
            {
                DataTable profileDt = DatabaseHelper.ExecuteDataTable("SELECT TOP 1 * FROM profile_tbl ORDER BY profile_id DESC");
                if (profileDt != null && profileDt.Rows.Count > 0)
                {
                    var row = profileDt.Rows[0];
                    result.Profile = new ProfileDto
                    {
                        ProfileId = GetIntWithFallback(row, "profile_id", 1),
                        FirstName = GetStringWithFallback(row, "first_name", fallback.Profile.FirstName),
                        LastName = GetStringWithFallback(row, "last_name", fallback.Profile.LastName),
                        HeroSubline = GetStringWithFallback(row, "hero_subline", fallback.Profile.HeroSubline),
                        HeroNames = GetStringWithFallback(row, "hero_names", fallback.Profile.HeroNames),
                        RoleSummary = GetStringWithFallback(row, "role_summary", fallback.Profile.RoleSummary),
                        RoleTitle = GetStringWithFallback(row, "role_title", fallback.Profile.RoleTitle),
                        FocusArea = GetStringWithFallback(row, "focus_area", fallback.Profile.FocusArea),
                        BasedIn = GetStringWithFallback(row, "based_in", fallback.Profile.BasedIn),
                        AvatarPath = GetStringWithFallback(row, "avatar_path", fallback.Profile.AvatarPath),
                        LocationAddress = GetStringWithFallback(row, "location_address", fallback.Profile.LocationAddress),
                        Age = GetIntWithFallback(row, "age", fallback.Profile.Age),
                        ExperienceYears = GetIntWithFallback(row, "experience_years", fallback.Profile.ExperienceYears),
                        Email = GetStringWithFallback(row, "email", fallback.Profile.Email),
                        GithubUrl = GetStringWithFallback(row, "github_url", fallback.Profile.GithubUrl),
                        LinkedinUrl = GetStringWithFallback(row, "linkedin_url", fallback.Profile.LinkedinUrl)
                    };
                }
                else
                {
                    result.Profile = fallback.Profile;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Profile fetch error: {ex.Message}");
                result.Profile = fallback.Profile;
            }

            // 2. Tech Stack
            try
            {
                DataTable techDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM tech_stacks_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY group_name, sort_order, tech_id ASC");
                if (techDt != null && techDt.Rows.Count > 0)
                {
                    foreach (DataRow row in techDt.Rows)
                    {
                        result.TechStacks.Add(new TechStackItemDto
                        {
                            TechId = GetIntWithFallback(row, "tech_id", 0),
                            GroupName = GetStringWithFallback(row, "group_name", "Frontend"),
                            Label = GetStringWithFallback(row, "label", "Tech"),
                            IconPath = GetStringWithFallback(row, "icon_path", "Assets/Icons/csharp.svg"),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] TechStacks fetch error: {ex.Message}");
            }
            if (result.TechStacks.Count == 0)
            {
                result.TechStacks = new List<TechStackItemDto>(fallback.TechStacks);
            }

            // 3. Skills
            try
            {
                DataTable skillsDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM skills_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, skill_id ASC");
                if (skillsDt != null && skillsDt.Rows.Count > 0)
                {
                    foreach (DataRow row in skillsDt.Rows)
                    {
                        result.Skills.Add(new SkillDto
                        {
                            SkillId = GetIntWithFallback(row, "skill_id", 0),
                            SkillName = GetStringWithFallback(row, "skill_name", "Skill"),
                            ProficiencyVal = GetIntWithFallback(row, "proficiency_val", 80),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Skills fetch error: {ex.Message}");
            }
            if (result.Skills.Count == 0)
            {
                result.Skills = new List<SkillDto>(fallback.Skills);
            }

            // 4. Experiences
            try
            {
                DataTable expDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM experiences_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, exp_id ASC");
                if (expDt != null && expDt.Rows.Count > 0)
                {
                    foreach (DataRow row in expDt.Rows)
                    {
                        result.Experiences.Add(new ExperienceDto
                        {
                            ExpId = GetIntWithFallback(row, "exp_id", 0),
                            RoleTitle = GetStringWithFallback(row, "role_title", "Developer"),
                            CompanyName = GetStringWithFallback(row, "company_name", "Company"),
                            PeriodRange = GetStringWithFallback(row, "period_range", "2024 — Present"),
                            DescriptionText = GetStringWithFallback(row, "description_text", ""),
                            Tags = GetStringWithFallback(row, "tags", ""),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Experiences fetch error: {ex.Message}");
            }
            if (result.Experiences.Count == 0)
            {
                result.Experiences = new List<ExperienceDto>(fallback.Experiences);
            }

            // 5. Projects
            try
            {
                DataTable projDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM projects_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, project_id ASC");
                if (projDt != null && projDt.Rows.Count > 0)
                {
                    foreach (DataRow row in projDt.Rows)
                    {
                        result.Projects.Add(new ProjectDto
                        {
                            ProjectId = GetIntWithFallback(row, "project_id", 0),
                            Title = GetStringWithFallback(row, "title", "Project"),
                            ImagePath = GetStringWithFallback(row, "image_path", "Assets/Images/samsondentalcenter.png"),
                            ProjectUrl = GetStringWithFallback(row, "project_url", "https://github.com/marcKevzzz"),
                            Tags = GetStringWithFallback(row, "tags", ""),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Projects fetch error: {ex.Message}");
            }
            if (result.Projects.Count == 0)
            {
                result.Projects = new List<ProjectDto>(fallback.Projects);
            }

            // 6. Education
            try
            {
                DataTable eduDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM educations_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, edu_id ASC");
                if (eduDt != null && eduDt.Rows.Count > 0)
                {
                    foreach (DataRow row in eduDt.Rows)
                    {
                        result.Educations.Add(new EducationDto
                        {
                            EduId = GetIntWithFallback(row, "edu_id", 0),
                            YearPeriod = GetStringWithFallback(row, "year_period", "2024 — Present"),
                            Title = GetStringWithFallback(row, "title", "Education Title"),
                            Subtitle = GetStringWithFallback(row, "subtitle", "Degree / Major"),
                            InstitutionName = GetStringWithFallback(row, "institution_name", "Institution"),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Educations fetch error: {ex.Message}");
            }
            if (result.Educations.Count == 0)
            {
                result.Educations = new List<EducationDto>(fallback.Educations);
            }

            // 7. Awards
            try
            {
                DataTable awardsDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM awards_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, award_id ASC");
                if (awardsDt != null && awardsDt.Rows.Count > 0)
                {
                    foreach (DataRow row in awardsDt.Rows)
                    {
                        result.Awards.Add(new AwardDto
                        {
                            AwardId = GetIntWithFallback(row, "award_id", 0),
                            AwardYear = GetStringWithFallback(row, "award_year", "2026"),
                            Title = GetStringWithFallback(row, "title", "Award Title"),
                            Subtitle = GetStringWithFallback(row, "subtitle", "Achievement"),
                            OrganizationName = GetStringWithFallback(row, "organization_name", "Organization"),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Awards fetch error: {ex.Message}");
            }
            if (result.Awards.Count == 0)
            {
                result.Awards = new List<AwardDto>(fallback.Awards);
            }

            // 8. Hobbies
            try
            {
                DataTable hobbiesDt = DatabaseHelper.ExecuteDataTable("SELECT * FROM hobbies_tbl WHERE is_active = 1 OR is_active IS NULL ORDER BY sort_order, hobby_id ASC");
                if (hobbiesDt != null && hobbiesDt.Rows.Count > 0)
                {
                    foreach (DataRow row in hobbiesDt.Rows)
                    {
                        result.Hobbies.Add(new HobbyDto
                        {
                            HobbyId = GetIntWithFallback(row, "hobby_id", 0),
                            HobbyName = GetStringWithFallback(row, "hobby_name", "Hobby"),
                            SortOrder = GetIntWithFallback(row, "sort_order", 0),
                            IsActive = row.Table.Columns.Contains("is_active") && row["is_active"] != DBNull.Value ? Convert.ToBoolean(row["is_active"]) : true
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] Hobbies fetch error: {ex.Message}");
            }
            if (result.Hobbies.Count == 0)
            {
                result.Hobbies = new List<HobbyDto>(fallback.Hobbies);
            }

            return result;
        }

        private static void EnsureDefaults(PortfolioDataDto data)
        {
            var def = GetDefaultFallbackData();

            if (data.Profile == null || string.IsNullOrWhiteSpace(data.Profile.FirstName))
            {
                data.Profile = def.Profile;
            }

            if (data.TechStacks == null || data.TechStacks.Count == 0)
            {
                data.TechStacks = new List<TechStackItemDto>(def.TechStacks);
            }

            if (data.Skills == null || data.Skills.Count == 0)
            {
                data.Skills = new List<SkillDto>(def.Skills);
            }

            if (data.Experiences == null || data.Experiences.Count == 0)
            {
                data.Experiences = new List<ExperienceDto>(def.Experiences);
            }

            if (data.Projects == null || data.Projects.Count == 0)
            {
                data.Projects = new List<ProjectDto>(def.Projects);
            }

            if (data.Educations == null || data.Educations.Count == 0)
            {
                data.Educations = new List<EducationDto>(def.Educations);
            }

            if (data.Awards == null || data.Awards.Count == 0)
            {
                data.Awards = new List<AwardDto>(def.Awards);
            }

            if (data.Hobbies == null || data.Hobbies.Count == 0)
            {
                data.Hobbies = new List<HobbyDto>(def.Hobbies);
            }
        }

        public static PortfolioDataDto GetDefaultFallbackData()
        {
            return new PortfolioDataDto
            {
                Profile = new ProfileDto
                {
                    ProfileId = 1,
                    FirstName = "Marc Kevin",
                    LastName = "Del Mundo",
                    HeroSubline = "builds interfaces",
                    HeroNames = "Kevs,Marc Kevin,Del Mundo",
                    RoleSummary = "Web developer working across front-end interfaces and the structured data systems behind them — from motion-driven product pages to large-scale JSON datasets.",
                    RoleTitle = "Web Developer",
                    FocusArea = "Interfaces & Data Systems",
                    BasedIn = "Quezon City",
                    AvatarPath = "Assets/Images/pixelart_portrait.png",
                    LocationAddress = "B2 L6 Emerald St. Novaliches Proper, Q.C.",
                    Age = 19,
                    ExperienceYears = 3,
                    Email = "delmundo.marckevin.ferolino@gmail.com",
                    GithubUrl = "https://github.com/marcKevzzz",
                    LinkedinUrl = "https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436"
                },
                TechStacks = new List<TechStackItemDto>
                {
                    new TechStackItemDto { TechId = 1, GroupName = "Frontend", Label = "HTML5", IconPath = "Assets/Icons/html5.svg", SortOrder = 1 },
                    new TechStackItemDto { TechId = 2, GroupName = "Frontend", Label = "CSS3", IconPath = "Assets/Icons/css3.svg", SortOrder = 2 },
                    new TechStackItemDto { TechId = 3, GroupName = "Frontend", Label = "JavaScript", IconPath = "Assets/Icons/javascript.svg", SortOrder = 3 },
                    new TechStackItemDto { TechId = 4, GroupName = "Frontend", Label = "React", IconPath = "Assets/Icons/react.svg", SortOrder = 4 },
                    new TechStackItemDto { TechId = 5, GroupName = "3D & Motion", Label = "Three.js", IconPath = "Assets/Icons/threejs.svg", SortOrder = 1 },
                    new TechStackItemDto { TechId = 6, GroupName = "3D & Motion", Label = "GSAP", IconPath = "Assets/Icons/gsap.svg", SortOrder = 2 },
                    new TechStackItemDto { TechId = 7, GroupName = "Backend & Database", Label = "Node.js", IconPath = "Assets/Icons/nodejs.svg", SortOrder = 1 },
                    new TechStackItemDto { TechId = 8, GroupName = "Backend & Database", Label = "Express", IconPath = "Assets/Icons/express.svg", SortOrder = 2 },
                    new TechStackItemDto { TechId = 9, GroupName = "Backend & Database", Label = "C#", IconPath = "Assets/Icons/csharp.svg", SortOrder = 3 },
                    new TechStackItemDto { TechId = 10, GroupName = "Backend & Database", Label = "MySQL", IconPath = "Assets/Icons/mysql.svg", SortOrder = 4 },
                    new TechStackItemDto { TechId = 11, GroupName = "Backend & Database", Label = "MongoDB", IconPath = "Assets/Icons/mongodb.svg", SortOrder = 5 },
                    new TechStackItemDto { TechId = 12, GroupName = "Tools & DevOps", Label = "Git", IconPath = "Assets/Icons/git.svg", SortOrder = 1 },
                    new TechStackItemDto { TechId = 13, GroupName = "Tools & DevOps", Label = "GitHub", IconPath = "Assets/Icons/github.svg", SortOrder = 2 },
                    new TechStackItemDto { TechId = 14, GroupName = "Tools & DevOps", Label = "Figma", IconPath = "Assets/Icons/figma.svg", SortOrder = 3 },
                    new TechStackItemDto { TechId = 15, GroupName = "Tools & DevOps", Label = "VS Code", IconPath = "Assets/Icons/vscode.svg", SortOrder = 4 }
                },
                Skills = new List<SkillDto>
                {
                    new SkillDto { SkillId = 1, SkillName = "Frontend Development", ProficiencyVal = 90, SortOrder = 1 },
                    new SkillDto { SkillId = 2, SkillName = "C# & ASP.NET", ProficiencyVal = 85, SortOrder = 2 },
                    new SkillDto { SkillId = 3, SkillName = "Database Architecture", ProficiencyVal = 82, SortOrder = 3 },
                    new SkillDto { SkillId = 4, SkillName = "GSAP & Creative Motion", ProficiencyVal = 80, SortOrder = 4 },
                    new SkillDto { SkillId = 5, SkillName = "API & Backend Services", ProficiencyVal = 84, SortOrder = 5 },
                    new SkillDto { SkillId = 6, SkillName = "UI/UX & Responsive Systems", ProficiencyVal = 88, SortOrder = 6 }
                },
                Experiences = new List<ExperienceDto>
                {
                    new ExperienceDto
                    {
                        ExpId = 1,
                        RoleTitle = "Lead Full-Stack Developer",
                        CompanyName = "Samson Dental Center",
                        PeriodRange = "2025 — Present",
                        DescriptionText = "Architected clinic management platform with real-time patient queue, dynamic charting, and appointment scheduling.",
                        Tags = "ASP.NET, C#, SQLite, JavaScript, GSAP",
                        SortOrder = 1
                    },
                    new ExperienceDto
                    {
                        ExpId = 2,
                        RoleTitle = "Front-End Developer & UI Designer",
                        CompanyName = "Freelance / Independent",
                        PeriodRange = "2023 — 2025",
                        DescriptionText = "Built bespoke web applications, interactive visual calculators, algorithmic simulators, and data dashboards.",
                        Tags = "HTML5, CSS3, JavaScript, GSAP, UI/UX",
                        SortOrder = 2
                    }
                },
                Projects = new List<ProjectDto>
                {
                    new ProjectDto
                    {
                        ProjectId = 1,
                        Title = "Samson Dental Center",
                        ImagePath = "Assets/Images/samsondentalcenter.png",
                        ProjectUrl = "https://github.com/marcKevzzz/SamsonDentalCenterManagementSystem",
                        Tags = "HTML5, CSS3, JavaScript, Healthcare UX, Responsive",
                        SortOrder = 1
                    },
                    new ProjectDto
                    {
                        ProjectId = 2,
                        Title = "Review Bot Assistant",
                        ImagePath = "Assets/Images/reviewbot.png",
                        ProjectUrl = "https://github.com/marcKevzzz/reviewbot",
                        Tags = "Chatbot AI, Conversational UI, DOM Scripting",
                        SortOrder = 2
                    },
                    new ProjectDto
                    {
                        ProjectId = 3,
                        Title = "CPU Scheduling Calculator",
                        ImagePath = "Assets/Images/cpu_scheduler.png",
                        ProjectUrl = "https://github.com/marcKevzzz/cpu-scheduling-calculator",
                        Tags = "OS Scheduling, Gantt Chart, Algorithm Visualizer",
                        SortOrder = 3
                    },
                    new ProjectDto
                    {
                        ProjectId = 4,
                        Title = "MLBB Mayhem",
                        ImagePath = "Assets/Images/mlbb_mayhem.png",
                        ProjectUrl = "https://github.com/marcKevzzz/MLBB-Meyhem",
                        Tags = "Esports UI, Draft Simulator, Interactive Gaming",
                        SortOrder = 4
                    },
                    new ProjectDto
                    {
                        ProjectId = 5,
                        Title = "AeroStack Payroll System",
                        ImagePath = "Assets/Images/payroll.png",
                        ProjectUrl = "https://github.com/marcKevzzz/Payroll-Web-System",
                        Tags = "Enterprise UI, Data Analytics, Payroll Engine, DTR Logging",
                        SortOrder = 5
                    },
                    new ProjectDto
                    {
                        ProjectId = 6,
                        Title = "Tower of Hanoi",
                        ImagePath = "Assets/Images/tower_of_hanoi.png",
                        ProjectUrl = "https://github.com/marcKevzzz/towerOfHanoi",
                        Tags = "Game Physics, Leaderboards, Performance Stats",
                        SortOrder = 6
                    }
                },
                Educations = new List<EducationDto>
                {
                    new EducationDto
                    {
                        EduId = 1,
                        YearPeriod = "2024 — Present",
                        Title = "Collegiate Level",
                        Subtitle = "Bachelor of Science in Information Technology",
                        InstitutionName = "Quezon City University",
                        SortOrder = 1
                    },
                    new EducationDto
                    {
                        EduId = 2,
                        YearPeriod = "June — 2024",
                        Title = "Senior High School",
                        Subtitle = "Information and Communication Technology",
                        InstitutionName = "Gardner College Diliman",
                        SortOrder = 2
                    }
                },
                Awards = new List<AwardDto>
                {
                    new AwardDto
                    {
                        AwardId = 1,
                        AwardYear = "2026",
                        Title = "DevCup 2026 Competition",
                        Subtitle = "2nd Place QCU",
                        OrganizationName = "Quezon City University",
                        SortOrder = 1
                    },
                    new AwardDto
                    {
                        AwardId = 2,
                        AwardYear = "2025",
                        Title = "Code Quest 2025",
                        Subtitle = "Certificate of Participation",
                        OrganizationName = "Quezon City University",
                        SortOrder = 2
                    },
                    new AwardDto
                    {
                        AwardId = 3,
                        AwardYear = "2026",
                        Title = "AWS Learning Club QCU",
                        Subtitle = "Operational Member",
                        OrganizationName = "AWS Learning Club",
                        SortOrder = 3
                    },
                    new AwardDto
                    {
                        AwardId = 4,
                        AwardYear = "2025",
                        Title = "The Hour of Code",
                        Subtitle = "Certificate of Completion",
                        OrganizationName = "ASEAN Youth Organization",
                        SortOrder = 4
                    }
                },
                Hobbies = new List<HobbyDto>
                {
                    new HobbyDto { HobbyId = 1, HobbyName = "Reading Manhwa, Manhua & Manga", SortOrder = 1 },
                    new HobbyDto { HobbyId = 2, HobbyName = "Online Games", SortOrder = 2 },
                    new HobbyDto { HobbyId = 3, HobbyName = "Coding", SortOrder = 3 },
                    new HobbyDto { HobbyId = 4, HobbyName = "Basketball", SortOrder = 4 }
                }
            };
        }

        #region CRUD Operations for Admin Console

        public static bool SaveProfile(ProfileDto profile)
        {
            if (profile == null) return false;
            try
            {
                int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar("SELECT COUNT(*) FROM profile_tbl") ?? 0);
                string query;
                if (count > 0)
                {
                    query = @"UPDATE profile_tbl SET 
                                first_name = @FirstName,
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
                              WHERE profile_id = (SELECT TOP 1 profile_id FROM profile_tbl ORDER BY profile_id DESC)";
                }
                else
                {
                    query = @"INSERT INTO profile_tbl (first_name, last_name, hero_subline, hero_names, role_summary, role_title, focus_area, based_in, avatar_path, location_address, age, experience_years, email, github_url, linkedin_url, updated_at)
                              VALUES (@FirstName, @LastName, @HeroSubline, @HeroNames, @RoleSummary, @RoleTitle, @FocusArea, @BasedIn, @AvatarPath, @LocationAddress, @Age, @ExperienceYears, @Email, @GithubUrl, @LinkedinUrl, GETDATE())";
                }

                DatabaseHelper.ExecuteNonQuery(query,
                    new System.Data.SqlClient.SqlParameter("@FirstName", (object)profile.FirstName ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@LastName", (object)profile.LastName ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@HeroSubline", (object)profile.HeroSubline ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@HeroNames", (object)profile.HeroNames ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@RoleSummary", (object)profile.RoleSummary ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@RoleTitle", (object)profile.RoleTitle ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@FocusArea", (object)profile.FocusArea ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@BasedIn", (object)profile.BasedIn ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@AvatarPath", (object)profile.AvatarPath ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@LocationAddress", (object)profile.LocationAddress ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@Age", profile.Age),
                    new System.Data.SqlClient.SqlParameter("@ExperienceYears", profile.ExperienceYears),
                    new System.Data.SqlClient.SqlParameter("@Email", (object)profile.Email ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@GithubUrl", (object)profile.GithubUrl ?? DBNull.Value),
                    new System.Data.SqlClient.SqlParameter("@LinkedinUrl", (object)profile.LinkedinUrl ?? DBNull.Value)
                );

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveProfile error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveTechStack(TechStackItemDto item, string svgContent = null)
        {
            if (item == null) return false;
            try
            {
                // If raw SVG markup was provided, write to Assets/Icons
                if (!string.IsNullOrWhiteSpace(svgContent) && svgContent.Trim().IndexOf("<svg", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    string safeName = System.Text.RegularExpressions.Regex.Replace(item.Label ?? "icon", @"[^a-zA-Z0-9_\-]", "").ToLowerInvariant();
                    if (string.IsNullOrEmpty(safeName)) safeName = "tech_" + DateTime.Now.Ticks;
                    string fileName = $"{safeName}.svg";

                    string iconsDir = HttpContext.Current?.Server.MapPath("~/Assets/Icons");
                    if (!string.IsNullOrEmpty(iconsDir))
                    {
                        if (!System.IO.Directory.Exists(iconsDir))
                        {
                            System.IO.Directory.CreateDirectory(iconsDir);
                        }
                        string fullPath = System.IO.Path.Combine(iconsDir, fileName);
                        System.IO.File.WriteAllText(fullPath, svgContent.Trim(), System.Text.Encoding.UTF8);
                        item.IconPath = $"Assets/Icons/{fileName}";
                    }
                }

                if (string.IsNullOrWhiteSpace(item.IconPath))
                {
                    item.IconPath = "Assets/Icons/csharp.svg";
                }

                string query;
                if (item.TechId > 0)
                {
                    query = @"UPDATE tech_stacks_tbl SET group_name = @GroupName, label = @Label, icon_path = @IconPath, sort_order = @SortOrder, is_active = @IsActive WHERE tech_id = @TechId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@GroupName", item.GroupName ?? "Frontend"),
                        new System.Data.SqlClient.SqlParameter("@Label", item.Label ?? "Tech"),
                        new System.Data.SqlClient.SqlParameter("@IconPath", item.IconPath),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", item.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", item.IsActive),
                        new System.Data.SqlClient.SqlParameter("@TechId", item.TechId)
                    );
                }
                else
                {
                    query = @"INSERT INTO tech_stacks_tbl (group_name, label, icon_path, sort_order, is_active) VALUES (@GroupName, @Label, @IconPath, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@GroupName", item.GroupName ?? "Frontend"),
                        new System.Data.SqlClient.SqlParameter("@Label", item.Label ?? "Tech"),
                        new System.Data.SqlClient.SqlParameter("@IconPath", item.IconPath),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", item.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", item.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveTechStack error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteTechStack(int techId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM tech_stacks_tbl WHERE tech_id = @TechId",
                    new System.Data.SqlClient.SqlParameter("@TechId", techId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteTechStack error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveSkill(SkillDto skill)
        {
            if (skill == null) return false;
            try
            {
                string query;
                if (skill.SkillId > 0)
                {
                    query = @"UPDATE skills_tbl SET skill_name = @SkillName, proficiency_val = @ProficiencyVal, sort_order = @SortOrder, is_active = @IsActive WHERE skill_id = @SkillId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@SkillName", skill.SkillName ?? "Skill"),
                        new System.Data.SqlClient.SqlParameter("@ProficiencyVal", Math.Max(0, Math.Min(100, skill.ProficiencyVal))),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", skill.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", skill.IsActive),
                        new System.Data.SqlClient.SqlParameter("@SkillId", skill.SkillId)
                    );
                }
                else
                {
                    query = @"INSERT INTO skills_tbl (skill_name, proficiency_val, sort_order, is_active) VALUES (@SkillName, @ProficiencyVal, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@SkillName", skill.SkillName ?? "Skill"),
                        new System.Data.SqlClient.SqlParameter("@ProficiencyVal", Math.Max(0, Math.Min(100, skill.ProficiencyVal))),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", skill.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", skill.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveSkill error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteSkill(int skillId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM skills_tbl WHERE skill_id = @SkillId",
                    new System.Data.SqlClient.SqlParameter("@SkillId", skillId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteSkill error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveExperience(ExperienceDto exp)
        {
            if (exp == null) return false;
            try
            {
                string query;
                if (exp.ExpId > 0)
                {
                    query = @"UPDATE experiences_tbl SET role_title = @RoleTitle, company_name = @CompanyName, period_range = @PeriodRange, description_text = @DescriptionText, tags = @Tags, sort_order = @SortOrder, is_active = @IsActive WHERE exp_id = @ExpId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@RoleTitle", exp.RoleTitle ?? "Role"),
                        new System.Data.SqlClient.SqlParameter("@CompanyName", exp.CompanyName ?? "Company"),
                        new System.Data.SqlClient.SqlParameter("@PeriodRange", exp.PeriodRange ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@DescriptionText", exp.DescriptionText ?? ""),
                        new System.Data.SqlClient.SqlParameter("@Tags", exp.Tags ?? ""),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", exp.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", exp.IsActive),
                        new System.Data.SqlClient.SqlParameter("@ExpId", exp.ExpId)
                    );
                }
                else
                {
                    query = @"INSERT INTO experiences_tbl (role_title, company_name, period_range, description_text, tags, sort_order, is_active) VALUES (@RoleTitle, @CompanyName, @PeriodRange, @DescriptionText, @Tags, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@RoleTitle", exp.RoleTitle ?? "Role"),
                        new System.Data.SqlClient.SqlParameter("@CompanyName", exp.CompanyName ?? "Company"),
                        new System.Data.SqlClient.SqlParameter("@PeriodRange", exp.PeriodRange ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@DescriptionText", exp.DescriptionText ?? ""),
                        new System.Data.SqlClient.SqlParameter("@Tags", exp.Tags ?? ""),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", exp.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", exp.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveExperience error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteExperience(int expId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM experiences_tbl WHERE exp_id = @ExpId",
                    new System.Data.SqlClient.SqlParameter("@ExpId", expId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteExperience error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveProject(ProjectDto project)
        {
            if (project == null) return false;
            try
            {
                string query;
                if (project.ProjectId > 0)
                {
                    query = @"UPDATE projects_tbl SET title = @Title, image_path = @ImagePath, project_url = @ProjectUrl, tags = @Tags, sort_order = @SortOrder, is_active = @IsActive WHERE project_id = @ProjectId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@Title", project.Title ?? "Project"),
                        new System.Data.SqlClient.SqlParameter("@ImagePath", project.ImagePath ?? "Assets/Images/samsondentalcenter.png"),
                        new System.Data.SqlClient.SqlParameter("@ProjectUrl", project.ProjectUrl ?? ""),
                        new System.Data.SqlClient.SqlParameter("@Tags", project.Tags ?? ""),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", project.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", project.IsActive),
                        new System.Data.SqlClient.SqlParameter("@ProjectId", project.ProjectId)
                    );
                }
                else
                {
                    query = @"INSERT INTO projects_tbl (title, image_path, project_url, tags, sort_order, is_active) VALUES (@Title, @ImagePath, @ProjectUrl, @Tags, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@Title", project.Title ?? "Project"),
                        new System.Data.SqlClient.SqlParameter("@ImagePath", project.ImagePath ?? "Assets/Images/samsondentalcenter.png"),
                        new System.Data.SqlClient.SqlParameter("@ProjectUrl", project.ProjectUrl ?? ""),
                        new System.Data.SqlClient.SqlParameter("@Tags", project.Tags ?? ""),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", project.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", project.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveProject error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteProject(int projectId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM projects_tbl WHERE project_id = @ProjectId",
                    new System.Data.SqlClient.SqlParameter("@ProjectId", projectId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteProject error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveEducation(EducationDto edu)
        {
            if (edu == null) return false;
            try
            {
                string query;
                if (edu.EduId > 0)
                {
                    query = @"UPDATE educations_tbl SET year_period = @YearPeriod, title = @Title, subtitle = @Subtitle, institution_name = @InstitutionName, sort_order = @SortOrder, is_active = @IsActive WHERE edu_id = @EduId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@YearPeriod", edu.YearPeriod ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@Title", edu.Title ?? "Education"),
                        new System.Data.SqlClient.SqlParameter("@Subtitle", edu.Subtitle ?? ""),
                        new System.Data.SqlClient.SqlParameter("@InstitutionName", edu.InstitutionName ?? "Institution"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", edu.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", edu.IsActive),
                        new System.Data.SqlClient.SqlParameter("@EduId", edu.EduId)
                    );
                }
                else
                {
                    query = @"INSERT INTO educations_tbl (year_period, title, subtitle, institution_name, sort_order, is_active) VALUES (@YearPeriod, @Title, @Subtitle, @InstitutionName, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@YearPeriod", edu.YearPeriod ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@Title", edu.Title ?? "Education"),
                        new System.Data.SqlClient.SqlParameter("@Subtitle", edu.Subtitle ?? ""),
                        new System.Data.SqlClient.SqlParameter("@InstitutionName", edu.InstitutionName ?? "Institution"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", edu.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", edu.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveEducation error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteEducation(int eduId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM educations_tbl WHERE edu_id = @EduId",
                    new System.Data.SqlClient.SqlParameter("@EduId", eduId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteEducation error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveAward(AwardDto award)
        {
            if (award == null) return false;
            try
            {
                string query;
                if (award.AwardId > 0)
                {
                    query = @"UPDATE awards_tbl SET award_year = @AwardYear, title = @Title, subtitle = @Subtitle, organization_name = @OrganizationName, sort_order = @SortOrder, is_active = @IsActive WHERE award_id = @AwardId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@AwardYear", award.AwardYear ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@Title", award.Title ?? "Award"),
                        new System.Data.SqlClient.SqlParameter("@Subtitle", award.Subtitle ?? ""),
                        new System.Data.SqlClient.SqlParameter("@OrganizationName", award.OrganizationName ?? "Organization"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", award.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", award.IsActive),
                        new System.Data.SqlClient.SqlParameter("@AwardId", award.AwardId)
                    );
                }
                else
                {
                    query = @"INSERT INTO awards_tbl (award_year, title, subtitle, organization_name, sort_order, is_active) VALUES (@AwardYear, @Title, @Subtitle, @OrganizationName, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@AwardYear", award.AwardYear ?? "2026"),
                        new System.Data.SqlClient.SqlParameter("@Title", award.Title ?? "Award"),
                        new System.Data.SqlClient.SqlParameter("@Subtitle", award.Subtitle ?? ""),
                        new System.Data.SqlClient.SqlParameter("@OrganizationName", award.OrganizationName ?? "Organization"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", award.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", award.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveAward error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteAward(int awardId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM awards_tbl WHERE award_id = @AwardId",
                    new System.Data.SqlClient.SqlParameter("@AwardId", awardId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteAward error: {ex.Message}");
                return false;
            }
        }

        public static bool SaveHobby(HobbyDto hobby)
        {
            if (hobby == null) return false;
            try
            {
                string query;
                if (hobby.HobbyId > 0)
                {
                    query = @"UPDATE hobbies_tbl SET hobby_name = @HobbyName, sort_order = @SortOrder, is_active = @IsActive WHERE hobby_id = @HobbyId";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@HobbyName", hobby.HobbyName ?? "Hobby"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", hobby.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", hobby.IsActive),
                        new System.Data.SqlClient.SqlParameter("@HobbyId", hobby.HobbyId)
                    );
                }
                else
                {
                    query = @"INSERT INTO hobbies_tbl (hobby_name, sort_order, is_active) VALUES (@HobbyName, @SortOrder, @IsActive)";
                    DatabaseHelper.ExecuteNonQuery(query,
                        new System.Data.SqlClient.SqlParameter("@HobbyName", hobby.HobbyName ?? "Hobby"),
                        new System.Data.SqlClient.SqlParameter("@SortOrder", hobby.SortOrder),
                        new System.Data.SqlClient.SqlParameter("@IsActive", hobby.IsActive)
                    );
                }

                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SaveHobby error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteHobby(int hobbyId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM hobbies_tbl WHERE hobby_id = @HobbyId",
                    new System.Data.SqlClient.SqlParameter("@HobbyId", hobbyId));
                InvalidateCache();
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteHobby error: {ex.Message}");
                return false;
            }
        }

        public static List<User> GetAllUsers()
        {
            var list = new List<User>();
            try
            {
                DataTable dt = DatabaseHelper.ExecuteDataTable("SELECT * FROM users_tbl ORDER BY created_at DESC");
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        list.Add(new User
                        {
                            UserId = row["user_id"] != DBNull.Value ? Convert.ToInt32(row["user_id"]) : 0,
                            FirstName = row["first_name"]?.ToString() ?? "",
                            LastName = row["last_name"]?.ToString() ?? "",
                            Email = row["email"]?.ToString() ?? "",
                            Role = row.Table.Columns.Contains("user_role") && row["user_role"] != DBNull.Value ? row["user_role"].ToString() : "User",
                            ProfileImage = row.Table.Columns.Contains("avatar_url") && row["avatar_url"] != DBNull.Value ? row["avatar_url"].ToString() : "",
                            IsActive = row["is_active"] != DBNull.Value && Convert.ToBoolean(row["is_active"]),
                            CreatedAt = row["created_at"] != DBNull.Value ? Convert.ToDateTime(row["created_at"]) : DateTime.UtcNow
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] GetAllUsers error: {ex.Message}");
            }

            if (list.Count == 0)
            {
                list.Add(new User
                {
                    UserId = 1,
                    FirstName = "Marc Kevin",
                    LastName = "Del Mundo",
                    Email = "delmundo.marckevin.ferolino@gmail.com",
                    Role = "Admin",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow.AddMonths(-3)
                });
            }

            return list;
        }

        public static bool SetUserActiveStatus(int userId, bool isActive)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("UPDATE users_tbl SET is_active = @IsActive WHERE user_id = @UserId",
                    new System.Data.SqlClient.SqlParameter("@IsActive", isActive),
                    new System.Data.SqlClient.SqlParameter("@UserId", userId));
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] SetUserActiveStatus error: {ex.Message}");
                return false;
            }
        }

        public static bool DeleteUser(int userId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM users_tbl WHERE user_id = @UserId",
                    new System.Data.SqlClient.SqlParameter("@UserId", userId));
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] DeleteUser error: {ex.Message}");
                return false;
            }
        }

        public static bool UpdateAdminCredentials(int userId, string firstName, string lastName, string email, string newPassword, string avatarPath = null)
        {
            try
            {
                string query;
                var paramList = new List<System.Data.SqlClient.SqlParameter>
                {
                    new System.Data.SqlClient.SqlParameter("@FirstName", firstName ?? "Admin"),
                    new System.Data.SqlClient.SqlParameter("@LastName", lastName ?? "User"),
                    new System.Data.SqlClient.SqlParameter("@Email", email ?? ""),
                    new System.Data.SqlClient.SqlParameter("@UserId", userId)
                };

                if (!string.IsNullOrWhiteSpace(newPassword))
                {
                    string hash = Helpers.AuthHelper.HashPassword(newPassword);
                    query = "UPDATE users_tbl SET first_name = @FirstName, last_name = @LastName, email = @Email, password_hash = @PasswordHash WHERE user_id = @UserId";
                    paramList.Add(new System.Data.SqlClient.SqlParameter("@PasswordHash", hash));
                }
                else
                {
                    query = "UPDATE users_tbl SET first_name = @FirstName, last_name = @LastName, email = @Email WHERE user_id = @UserId";
                }

                DatabaseHelper.ExecuteNonQuery(query, paramList.ToArray());
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[PortfolioService] UpdateAdminCredentials error: {ex.Message}");
                return false;
            }
        }

        #endregion
    }
}
