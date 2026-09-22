using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio.Pages.User
{
    public partial class PortfolioBuilder : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx", true);
                return;
            }

            // System Administrators have their own console and do not have a personal portfolio builder
            if (AuthHelper.IsAdmin())
            {
                Response.Redirect("~/Pages/Admin/Admin.aspx", true);
                return;
            }
        }
    }
}
