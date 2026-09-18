using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class NavSection : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            var user = AuthHelper.GetCurrentUser();
            if (user != null && !string.IsNullOrEmpty(user.ProfileImage))
            {
                imgNavAvatar.ImageUrl = ResolveUrl("~/" + user.ProfileImage.TrimStart('~', '/'));
                imgNavAvatar.Visible = true;
                phNavSvg.Visible = false;
            }
            else
            {
                imgNavAvatar.Visible = false;
                phNavSvg.Visible = true;
            }
        }
    }
}
