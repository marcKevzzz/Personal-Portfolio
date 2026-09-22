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
                BindAll();
            }
        }

        public void BindAll()
        {
            BindUsers();
            BindResetRequests();
        }

        public void BindUsers()
        {
            var list = PortfolioService.GetAllUsers();
            rptUsersTable.DataSource = list;
            rptUsersTable.DataBind();
        }

        public void BindResetRequests()
        {
            var requests = PortfolioService.GetPasswordResetRequests();
            if (requests == null || requests.Count == 0)
            {
                pnlNoRequests.Visible = true;
                rptResetRequests.Visible = false;
                lblPendingRequestsCount.Visible = false;
            }
            else
            {
                pnlNoRequests.Visible = false;
                rptResetRequests.Visible = true;
                rptResetRequests.DataSource = requests;
                rptResetRequests.DataBind();

                int pendingCount = requests.Count(r => (r.Status ?? "").Trim().ToLowerInvariant() == "pending");
                if (pendingCount > 0)
                {
                    lblPendingRequestsCount.Text = $"{pendingCount} PENDING";
                    lblPendingRequestsCount.Visible = true;
                }
                else
                {
                    lblPendingRequestsCount.Visible = false;
                }
            }
        }


        protected void btnRefreshResetRequests_Click(object sender, EventArgs e)
        {
            BindResetRequests();
            string script = "if(window.AdminToast) AdminToast.info('Password reset requests refreshed from database.', 'Refreshed');";
            Page.ClientScript.RegisterStartupScript(GetType(), "refreshReqToast", script, true);
        }

        protected string GetStatusBadgeClass(string status)
        {
            switch (status?.Trim().ToLowerInvariant())
            {
                case "pending":
                    return "status-pill active";
                case "password_removed":
                    return "status-pill active";
                case "used":
                    return "status-pill";
                default:
                    return "status-pill inactive";
            }
        }

        protected void rptResetRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int resetId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "ApproveReset")
            {
                bool ok = PortfolioService.ApprovePasswordResetRequest(resetId);
                BindAll();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Password removed for user. They can now set a new password upon next sign-in.', 'Request Approved');"
                    : "if(window.AdminToast) AdminToast.error('Failed to approve password reset request.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "resetApproveToast", script, true);
            }
            else if (e.CommandName == "RejectReset")
            {
                bool ok = PortfolioService.RejectPasswordResetRequest(resetId);
                BindAll();
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
                BindAll();

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
