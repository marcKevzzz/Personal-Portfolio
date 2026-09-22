using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Caching;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Services
{
    /// <summary>
    /// PortfolioService manages all multi-user portfolio data persistence,
    /// executing MS SQL Stored Procedures for high performance and clean architecture.
    /// </summary>
    public static class PortfolioService
    {
        private static readonly object CacheLock = new object();

        private static string GetCacheKey(int userId)
        {
            return $"PORTFOLIO_DATA_USER_{userId}";
        }

        /// <summary>
        /// Retrieves the portfolio data for the current authenticated user.
        /// </summary>
        public static PortfolioDataDto GetPortfolioData(bool forceRefresh = false)
        {
            return GetPortfolioData(0, forceRefresh);
        }

        /// <summary>
        /// Retrieves the complete portfolio data for a specific user using sp_GetUserPortfolioData.
        /// </summary>
        public static PortfolioDataDto GetPortfolioData(int userId, bool forceRefresh = false)
        {
            if (userId <= 0)
            {
                userId = AuthHelper.GetCurrentUserId();
                if (userId <= 0) userId = 1;
            }

            string cacheKey = GetCacheKey(userId);

            if (!forceRefresh)
            {
                var cached = HttpRuntime.Cache?.Get(cacheKey) as PortfolioDataDto;
                if (cached != null) return cached;
            }

            lock (CacheLock)
            {
                if (!forceRefresh)
                {
                    var cached = HttpRuntime.Cache?.Get(cacheKey) as PortfolioDataDto;
                    if (cached != null) return cached;
                }

                var data = new PortfolioDataDto
                {
                    UserId = userId,
                    IsOwner = (AuthHelper.GetCurrentUserId() == userId)
                };

                try
                {
                    var pUser = new SqlParameter("@user_id", userId);
                    var ds = DatabaseHelper.ExecuteStoredProcedureDataSet("sp_GetUserPortfolioData", pUser);

                    if (ds != null && ds.Tables.Count > 0)
                    {
                        // 1. Profile Table (Table 0)
                        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        {
                            var r = ds.Tables[0].Rows[0];
                            data.Profile = new ProfileDto
                            {
                                ProfileId = Convert.ToInt32(r["profile_id"]),
                                UserId = Convert.ToInt32(r["user_id"]),
                                FirstName = r["first_name"]?.ToString() ?? "",
                                LastName = r["last_name"]?.ToString() ?? "",
                                HeroNames = r["hero_names"]?.ToString() ?? "",
                                RoleSummary = r["role_summary"]?.ToString() ?? "",
                                RoleTitle = r["role_title"]?.ToString() ?? "Web Developer",
                                FocusArea = r["focus_area"]?.ToString() ?? "Interfaces & Data Systems",
                                BasedIn = r["based_in"]?.ToString() ?? "Quezon City",
                                AvatarPath = r["avatar_path"]?.ToString() ?? "Assets/Images/pixelart_portrait.png",
                                LocationAddress = r["location_address"]?.ToString() ?? "",
                                BirthDate = r["birth_date"] != DBNull.Value ? Convert.ToDateTime(r["birth_date"]) : (DateTime?)null,
                                Age = Convert.ToInt32(r["derived_age"]),
                                ExperienceYears = r["experience_years"] != DBNull.Value ? Convert.ToInt32(r["experience_years"]) : 1,
                                Email = r["email"]?.ToString() ?? "",
                                GithubUrl = r["github_url"]?.ToString() ?? "",
                                LinkedinUrl = r["linkedin_url"]?.ToString() ?? ""
                            };
                            data.UserRole = r["user_role"]?.ToString() ?? "User";
                        }
                        else
                        {
                            // If user has not created profile yet, seed initial metadata from users_tbl
                            data.Profile = GetInitialProfileFromUser(userId);
                        }

                        // 2. Tech Stack (Table 1)
                        if (ds.Tables.Count > 1)
                        {
                            foreach (DataRow r in ds.Tables[1].Rows)
                            {
                                data.TechStacks.Add(new TechStackItemDto
                                {
                                    TechId = Convert.ToInt32(r["tech_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    GroupName = r["group_name"]?.ToString() ?? "",
                                    Label = r["label"]?.ToString() ?? "",
                                    IconPath = r["icon_path"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 3. Skills (Table 2)
                        if (ds.Tables.Count > 2)
                        {
                            foreach (DataRow r in ds.Tables[2].Rows)
                            {
                                data.Skills.Add(new SkillDto
                                {
                                    SkillId = Convert.ToInt32(r["skill_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    SkillName = r["skill_name"]?.ToString() ?? "",
                                    ProficiencyVal = Convert.ToInt32(r["proficiency_val"]),
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 4. Experiences (Table 3)
                        if (ds.Tables.Count > 3)
                        {
                            foreach (DataRow r in ds.Tables[3].Rows)
                            {
                                data.Experiences.Add(new ExperienceDto
                                {
                                    ExpId = Convert.ToInt32(r["exp_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    RoleTitle = r["role_title"]?.ToString() ?? "",
                                    CompanyName = r["company_name"]?.ToString() ?? "",
                                    StartYear = Convert.ToInt32(r["start_year"]),
                                    EndYear = r["end_year"] != DBNull.Value ? Convert.ToInt32(r["end_year"]) : (int?)null,
                                    IsCurrent = Convert.ToBoolean(r["is_current"]),
                                    PeriodRange = r["period_display"]?.ToString() ?? "",
                                    DescriptionText = r["description_text"]?.ToString() ?? "",
                                    Tags = r["tags"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 5. Projects (Table 4)
                        if (ds.Tables.Count > 4)
                        {
                            foreach (DataRow r in ds.Tables[4].Rows)
                            {
                                data.Projects.Add(new ProjectDto
                                {
                                    ProjectId = Convert.ToInt32(r["project_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    Title = r["title"]?.ToString() ?? "",
                                    ImagePath = r["image_path"]?.ToString() ?? "",
                                    ProjectUrl = r["project_url"]?.ToString() ?? "",
                                    Tags = r["tags"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 6. Educations (Table 5)
                        if (ds.Tables.Count > 5)
                        {
                            foreach (DataRow r in ds.Tables[5].Rows)
                            {
                                data.Educations.Add(new EducationDto
                                {
                                    EduId = Convert.ToInt32(r["edu_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    StartYear = Convert.ToInt32(r["start_year"]),
                                    EndYear = r["end_year"] != DBNull.Value ? Convert.ToInt32(r["end_year"]) : (int?)null,
                                    IsCurrent = Convert.ToBoolean(r["is_current"]),
                                    YearPeriod = r["year_display"]?.ToString() ?? "",
                                    Title = r["title"]?.ToString() ?? "",
                                    Subtitle = r["subtitle"]?.ToString() ?? "",
                                    InstitutionName = r["institution_name"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 7. Awards (Table 6)
                        if (ds.Tables.Count > 6)
                        {
                            foreach (DataRow r in ds.Tables[6].Rows)
                            {
                                data.Awards.Add(new AwardDto
                                {
                                    AwardId = Convert.ToInt32(r["award_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    AwardYear = r["award_year"]?.ToString() ?? "",
                                    Title = r["title"]?.ToString() ?? "",
                                    Subtitle = r["subtitle"]?.ToString() ?? "",
                                    OrganizationName = r["organization_name"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }

                        // 8. Hobbies (Table 7)
                        if (ds.Tables.Count > 7)
                        {
                            foreach (DataRow r in ds.Tables[7].Rows)
                            {
                                data.Hobbies.Add(new HobbyDto
                                {
                                    HobbyId = Convert.ToInt32(r["hobby_id"]),
                                    UserId = Convert.ToInt32(r["user_id"]),
                                    HobbyName = r["hobby_name"]?.ToString() ?? "",
                                    HobbyDescription = r["hobby_description"]?.ToString() ?? "",
                                    SortOrder = Convert.ToInt32(r["sort_order"]),
                                    IsActive = Convert.ToBoolean(r["is_active"])
                                });
                            }
                        }
                    }
                    else
                    {
                        data.Profile = GetInitialProfileFromUser(userId);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[PortfolioService] Error fetching user {userId} data: {ex.Message}");
                    data.Profile = GetInitialProfileFromUser(userId);
                }

                if (HttpRuntime.Cache != null && data != null)
                {
                    HttpRuntime.Cache.Insert(
                        cacheKey,
                        data,
                        null,
                        DateTime.Now.AddMinutes(15),
                        Cache.NoSlidingExpiration,
                        CacheItemPriority.High,
                        null
                    );
                }

                return data;
            }
        }

        private static ProfileDto GetInitialProfileFromUser(int userId)
        {
            var p = new ProfileDto
            {
                UserId = userId,
                RoleTitle = "Web Developer",
                FocusArea = "Interfaces & Data Systems",
                BasedIn = "Quezon City",
                AvatarPath = "Assets/Images/pixelart_portrait.png",
                ExperienceYears = 1
            };

            try
            {
                var dt = DatabaseHelper.ExecuteQuery("SELECT first_name, last_name, email FROM users_tbl WHERE user_id = @UserId",
                    new SqlParameter("@UserId", userId));
                if (dt != null && dt.Rows.Count > 0)
                {
                    p.FirstName = dt.Rows[0]["first_name"]?.ToString() ?? "";
                    p.LastName = dt.Rows[0]["last_name"]?.ToString() ?? "";
                    p.Email = dt.Rows[0]["email"]?.ToString() ?? "";
                    p.HeroNames = $"{p.FirstName},{p.LastName}".Trim(',');
                }
            }
            catch { }

            return p;
        }

        public static void InvalidateCache(int userId = 0)
        {
            try
            {
                if (userId > 0)
                {
                    HttpRuntime.Cache?.Remove(GetCacheKey(userId));
                }
                else
                {
                    int currentUid = AuthHelper.GetCurrentUserId();
                    if (currentUid > 0) HttpRuntime.Cache?.Remove(GetCacheKey(currentUid));
                }
            }
            catch { }
        }

        // -------------------------------------------------------------
        // CRUD Operations with Stored Procedures
        // -------------------------------------------------------------

        public static bool SaveProfile(ProfileDto p, int userId = 0)
        {
            if (userId <= 0) userId = p.UserId > 0 ? p.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@user_id", userId),
                new SqlParameter("@first_name", (object)p.FirstName ?? DBNull.Value),
                new SqlParameter("@last_name", (object)p.LastName ?? DBNull.Value),
                new SqlParameter("@hero_names", (object)p.HeroNames ?? DBNull.Value),
                new SqlParameter("@role_summary", (object)p.RoleSummary ?? DBNull.Value),
                new SqlParameter("@role_title", (object)p.RoleTitle ?? DBNull.Value),
                new SqlParameter("@focus_area", (object)p.FocusArea ?? DBNull.Value),
                new SqlParameter("@based_in", (object)p.BasedIn ?? DBNull.Value),
                new SqlParameter("@avatar_path", (object)p.AvatarPath ?? DBNull.Value),
                new SqlParameter("@location_address", (object)p.LocationAddress ?? DBNull.Value),
                new SqlParameter("@birth_date", p.BirthDate.HasValue ? (object)p.BirthDate.Value : DBNull.Value),
                new SqlParameter("@experience_years", p.ExperienceYears),
                new SqlParameter("@email", (object)p.Email ?? DBNull.Value),
                new SqlParameter("@github_url", (object)p.GithubUrl ?? DBNull.Value),
                new SqlParameter("@linkedin_url", (object)p.LinkedinUrl ?? DBNull.Value)
            };

            try
            {
                int rows = DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveProfile", parameters);
                InvalidateCache(userId);
                return rows >= 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[PortfolioService] SaveProfile error: " + ex.Message);
                return false;
            }
        }

        public static bool SaveTechStack(TechStackItemDto item, string rawSvg, int userId = 0)
        {
            if (userId <= 0) userId = item.UserId > 0 ? item.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            if (!string.IsNullOrWhiteSpace(rawSvg))
            {
                try
                {
                    string iconName = (item.Label ?? "tech").ToLowerInvariant().Replace(" ", "_").Replace("#", "sharp").Replace(".", "_") + "_" + DateTime.UtcNow.Ticks + ".svg";
                    string targetDir = HttpContext.Current != null ? HttpContext.Current.Server.MapPath("~/Assets/Icons/") : null;
                    if (!string.IsNullOrEmpty(targetDir))
                    {
                        if (!System.IO.Directory.Exists(targetDir)) System.IO.Directory.CreateDirectory(targetDir);
                        string fullPath = System.IO.Path.Combine(targetDir, iconName);
                        System.IO.File.WriteAllText(fullPath, rawSvg);
                        item.IconPath = "Assets/Icons/" + iconName;
                    }
                }
                catch { }
            }

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@tech_id", item.TechId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@group_name", item.GroupName ?? "Frontend"),
                new SqlParameter("@label", item.Label ?? ""),
                new SqlParameter("@icon_path", item.IconPath ?? ""),
                new SqlParameter("@sort_order", item.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveTechStack", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveTechStack(TechStackItemDto item, int userId = 0)
        {
            return SaveTechStack(item, null, userId);
        }

        public static bool DeleteTechStack(int techId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteTechStack",
                    new SqlParameter("@tech_id", techId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveSkill(SkillDto skill, int userId = 0)
        {
            if (userId <= 0) userId = skill.UserId > 0 ? skill.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@skill_id", skill.SkillId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@skill_name", skill.SkillName ?? ""),
                new SqlParameter("@proficiency_val", skill.ProficiencyVal),
                new SqlParameter("@sort_order", skill.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveSkill", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteSkill(int skillId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteSkill",
                    new SqlParameter("@skill_id", skillId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveExperience(ExperienceDto exp, int userId = 0)
        {
            if (userId <= 0) userId = exp.UserId > 0 ? exp.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@exp_id", exp.ExpId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@role_title", exp.RoleTitle ?? ""),
                new SqlParameter("@company_name", exp.CompanyName ?? ""),
                new SqlParameter("@start_year", exp.StartYear),
                new SqlParameter("@end_year", exp.EndYear.HasValue ? (object)exp.EndYear.Value : DBNull.Value),
                new SqlParameter("@is_current", exp.IsCurrent),
                new SqlParameter("@description_text", (object)exp.DescriptionText ?? DBNull.Value),
                new SqlParameter("@tags", (object)exp.Tags ?? DBNull.Value),
                new SqlParameter("@sort_order", exp.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveExperience", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteExperience(int expId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteExperience",
                    new SqlParameter("@exp_id", expId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveProject(ProjectDto project, int userId = 0)
        {
            if (userId <= 0) userId = project.UserId > 0 ? project.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@project_id", project.ProjectId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@title", project.Title ?? ""),
                new SqlParameter("@image_path", project.ImagePath ?? ""),
                new SqlParameter("@project_url", (object)project.ProjectUrl ?? DBNull.Value),
                new SqlParameter("@tags", (object)project.Tags ?? DBNull.Value),
                new SqlParameter("@sort_order", project.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveProject", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteProject(int projectId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteProject",
                    new SqlParameter("@project_id", projectId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveEducation(EducationDto edu, int userId = 0)
        {
            if (userId <= 0) userId = edu.UserId > 0 ? edu.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@edu_id", edu.EduId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@title", edu.Title ?? ""),
                new SqlParameter("@subtitle", edu.Subtitle ?? ""),
                new SqlParameter("@institution_name", edu.InstitutionName ?? ""),
                new SqlParameter("@start_year", edu.StartYear),
                new SqlParameter("@end_year", edu.EndYear.HasValue ? (object)edu.EndYear.Value : DBNull.Value),
                new SqlParameter("@is_current", edu.IsCurrent),
                new SqlParameter("@sort_order", edu.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveEducation", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteEducation(int eduId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteEducation",
                    new SqlParameter("@edu_id", eduId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveAward(AwardDto award, int userId = 0)
        {
            if (userId <= 0) userId = award.UserId > 0 ? award.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@award_id", award.AwardId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@award_year", award.AwardYear ?? ""),
                new SqlParameter("@title", award.Title ?? ""),
                new SqlParameter("@subtitle", award.Subtitle ?? ""),
                new SqlParameter("@organization_name", award.OrganizationName ?? ""),
                new SqlParameter("@sort_order", award.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveAward", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteAward(int awardId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteAward",
                    new SqlParameter("@award_id", awardId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool SaveHobby(HobbyDto hobby, int userId = 0)
        {
            if (userId <= 0) userId = hobby.UserId > 0 ? hobby.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0) userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@hobby_id", hobby.HobbyId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@hobby_name", hobby.HobbyName ?? ""),
                new SqlParameter("@hobby_description", (object)hobby.HobbyDescription ?? DBNull.Value),
                new SqlParameter("@sort_order", hobby.SortOrder)
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveHobby", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        public static bool DeleteHobby(int hobbyId, int userId = 0)
        {
            if (userId <= 0) userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_DeleteHobby",
                    new SqlParameter("@hobby_id", hobbyId),
                    new SqlParameter("@user_id", userId));
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }

        // -------------------------------------------------------------
        // User Supervision & Admin Services
        // -------------------------------------------------------------

        public static List<UserSummaryDto> GetAllUsers()
        {
            var list = new List<UserSummaryDto>();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable("sp_GetAllUsers");
                if (dt != null)
                {
                    foreach (DataRow r in dt.Rows)
                    {
                        list.Add(new UserSummaryDto
                        {
                            UserId = Convert.ToInt32(r["UserId"]),
                            FirstName = r["FirstName"]?.ToString() ?? "",
                            LastName = r["LastName"]?.ToString() ?? "",
                            FullName = $"{r["FirstName"]} {r["LastName"]}".Trim(),
                            Email = r["Email"]?.ToString() ?? "",
                            Role = r["Role"]?.ToString() ?? "User",
                            IsActive = Convert.ToBoolean(r["IsActive"]),
                            CreatedAt = Convert.ToDateTime(r["CreatedAt"]),
                            LastLoginAt = r["LastLoginAt"] != DBNull.Value ? Convert.ToDateTime(r["LastLoginAt"]) : (DateTime?)null,
                            LoginCount = Convert.ToInt32(r["LoginCount"]),
                            HasProfile = Convert.ToBoolean(r["HasProfile"]),
                            BirthDate = r["BirthDate"] != DBNull.Value ? Convert.ToDateTime(r["BirthDate"]) : (DateTime?)null,
                            RoleTitle = r["RoleTitle"]?.ToString() ?? ""
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[PortfolioService] GetAllUsers error: " + ex.Message);
            }
            return list;
        }

        public static bool ToggleUserStatus(int targetUserId, bool isActive)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_ToggleUserStatus",
                    new SqlParameter("@user_id", targetUserId),
                    new SqlParameter("@is_active", isActive));
                return true;
            }
            catch { return false; }
        }

        public static bool ResetUserPassword(int targetUserId)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_ResetUserPassword",
                    new SqlParameter("@user_id", targetUserId));
                return true;
            }
            catch { return false; }
        }

        public static DashboardStatsDto GetDashboardStats()
        {
            var stats = new DashboardStatsDto();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable("sp_GetDashboardStats");
                if (dt != null && dt.Rows.Count > 0)
                {
                    var r = dt.Rows[0];
                    stats.TotalUsers = Convert.ToInt32(r["TotalUsers"]);
                    stats.ActiveUsers = Convert.ToInt32(r["ActiveUsers"]);
                    stats.InactiveUsers = Convert.ToInt32(r["InactiveUsers"]);
                    stats.AdminUsers = Convert.ToInt32(r["AdminUsers"]);
                    stats.SignUpsToday = Convert.ToInt32(r["SignUpsToday"]);
                    stats.SignUpsThisWeek = Convert.ToInt32(r["SignUpsThisWeek"]);
                    stats.SignUpsThisMonth = Convert.ToInt32(r["SignUpsThisMonth"]);
                    stats.TotalLogins = Convert.ToInt32(r["TotalLogins"]);
                    stats.DailyActiveUsers = Convert.ToInt32(r["DailyActiveUsers"]);
                    stats.MonthlyActiveUsers = Convert.ToInt32(r["MonthlyActiveUsers"]);
                    stats.PendingPasswordResets = Convert.ToInt32(r["PendingPasswordResets"]);
                    stats.TotalProjects = Convert.ToInt32(r["TotalProjects"]);
                    stats.TotalSkills = Convert.ToInt32(r["TotalSkills"]);
                    stats.TotalTechStacks = Convert.ToInt32(r["TotalTechStacks"]);
                    stats.TotalExperiences = Convert.ToInt32(r["TotalExperiences"]);
                    stats.TotalEducations = Convert.ToInt32(r["TotalEducations"]);
                    stats.TotalAwards = Convert.ToInt32(r["TotalAwards"]);
                    stats.TotalHobbies = Convert.ToInt32(r["TotalHobbies"]);
                }

                stats.RecentUsers = GetAllUsers();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[PortfolioService] GetDashboardStats error: " + ex.Message);
            }
            return stats;
        }

        public static void RecordUserLogin(int userId, string ip, string ua)
        {
            try
            {
                string sql = @"UPDATE dbo.users_tbl 
                               SET last_login_at = GETDATE(), login_count = ISNULL(login_count, 0) + 1 
                               WHERE user_id = @UserId;
                               INSERT INTO dbo.user_logins_tbl (user_id, login_time, ip_address, user_agent)
                               VALUES (@UserId, GETDATE(), @Ip, @Ua);";
                DatabaseHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@Ip", (object)ip ?? DBNull.Value),
                    new SqlParameter("@Ua", (object)ua ?? DBNull.Value));
            }
            catch { }
        }

        public static List<PasswordResetRequestDto> GetPendingPasswordResets()
        {
            var list = new List<PasswordResetRequestDto>();
            try
            {
                string query = @"SELECT r.reset_id, r.user_id, r.email, r.reason, r.status, r.created_at,
                                        ISNULL(u.first_name + ' ' + u.last_name, r.email) AS user_name
                                 FROM password_resets_tbl r
                                 LEFT JOIN users_tbl u ON r.user_id = u.user_id
                                 WHERE r.status = 'pending'
                                 ORDER BY r.reset_id DESC;";
                var dt = DatabaseHelper.ExecuteDataTable(query);
                if (dt != null)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        list.Add(new PasswordResetRequestDto
                        {
                            ResetId = Convert.ToInt32(row["reset_id"]),
                            UserId = row["user_id"] != DBNull.Value ? Convert.ToInt32(row["user_id"]) : (int?)null,
                            UserName = row["user_name"]?.ToString() ?? "",
                            Email = row["email"]?.ToString() ?? "",
                            Reason = row["reason"]?.ToString() ?? "",
                            Status = row["status"]?.ToString() ?? "pending",
                            CreatedAt = Convert.ToDateTime(row["created_at"])
                        });
                    }
                }
            }
            catch { }
            return list;
        }

        public static bool ApprovePasswordReset(int resetId)
        {
            try
            {
                string sql = "UPDATE password_resets_tbl SET status = 'password_removed' WHERE reset_id = @ResetId;";
                DatabaseHelper.ExecuteNonQuery(sql, new SqlParameter("@ResetId", resetId));
                return true;
            }
            catch { return false; }
        }

        public static bool RejectPasswordReset(int resetId)
        {
            try
            {
                string sql = "UPDATE password_resets_tbl SET status = 'used' WHERE reset_id = @ResetId;";
                DatabaseHelper.ExecuteNonQuery(sql, new SqlParameter("@ResetId", resetId));
                return true;
            }
            catch { return false; }
        }

        public static bool SetUserActiveStatus(int userId, bool isActive) => ToggleUserStatus(userId, isActive);
        public static bool AdminResetUserPassword(int userId) => ResetUserPassword(userId);
        public static List<PasswordResetRequestDto> GetPasswordResetRequests() => GetPendingPasswordResets();
        public static bool ApprovePasswordResetRequest(int resetId) => ApprovePasswordReset(resetId);
        public static bool RejectPasswordResetRequest(int resetId) => RejectPasswordReset(resetId);

        public static bool DeleteUser(int userId)
        {
            try
            {
                DatabaseHelper.ExecuteNonQuery("DELETE FROM users_tbl WHERE user_id = @UserId", new SqlParameter("@UserId", userId));
                return true;
            }
            catch { return false; }
        }

        public static bool UpdateAdminCredentials(int userId, string firstName, string lastName, string email, string newPassword, string avatarPath = null)
        {
            try
            {
                var paramList = new List<SqlParameter>
                {
                    new SqlParameter("@FirstName", firstName ?? "Admin"),
                    new SqlParameter("@LastName", lastName ?? "User"),
                    new SqlParameter("@Email", email ?? ""),
                    new SqlParameter("@UserId", userId)
                };

                string query;
                if (!string.IsNullOrWhiteSpace(newPassword))
                {
                    string hash = AuthHelper.HashPassword(newPassword);
                    query = "UPDATE users_tbl SET first_name = @FirstName, last_name = @LastName, email = @Email, password_hash = @PasswordHash";
                    paramList.Add(new SqlParameter("@PasswordHash", hash));
                }
                else
                {
                    query = "UPDATE users_tbl SET first_name = @FirstName, last_name = @LastName, email = @Email";
                }

                if (!string.IsNullOrWhiteSpace(avatarPath))
                {
                    query += ", profile_image = @ProfileImage";
                    paramList.Add(new SqlParameter("@ProfileImage", avatarPath));
                }

                query += " WHERE user_id = @UserId;";
                DatabaseHelper.ExecuteNonQuery(query, paramList.ToArray());
                InvalidateCache(userId);
                return true;
            }
            catch { return false; }
        }
    }
}
