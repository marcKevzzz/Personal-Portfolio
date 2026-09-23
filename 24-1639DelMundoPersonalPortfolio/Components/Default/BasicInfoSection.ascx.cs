using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class BasicInfoSection : UserControl
    {
        public ProfileDto ProfileData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(ProfileDto profile)
        {
            ProfileData = profile ?? new ProfileDto();

            string fullName = string.IsNullOrWhiteSpace(ProfileData.FullName)
                ? (AuthHelper.GetCurrentUser() != null ? $"{AuthHelper.GetCurrentUser().FirstName} {AuthHelper.GetCurrentUser().LastName}" : "Portfolio Owner")
                : ProfileData.FullName;
            string location = string.IsNullOrWhiteSpace(ProfileData.LocationAddress) ? "No location added yet" : ProfileData.LocationAddress;
            string ageText = ProfileData.Age > 0 ? $"{ProfileData.Age} years old" : "No birthday added yet";
            string expText = ProfileData.ExperienceYears > 0 ? $"{ProfileData.ExperienceYears} years of coding" : "No years of experience added yet";

            litName.Text = Server.HtmlEncode(fullName);
            litLocation.Text = Server.HtmlEncode(location);
            litAge.Text = Server.HtmlEncode(ageText);
            litExperience.Text = Server.HtmlEncode(expText);
        }
    }
}
