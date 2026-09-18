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

            string email = string.IsNullOrWhiteSpace(ProfileData.Email) ? "delmundo.marckevin.ferolino@gmail.com" : ProfileData.Email;
            string github = string.IsNullOrWhiteSpace(ProfileData.GithubUrl) ? "https://github.com/marcKevzzz" : ProfileData.GithubUrl;
            string linkedin = string.IsNullOrWhiteSpace(ProfileData.LinkedinUrl) ? "https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436/" : ProfileData.LinkedinUrl;

            contactEmailLink.NavigateUrl = $"mailto:{email}";
            contactGithubLink.NavigateUrl = github;
            contactLinkedinLink.NavigateUrl = linkedin;
        }
    }
}
