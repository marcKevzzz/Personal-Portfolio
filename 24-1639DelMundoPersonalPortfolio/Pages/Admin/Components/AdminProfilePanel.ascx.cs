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
            string avatar = currentUser != null ? currentUser.ProfileImage : "";

            litAdminDisplayName.Text = Server.HtmlEncode(fullName);
            txtAdminFullName.Text = fullName;
            txtAdminEmail.Text = email;

            if (!string.IsNullOrEmpty(avatar))
            {
                imgAdminAvatar.ImageUrl = ResolveUrl("~/" + avatar.TrimStart('~', '/'));
                imgAdminAvatar.Visible = true;
                adminAvatarSvgPlaceholder.Visible = false;
            }
            else
            {
                imgAdminAvatar.Visible = false;
                adminAvatarSvgPlaceholder.Visible = true;
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

            string newAvatarPath = null;
            if (adminAvatarUpload != null && adminAvatarUpload.HasFile)
            {
                try
                {
                    string ext = System.IO.Path.GetExtension(adminAvatarUpload.FileName).ToLowerInvariant();
                    string[] allowedExts = { ".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif" };
                    if (System.Linq.Enumerable.Contains(allowedExts, ext))
                    {
                        string targetDir = Server.MapPath("~/Assets/Images/");
                        if (!System.IO.Directory.Exists(targetDir))
                        {
                            System.IO.Directory.CreateDirectory(targetDir);
                        }
                        string fileName = $"admin_avatar_{DateTime.UtcNow.Ticks}{ext}";
                        string fullPath = System.IO.Path.Combine(targetDir, fileName);
                        adminAvatarUpload.SaveAs(fullPath);
                        newAvatarPath = "Assets/Images/" + fileName;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("[AdminProfilePanel] Avatar upload error: " + ex.Message);
                }
            }

            var currentUser = AuthHelper.GetCurrentUser();
            int userId = currentUser != null && currentUser.UserId > 0 ? currentUser.UserId : 1;

            bool ok = PortfolioService.UpdateAdminCredentials(userId, firstName, lastName, email, newPass, newAvatarPath);

            if (ok && currentUser != null)
            {
                currentUser.FirstName = firstName;
                currentUser.LastName = lastName;
                currentUser.Email = email;
                if (!string.IsNullOrEmpty(newAvatarPath))
                {
                    currentUser.ProfileImage = newAvatarPath;
                }
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
