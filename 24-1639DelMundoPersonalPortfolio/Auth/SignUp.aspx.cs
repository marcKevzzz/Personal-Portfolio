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

            if (string.IsNullOrEmpty(emailVal) || !emailVal.Contains("@") || !emailVal.Contains("."))
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
                // 1. Check if email is already registered
                string checkQuery = "SELECT COUNT(1) FROM users_tbl WHERE LOWER(email) = LOWER(@Email)";
                var emailParam = new SqlParameter("@Email", emailVal);
                int count = Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, emailParam));

                if (count > 0)
                {
                    ShowAlert("An account with this email address already exists. Please sign in instead.", isError: true);
                    return;
                }

                // 2. Hash password securely
                string passwordHash = AuthHelper.HashPassword(passVal);

                // 3. Assign role: Admin for owner email, User for regular accounts
                string role = "User";
                if (string.Equals(emailVal, "delmundo.marckevin.ferolino@gmail.com", StringComparison.OrdinalIgnoreCase))
                {
                    role = "Admin";
                }

                // 4. Insert new user into users_tbl and seed initial profile
                string insertQuery = @"INSERT INTO users_tbl 
                                       (first_name, last_name, email, password_hash, user_role, is_active, created_at)
                                       VALUES 
                                       (@FirstName, @LastName, @Email, @PasswordHash, @UserRole, 1, GETDATE());
                                       SELECT SCOPE_IDENTITY();";

                var parameters = new SqlParameter[]
                {
                    new SqlParameter("@FirstName", fName),
                    new SqlParameter("@LastName", lName),
                    new SqlParameter("@Email", emailVal),
                    new SqlParameter("@PasswordHash", passwordHash),
                    new SqlParameter("@UserRole", role)
                };

                object newIdObj = DatabaseHelper.ExecuteScalar(insertQuery, parameters);
                int newUserId = (newIdObj != null && newIdObj != DBNull.Value) ? Convert.ToInt32(newIdObj) : 0;

                if (newUserId > 0)
                {
                    try
                    {
                        string profileInsert = @"INSERT INTO profile_tbl (user_id, first_name, last_name, email, role_title, focus_area, based_in, avatar_path, updated_at)
                                                 VALUES (@UserId, @FirstName, @LastName, @Email, 'Web Developer', 'Interfaces & Data Systems', 'Quezon City', 'Assets/Images/pixelart_portrait.png', GETDATE());";
                        DatabaseHelper.ExecuteNonQuery(profileInsert,
                            new SqlParameter("@UserId", newUserId),
                            new SqlParameter("@FirstName", fName),
                            new SqlParameter("@LastName", lName),
                            new SqlParameter("@Email", emailVal));
                    }
                    catch { }

                    Response.Redirect("~/Auth/SignIn.aspx?registered=true&email=" + Server.UrlEncode(emailVal));
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