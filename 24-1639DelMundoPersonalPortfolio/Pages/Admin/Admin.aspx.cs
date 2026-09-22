using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class Admin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx");
                return;
            }

            bool isAdmin = AuthHelper.IsAdmin();

            if (ucDashboardPanel != null) ucDashboardPanel.Visible = isAdmin;
            if (ucUsersPanel != null) ucUsersPanel.Visible = isAdmin;
            if (ucAdminProfilePanel != null) ucAdminProfilePanel.Visible = isAdmin;

            if (ucProfilePanel != null) ucProfilePanel.Visible = !isAdmin;
            if (ucTechStackPanel != null) ucTechStackPanel.Visible = !isAdmin;
            if (ucSkillsPanel != null) ucSkillsPanel.Visible = !isAdmin;
            if (ucExperiencePanel != null) ucExperiencePanel.Visible = !isAdmin;
            if (ucProjectsPanel != null) ucProjectsPanel.Visible = !isAdmin;
            if (ucEducationPanel != null) ucEducationPanel.Visible = !isAdmin;
            if (ucAwardsPanel != null) ucAwardsPanel.Visible = !isAdmin;
            if (ucHobbiesPanel != null) ucHobbiesPanel.Visible = !isAdmin;

            if (!IsPostBack)
            {
                if (isAdmin)
                {
                    ucUsersPanel?.BindAll();
                    ucAdminProfilePanel?.LoadAdminDetails();
                }
                else
                {
                    ucProfilePanel?.LoadProfileData();
                    ucTechStackPanel?.BindTechStack();
                    ucSkillsPanel?.BindSkills();
                    ucExperiencePanel?.BindExperiences();
                    ucProjectsPanel?.BindProjects();
                    ucEducationPanel?.BindEducations();
                    ucAwardsPanel?.BindAwards();
                    ucHobbiesPanel?.BindHobbies();
                }
            }
        }
    }
}
