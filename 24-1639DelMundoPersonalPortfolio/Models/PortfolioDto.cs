using System;
using System.Collections.Generic;

namespace _24_1639DelMundoPersonalPortfolio.Models
{
    public class PortfolioDataDto
    {
        public int UserId { get; set; }
        public string UserRole { get; set; } = "User";
        public bool IsOwner { get; set; } = false;
        public ProfileDto Profile { get; set; } = new ProfileDto();
        public List<TechStackItemDto> TechStacks { get; set; } = new List<TechStackItemDto>();
        public List<SkillDto> Skills { get; set; } = new List<SkillDto>();
        public List<ExperienceDto> Experiences { get; set; } = new List<ExperienceDto>();
        public List<ProjectDto> Projects { get; set; } = new List<ProjectDto>();
        public List<EducationDto> Educations { get; set; } = new List<EducationDto>();
        public List<AwardDto> Awards { get; set; } = new List<AwardDto>();
        public List<HobbyDto> Hobbies { get; set; } = new List<HobbyDto>();
        public DateTime FetchedAt { get; set; } = DateTime.UtcNow;
    }

    public class ProfileDto
    {
        public int ProfileId { get; set; }
        public int UserId { get; set; }
        public string FirstName { get; set; } = "";
        public string LastName { get; set; } = "";
        public string FullName => $"{FirstName} {LastName}".Trim();
        public string HeroSubline { get; set; } = "";
        public string HeroNames { get; set; } = "";
        public string RoleSummary { get; set; } = "";
        public string RoleTitle { get; set; } = "";
        public string FocusArea { get; set; } = "";
        public string BasedIn { get; set; } = "";
        public string AvatarPath { get; set; } = "Assets/Images/image_placeholder.png";
        public string LocationAddress { get; set; } = "";
        public DateTime? BirthDate { get; set; }

        private int _fallbackAge = 0;
        public int Age
        {
            get
            {
                if (BirthDate.HasValue)
                {
                    var today = DateTime.Today;
                    int age = today.Year - BirthDate.Value.Year;
                    if (BirthDate.Value.Date > today.AddYears(-age))
                        age--;
                    return age >= 0 ? age : 0;
                }
                return _fallbackAge;
            }
            set { _fallbackAge = value; }
        }

        public int ExperienceYears { get; set; } = 1;
        public string Email { get; set; } = "";
        public string GithubUrl { get; set; } = "";
        public string LinkedinUrl { get; set; } = "";
    }

    public class TechStackItemDto
    {
        public int TechId { get; set; }
        public int UserId { get; set; }
        public string GroupName { get; set; } = "";
        public string Label { get; set; } = "";
        public string IconPath { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class SkillDto
    {
        public int SkillId { get; set; }
        public int UserId { get; set; }
        public string SkillName { get; set; } = "";
        public int ProficiencyVal { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class ExperienceDto
    {
        public int ExpId { get; set; }
        public int UserId { get; set; }
        public string RoleTitle { get; set; } = "";
        public string CompanyName { get; set; } = "";
        public int StartYear { get; set; } = 2024;
        public int? EndYear { get; set; }
        public bool IsCurrent { get; set; }

        public string PeriodRange
        {
            get
            {
                if (IsCurrent || !EndYear.HasValue)
                    return $"{StartYear} — Present";
                return $"{StartYear} — {EndYear.Value}";
            }
        }

        public string DescriptionText { get; set; } = "";
        public string Tags { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class ProjectDto
    {
        public int ProjectId { get; set; }
        public int UserId { get; set; }
        public string Title { get; set; } = "";
        public string ImagePath { get; set; } = "";
        public string ProjectUrl { get; set; } = "";
        public string Tags { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class EducationDto
    {
        public int EduId { get; set; }
        public int UserId { get; set; }
        public int StartYear { get; set; } = 2024;
        public int? EndYear { get; set; }
        public bool IsCurrent { get; set; } = true;

        public string YearPeriod
        {
            get
            {
                if (IsCurrent || !EndYear.HasValue)
                    return $"{StartYear} — Present";
                return $"{StartYear} — {EndYear.Value}";
            }
        }

        public string Title { get; set; } = "";
        public string Subtitle { get; set; } = "";
        public string InstitutionName { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class AwardDto
    {
        public int AwardId { get; set; }
        public int UserId { get; set; }
        public string AwardYear { get; set; } = "";
        public string Title { get; set; } = "";
        public string Subtitle { get; set; } = "";
        public string OrganizationName { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class HobbyDto
    {
        public int HobbyId { get; set; }
        public int UserId { get; set; }
        public string HobbyName { get; set; } = "";
        public string HobbyDescription { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }

    public class PasswordResetRequestDto
    {
        public int ResetId { get; set; }
        public int? UserId { get; set; }
        public string UserName { get; set; } = "";
        public string Email { get; set; } = "";
        public string Reason { get; set; } = "";
        public string Status { get; set; } = "pending";
        public DateTime CreatedAt { get; set; }
    }

    public class DashboardStatsDto
    {
        public int TotalProjects { get; set; }
        public int TotalFeaturedProjects { get; set; }
        public int TotalTechStacks { get; set; }
        public int TotalTechCategories { get; set; }
        public int TotalSkills { get; set; }
        public int TotalExperiences { get; set; }
        public int TotalEducations { get; set; }
        public int TotalAwards { get; set; }
        public int TotalHobbies { get; set; }

        // User Accounts Overview Metrics
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int InactiveUsers { get; set; }
        public int AdminUsers { get; set; }
        public int SignUpsToday { get; set; }
        public int SignUpsThisWeek { get; set; }
        public int SignUpsThisMonth { get; set; }

        // User Activity & Engagement Metrics
        public int TotalLogins { get; set; }
        public int DailyActiveUsers { get; set; }
        public int MonthlyActiveUsers { get; set; }

        public int PendingPasswordResets { get; set; }
        public int ExperienceYears { get; set; }
        public int ProfileCompletenessPct { get; set; }
        public int TotalPortfolios { get; set; }
        public int ConfiguredPortfolios { get; set; }
        public int PortfolioCreationRate { get; set; }
        public bool IsDatabaseConnected { get; set; }
        public string DatabaseSource { get; set; } = "MSSQL Server (Stored Procedures)";
        public DateTime ReportGeneratedAt { get; set; } = DateTime.UtcNow;

        public List<CategoryStatDto> TechCategoryStats { get; set; } = new List<CategoryStatDto>();
        public List<CategoryStatDto> ProjectCategoryStats { get; set; } =
            new List<CategoryStatDto>();
        public List<UserSummaryDto> RecentUsers { get; set; } = new List<UserSummaryDto>();
        public List<PasswordResetSummaryDto> RecentPendingResets { get; set; } =
            new List<PasswordResetSummaryDto>();
        public List<UserPortfolioReportDto> UserPortfolioReports { get; set; } =
            new List<UserPortfolioReportDto>();
    }

    public class UserPortfolioReportDto
    {
        public int UserId { get; set; }
        public string FirstName { get; set; } = "";
        public string LastName { get; set; } = "";
        public string FullName { get; set; } = "";
        public string Email { get; set; } = "";
        public bool IsActive { get; set; } = true;
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
        public int LoginCount { get; set; }
        public bool HasProfile { get; set; }
        public string RoleTitle { get; set; } = "Not Set";
        public DateTime? LastProfileUpdate { get; set; }
        public int ProjectsCount { get; set; }
        public int SkillsCount { get; set; }
        public int TechCount { get; set; }
        public int ExperiencesCount { get; set; }
        public string PortfolioStatus { get; set; } = "Not Started";
    }

    public class CategoryStatDto
    {
        public string Category { get; set; } = "";
        public int ItemCount { get; set; }
        public int HighlightCount { get; set; }
        public double Percentage { get; set; }
    }

    public class UserSummaryDto
    {
        public int UserId { get; set; }
        public string FirstName { get; set; } = "";
        public string LastName { get; set; } = "";
        public string Email { get; set; } = "";
        public string FullName { get; set; } = "";
        public string Role { get; set; } = "User";
        public bool IsActive { get; set; } = true;
        public DateTime? LastLoginAt { get; set; }
        public int LoginCount { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool HasProfile { get; set; }
        public DateTime? BirthDate { get; set; }
        public string RoleTitle { get; set; } = "";
    }

    public class PasswordResetSummaryDto
    {
        public int ResetId { get; set; }
        public int UserId { get; set; }
        public string Email { get; set; } = "";
        public string FullName { get; set; } = "";
        public string Status { get; set; } = "Pending";
        public DateTime RequestedAt { get; set; }
    }
}
