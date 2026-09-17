using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!AuthHelper.IsAuthenticated() || !AuthHelper.IsAdmin())
                {
                    Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                    return;
                }

                if (Request.QueryString["login"] == "true")
                {
                    var adminUser = AuthHelper.GetCurrentUser();
                    string adminName = adminUser != null ? $"{adminUser.FirstName} {adminUser.LastName}" : "Administrator";
                    string script = $"document.addEventListener('DOMContentLoaded', function() {{ if (typeof AdminToast !== 'undefined') {{ AdminToast.show('Welcome to Admin Portal, {adminName}', 'success'); }} else if (typeof Toast !== 'undefined') {{ Toast.show({{ title: 'ADMIN ACCESS', message: 'Welcome back, {adminName}', type: 'success' }}); }} }});";
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "adminLoginToast", script, true);
                }
            }
        }
    }
}
