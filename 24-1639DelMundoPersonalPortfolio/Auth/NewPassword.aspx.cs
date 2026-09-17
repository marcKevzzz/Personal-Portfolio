using System;
using System.Data.SqlClient;
using System.Web.Services;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class NewPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string emailParam = Request.QueryString["email"];
                if (!string.IsNullOrEmpty(emailParam))
                {
                    resetEmail.Text = emailParam;
                }
            }
        }

        protected void btnSetNewPassword_Click(object sender, EventArgs e)
        {
            string emailVal = (resetEmail.Text ?? "").Trim().ToLowerInvariant();
            string newPass = (password.Text ?? "").Trim();
            string confirmVal = (confirm.Text ?? "").Trim();

            if (string.IsNullOrEmpty(emailVal))
            {
                ShowAlert("Email address is missing.", isError: true);
                return;
            }

            if (string.IsNullOrEmpty(newPass) || newPass.Length < 8)
            {
                ShowAlert("Password must be at least 8 characters long.", isError: true);
                return;
            }

            if (!string.Equals(newPass, confirmVal))
            {
                ShowAlert("Passwords do not match.", isError: true);
                return;
            }

            try
            {
                // 1. Verify user exists in database
                string userCheckQuery = "SELECT COUNT(1) FROM users_tbl WHERE LOWER(email) = LOWER(@Email);";
                int userExists = Convert.ToInt32(DatabaseHelper.ExecuteScalar(userCheckQuery, new SqlParameter("@Email", emailVal)));

                if (userExists == 0)
                {
                    ShowAlert("No account found with this email address.", isError: true);
                    return;
                }

                // 2. Hash new password
                string passwordHash = AuthHelper.HashPassword(newPass);

                // 3. Update password in users_tbl
                string updatePassQuery = @"UPDATE users_tbl 
                                          SET password_hash = @PasswordHash 
                                          WHERE LOWER(email) = LOWER(@Email);";

                DatabaseHelper.ExecuteNonQuery(updatePassQuery,
                    new SqlParameter("@PasswordHash", passwordHash),
                    new SqlParameter("@Email", emailVal));

                // 4. Update status in password_resets_tbl to 'used'
                string updateReqQuery = @"UPDATE password_resets_tbl 
                                         SET status = 'used' 
                                         WHERE LOWER(email) = LOWER(@Email) AND status = 'password_removed';";

                DatabaseHelper.ExecuteNonQuery(updateReqQuery, new SqlParameter("@Email", emailVal));

                Response.Redirect("~/Auth/SignIn.aspx?reset=success&email=" + Server.UrlEncode(emailVal));
            }
            catch (Exception ex)
            {
                ShowAlert("Error updating password: " + ex.Message, isError: true);
            }
        }

        private void ShowAlert(string message, bool isError)
        {
            pnlAlert.Visible = true;
            if (isError)
            {
                pnlAlert.CssClass = "save-toast alert-danger";
                litAlertIcon.Text = @"<svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""#ff4d4f"" stroke-width=""2.5"">
                                        <circle cx=""12"" cy=""12"" r=""10""></circle>
                                        <line x1=""12"" y1=""8"" x2=""12"" y2=""12""></line>
                                        <line x1=""12"" y1=""16"" x2=""12.01"" y2=""16""></line>
                                      </svg>";
            }
            else
            {
                pnlAlert.CssClass = "save-toast alert-success";
                litAlertIcon.Text = @"<svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""#00d26a"" stroke-width=""2.5"">
                                        <polyline points=""20 6 9 17 4 12""></polyline>
                                      </svg>";
            }
            litAlertMsg.Text = $"<span>{Server.HtmlEncode(message)}</span>";
        }
    }
}
