using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class NavSection : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                lnkNavProfile.NavigateUrl = "~/Auth/SignIn.aspx";
                lnkNavProfile.ToolTip = "Sign In / My Website";
            }
            else if (AuthHelper.IsAdmin())
            {
                lnkNavProfile.NavigateUrl = "~/Pages/Admin/Admin.aspx";
                lnkNavProfile.ToolTip = "Admin Console";
            }
            else
            {
                lnkNavProfile.NavigateUrl = "~/Pages/User/PortfolioBuilder.aspx";
                lnkNavProfile.ToolTip = "Website Builder";
            }
        }
    }
}
