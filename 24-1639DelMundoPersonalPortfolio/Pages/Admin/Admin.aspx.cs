using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class Admin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx");
                return;
            }

            if (!AuthHelper.IsAdmin())
            {
                Response.Redirect("~/Pages/User/PortfolioBuilder.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ucUsersPanel?.BindAll();
                ucAdminProfilePanel?.LoadAdminDetails();
            }
        }
    }
}
