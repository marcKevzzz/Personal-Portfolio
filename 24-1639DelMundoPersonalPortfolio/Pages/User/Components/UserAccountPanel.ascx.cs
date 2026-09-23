using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.User.Components
{
    public partial class UserAccountPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserDetails();
            }
        }

        public void LoadUserDetails()
        {
            var currentUser = AuthHelper.GetCurrentUser();
            if (currentUser == null) return;

            string fullName = $"{currentUser.FirstName} {currentUser.LastName}".Trim();
            litUserDisplayName.Text = Server.HtmlEncode(string.IsNullOrEmpty(fullName) ? currentUser.Email : fullName);
            txtUserFirstName.Text = currentUser.FirstName ?? "";
            txtUserLastName.Text = currentUser.LastName ?? "";
            txtUserEmail.Text = currentUser.Email ?? "";

            // Check if user has uploaded avatar image
            var portfolioData = PortfolioService.GetPortfolioData(currentUser.UserId);
            string avatar = portfolioData?.Profile?.AvatarPath;
            bool hasRealAvatar = !string.IsNullOrWhiteSpace(avatar)
                && !avatar.Contains("image_placeholder")
                && !avatar.Contains("pixelart_portrait");

            string initial = !string.IsNullOrWhiteSpace(currentUser.FirstName)
                ? currentUser.FirstName.Substring(0, 1).ToUpper()
                : (!string.IsNullOrWhiteSpace(currentUser.Email) ? currentUser.Email.Substring(0, 1).ToUpper() : "U");

            if (hasRealAvatar)
            {
                imgUserAccountAvatar.ImageUrl = ResolveUrl("~/" + avatar.TrimStart('~', '/'));
                imgUserAccountAvatar.Style["display"] = "block";
                userAccountInitials.Style["display"] = "none";
                avatarSvgPlaceholder.Style["display"] = "none";
            }
            else if (!string.IsNullOrEmpty(initial))
            {
                imgUserAccountAvatar.Style["display"] = "none";
                userAccountInitials.InnerText = initial;
                userAccountInitials.Style["display"] = "flex";
                avatarSvgPlaceholder.Style["display"] = "none";
            }
            else
            {
                imgUserAccountAvatar.Style["display"] = "none";
                userAccountInitials.Style["display"] = "none";
                avatarSvgPlaceholder.Style["display"] = "flex";
            }
        }

        protected void btnSaveAccountDetails_Click(object sender, EventArgs e)
        {
            var currentUser = AuthHelper.GetCurrentUser();
            if (currentUser == null)
            {
                Response.Redirect("~/Auth/SignIn.aspx", true);
                return;
            }

            string firstName = txtUserFirstName.Text.Trim();
            string lastName = txtUserLastName.Text.Trim();
            string newPass = txtUserNewPassword.Text.Trim();
            string confirmPass = txtUserConfirmPassword.Text.Trim();

            if (string.IsNullOrWhiteSpace(firstName))
            {
                string warn = "if(window.AdminToast) AdminToast.warning('First name is required.', 'Validation');";
                Page.ClientScript.RegisterStartupScript(GetType(), "reqFirst", warn, true);
                return;
            }

            if (!string.IsNullOrEmpty(newPass))
            {
                if (newPass.Length < 8)
                {
                    string warn = "if(window.AdminToast) AdminToast.warning('New password must be at least 8 characters long.', 'Security');";
                    Page.ClientScript.RegisterStartupScript(GetType(), "pwLenWarn", warn, true);
                    return;
                }
                if (newPass != confirmPass)
                {
                    string warn = "if(window.AdminToast) AdminToast.error('Passwords do not match. Please re-enter your new password.', 'Password Mismatch');";
                    Page.ClientScript.RegisterStartupScript(GetType(), "pwMismatch", warn, true);
                    return;
                }
            }

            bool ok = PortfolioService.UpdateUserDetails(currentUser.UserId, firstName, lastName, newPass);

            if (ok)
            {
                currentUser.FirstName = firstName;
                currentUser.LastName = lastName;
                AuthHelper.SetUserSession(currentUser);

                txtUserNewPassword.Text = "";
                txtUserConfirmPassword.Text = "";
                LoadUserDetails();

                string script = "if(window.AdminToast) AdminToast.success('Your user account details and credentials have been updated.', 'Account Updated');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userSavedToast", script, true);
            }
            else
            {
                string script = "if(window.AdminToast) AdminToast.error('Failed to update user account details. Please try again.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "userErrToast", script, true);
            }
        }
    }
}
