using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Data;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio
{
    public partial class AccountProfile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!AuthHelper.IsAuthenticated())
            {
                Response.Redirect("~/Auth/SignIn.aspx?returnUrl=" + Server.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        private void LoadUserProfile()
        {
            var currentUser = AuthHelper.GetCurrentUser();
            if (currentUser == null) return;

            // Query fresh user data from database
            string query = @"SELECT user_id, first_name, last_name, email, password_hash, user_role, is_active, created_at 
                             FROM users_tbl 
                             WHERE user_id = @UserId;";

            var dt = DatabaseHelper.ExecuteQuery(query, new SqlParameter("@UserId", currentUser.UserId));
            if (dt != null && dt.Rows.Count > 0)
            {
                var row = dt.Rows[0];
                string fName = row["first_name"].ToString();
                string lName = row["last_name"].ToString();
                string email = row["email"].ToString();
                string role = row["user_role"].ToString();
                bool isActive = Convert.ToBoolean(row["is_active"]);
                DateTime createdAt = Convert.ToDateTime(row["created_at"]);

                // Sync session
                currentUser.FirstName = fName;
                currentUser.LastName = lName;
                currentUser.Email = email;
                currentUser.Role = role;
                currentUser.IsActive = isActive;
                currentUser.CreatedAt = createdAt;
                AuthHelper.SetUserSession(currentUser);

                // Populate form fields
                txtFirstName.Text = fName;
                txtLastName.Text = lName;
                txtEmail.Text = email;
                txtRole.Text = role;

                // Populate Sidebar & Avatar
                litProfileHeaderName.Text = Server.HtmlEncode($"{fName} {lName}");
                litStatusText.Text = isActive ? "Active Account" : "Deactivated";
                litMemberSince.Text = createdAt.ToString("MMMM yyyy");

                var pData = PortfolioService.GetPortfolioData(currentUser.UserId);
                string avatar = pData?.Profile?.AvatarPath;
                bool hasRealAvatar = !string.IsNullOrWhiteSpace(avatar)
                    && !avatar.Contains("image_placeholder")
                    && !avatar.Contains("pixelart_portrait");
                string initial = !string.IsNullOrWhiteSpace(fName)
                    ? fName.Substring(0, 1).ToUpper()
                    : (!string.IsNullOrWhiteSpace(email) ? email.Substring(0, 1).ToUpper() : "U");

                if (hasRealAvatar)
                {
                    imgAvatarPreview.ImageUrl = ResolveUrl("~/" + avatar.TrimStart('~', '/'));
                    imgAvatarPreview.Style["display"] = "block";
                    userProfileInitials.Style["display"] = "none";
                    avatarSvgPlaceholder.Style["display"] = "none";
                }
                else if (!string.IsNullOrEmpty(initial))
                {
                    imgAvatarPreview.Style["display"] = "none";
                    userProfileInitials.InnerText = initial;
                    userProfileInitials.Style["display"] = "flex";
                    avatarSvgPlaceholder.Style["display"] = "none";
                }
                else
                {
                    imgAvatarPreview.Style["display"] = "none";
                    userProfileInitials.Style["display"] = "none";
                    avatarSvgPlaceholder.Style["display"] = "flex";
                }

                if (AuthHelper.IsAdmin())
                {
                    adminQueueSection.Visible = true;
                    LoadAdminRequests();
                }
                else
                {
                    adminQueueSection.Visible = false;
                }
            }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            var currentUser = AuthHelper.GetCurrentUser();
            if (currentUser == null)
            {
                Response.Redirect("~/Auth/SignIn.aspx");
                return;
            }

            string newFirstName = (txtFirstName.Text ?? "").Trim();
            string newLastName = (txtLastName.Text ?? "").Trim();
            string newPassword = (txtNewPassword.Text ?? "").Trim();
            string confirmPassword = (txtConfirmPassword.Text ?? "").Trim();

            if (string.IsNullOrEmpty(newFirstName))
            {
                ShowAlert("First name is required.", isError: true);
                return;
            }

            if (string.IsNullOrEmpty(newLastName))
            {
                ShowAlert("Last name is required.", isError: true);
                return;
            }

            // Handle Optional Password Change
            string newPasswordHash = null;
            if (!string.IsNullOrEmpty(newPassword))
            {
                if (newPassword.Length < 8)
                {
                    ShowAlert("New password must be at least 8 characters long.", isError: true);
                    return;
                }

                if (!string.Equals(newPassword, confirmPassword))
                {
                    ShowAlert("New password and confirmation do not match.", isError: true);
                    return;
                }

                newPasswordHash = AuthHelper.HashPassword(newPassword);
            }


            try
            {
                // Build dynamic UPDATE query
                string updateSql = @"UPDATE users_tbl 
                                    SET first_name = @FirstName, 
                                        last_name = @LastName";

                if (!string.IsNullOrEmpty(newPasswordHash))
                {
                    updateSql += ", password_hash = @PasswordHash";
                }

                updateSql += " WHERE user_id = @UserId;";

                var parameters = new System.Collections.Generic.List<SqlParameter>
                {
                    new SqlParameter("@FirstName", newFirstName),
                    new SqlParameter("@LastName", newLastName),
                    new SqlParameter("@UserId", currentUser.UserId)
                };

                if (!string.IsNullOrEmpty(newPasswordHash))
                {
                    parameters.Add(new SqlParameter("@PasswordHash", newPasswordHash));
                }

                int rowsAffected = DatabaseHelper.ExecuteNonQuery(updateSql, parameters.ToArray());

                if (rowsAffected > 0)
                {
                    // Update user in session
                    currentUser.FirstName = newFirstName;
                    currentUser.LastName = newLastName;
                    if (!string.IsNullOrEmpty(newPasswordHash))
                    {
                        currentUser.PasswordHash = newPasswordHash;
                    }

                    AuthHelper.SetUserSession(currentUser);

                    // Update UI literals
                    litProfileHeaderName.Text = Server.HtmlEncode($"{newFirstName} {newLastName}");
                    txtNewPassword.Text = string.Empty;
                    txtConfirmPassword.Text = string.Empty;

                    ShowAlert("Account details and profile updated successfully.", isError: false);

                    string toastScript = @"if (typeof Toast !== 'undefined') { 
                                              Toast.success('Profile details and avatar updated successfully.', 'Changes Saved'); 
                                           }";
                    ClientScript.RegisterStartupScript(this.GetType(), "saveProfileSuccessToast", toastScript, true);
                }
                else
                {
                    ShowAlert("Unable to update account details. Please try again.", isError: true);
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Database error updating profile: " + ex.Message, isError: true);
            }
        }

        private void LoadAdminRequests()
        {
            try
            {
                string reqQuery = @"SELECT reset_id, user_id, email, reason, status, created_at 
                                   FROM password_resets_tbl 
                                   WHERE status = 'pending' 
                                   ORDER BY reset_id DESC;";

                var dt = DatabaseHelper.ExecuteQuery(reqQuery);
                rptAdminRequests.DataSource = dt;
                rptAdminRequests.DataBind();
            }
            catch (Exception ex)
            {
                ShowAlert("Error loading admin requests: " + ex.Message, isError: true);
            }
        }

        protected void rptAdminRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "RemovePassword")
            {
                if (!AuthHelper.IsAdmin())
                {
                    ShowAlert("Unauthorized action.", isError: true);
                    return;
                }

                int resetId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    string updateSql = "UPDATE password_resets_tbl SET status = 'password_removed' WHERE reset_id = @ResetId;";
                    DatabaseHelper.ExecuteNonQuery(updateSql, new SqlParameter("@ResetId", resetId));

                    LoadAdminRequests();
                    ShowAlert("Password successfully removed for the requested user.", isError: false);
                }
                catch (Exception ex)
                {
                    ShowAlert("Error removing password: " + ex.Message, isError: true);
                }
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
