using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class ContactSection : UserControl
    {
        public ProfileDto ProfileData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(ProfileDto profile)
        {
            ProfileData = profile ?? new ProfileDto();

            var user = _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUser();
            string email = string.IsNullOrWhiteSpace(ProfileData.Email) ? (user?.Email ?? "") : ProfileData.Email;
            string github = string.IsNullOrWhiteSpace(ProfileData.GithubUrl) ? "" : ProfileData.GithubUrl.Trim();
            string linkedin = string.IsNullOrWhiteSpace(ProfileData.LinkedinUrl) ? "" : ProfileData.LinkedinUrl.Trim();

            // Email link
            if (!string.IsNullOrWhiteSpace(email))
            {
                contactEmailLink.NavigateUrl = $"mailto:{email}";
                contactEmailLink.Visible = true;
                litEmailEmpty.Visible = false;
            }
            else
            {
                contactEmailLink.Visible = false;
                litEmailEmpty.Visible = true;
            }

            // GitHub link
            if (!string.IsNullOrWhiteSpace(github))
            {
                contactGithubLink.NavigateUrl = github;
                contactGithubLink.Visible = true;
                litGithubEmpty.Visible = false;
            }
            else
            {
                contactGithubLink.Visible = false;
                litGithubEmpty.Visible = true;
            }

            // LinkedIn link
            if (!string.IsNullOrWhiteSpace(linkedin))
            {
                contactLinkedinLink.NavigateUrl = linkedin;
                contactLinkedinLink.Visible = true;
                litLinkedinEmpty.Visible = false;
            }
            else
            {
                contactLinkedinLink.Visible = false;
                litLinkedinEmpty.Visible = true;
            }
        }
    }
}
