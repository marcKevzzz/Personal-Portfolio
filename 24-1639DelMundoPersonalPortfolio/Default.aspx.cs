using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack && Request.QueryString["login"] == "true")
            {
                var user = AuthHelper.GetCurrentUser();
                string userName = user != null ? $"{user.FirstName} {user.LastName}" : "Welcome";
                string script = $@"window.__showWelcomeToast = function() {{ 
                                      if (typeof Toast !== 'undefined') {{ 
                                          Toast.show({{ title: 'WELCOME BACK', message: 'Signed in as {userName.Replace("'", "\\'")}', type: 'success' }}); 
                                      }} 
                                  }};";
                ClientScript.RegisterStartupScript(this.GetType(), "loginWelcomeToast", script, true);
            }
        }
    }
}