using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Services;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class SignIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["logout"] == "true")
            {
                AuthHelper.Logout();
                ShowAlert("You have been signed out successfully.", isError: false);
                return;
            }

            if (!IsPostBack)
            {
                if (Request.QueryString["registered"] == "true")
                {
                    ShowAlert("Account created successfully! Please sign in.", isError: false);
                    string regEmail = Request.QueryString["email"];
                    if (!string.IsNullOrEmpty(regEmail))
                    {
                        email.Text = regEmail;
                    }
                }
                else if (Request.QueryString["reset"] == "success")
                {
                    ShowAlert("Password updated successfully! Please sign in with your new password.", isError: false);
                    string resetEmail = Request.QueryString["email"];
                    if (!string.IsNullOrEmpty(resetEmail))
                    {
                        email.Text = resetEmail;
                    }
                }

                // If already logged in, redirect to appropriate destination
                if (AuthHelper.IsAuthenticated())
                {
                    if (AuthHelper.IsAdmin())
                    {
                        Response.Redirect("~/Pages/Admin/Admin.aspx");
                    }
                    else
                    {
                        Response.Redirect("~/Default.aspx");
                    }
                }
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            string emailVal = (email.Text ?? "").Trim().ToLowerInvariant();
            string passVal = (password.Text ?? "").Trim();

            if (string.IsNullOrEmpty(emailVal) || string.IsNullOrEmpty(passVal))
            {
                ShowAlert("Please provide both email and password.", isError: true);
                return;
            }

            try
            {
                // 1. Query user from users_tbl
                string query = @"SELECT user_id, first_name, last_name, email, password_hash, user_role, profile_image, is_active, created_at 
                                 FROM users_tbl 
                                 WHERE LOWER(email) = LOWER(@Email);";

                var dt = DatabaseHelper.ExecuteQuery(query, new SqlParameter("@Email", emailVal));

                if (dt == null || dt.Rows.Count == 0)
                {
                    ShowAlert("Invalid email or password.", isError: true);
                    return;
                }

                var row = dt.Rows[0];
                bool isActive = Convert.ToBoolean(row["is_active"]);
                if (!isActive)
                {
                    ShowAlert("This account has been deactivated. Please contact an administrator.", isError: true);
                    return;
                }

                int userId = Convert.ToInt32(row["user_id"]);
                string storedHash = row["password_hash"].ToString();
                string userRole = row["user_role"].ToString();
                string firstName = row["first_name"].ToString();
                string lastName = row["last_name"].ToString();
                string profileImage = row["profile_image"] != DBNull.Value ? row["profile_image"].ToString() : null;

                // 2. Check if password was removed by Admin for password reset
                string checkReqQuery = @"SELECT TOP 1 status 
                                         FROM password_resets_tbl 
                                         WHERE LOWER(email) = LOWER(@Email) 
                                         ORDER BY reset_id DESC;";

                object statusObj = DatabaseHelper.ExecuteScalar(checkReqQuery, new SqlParameter("@Email", emailVal));
                string latestStatus = statusObj?.ToString();

                if (string.Equals(latestStatus, "password_removed", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/Auth/NewPassword.aspx?email=" + Server.UrlEncode(emailVal));
                    return;
                }

                // 3. Verify Password Hash
                if (!AuthHelper.VerifyPassword(passVal, storedHash))
                {
                    ShowAlert("Invalid email or password.", isError: true);
                    return;
                }

                // 4. Create User instance and set session
                var user = new User
                {
                    UserId = userId,
                    FirstName = firstName,
                    LastName = lastName,
                    Email = emailVal,
                    PasswordHash = storedHash,
                    Role = userRole,
                    ProfileImage = profileImage,
                    IsActive = isActive,
                    CreatedAt = Convert.ToDateTime(row["created_at"])
                };

                bool isRemember = remember != null && remember.Checked;
                AuthHelper.SetUserSession(user, isRemember);

                // 5. Redirect based on role
                if (string.Equals(userRole, "Admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/Pages/Admin/Admin.aspx?login=true");
                }
                else
                {
                    Response.Redirect("~/Default.aspx?login=true");
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Authentication error: " + ex.Message, isError: true);
            }
        }

        protected void btnSubmitForgotReq_Click(object sender, EventArgs e)
        {
            string reqEmail = (forgotEmail.Text ?? "").Trim().ToLowerInvariant();
            string reqReason = (forgotReason.Text ?? "").Trim();

            if (string.IsNullOrEmpty(reqEmail))
            {
                ShowAlert("Please enter your registered account email.", isError: true);
                return;
            }

            try
            {
                // Verify user exists
                string userQuery = "SELECT user_id FROM users_tbl WHERE LOWER(email) = LOWER(@Email);";
                object userObj = DatabaseHelper.ExecuteScalar(userQuery, new SqlParameter("@Email", reqEmail));

                if (userObj == null)
                {
                    ShowAlert("No registered account found with that email address.", isError: true);
                    return;
                }

                int userId = Convert.ToInt32(userObj);

                // Insert into password_resets_tbl
                string insertQuery = @"INSERT INTO password_resets_tbl 
                                       (user_id, email, reason, status, created_at)
                                       VALUES 
                                       (@UserId, @Email, @Reason, 'pending', GETDATE());";

                var parameters = new SqlParameter[]
                {
                    new SqlParameter("@UserId", userId),
                    new SqlParameter("@Email", reqEmail),
                    new SqlParameter("@Reason", string.IsNullOrEmpty(reqReason) ? "Password removal requested." : (object)reqReason)
                };

                DatabaseHelper.ExecuteNonQuery(insertQuery, parameters);

                ShowAlert("Password removal request submitted to the administrator. Once approved, you can create a new password.", isError: false);
            }
            catch (Exception ex)
            {
                ShowAlert("Error submitting request: " + ex.Message, isError: true);
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