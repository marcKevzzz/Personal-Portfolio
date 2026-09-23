using System;
using System.Text;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class HeroSection : UserControl
    {
        public ProfileDto ProfileData { get; set; }

        protected void Page_Load(object sender, EventArgs e) { }

        public void BindData(ProfileDto profile)
        {
            ProfileData = profile ?? new ProfileDto();

            string userFallback =
                _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUserName();
            string heroNames = !string.IsNullOrWhiteSpace(ProfileData.HeroNames)
                ? ProfileData.HeroNames
                : (!string.IsNullOrWhiteSpace(userFallback) ? userFallback : "Portfolio,Creator");
            heroDynamicName.Attributes["data-names"] = heroNames;

            litHeroDynamicName.Text = GetHeroNameSpans();
            litHeroSubline.Text = GetHeroSublineSpans();

            litHeroRoleSummary.Text = !string.IsNullOrWhiteSpace(ProfileData.RoleSummary)
                ? Server.HtmlEncode(ProfileData.RoleSummary)
                : "<span class=\"empty-hint-text\" style=\"color:var(--text-dim); font-style:italic;\">No introduction added yet.</span>";

            litRoleTitle.Text = !string.IsNullOrWhiteSpace(ProfileData.RoleTitle)
                ? Server.HtmlEncode(ProfileData.RoleTitle)
                : "No role title added yet";

            litFocusArea.Text = !string.IsNullOrWhiteSpace(ProfileData.FocusArea)
                ? Server.HtmlEncode(ProfileData.FocusArea)
                : "No focus area added yet";

            litBasedIn.Text = !string.IsNullOrWhiteSpace(ProfileData.BasedIn)
                ? Server.HtmlEncode(ProfileData.BasedIn)
                : "No location added yet";

            bool isPlaceholder = string.IsNullOrWhiteSpace(ProfileData.AvatarPath);
            string avatarUrl = isPlaceholder
                ? "Assets/Images/image_placeholder.png"
                : ProfileData.AvatarPath;
            imgAvatar.ImageUrl = ResolveUrl("~/" + avatarUrl.TrimStart('~', '/'));
            imgAvatar.AlternateText = string.IsNullOrWhiteSpace(ProfileData.FullName)
                ? "Portfolio Avatar"
                : ProfileData.FullName;

            // Apply dimmed/scaled state when showing default placeholder
            if (isPlaceholder)
                imgAvatar.CssClass = "avatar-img is-placeholder";
            else
                imgAvatar.CssClass = "avatar-img";
        }

        private string GetHeroNameSpans()
        {
            string name = !string.IsNullOrWhiteSpace(ProfileData?.FirstName)
                ? ProfileData.FirstName
                : (
                    !string.IsNullOrWhiteSpace(ProfileData?.FullName)
                        ? ProfileData.FullName
                        : (
                            _24_1639DelMundoPersonalPortfolio
                                .Helpers.AuthHelper.GetCurrentUser()
                                ?.FirstName
                            ?? "Portfolio"
                        )
                );
            var sb = new StringBuilder();
            foreach (char c in name)
            {
                if (c == ' ')
                {
                    sb.Append("<span class=\"glyph-char glyph-space\">&nbsp;</span>");
                }
                else
                {
                    sb.AppendFormat(
                        "<span class=\"glyph-char\">{0}</span>",
                        Server.HtmlEncode(c.ToString())
                    );
                }
            }
            return sb.ToString();
        }

        private string GetHeroSublineSpans()
        {
            if (string.IsNullOrWhiteSpace(ProfileData?.HeroSubline))
            {
                return "<span class=\"accent glyph\">/</span><span class=\"glyph glyph-space\">&nbsp;</span><span class=\"glyph\" style=\"color:var(--text-dim); font-style:italic;\">no subline added yet</span>";
            }

            string subline = ProfileData.HeroSubline.TrimStart('/', ' ');
            var sb = new StringBuilder();
            sb.Append(
                "<span class=\"accent glyph\">/</span><span class=\"glyph glyph-space\">&nbsp;</span>"
            );
            foreach (char c in subline)
            {
                if (c == ' ')
                {
                    sb.Append("<span class=\"glyph glyph-space\">&nbsp;</span>");
                }
                else
                {
                    sb.AppendFormat(
                        "<span class=\"glyph\">{0}</span>",
                        Server.HtmlEncode(c.ToString())
                    );
                }
            }
            return sb.ToString();
        }
    }
}
