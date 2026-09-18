using System;
using System.Collections.Generic;

namespace _24_1639DelMundoPersonalPortfolio.Models
{
    public class PortfolioDataDto
    {
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
        public string FirstName { get; set; } = "Marc Kevin";
        public string LastName { get; set; } = "Del Mundo";
        public string FullName => $"{FirstName} {LastName}".Trim();
        public string HeroSubline { get; set; } = "builds interfaces";
        public string HeroNames { get; set; } = "Kevs,Marc Kevin,Del Mundo";
        public string RoleSummary { get; set; }
        public string RoleTitle { get; set; } = "Web Developer";
        public string FocusArea { get; set; } = "Interfaces & Data Systems";
        public string BasedIn { get; set; } = "Quezon City";
        public string AvatarPath { get; set; } = "Assets/Images/pixelart_portrait.png";
        public string LocationAddress { get; set; } = "B2 L6 Emerald St. Novaliches Proper, Q.C.";
        public int Age { get; set; } = 19;
        public int ExperienceYears { get; set; } = 3;
        public string Email { get; set; } = "delmundo.marckevin.ferolino@gmail.com";
        public string GithubUrl { get; set; } = "https://github.com/marcKevzzz";
        public string LinkedinUrl { get; set; } = "https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436";
    }

    public class TechStackItemDto
    {
        public int TechId { get; set; }
        public string GroupName { get; set; } = "";
        public string Label { get; set; } = "";
        public string IconPath { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class SkillDto
    {
        public int SkillId { get; set; }
        public string SkillName { get; set; } = "";
        public int ProficiencyVal { get; set; }
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class ExperienceDto
    {
        public int ExpId { get; set; }
        public string RoleTitle { get; set; } = "";
        public string CompanyName { get; set; } = "";
        public string PeriodRange { get; set; } = "";
        public string DescriptionText { get; set; } = "";
        public string Tags { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class ProjectDto
    {
        public int ProjectId { get; set; }
        public string Title { get; set; } = "";
        public string ImagePath { get; set; } = "";
        public string ProjectUrl { get; set; } = "";
        public string Tags { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class EducationDto
    {
        public int EduId { get; set; }
        public string YearPeriod { get; set; } = "";
        public string Title { get; set; } = "";
        public string Subtitle { get; set; } = "";
        public string InstitutionName { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class AwardDto
    {
        public int AwardId { get; set; }
        public string AwardYear { get; set; } = "";
        public string Title { get; set; } = "";
        public string Subtitle { get; set; } = "";
        public string OrganizationName { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }

    public class HobbyDto
    {
        public int HobbyId { get; set; }
        public string HobbyName { get; set; } = "";
        public int SortOrder { get; set; }
        public bool IsActive { get; set; } = true;
    }
}
