using System;
using System.Text;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class HeroSection : UserControl
    {
        public ProfileDto ProfileData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(ProfileDto profile)
        {
            ProfileData = profile ?? new ProfileDto();

            string userFallback = _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUserName();
            string heroNames = string.IsNullOrWhiteSpace(ProfileData.HeroNames) ? (string.IsNullOrWhiteSpace(userFallback) ? "Portfolio,Developer" : userFallback) : ProfileData.HeroNames;
            heroDynamicName.Attributes["data-names"] = heroNames;

            litHeroDynamicName.Text = GetHeroNameSpans();
            litHeroSubline.Text = GetHeroSublineSpans();
            litHeroRoleSummary.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.RoleSummary) ? "Web developer creating clean interfaces and responsive web experiences." : ProfileData.RoleSummary);
            litRoleTitle.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.RoleTitle) ? "Web Developer" : ProfileData.RoleTitle);
            litFocusArea.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.FocusArea) ? "Interfaces & Web Systems" : ProfileData.FocusArea);
            litBasedIn.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.BasedIn) ? "Quezon City" : ProfileData.BasedIn);

            string avatarUrl = string.IsNullOrWhiteSpace(ProfileData.AvatarPath) ? "Assets/Images/pixelart_portrait.png" : ProfileData.AvatarPath;
            imgAvatar.ImageUrl = ResolveUrl("~/" + avatarUrl.TrimStart('~', '/'));
            imgAvatar.AlternateText = string.IsNullOrWhiteSpace(ProfileData.FullName) ? "Portfolio Avatar" : ProfileData.FullName;
        }

        private string GetHeroNameSpans()
        {
            string name = string.IsNullOrWhiteSpace(ProfileData?.FirstName) ? (_24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUser()?.FirstName ?? "Portfolio") : ProfileData.FirstName;
            var sb = new StringBuilder();
            foreach (char c in name)
            {
                if (c == ' ')
                {
                    sb.Append("<span class=\"glyph-char glyph-space\">&nbsp;</span>");
                }
                else
                {
                    sb.AppendFormat("<span class=\"glyph-char\">{0}</span>", Server.HtmlEncode(c.ToString()));
                }
            }
            return sb.ToString();
        }

        private string GetHeroSublineSpans()
        {
            string subline = string.IsNullOrWhiteSpace(ProfileData?.HeroSubline) ? "builds interfaces" : ProfileData.HeroSubline;
            subline = subline.TrimStart('/', ' ');
            var sb = new StringBuilder();
            sb.Append("<span class=\"accent glyph\">/</span><span class=\"glyph glyph-space\">&nbsp;</span>");
            foreach (char c in subline)
            {
                if (c == ' ')
                {
                    sb.Append("<span class=\"glyph glyph-space\">&nbsp;</span>");
                }
                else
                {
                    sb.AppendFormat("<span class=\"glyph\">{0}</span>", Server.HtmlEncode(c.ToString()));
                }
            }
            return sb.ToString();
        }
    }
}
