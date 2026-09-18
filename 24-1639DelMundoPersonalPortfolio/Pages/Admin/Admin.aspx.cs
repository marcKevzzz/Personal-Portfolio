using System;
using System.Web.UI;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class Admin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ucProfilePanel?.LoadProfileData();
                ucTechStackPanel?.BindTechStack();
                ucSkillsPanel?.BindSkills();
                ucExperiencePanel?.BindExperiences();
                ucProjectsPanel?.BindProjects();
                ucEducationPanel?.BindEducations();
                ucAwardsPanel?.BindAwards();
                ucHobbiesPanel?.BindHobbies();
                ucUsersPanel?.BindAll();
                ucAdminProfilePanel?.LoadAdminDetails();
            }
        }
    }
}
