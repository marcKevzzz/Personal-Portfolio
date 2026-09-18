using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class UsersPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsers();
            }
        }

        public void BindUsers()
        {
            var list = PortfolioService.GetAllUsers();
            rptUsersTable.DataSource = list;
            rptUsersTable.DataBind();
        }

        protected void rptUsersTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ToggleStatus")
            {
                string[] parts = e.CommandArgument.ToString().Split('|');
                int userId = Convert.ToInt32(parts[0]);
                bool currentStatus = Convert.ToBoolean(parts[1]);
                bool newStatus = !currentStatus;

                bool ok = PortfolioService.SetUserActiveStatus(userId, newStatus);
                BindUsers();

                string statusText = newStatus ? "activated" : "deactivated";
                string script = ok 
                    ? $"if(window.AdminToast) AdminToast.success('User has been {statusText}.', 'User Status');"
                    : "if(window.AdminToast) AdminToast.error('Failed to change user status.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userStatusToast", script, true);
            }
            else if (e.CommandName == "DeleteUser")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                bool ok = PortfolioService.DeleteUser(userId);
                BindUsers();

                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('User deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete user.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userDelToast", script, true);
            }
        }
    }
}
