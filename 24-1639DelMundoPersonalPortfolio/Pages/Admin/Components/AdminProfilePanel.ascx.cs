using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class AdminProfilePanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAdminDetails();
            }
        }

        public void LoadAdminDetails()
        {
            var currentUser = AuthHelper.GetCurrentUser();
            string fullName = currentUser != null ? $"{currentUser.FirstName} {currentUser.LastName}".Trim() : "Marc Kevin Del Mundo";
            string email = currentUser != null ? currentUser.Email : "delmundo.marckevin.ferolino@gmail.com";

            litAdminDisplayName.Text = Server.HtmlEncode(fullName);
            txtAdminFullName.Text = fullName;
            txtAdminEmail.Text = email;

            int currentUserId = currentUser != null ? currentUser.UserId : AuthHelper.GetCurrentUserId();
            var portfolioData = PortfolioService.GetPortfolioData(currentUserId);
            string avatar = portfolioData?.Profile?.AvatarPath;
            bool hasRealAvatar = !string.IsNullOrWhiteSpace(avatar)
                && !avatar.Contains("image_placeholder")
                && !avatar.Contains("pixelart_portrait");

            string initial = !string.IsNullOrWhiteSpace(fullName)
                ? fullName.Substring(0, 1).ToUpper()
                : (!string.IsNullOrWhiteSpace(email) ? email.Substring(0, 1).ToUpper() : "M");

            if (hasRealAvatar)
            {
                imgAdminAvatar.ImageUrl = ResolveUrl("~/" + avatar.TrimStart('~', '/'));
                imgAdminAvatar.Visible = true;
                adminAvatarInitials.Style["display"] = "none";
                adminAvatarSvgPlaceholder.Style["display"] = "none";
            }
            else if (!string.IsNullOrEmpty(initial))
            {
                imgAdminAvatar.Visible = false;
                adminAvatarInitials.InnerText = initial;
                adminAvatarInitials.Style["display"] = "flex";
                adminAvatarSvgPlaceholder.Style["display"] = "none";
            }
            else
            {
                imgAdminAvatar.Visible = false;
                adminAvatarInitials.Style["display"] = "none";
                adminAvatarSvgPlaceholder.Style["display"] = "flex";
            }
        }

        protected void btnSaveAdminProfile_Click(object sender, EventArgs e)
        {
            string fullName = txtAdminFullName.Text.Trim();
            string email = txtAdminEmail.Text.Trim();
            string newPass = txtAdminNewPassword.Text.Trim();
            string confirmPass = txtAdminConfirmPassword.Text.Trim();

            if (!string.IsNullOrEmpty(newPass))
            {
                if (newPass.Length < 8)
                {
                    string warnScript = "if(window.AdminToast) AdminToast.warning('Password must be at least 8 characters long.', 'Security');";
                    Page.ClientScript.RegisterStartupScript(GetType(), "pwLengthWarn", warnScript, true);
                    return;
                }
                if (newPass != confirmPass)
                {
                    string errScript = "if(window.AdminToast) AdminToast.error('Passwords do not match. Please verify your new password.', 'Password Mismatch');";
                    Page.ClientScript.RegisterStartupScript(GetType(), "pwMismatchErr", errScript, true);
                    return;
                }
            }

            string firstName = fullName;
            string lastName = "";
            int lastSpace = fullName.LastIndexOf(' ');
            if (lastSpace > 0)
            {
                firstName = fullName.Substring(0, lastSpace);
                lastName = fullName.Substring(lastSpace + 1);
            }

            var currentUser = AuthHelper.GetCurrentUser();
            int userId = currentUser != null && currentUser.UserId > 0 ? currentUser.UserId : 1;

            bool ok = PortfolioService.UpdateAdminCredentials(userId, firstName, lastName, email, newPass);

            if (ok && currentUser != null)
            {
                currentUser.FirstName = firstName;
                currentUser.LastName = lastName;
                currentUser.Email = email;
                AuthHelper.SetUserSession(currentUser);
            }

            LoadAdminDetails();
            txtAdminNewPassword.Text = "";
            txtAdminConfirmPassword.Text = "";

            string script = ok 
                ? "if(window.AdminToast) AdminToast.success('Admin credentials and security settings updated successfully.', 'Credentials Saved');"
                : "if(window.AdminToast) AdminToast.error('Failed to update admin credentials.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "adminSavedToast", script, true);
        }
    }
}
