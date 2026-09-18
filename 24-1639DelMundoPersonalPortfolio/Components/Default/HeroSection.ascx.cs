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

            string heroNames = string.IsNullOrWhiteSpace(ProfileData.HeroNames) ? "Kevs,Marc Kevin,Del Mundo" : ProfileData.HeroNames;
            heroDynamicName.Attributes["data-names"] = heroNames;

            litHeroDynamicName.Text = GetHeroNameSpans();
            litHeroSubline.Text = GetHeroSublineSpans();
            litHeroRoleSummary.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.RoleSummary) ? "Web developer working across front-end interfaces and the structured data systems behind them — from motion-driven product pages to large-scale JSON datasets." : ProfileData.RoleSummary);
            litRoleTitle.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.RoleTitle) ? "Web Developer" : ProfileData.RoleTitle);
            litFocusArea.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.FocusArea) ? "Interfaces & Data Systems" : ProfileData.FocusArea);
            litBasedIn.Text = Server.HtmlEncode(string.IsNullOrWhiteSpace(ProfileData.BasedIn) ? "Quezon City" : ProfileData.BasedIn);

            string avatarUrl = string.IsNullOrWhiteSpace(ProfileData.AvatarPath) ? "Assets/Images/pixelart_portrait.png" : ProfileData.AvatarPath;
            imgAvatar.ImageUrl = ResolveUrl("~/" + avatarUrl.TrimStart('~', '/'));
            imgAvatar.AlternateText = string.IsNullOrWhiteSpace(ProfileData.FullName) ? "Marc Kevin Del Mundo" : ProfileData.FullName;
        }

        private string GetHeroNameSpans()
        {
            string name = string.IsNullOrWhiteSpace(ProfileData?.FirstName) ? "Marc Kevin" : ProfileData.FirstName;
            var sb = new StringBuilder();
            foreach (char c in name)
            {
                sb.AppendFormat("<span class=\"glyph-char\">{0}</span>", c == ' ' ? "&nbsp;" : Server.HtmlEncode(c.ToString()));
            }
            return sb.ToString();
        }

        private string GetHeroSublineSpans()
        {
            string subline = string.IsNullOrWhiteSpace(ProfileData?.HeroSubline) ? "buildsinterfaces" : ProfileData.HeroSubline;
            subline = subline.TrimStart('/', ' ');
            var sb = new StringBuilder();
            sb.Append("<span class=\"accent glyph\">/</span><span class=\"glyph\">&nbsp;</span>");
            foreach (char c in subline)
            {
                sb.AppendFormat("<span class=\"glyph\">{0}</span>", c == ' ' ? "&nbsp;" : Server.HtmlEncode(c.ToString()));
            }
            return sb.ToString();
        }
    }
}
