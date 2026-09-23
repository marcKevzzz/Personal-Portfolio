using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class AdminMaster : System.Web.UI.MasterPage
    {
        public bool IsReadOnly { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            IsReadOnly = !AuthHelper.IsAdmin();

            if (!IsPostBack)
            {
                if (Request.QueryString["login"] == "true")
                {
                    var currentUser = AuthHelper.GetCurrentUser();
                    string userName = currentUser != null ? $"{currentUser.FirstName} {currentUser.LastName}".Trim() : "User";
                    string title = IsReadOnly ? "VIEWER ACCESS" : "ADMIN ACCESS";
                    string msg = IsReadOnly 
                        ? $"Welcome to Admin Console (Read-Only Viewer), {userName}" 
                        : $"Welcome back to Admin Portal, {userName}";
                    string script = $"document.addEventListener('DOMContentLoaded', function() {{ if (typeof AdminToast !== 'undefined') {{ AdminToast.show('{msg}', 'success'); }} else if (typeof Toast !== 'undefined') {{ Toast.show({{ title: '{title}', message: '{msg}', type: 'info' }}); }} }});";
                    Page.ClientScript.RegisterStartupScript(this.GetType(), "adminLoginToast", script, true);
                }
            }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            DuplicateSubmissionGuard.RegisterToken(this.Page);
        }
    }
}
