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
            bool isAuthenticated = AuthHelper.IsAuthenticated();
            int currentUserId = isAuthenticated ? AuthHelper.GetCurrentUserId() : 0;
            bool isAdmin = isAuthenticated && AuthHelper.IsAdmin();

            int targetUserId = 0;
            if (int.TryParse(Request.QueryString["userId"], out int qUserId) && qUserId > 0)
            {
                targetUserId = qUserId;
            }
            else if (int.TryParse(Request.QueryString["id"], out int qId) && qId > 0)
            {
                targetUserId = qId;
            }

            int effectiveUserId = 0;

            if (targetUserId > 0)
            {
                // Target user specified in query string - allow any user or visitor to view!
                var checkData = PortfolioService.GetPortfolioData(targetUserId, false);
                if (checkData != null && checkData.Profile != null)
                {
                    effectiveUserId = targetUserId;
                }
                else
                {
                    // Target user not found
                    if (isAuthenticated)
                    {
                        effectiveUserId = isAdmin ? 1 : currentUserId;
                    }
                    else
                    {
                        Response.Redirect("~/Auth/SignIn.aspx", true);
                        return;
                    }
                }
            }
            else
            {
                // No target user specified in URL
                if (!isAuthenticated)
                {
                    Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl), true);
                    return;
                }

                if (isAdmin)
                {
                    // Admins visiting without userId view the first registered user or redirect to Admin
                    // var allUsers = PortfolioService.GetAllUsers(excludeAdmins: true);
                    // if (allUsers != null && allUsers.Count > 0)
                    // {
                    //     effectiveUserId = allUsers[0].UserId;
                    // }
                    // else
                    // {
                        Response.Redirect("~/Pages/Admin/Admin.aspx", true);
                        return;
                    // }
                }
                else
                {
                    effectiveUserId = currentUserId;
                }
            }

            var data = PortfolioService.GetPortfolioData(effectiveUserId, false);

            // Determine if viewer is looking at someone else's portfolio
            bool isViewingOther = (effectiveUserId != currentUserId);
            pnlAdminViewingBanner.Visible = isViewingOther;

            if (isViewingOther)
            {
                string name = data?.Profile?.LastName;
                if (string.IsNullOrWhiteSpace(name))
                    name = !string.IsNullOrWhiteSpace(data?.Profile?.HeroNames) ? data.Profile.HeroNames.Split(',')[0] : $"User #{effectiveUserId}";
                litViewingUserName.Text = Server.HtmlEncode(name);

                if (isAdmin)
                {
                    lnkReturnToSelf.NavigateUrl = "~/Pages/Admin/Admin.aspx";
                    lnkReturnToSelf.Text = "← Back";
                }
                else if (isAuthenticated)
                {
                    lnkReturnToSelf.NavigateUrl = "~/Default.aspx";
                    lnkReturnToSelf.Text = "← Return";
                }
                else
                {
                    lnkReturnToSelf.NavigateUrl = "~/Auth/SignIn.aspx";
                    lnkReturnToSelf.Text = "Sign In / Create Portfolio";
                }

                // Bind community portfolio switcher list
                var usersList = PortfolioService.GetAllUsers(excludeAdmins: true);
                rptUserPortfolios.DataSource = usersList;
                rptUserPortfolios.DataBind();
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
                ContactSectionControl.BindData(data.Contacts, data.Profile);
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
        public static PortfolioDataDto GetPortfolioData(int userId = 0, bool forceRefresh = false)
        {
            if (userId <= 0)
                userId = AuthHelper.GetCurrentUserId();
            return PortfolioService.GetPortfolioData(userId, forceRefresh);
        }
    }
}