using System;
using System.Linq;
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

        public void BindAll()
        {
            BindUsers();
        }

        public int CurrentUserId => _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUserId();

        public void BindUsers()
        {
            var list = PortfolioService.GetAllUsers(excludeAdmins: false)
                .ToList();
            rptUsersTable.DataSource = list;
            rptUsersTable.DataBind();

            int pendingCount = list.Count(u => u.HasPendingReset);
            if (pendingCount > 0)
            {
                lblPendingResetBadge.Text = $"{pendingCount} RESET REQUEST" + (pendingCount > 1 ? "S" : "");
                lblPendingResetBadge.Visible = true;
            }
            else
            {
                lblPendingResetBadge.Visible = false;
            }
        }

        protected void btnModalApproveReset_Click(object sender, EventArgs e)
        {
            if (int.TryParse(hfSelectedResetId.Value, out int resetId) && resetId > 0)
            {
                bool ok = PortfolioService.ApprovePasswordResetRequest(resetId);
                BindUsers();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Password removed for user. They can now set a new password upon next sign-in.', 'Request Approved');"
                    : "if(window.AdminToast) AdminToast.error('Failed to approve password reset request.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "resetApproveToast", script, true);
            }
        }

        protected void btnModalRejectReset_Click(object sender, EventArgs e)
        {
            if (int.TryParse(hfSelectedResetId.Value, out int resetId) && resetId > 0)
            {
                bool ok = PortfolioService.RejectPasswordResetRequest(resetId);
                BindUsers();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Password reset request has been dismissed.', 'Request Dismissed');"
                    : "if(window.AdminToast) AdminToast.error('Failed to dismiss request.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "resetRejectToast", script, true);
            }
        }

        protected void rptUsersTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "ResetUserPassword")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                bool ok = PortfolioService.AdminResetUserPassword(userId);
                BindUsers();

                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('User password has been cleared. The user will be redirected to create a new password on their next sign-in.', 'Password Reset Initiated');"
                    : "if(window.AdminToast) AdminToast.error('Failed to reset user password.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userResetToast", script, true);
            }
            else if (e.CommandName == "ToggleStatus")
            {
                string[] parts = e.CommandArgument.ToString().Split('|');
                int userId = Convert.ToInt32(parts[0]);
                bool currentStatus = Convert.ToBoolean(parts[1]);
                bool newStatus = !currentStatus;

                int currentAdminId = CurrentUserId;
                if (userId == currentAdminId && !newStatus)
                {
                    string scriptWarn = "if(window.AdminToast) AdminToast.error('You cannot deactivate your own active admin account.', 'Action Prohibited');";
                    Page.ClientScript.RegisterStartupScript(GetType(), "selfDeactivateErr", scriptWarn, true);
                    return;
                }

                bool ok = PortfolioService.SetUserActiveStatus(userId, newStatus);
                BindUsers();

                string statusText = newStatus ? "activated" : "deactivated";
                string script = ok 
                    ? $"if(window.AdminToast) AdminToast.success('User has been {statusText}.', 'User Status');"
                    : "if(window.AdminToast) AdminToast.error('Failed to change user status.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userStatusToast", script, true);
            }
        }
    }
}
