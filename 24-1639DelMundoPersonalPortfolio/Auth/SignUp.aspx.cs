using System;
using System.Data.SqlClient;
using System.Web.Services;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Helpers;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class SignUp : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect to appropriate page
            if (!IsPostBack && AuthHelper.IsAuthenticated())
            {
                if (AuthHelper.IsAdmin())
                {
                    Response.Redirect("~/Pages/Admin/Admin.aspx");
                }
                else
                {
                    Response.Redirect("~/Pages/User/PortfolioBuilder.aspx");
                }
            }
        }

        protected void btnAcceptTerms_Click(object sender, EventArgs e)
        {
            string fName = (firstName.Text ?? "").Trim();
            string lName = (lastName.Text ?? "").Trim();
            string emailVal = (email.Text ?? "").Trim().ToLowerInvariant();
            string passVal = (password.Text ?? "").Trim();
            string confirmVal = (confirm.Text ?? "").Trim();

            if (string.IsNullOrEmpty(fName))
            {
                ShowAlert("First name is required.", isError: true);
                return;
            }

            if (string.IsNullOrEmpty(lName))
            {
                ShowAlert("Last name is required.", isError: true);
                return;
            }

            if (
                string.IsNullOrEmpty(emailVal)
                || !emailVal.Contains("@")
                || !emailVal.Contains(".")
            )
            {
                ShowAlert("Please provide a valid email address.", isError: true);
                return;
            }

            if (string.IsNullOrEmpty(passVal) || passVal.Length < 8)
            {
                ShowAlert("Password must be at least 8 characters long.", isError: true);
                return;
            }

            if (!string.Equals(passVal, confirmVal))
            {
                ShowAlert("Passwords do not match.", isError: true);
                return;
            }

            try
            {
                // 1. Check if email is already registered using stored procedure
                object emailCountObj = DatabaseHelper.ExecuteStoredProcedureScalar(
                    "sp_CheckUserEmailExists",
                    new SqlParameter("@email", emailVal)
                );
                int count = (emailCountObj != null && emailCountObj != DBNull.Value) ? Convert.ToInt32(emailCountObj) : 0;

                if (count > 0)
                {
                    ShowAlert(
                        "An account with this email address already exists. Please sign in instead.",
                        isError: true
                    );
                    return;
                }

                // 2. Hash password securely
                string passwordHash = AuthHelper.HashPassword(passVal);

                // 3. Assign role: Admin for owner email, User for regular accounts
                string role = "User";
                if (
                    string.Equals(
                        emailVal,
                        "delmundo.marckevin.ferolino@gmail.com",
                        StringComparison.OrdinalIgnoreCase
                    )
                )
                {
                    role = "Admin";
                }

                // 4. Register user and initialize blank profile atomically via sp_RegisterUser
                var parameters = new SqlParameter[]
                {
                    new SqlParameter("@first_name", fName),
                    new SqlParameter("@last_name", lName),
                    new SqlParameter("@email", emailVal),
                    new SqlParameter("@password_hash", passwordHash),
                    new SqlParameter("@user_role", role),
                    new SqlParameter("@is_active", true),
                };

                object newIdObj = DatabaseHelper.ExecuteStoredProcedureScalar("sp_RegisterUser", parameters);
                int newUserId = (newIdObj != null && newIdObj != DBNull.Value) ? Convert.ToInt32(newIdObj) : 0;

                if (newUserId > 0)
                {
                    Response.Redirect(
                        "~/Auth/SignIn.aspx?registered=true&email=" + Server.UrlEncode(emailVal)
                    );
                }
                else
                {
                    ShowAlert("Unable to create account. Please try again.", isError: true);
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Database error: " + ex.Message, isError: true);
            }
        }

        private void ShowAlert(string message, bool isError)
        {
            pnlAlert.Visible = true;
            if (isError)
            {
                pnlAlert.CssClass = "save-toast alert-danger";
                litAlertIcon.Text =
                    @"<svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""#ff4d4f"" stroke-width=""2.5"">
                                        <circle cx=""12"" cy=""12"" r=""10""></circle>
                                        <line x1=""12"" y1=""8"" x2=""12"" y2=""12""></line>
                                        <line x1=""12"" y1=""16"" x2=""12.01"" y2=""16""></line>
                                      </svg>";
            }
            else
            {
                pnlAlert.CssClass = "save-toast alert-success";
                litAlertIcon.Text =
                    @"<svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""#00d26a"" stroke-width=""2.5"">
                                        <polyline points=""20 6 9 17 4 12""></polyline>
                                      </svg>";
            }
            litAlertMsg.Text = $"<span>{Server.HtmlEncode(message)}</span>";
        }
    }
}
