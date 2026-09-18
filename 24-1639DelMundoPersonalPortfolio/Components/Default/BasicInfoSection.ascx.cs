using System;
using System.Web.UI;
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

            string fullName = string.IsNullOrWhiteSpace(ProfileData.FullName) ? "Del Mundo, Marc Kevin F." : ProfileData.FullName;
            string location = string.IsNullOrWhiteSpace(ProfileData.LocationAddress) ? "B2 L6 Emerald St. Novaliches Proper, Q.C." : ProfileData.LocationAddress;
            int age = ProfileData.Age > 0 ? ProfileData.Age : 19;
            int exp = ProfileData.ExperienceYears > 0 ? ProfileData.ExperienceYears : 3;

            litName.Text = Server.HtmlEncode(fullName);
            litLocation.Text = Server.HtmlEncode(location);
            litAge.Text = $"{age} years old";
            litExperience.Text = $"{exp} years of coding";
        }
    }
}
