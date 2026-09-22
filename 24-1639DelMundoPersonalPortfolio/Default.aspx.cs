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
                Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl), true);
                return;
            }

            int currentUserId = AuthHelper.GetCurrentUserId();
            int effectiveUserId;

            if (AuthHelper.IsAdmin())
            {
                // System Administrators do not have a personal live portfolio
                // They can only view other registered users' websites via ?userId=X
                if (int.TryParse(Request.QueryString["userId"], out int qUserId) && qUserId > 0 && qUserId != currentUserId)
                {
                    effectiveUserId = qUserId;
                    pnlAdminViewingBanner.Visible = true;
                }
                else
                {
                    // No target user specified or tried to view self -> redirect back to Admin Console
                    Response.Redirect("~/Pages/Admin/Admin.aspx", true);
                    return;
                }
            }
            else
            {
                // Normal users can ONLY view their own personal portfolio preview
                // Other userId query parameters are strictly forbidden/ignored
                effectiveUserId = currentUserId;
                pnlAdminViewingBanner.Visible = false;
            }

            var data = PortfolioService.GetPortfolioData(effectiveUserId, false);

            if (AuthHelper.IsAdmin() && pnlAdminViewingBanner.Visible)
            {
                string name = data?.Profile?.FullName;
                if (string.IsNullOrWhiteSpace(name)) name = $"User #{effectiveUserId}";
                litViewingUserName.Text = Server.HtmlEncode(name);
            }

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
            int currentUserId = AuthHelper.GetCurrentUserId();
            return PortfolioService.GetPortfolioData(currentUserId, forceRefresh);
        }
    }
}