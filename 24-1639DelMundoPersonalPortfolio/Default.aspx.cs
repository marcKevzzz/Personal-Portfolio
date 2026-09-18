using System;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            // Fetch cached portfolio data from C# service (with automatic fallback if DB unreachable)
            var data = PortfolioService.GetPortfolioData();
            if (data != null)
            {
                HeroSectionControl.BindData(data.Profile);
                BasicInfoSectionControl.BindData(data.Profile);
                TechStackSectionControl.BindData(data.TechStacks);
                SkillsSectionControl.BindData(data.Skills);
                ExperienceSectionControl.BindData(data.Experiences);
                ProjectsSectionControl.BindData(data.Projects);
                EducationSectionControl.BindData(data.Educations);
                AwardsSectionControl.BindData(data.Awards);
                HobbiesSectionControl.BindData(data.Hobbies);
                ContactSectionControl.BindData(data.Profile);
            }

            if (!IsPostBack && Request.QueryString["login"] == "true")
            {
                var user = AuthHelper.GetCurrentUser();
                string userName = user != null ? $"{user.FirstName} {user.LastName}" : "Welcome";
                string script = $@"window.__showWelcomeToast = function() {{ 
                                      if (typeof Toast !== 'undefined') {{ 
                                          Toast.show({{ title: 'WELCOME BACK', message: 'Signed in as {userName.Replace("'", "\\'")}', type: 'success' }}); 
                                      }} 
                                  }};";
                ClientScript.RegisterStartupScript(this.GetType(), "loginWelcomeToast", script, true);
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static PortfolioDataDto GetPortfolioData(bool forceRefresh = false)
        {
            return PortfolioService.GetPortfolioData(forceRefresh);
        }
    }
}