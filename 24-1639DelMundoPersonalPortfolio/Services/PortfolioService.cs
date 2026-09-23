using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
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
                if (userId <= 0)
                    userId = 1;
            }

            string cacheKey = GetCacheKey(userId);

            if (!forceRefresh)
            {
                var cached = HttpRuntime.Cache?.Get(cacheKey) as PortfolioDataDto;
                if (cached != null)
                    return cached;
            }

            lock (CacheLock)
            {
                if (!forceRefresh)
                {
                    var cached = HttpRuntime.Cache?.Get(cacheKey) as PortfolioDataDto;
                    if (cached != null)
                        return cached;
                }

                var data = new PortfolioDataDto
                {
                    UserId = userId,
                    IsOwner = (AuthHelper.GetCurrentUserId() == userId),
                };

                try
                {
                    var pUser = new SqlParameter("@user_id", userId);
                    var ds = DatabaseHelper.ExecuteStoredProcedureDataSet(
                        "sp_GetUserPortfolioData",
                        pUser
                    );

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
                                HeroSubline = r["hero_subline"]?.ToString() ?? "",
                                RoleSummary = r["role_summary"]?.ToString() ?? "",
                                RoleTitle = r["role_title"]?.ToString() ?? "",
                                FocusArea = r["focus_area"]?.ToString() ?? "",
                                BasedIn = r["based_in"]?.ToString() ?? "",
                                AvatarPath =
                                    r["avatar_path"]?.ToString()
                                    ?? "Assets/Images/image_placeholder.png",
                                LocationAddress = r["location_address"]?.ToString() ?? "",
                                BirthDate =
                                    r["birth_date"] != DBNull.Value
                                        ? Convert.ToDateTime(r["birth_date"])
                                        : (DateTime?)null,
                                Age = Convert.ToInt32(r["derived_age"]),
                                ExperienceYears =
                                    r["experience_years"] != DBNull.Value
                                        ? Convert.ToInt32(r["experience_years"])
                                        : 1,
                                Email = ds.Tables[0].Columns.Contains("email")
                                    ? (r["email"]?.ToString() ?? "")
                                    : "",
                                GithubUrl = ds.Tables[0].Columns.Contains("github_url")
                                    ? (r["github_url"]?.ToString() ?? "")
                                    : "",
                                LinkedinUrl = ds.Tables[0].Columns.Contains("linkedin_url")
                                    ? (r["linkedin_url"]?.ToString() ?? "")
                                    : "",
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
                                data.TechStacks.Add(
                                    new TechStackItemDto
                                    {
                                        TechId = Convert.ToInt32(r["tech_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        GroupName = r["group_name"]?.ToString() ?? "",
                                        Label = r["label"]?.ToString() ?? "",
                                        IconPath = r["icon_path"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 3. Skills (Table 2)
                        if (ds.Tables.Count > 2)
                        {
                            foreach (DataRow r in ds.Tables[2].Rows)
                            {
                                data.Skills.Add(
                                    new SkillDto
                                    {
                                        SkillId = Convert.ToInt32(r["skill_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        SkillName = r["skill_name"]?.ToString() ?? "",
                                        ProficiencyVal = Convert.ToInt32(r["proficiency_val"]),
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 4. Experiences (Table 3)
                        if (ds.Tables.Count > 3)
                        {
                            foreach (DataRow r in ds.Tables[3].Rows)
                            {
                                data.Experiences.Add(
                                    new ExperienceDto
                                    {
                                        ExpId = Convert.ToInt32(r["exp_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        RoleTitle = r["role_title"]?.ToString() ?? "",
                                        CompanyName = r["company_name"]?.ToString() ?? "",
                                        StartYear = Convert.ToInt32(r["start_year"]),
                                        EndYear =
                                            r["end_year"] != DBNull.Value
                                                ? Convert.ToInt32(r["end_year"])
                                                : (int?)null,
                                        IsCurrent = Convert.ToBoolean(r["is_current"]),
                                        DescriptionText = r["description_text"]?.ToString() ?? "",
                                        Tags = r["tags"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 5. Projects (Table 4)
                        if (ds.Tables.Count > 4)
                        {
                            foreach (DataRow r in ds.Tables[4].Rows)
                            {
                                data.Projects.Add(
                                    new ProjectDto
                                    {
                                        ProjectId = Convert.ToInt32(r["project_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        Title = r["title"]?.ToString() ?? "",
                                        ImagePath = r["image_path"]?.ToString() ?? "",
                                        ProjectUrl = r["project_url"]?.ToString() ?? "",
                                        Tags = r["tags"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 6. Educations (Table 5)
                        if (ds.Tables.Count > 5)
                        {
                            foreach (DataRow r in ds.Tables[5].Rows)
                            {
                                data.Educations.Add(
                                    new EducationDto
                                    {
                                        EduId = Convert.ToInt32(r["edu_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        StartYear = Convert.ToInt32(r["start_year"]),
                                        EndYear =
                                            r["end_year"] != DBNull.Value
                                                ? Convert.ToInt32(r["end_year"])
                                                : (int?)null,
                                        IsCurrent = Convert.ToBoolean(r["is_current"]),
                                        Title = r["title"]?.ToString() ?? "",
                                        Subtitle = r["subtitle"]?.ToString() ?? "",
                                        InstitutionName = r["institution_name"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 7. Awards (Table 6)
                        if (ds.Tables.Count > 6)
                        {
                            foreach (DataRow r in ds.Tables[6].Rows)
                            {
                                data.Awards.Add(
                                    new AwardDto
                                    {
                                        AwardId = Convert.ToInt32(r["award_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        AwardYear = r["award_year"]?.ToString() ?? "",
                                        Title = r["title"]?.ToString() ?? "",
                                        Subtitle = r["subtitle"]?.ToString() ?? "",
                                        OrganizationName = r["organization_name"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
                            }
                        }

                        // 8. Hobbies (Table 7)
                        if (ds.Tables.Count > 7)
                        {
                            foreach (DataRow r in ds.Tables[7].Rows)
                            {
                                data.Hobbies.Add(
                                    new HobbyDto
                                    {
                                        HobbyId = Convert.ToInt32(r["hobby_id"]),
                                        UserId = Convert.ToInt32(r["user_id"]),
                                        HobbyName = r["hobby_name"]?.ToString() ?? "",
                                        HobbyDescription = r["hobby_description"]?.ToString() ?? "",
                                        IsActive = Convert.ToBoolean(r["is_active"]),
                                    }
                                );
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
                    System.Diagnostics.Debug.WriteLine(
                        $"[PortfolioService] Error fetching user {userId} data: {ex.Message}"
                    );
                    data.Profile = GetInitialProfileFromUser(userId);
                }

                try
                {
                    data.Contacts = GetContacts(userId);
                    if (data.Profile != null)
                    {
                        if (string.IsNullOrWhiteSpace(data.Profile.Email))
                            data.Profile.Email =
                                data.Contacts.FirstOrDefault(c =>
                                    string.Equals(
                                        c.Platform,
                                        "Email",
                                        StringComparison.OrdinalIgnoreCase
                                    )
                                )?.ContactValue
                                ?? "";
                        if (string.IsNullOrWhiteSpace(data.Profile.GithubUrl))
                            data.Profile.GithubUrl =
                                data.Contacts.FirstOrDefault(c =>
                                    string.Equals(
                                        c.Platform,
                                        "GitHub",
                                        StringComparison.OrdinalIgnoreCase
                                    )
                                )?.ComputedUrl
                                ?? "";
                        if (string.IsNullOrWhiteSpace(data.Profile.LinkedinUrl))
                            data.Profile.LinkedinUrl =
                                data.Contacts.FirstOrDefault(c =>
                                    string.Equals(
                                        c.Platform,
                                        "LinkedIn",
                                        StringComparison.OrdinalIgnoreCase
                                    )
                                )?.ComputedUrl
                                ?? "";
                    }
                }
                catch { }

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
                RoleTitle = "",
                FocusArea = "",
                BasedIn = "",
                AvatarPath = "",
                ExperienceYears = 0,
            };

            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedure(
                    "sp_GetUserById",
                    new SqlParameter("@UserId", userId)
                );
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
                    if (currentUid > 0)
                        HttpRuntime.Cache?.Remove(GetCacheKey(currentUid));
                }
            }
            catch { }
        }

        // -------------------------------------------------------------
        // CRUD Operations with Stored Procedures
        // -------------------------------------------------------------

        public static bool SaveProfile(ProfileDto p, int userId = 0)
        {
            if (userId <= 0)
                userId = p.UserId > 0 ? p.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var baseParams = new List<SqlParameter>
            {
                new SqlParameter("@user_id", userId),
                new SqlParameter("@hero_subline", (object)p.HeroSubline ?? DBNull.Value),
                new SqlParameter("@hero_names", (object)p.HeroNames ?? DBNull.Value),
                new SqlParameter("@role_summary", (object)p.RoleSummary ?? DBNull.Value),
                new SqlParameter("@role_title", (object)p.RoleTitle ?? DBNull.Value),
                new SqlParameter("@focus_area", (object)p.FocusArea ?? DBNull.Value),
                new SqlParameter("@based_in", (object)p.BasedIn ?? DBNull.Value),
                new SqlParameter("@avatar_path", (object)p.AvatarPath ?? DBNull.Value),
                new SqlParameter("@location_address", (object)p.LocationAddress ?? DBNull.Value),
                new SqlParameter(
                    "@birth_date",
                    p.BirthDate.HasValue ? (object)p.BirthDate.Value.Date : DBNull.Value
                ),
                new SqlParameter("@experience_years", p.ExperienceYears),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_SaveProfile",
                    baseParams.ToArray()
                );
                InvalidateCache(userId);
                return true;
            }
            catch (Exception ex)
            {
                // Fallback: If DB stored procedure still expects legacy contact parameters, supply them
                if (
                    ex.Message.IndexOf("@email", StringComparison.OrdinalIgnoreCase) >= 0
                    || ex.Message.IndexOf("expects parameter", StringComparison.OrdinalIgnoreCase)
                        >= 0
                )
                {
                    try
                    {
                        var legacyParams = new List<SqlParameter>(baseParams)
                        {
                            new SqlParameter("@email", (object)p.Email ?? DBNull.Value),
                            new SqlParameter("@github_url", (object)p.GithubUrl ?? DBNull.Value),
                            new SqlParameter(
                                "@linkedin_url",
                                (object)p.LinkedinUrl ?? DBNull.Value
                            ),
                        };
                        DatabaseHelper.ExecuteStoredProcedureNonQuery(
                            "sp_SaveProfile",
                            legacyParams.ToArray()
                        );
                        InvalidateCache(userId);
                        return true;
                    }
                    catch { }
                }
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] SaveProfile error: " + ex.Message
                );
                return false;
            }
        }

        public static bool UpdateUserDetails(
            int userId,
            string firstName,
            string lastName,
            string newPassword = null
        )
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                return false;

            try
            {
                string hash = !string.IsNullOrEmpty(newPassword)
                    ? AuthHelper.HashPassword(newPassword)
                    : null;
                var parameters = new SqlParameter[]
                {
                    new SqlParameter("@user_id", userId),
                    new SqlParameter("@first_name", (object)firstName ?? DBNull.Value),
                    new SqlParameter("@last_name", (object)lastName ?? DBNull.Value),
                    new SqlParameter("@password_hash", (object)hash ?? DBNull.Value),
                };

                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_UpdateUserDetails", parameters);

                // Update active session user
                var currentUser = AuthHelper.GetCurrentUser();
                if (currentUser != null && currentUser.UserId == userId)
                {
                    currentUser.FirstName = firstName;
                    currentUser.LastName = lastName;
                    if (!string.IsNullOrEmpty(hash))
                        currentUser.PasswordHash = hash;
                    AuthHelper.SetUserSession(currentUser);
                }

                InvalidateCache(userId);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] UpdateUserDetails error: " + ex.Message
                );
                return false;
            }
        }

        public static bool SaveTechStack(TechStackItemDto item, string rawSvg, int userId = 0)
        {
            if (userId <= 0)
                userId = item.UserId > 0 ? item.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            string svgString = !string.IsNullOrWhiteSpace(rawSvg)
                ? rawSvg.Trim()
                : (item.IconPath ?? "").Trim();

            // Decode base64 if it was encoded from client to bypass request validation
            if (svgString.StartsWith("base64:", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    byte[] bytes = Convert.FromBase64String(svgString.Substring(7));
                    svgString = System.Text.Encoding.UTF8.GetString(bytes).Trim();
                }
                catch { }
            }

            if (
                !string.IsNullOrWhiteSpace(svgString)
                && svgString.IndexOf("<svg", StringComparison.OrdinalIgnoreCase) >= 0
            )
            {
                // Save the SVG tag itself directly instead of writing to disk or saving file path
                item.IconPath = svgString;
            }
            else if (string.IsNullOrWhiteSpace(item.IconPath) && item.TechId > 0)
            {
                try
                {
                    var existingList = GetPortfolioData(userId, false)?.TechStacks;
                    var existingItem =
                        existingList != null
                            ? System.Linq.Enumerable.FirstOrDefault(
                                existingList,
                                t => t.TechId == item.TechId
                            )
                            : null;
                    if (existingItem != null && !string.IsNullOrWhiteSpace(existingItem.IconPath))
                    {
                        item.IconPath = existingItem.IconPath;
                    }
                }
                catch { }
            }

            if (item.TechId == 0)
            {
                try
                {
                    var existingList = GetPortfolioData(userId, false)?.TechStacks;
                    var duplicate =
                        existingList != null
                            ? System.Linq.Enumerable.FirstOrDefault(
                                existingList,
                                t =>
                                    string.Equals(
                                        t.GroupName,
                                        item.GroupName,
                                        StringComparison.OrdinalIgnoreCase
                                    )
                                    && string.Equals(
                                        t.Label,
                                        item.Label,
                                        StringComparison.OrdinalIgnoreCase
                                    )
                            )
                            : null;
                    if (duplicate != null)
                    {
                        item.TechId = duplicate.TechId;
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
                new SqlParameter("@icon_path", System.Data.SqlDbType.NVarChar, -1)
                {
                    Value = (object)(item.IconPath ?? ""),
                },
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveTechStack", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] SaveTechStack error: " + ex.Message
                );
                return false;
            }
        }

        public static bool SaveTechStack(TechStackItemDto item, int userId = 0)
        {
            return SaveTechStack(item, null, userId);
        }

        public static bool DeleteTechStack(int techId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteTechStack",
                    new SqlParameter("@tech_id", techId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveSkill(SkillDto skill, int userId = 0)
        {
            if (userId <= 0)
                userId = skill.UserId > 0 ? skill.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@skill_id", skill.SkillId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@skill_name", skill.SkillName ?? ""),
                new SqlParameter("@proficiency_val", skill.ProficiencyVal),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveSkill", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteSkill(int skillId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteSkill",
                    new SqlParameter("@skill_id", skillId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveExperience(ExperienceDto exp, int userId = 0)
        {
            if (userId <= 0)
                userId = exp.UserId > 0 ? exp.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@exp_id", exp.ExpId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@role_title", exp.RoleTitle ?? ""),
                new SqlParameter("@company_name", exp.CompanyName ?? ""),
                new SqlParameter("@start_year", exp.StartYear),
                new SqlParameter(
                    "@end_year",
                    exp.EndYear.HasValue ? (object)exp.EndYear.Value : DBNull.Value
                ),
                new SqlParameter("@is_current", exp.IsCurrent),
                new SqlParameter("@description_text", (object)exp.DescriptionText ?? DBNull.Value),
                new SqlParameter("@tags", (object)exp.Tags ?? DBNull.Value),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveExperience", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteExperience(int expId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteExperience",
                    new SqlParameter("@exp_id", expId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveProject(ProjectDto project, int userId = 0)
        {
            if (userId <= 0)
                userId = project.UserId > 0 ? project.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@project_id", project.ProjectId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@title", project.Title ?? ""),
                new SqlParameter("@image_path", project.ImagePath ?? ""),
                new SqlParameter("@project_url", (object)project.ProjectUrl ?? DBNull.Value),
                new SqlParameter("@tags", (object)project.Tags ?? DBNull.Value),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveProject", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteProject(int projectId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteProject",
                    new SqlParameter("@project_id", projectId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveEducation(EducationDto edu, int userId = 0)
        {
            if (userId <= 0)
                userId = edu.UserId > 0 ? edu.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@edu_id", edu.EduId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@title", edu.Title ?? ""),
                new SqlParameter("@subtitle", edu.Subtitle ?? ""),
                new SqlParameter("@institution_name", edu.InstitutionName ?? ""),
                new SqlParameter("@start_year", edu.StartYear),
                new SqlParameter(
                    "@end_year",
                    edu.EndYear.HasValue ? (object)edu.EndYear.Value : DBNull.Value
                ),
                new SqlParameter("@is_current", edu.IsCurrent),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveEducation", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteEducation(int eduId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteEducation",
                    new SqlParameter("@edu_id", eduId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveAward(AwardDto award, int userId = 0)
        {
            if (userId <= 0)
                userId = award.UserId > 0 ? award.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@award_id", award.AwardId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@award_year", award.AwardYear ?? ""),
                new SqlParameter("@title", award.Title ?? ""),
                new SqlParameter("@subtitle", award.Subtitle ?? ""),
                new SqlParameter("@organization_name", award.OrganizationName ?? ""),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveAward", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteAward(int awardId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteAward",
                    new SqlParameter("@award_id", awardId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SaveHobby(HobbyDto hobby, int userId = 0)
        {
            if (userId <= 0)
                userId = hobby.UserId > 0 ? hobby.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@hobby_id", hobby.HobbyId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@hobby_name", hobby.HobbyName ?? ""),
                new SqlParameter(
                    "@hobby_description",
                    (object)hobby.HobbyDescription ?? DBNull.Value
                ),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveHobby", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool DeleteHobby(int hobbyId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteHobby",
                    new SqlParameter("@hobby_id", hobbyId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static List<ContactDto> GetContacts(int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var list = new List<ContactDto>();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable(
                    "sp_GetContacts",
                    new SqlParameter("@user_id", userId)
                );
                if (dt != null && dt.Rows.Count > 0)
                {
                    foreach (DataRow r in dt.Rows)
                    {
                        list.Add(
                            new ContactDto
                            {
                                ContactId = Convert.ToInt32(r["contact_id"]),
                                UserId = Convert.ToInt32(r["user_id"]),
                                Platform = r["platform"]?.ToString() ?? "Other",
                                ContactLabel =
                                    r["contact_label"] != DBNull.Value
                                        ? r["contact_label"].ToString()
                                        : "",
                                ContactValue = r["contact_value"]?.ToString() ?? "",
                                ContactUrl =
                                    r["contact_url"] != DBNull.Value
                                        ? r["contact_url"].ToString()
                                        : "",
                                DisplayOrder = Convert.ToInt32(r["display_order"]),
                                IsActive = Convert.ToBoolean(r["is_active"]),
                            }
                        );
                    }
                    return list;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] sp_GetContacts error (falling back): " + ex.Message
                );
            }

            // Fallback: Check profile_tbl for legacy contacts if contacts_tbl has no rows
            try
            {
                var dtProfile = DatabaseHelper.ExecuteStoredProcedure(
                    "sp_GetProfileContactInfo",
                    new SqlParameter("@user_id", userId)
                );
                if (dtProfile != null && dtProfile.Rows.Count > 0)
                {
                    var row = dtProfile.Rows[0];
                    string email = row["email"]?.ToString();
                    string github = row["github_url"]?.ToString();
                    string linkedin = row["linkedin_url"]?.ToString();

                    int order = 1;
                    if (!string.IsNullOrWhiteSpace(email))
                    {
                        list.Add(
                            new ContactDto
                            {
                                ContactId = -1,
                                UserId = userId,
                                Platform = "Email",
                                ContactLabel = "Email Address",
                                ContactValue = email.Trim(),
                                ContactUrl = "mailto:" + email.Trim(),
                                DisplayOrder = order++,
                                IsActive = true,
                            }
                        );
                    }
                    if (!string.IsNullOrWhiteSpace(github))
                    {
                        list.Add(
                            new ContactDto
                            {
                                ContactId = -2,
                                UserId = userId,
                                Platform = "GitHub",
                                ContactLabel = "GitHub Profile",
                                ContactValue = github.Trim(),
                                ContactUrl = github.Trim(),
                                DisplayOrder = order++,
                                IsActive = true,
                            }
                        );
                    }
                    if (!string.IsNullOrWhiteSpace(linkedin))
                    {
                        list.Add(
                            new ContactDto
                            {
                                ContactId = -3,
                                UserId = userId,
                                Platform = "LinkedIn",
                                ContactLabel = "LinkedIn Profile",
                                ContactValue = linkedin.Trim(),
                                ContactUrl = linkedin.Trim(),
                                DisplayOrder = order++,
                                IsActive = true,
                            }
                        );
                    }
                }
            }
            catch { }

            return list;
        }

        public static bool SaveContact(ContactDto contact, int userId = 0)
        {
            if (userId <= 0)
                userId = contact.UserId > 0 ? contact.UserId : AuthHelper.GetCurrentUserId();
            if (userId <= 0)
                userId = 1;

            var parameters = new SqlParameter[]
            {
                new SqlParameter("@contact_id", contact.ContactId),
                new SqlParameter("@user_id", userId),
                new SqlParameter("@platform", contact.Platform ?? "Other"),
                new SqlParameter("@contact_label", (object)contact.ContactLabel ?? DBNull.Value),
                new SqlParameter("@contact_value", contact.ContactValue ?? ""),
                new SqlParameter("@contact_url", (object)contact.ContactUrl ?? DBNull.Value),
                new SqlParameter("@display_order", contact.DisplayOrder),
            };

            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery("sp_SaveContact", parameters);
                InvalidateCache(userId);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] SaveContact error: " + ex.Message
                );
                return false;
            }
        }

        public static bool DeleteContact(int contactId, int userId = 0)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteContact",
                    new SqlParameter("@contact_id", contactId),
                    new SqlParameter("@user_id", userId)
                );
                InvalidateCache(userId);
                return true;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] DeleteContact error: " + ex.Message
                );
                return false;
            }
        }

        // -------------------------------------------------------------
        // User Supervision & Admin Services
        // -------------------------------------------------------------

        public static List<UserSummaryDto> GetAllUsers(bool excludeAdmins = false)
        {
            var list = new List<UserSummaryDto>();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable("sp_GetAllUsers");
                if (dt != null)
                {
                    foreach (DataRow r in dt.Rows)
                    {
                        string role = "User";
                        if (r.Table.Columns.Contains("Role") && r["Role"] != DBNull.Value)
                            role = r["Role"].ToString();
                        else if (
                            r.Table.Columns.Contains("UserRole")
                            && r["UserRole"] != DBNull.Value
                        )
                            role = r["UserRole"].ToString();
                        else if (
                            r.Table.Columns.Contains("user_role")
                            && r["user_role"] != DBNull.Value
                        )
                            role = r["user_role"].ToString();

                        if (
                            excludeAdmins
                            && role.Equals("Admin", StringComparison.OrdinalIgnoreCase)
                        )
                        {
                            continue;
                        }

                        string avatar = "";
                        if (
                            r.Table.Columns.Contains("AvatarPath")
                            && r["AvatarPath"] != DBNull.Value
                        )
                            avatar = r["AvatarPath"].ToString();
                        else if (
                            r.Table.Columns.Contains("avatar_path")
                            && r["avatar_path"] != DBNull.Value
                        )
                            avatar = r["avatar_path"].ToString();

                        list.Add(
                            new UserSummaryDto
                            {
                                UserId = Convert.ToInt32(r["UserId"]),
                                FirstName = r["FirstName"]?.ToString() ?? "",
                                LastName = r["LastName"]?.ToString() ?? "",
                                FullName = $"{r["FirstName"]} {r["LastName"]}".Trim(),
                                Email = r["Email"]?.ToString() ?? "",
                                Role = role,
                                IsActive = Convert.ToBoolean(r["IsActive"]),
                                CreatedAt = Convert.ToDateTime(r["CreatedAt"]),
                                LastLoginAt =
                                    r["LastLoginAt"] != DBNull.Value
                                        ? Convert.ToDateTime(r["LastLoginAt"])
                                        : (DateTime?)null,
                                LoginCount = Convert.ToInt32(r["LoginCount"]),
                                HasProfile = Convert.ToBoolean(r["HasProfile"]),
                                BirthDate =
                                    r["BirthDate"] != DBNull.Value
                                        ? Convert.ToDateTime(r["BirthDate"])
                                        : (DateTime?)null,
                                RoleTitle = r["RoleTitle"]?.ToString() ?? "",
                                AvatarPath = avatar,
                            }
                        );
                    }
                }

                // Batch-load avatar paths from profile_tbl if sp_GetAllUsers does not return AvatarPath column
                if (
                    list.Count > 0
                    && (
                        dt == null
                        || (
                            !dt.Columns.Contains("AvatarPath")
                            && !dt.Columns.Contains("avatar_path")
                        )
                    )
                )
                {
                    try
                    {
                        var avatarDt = DatabaseHelper.ExecuteStoredProcedureDataTable(
                            "sp_GetUsersAvatarMap"
                        );
                        if (avatarDt != null)
                        {
                            var map = new System.Collections.Generic.Dictionary<int, string>();
                            foreach (DataRow row in avatarDt.Rows)
                            {
                                int uid = Convert.ToInt32(row["user_id"]);
                                map[uid] = row["avatar_path"]?.ToString() ?? "";
                            }
                            foreach (var u in list)
                            {
                                if (map.ContainsKey(u.UserId))
                                    u.AvatarPath = map[u.UserId];
                            }
                        }
                    }
                    catch { }
                }

                // Link pending password reset requests to users
                try
                {
                    var pendingResets = GetPendingPasswordResets();

                    if (pendingResets != null && pendingResets.Count > 0)
                    {
                        foreach (var u in list)
                        {
                            var matched = pendingResets.FirstOrDefault(pr =>
                                (pr.UserId.HasValue && pr.UserId.Value == u.UserId)
                                || (
                                    !string.IsNullOrEmpty(pr.Email)
                                    && string.Equals(
                                        pr.Email,
                                        u.Email,
                                        StringComparison.OrdinalIgnoreCase
                                    )
                                )
                            );
                            if (matched != null)
                            {
                                u.PendingResetId = matched.ResetId;
                                u.PendingResetReason = matched.Reason;
                                u.PendingResetRequestedAt = matched.CreatedAt;
                            }
                        }
                    }
                }
                catch { }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] GetAllUsers error: " + ex.Message
                );
            }
            return list;
        }

        public static List<UserPortfolioReportDto> GetUserPortfolioReports()
        {
            var list = new List<UserPortfolioReportDto>();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable(
                    "sp_GetUserPortfolioReports"
                );
                if (dt != null)
                {
                    foreach (DataRow r in dt.Rows)
                    {
                        string avatar = "";
                        if (
                            r.Table.Columns.Contains("AvatarPath")
                            && r["AvatarPath"] != DBNull.Value
                        )
                            avatar = r["AvatarPath"].ToString();
                        else if (
                            r.Table.Columns.Contains("avatar_path")
                            && r["avatar_path"] != DBNull.Value
                        )
                            avatar = r["avatar_path"].ToString();

                        list.Add(
                            new UserPortfolioReportDto
                            {
                                UserId = Convert.ToInt32(r["UserId"]),
                                FirstName = r["FirstName"]?.ToString() ?? "",
                                LastName = r["LastName"]?.ToString() ?? "",
                                FullName = r["FullName"]?.ToString() ?? "",
                                Email = r["Email"]?.ToString() ?? "",
                                IsActive = Convert.ToBoolean(r["IsActive"]),
                                CreatedAt = Convert.ToDateTime(r["CreatedAt"]),
                                LastLoginAt =
                                    r["LastLoginAt"] != DBNull.Value
                                        ? Convert.ToDateTime(r["LastLoginAt"])
                                        : (DateTime?)null,
                                LoginCount = Convert.ToInt32(r["LoginCount"]),
                                HasProfile = Convert.ToBoolean(r["HasProfile"]),
                                RoleTitle = r["RoleTitle"]?.ToString() ?? "Not Set",
                                LastProfileUpdate =
                                    r["LastProfileUpdate"] != DBNull.Value
                                        ? Convert.ToDateTime(r["LastProfileUpdate"])
                                        : (DateTime?)null,
                                ProjectsCount = Convert.ToInt32(r["ProjectsCount"]),
                                SkillsCount = Convert.ToInt32(r["SkillsCount"]),
                                TechCount = Convert.ToInt32(r["TechCount"]),
                                ExperiencesCount = Convert.ToInt32(r["ExperiencesCount"]),
                                PortfolioStatus = r["PortfolioStatus"]?.ToString() ?? "Not Started",
                                Role =
                                    r.Table.Columns.Contains("Role") && r["Role"] != DBNull.Value
                                        ? r["Role"].ToString()
                                        : (
                                            r.Table.Columns.Contains("UserRole")
                                            && r["UserRole"] != DBNull.Value
                                                ? r["UserRole"].ToString()
                                                : (
                                                    r.Table.Columns.Contains("user_role")
                                                    && r["user_role"] != DBNull.Value
                                                        ? r["user_role"].ToString()
                                                        : "User"
                                                )
                                        ),
                                AvatarPath = avatar,
                            }
                        );
                    }
                }

                // Batch-load avatar paths from profile_tbl if sp_GetUserPortfolioReports does not return AvatarPath column
                if (
                    list.Count > 0
                    && (
                        dt == null
                        || (
                            !dt.Columns.Contains("AvatarPath")
                            && !dt.Columns.Contains("avatar_path")
                        )
                    )
                )
                {
                    try
                    {
                        var avatarDt = DatabaseHelper.ExecuteStoredProcedureDataTable(
                            "sp_GetUsersAvatarMap"
                        );
                        if (avatarDt != null)
                        {
                            var map = new System.Collections.Generic.Dictionary<int, string>();
                            foreach (DataRow row in avatarDt.Rows)
                            {
                                int uid = Convert.ToInt32(row["user_id"]);
                                map[uid] = row["avatar_path"]?.ToString() ?? "";
                            }
                            foreach (var u in list)
                            {
                                if (map.ContainsKey(u.UserId))
                                    u.AvatarPath = map[u.UserId];
                            }
                        }
                    }
                    catch { }
                }
                // Ensure all users (including Admins) are represented in the combined report list
                try
                {
                    var allUsers = GetAllUsers(excludeAdmins: false);
                    if (allUsers != null && allUsers.Count > 0)
                    {
                        var existingIds = new System.Collections.Generic.HashSet<int>(
                            System.Linq.Enumerable.Select(list, x => x.UserId)
                        );
                        foreach (var u in allUsers)
                        {
                            if (!existingIds.Contains(u.UserId))
                            {
                                list.Add(
                                    new UserPortfolioReportDto
                                    {
                                        UserId = u.UserId,
                                        FirstName = u.FirstName,
                                        LastName = u.LastName,
                                        FullName = u.FullName,
                                        Email = u.Email,
                                        IsActive = u.IsActive,
                                        CreatedAt = u.CreatedAt,
                                        LastLoginAt = u.LastLoginAt,
                                        LoginCount = u.LoginCount,
                                        HasProfile = u.HasProfile,
                                        RoleTitle = string.IsNullOrEmpty(u.RoleTitle)
                                            ? (
                                                u.Role.Equals(
                                                    "Admin",
                                                    StringComparison.OrdinalIgnoreCase
                                                )
                                                    ? "Administrator"
                                                    : "Not Set"
                                            )
                                            : u.RoleTitle,
                                        Role = u.Role,
                                        AvatarPath = u.AvatarPath,
                                        PortfolioStatus = u.Role.Equals(
                                            "Admin",
                                            StringComparison.OrdinalIgnoreCase
                                        )
                                            ? "N/A"
                                            : (u.HasProfile ? "In Progress" : "Not Started"),
                                    }
                                );
                            }
                        }
                    }
                }
                catch { }

                // Order by recent login stream: most recent sign-ins first, then by account creation
                list = System.Linq.Enumerable.ToList(
                    System.Linq.Enumerable.ThenByDescending(
                        System.Linq.Enumerable.ThenByDescending(
                            System.Linq.Enumerable.OrderByDescending(
                                list,
                                u => u.LastLoginAt.HasValue
                            ),
                            u => u.LastLoginAt
                        ),
                        u => u.CreatedAt
                    )
                );
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] GetUserPortfolioReports error: " + ex.Message
                );
            }
            return list;
        }

        public static bool ToggleUserStatus(int targetUserId, bool isActive)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_ToggleUserStatus",
                    new SqlParameter("@user_id", targetUserId),
                    new SqlParameter("@is_active", isActive)
                );
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool ResetUserPassword(int targetUserId)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_ResetUserPassword",
                    new SqlParameter("@user_id", targetUserId)
                );
                return true;
            }
            catch
            {
                return false;
            }
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
                    if (r.Table.Columns.Contains("TotalPortfolios"))
                        stats.TotalPortfolios = Convert.ToInt32(r["TotalPortfolios"]);
                    if (r.Table.Columns.Contains("ConfiguredPortfolios"))
                        stats.ConfiguredPortfolios = Convert.ToInt32(r["ConfiguredPortfolios"]);
                    if (r.Table.Columns.Contains("PortfolioCreationRate"))
                        stats.PortfolioCreationRate = Convert.ToInt32(r["PortfolioCreationRate"]);
                }

                var allUsers = GetAllUsers(excludeAdmins: false);
                stats.RecentUsers =
                    allUsers != null
                        ? System.Linq.Enumerable.ToList(
                            System.Linq.Enumerable.ThenByDescending(
                                System.Linq.Enumerable.ThenByDescending(
                                    System.Linq.Enumerable.OrderByDescending(
                                        allUsers,
                                        u => u.LastLoginAt.HasValue
                                    ),
                                    u => u.LastLoginAt
                                ),
                                u => u.CreatedAt
                            )
                        )
                        : new List<UserSummaryDto>();
                stats.UserPortfolioReports = GetUserPortfolioReports();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine(
                    "[PortfolioService] GetDashboardStats error: " + ex.Message
                );
            }
            return stats;
        }


        public static void RecordUserLogin(int userId, string ip, string ua)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_RecordUserLogin",
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@IpAddress", (object)ip ?? DBNull.Value),
                    new SqlParameter("@UserAgent", (object)ua ?? DBNull.Value)
                );
            }
            catch { }
        }

        public static List<PasswordResetRequestDto> GetPendingPasswordResets()
        {
            var list = new List<PasswordResetRequestDto>();
            try
            {
                var dt = DatabaseHelper.ExecuteStoredProcedureDataTable("sp_GetPendingPasswordResets");
                if (dt != null)
                {
                    foreach (DataRow row in dt.Rows)
                    {
                        list.Add(
                            new PasswordResetRequestDto
                            {
                                ResetId = Convert.ToInt32(row["reset_id"]),
                                UserId =
                                    row["user_id"] != DBNull.Value
                                        ? Convert.ToInt32(row["user_id"])
                                        : (int?)null,
                                UserName = row["user_name"]?.ToString() ?? "",
                                Email = row["email"]?.ToString() ?? "",
                                Reason = row["reason"]?.ToString() ?? "",
                                Status = row["status"]?.ToString() ?? "pending",
                                CreatedAt = Convert.ToDateTime(row["created_at"]),
                            }
                        );
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
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_ApprovePasswordReset",
                    new SqlParameter("@reset_id", resetId)
                );
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool RejectPasswordReset(int resetId)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_RejectPasswordReset",
                    new SqlParameter("@reset_id", resetId)
                );
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool SetUserActiveStatus(int userId, bool isActive) =>
            ToggleUserStatus(userId, isActive);

        public static bool AdminResetUserPassword(int userId) => ResetUserPassword(userId);

        public static List<PasswordResetRequestDto> GetPasswordResetRequests() =>
            GetPendingPasswordResets();

        public static bool ApprovePasswordResetRequest(int resetId) =>
            ApprovePasswordReset(resetId);

        public static bool RejectPasswordResetRequest(int resetId) => RejectPasswordReset(resetId);

        public static bool DeleteUser(int userId)
        {
            try
            {
                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_DeleteUser",
                    new SqlParameter("@UserId", userId)
                );
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static bool UpdateAdminCredentials(
            int userId,
            string firstName,
            string lastName,
            string email,
            string newPassword
        )
        {
            try
            {
                var paramList = new List<SqlParameter>
                {
                    new SqlParameter("@user_id", userId),
                    new SqlParameter("@first_name", firstName ?? "Admin"),
                    new SqlParameter("@last_name", lastName ?? "User"),
                    new SqlParameter("@email", email ?? ""),
                    new SqlParameter(
                        "@password_hash",
                        string.IsNullOrWhiteSpace(newPassword)
                            ? (object)DBNull.Value
                            : AuthHelper.HashPassword(newPassword)
                    ),
                };

                DatabaseHelper.ExecuteStoredProcedureNonQuery(
                    "sp_UpdateAdminCredentials",
                    paramList.ToArray()
                );
                InvalidateCache(userId);
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
