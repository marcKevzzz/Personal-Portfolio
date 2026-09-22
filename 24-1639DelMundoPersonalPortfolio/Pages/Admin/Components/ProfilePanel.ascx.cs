using System;
using System.Text;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class ProfilePanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfileData();
            }
        }

        public void LoadProfileData()
        {
            int currentUid = AuthHelper.GetCurrentUserId();
            var currentUser = AuthHelper.GetCurrentUser();
            var data = PortfolioService.GetPortfolioData(currentUid, true);
            var p = data?.Profile ?? new ProfileDto();

            // Populate pre-filled user identity from users_tbl
            string userFullName = !string.IsNullOrWhiteSpace(p.FullName) 
                ? p.FullName 
                : (currentUser != null ? $"{currentUser.FirstName} {currentUser.LastName}".Trim() : "Creator");
            string loginEmail = currentUser?.Email ?? "";

            litLinkedFullName.Text = Server.HtmlEncode(userFullName);
            litLinkedEmail.Text = Server.HtmlEncode(loginEmail);

            // Populate Profile Birth Date and live age calculation hint
            if (p.BirthDate.HasValue)
            {
                txtProfileBirthDate.Text = p.BirthDate.Value.ToString("yyyy-MM-dd");
                lblProfileAgeHint.Text = $"Calculated Portfolio Age: {p.Age} years old";
            }
            else
            {
                txtProfileBirthDate.Text = "";
                lblProfileAgeHint.Text = "Set your birth date to display your age on your portfolio.";
            }

            // Populate Profile Contact Email (default to login email if profile email not yet set)
            txtProfileEmail.Text = !string.IsNullOrWhiteSpace(p.Email) 
                ? p.Email 
                : loginEmail;

            txtHeroSubline.Text = p.HeroSubline ?? "builds interfaces";
            hidHeroNames.Value = p.HeroNames ?? (currentUser != null ? $"{currentUser.FirstName},{currentUser.LastName}" : "Kevs,Marc Kevin,Del Mundo");
            txtRoleSummary.Text = p.RoleSummary ?? "";
            txtRoleTitle.Text = p.RoleTitle ?? "Web Developer";
            txtFocusArea.Text = p.FocusArea ?? "Interfaces & Data Systems";
            txtBasedIn.Text = p.BasedIn ?? "Quezon City";
            hidExistingAvatarPath.Value = p.AvatarPath ?? "";
            if (!string.IsNullOrWhiteSpace(p.AvatarPath))
            {
                imgProfileAvatarThumb.ImageUrl = ResolveUrl("~/" + p.AvatarPath.TrimStart('~', '/'));
                profileAvatarPreviewBox.Style["display"] = "flex";
            }
            else
            {
                profileAvatarPreviewBox.Style["display"] = "none";
            }

            txtLocationAddress.Text = p.LocationAddress ?? "";
            txtExperienceYears.Text = p.ExperienceYears.ToString();
            txtGithubUrl.Text = p.GithubUrl ?? "";
            txtLinkedinUrl.Text = p.LinkedinUrl ?? "";

            RenderHeroChips(hidHeroNames.Value);
        }

        private void RenderHeroChips(string names)
        {
            if (string.IsNullOrWhiteSpace(names)) names = "Kevs,Marc Kevin,Del Mundo";
            var sb = new StringBuilder();
            sb.Append("<div class=\"chips-list\">");
            var parts = names.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var part in parts)
            {
                string clean = part.Trim();
                if (!string.IsNullOrEmpty(clean))
                {
                    sb.AppendFormat("<span class=\"chip-tag\"><span>{0}</span><span class=\"chip-remove\" title=\"Remove\">&times;</span></span>", Server.HtmlEncode(clean));
                }
            }
            sb.Append("</div>");
            litHeroChips.Text = sb.ToString();
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            int exp = int.TryParse(txtExperienceYears.Text, out int ex) ? ex : 0;
            string avatarPath = hidExistingAvatarPath.Value?.Trim() ?? "";

            if (fuProfileAvatar.HasFile)
            {
                try
                {
                    string ext = System.IO.Path.GetExtension(fuProfileAvatar.FileName).ToLowerInvariant();
                    string[] allowed = { ".png", ".jpg", ".jpeg", ".webp", ".svg", ".gif" };
                    if (System.Array.IndexOf(allowed, ext) >= 0)
                    {
                        string targetDir = Server.MapPath("~/Assets/Images/");
                        if (!System.IO.Directory.Exists(targetDir))
                        {
                            System.IO.Directory.CreateDirectory(targetDir);
                        }
                        string rawName = System.IO.Path.GetFileNameWithoutExtension(fuProfileAvatar.FileName);
                        string cleanName = System.Text.RegularExpressions.Regex.Replace(rawName, @"[^a-zA-Z0-9_\-]", "_");
                        string fileName = $"profile_avatar_{cleanName}_{DateTime.UtcNow.Ticks}{ext}";
                        string fullPath = System.IO.Path.Combine(targetDir, fileName);
                        fuProfileAvatar.SaveAs(fullPath);
                        avatarPath = "Assets/Images/" + fileName;
                        hidExistingAvatarPath.Value = avatarPath;
                    }
                }
                catch (Exception uploadEx)
                {
                    System.Diagnostics.Debug.WriteLine("[ProfilePanel] Avatar upload error: " + uploadEx.Message);
                }
            }

            if (!string.IsNullOrWhiteSpace(avatarPath))
            {
                imgProfileAvatarThumb.ImageUrl = ResolveUrl("~/" + avatarPath.TrimStart('~', '/'));
                profileAvatarPreviewBox.Style["display"] = "flex";
            }
            else
            {
                profileAvatarPreviewBox.Style["display"] = "none";
            }

            // Parse Date of Birth
            DateTime? birthDate = null;
            string bdayStr = txtProfileBirthDate.Text.Trim();
            if (!string.IsNullOrEmpty(bdayStr))
            {
                if (DateTime.TryParse(bdayStr, out DateTime parsedDate))
                {
                    if (parsedDate <= DateTime.Today && parsedDate >= DateTime.Today.AddYears(-130))
                    {
                        birthDate = parsedDate;
                    }
                }
            }

            int currentUid = AuthHelper.GetCurrentUserId();
            var profile = new ProfileDto
            {
                UserId = currentUid,
                BirthDate = birthDate,
                Email = txtProfileEmail.Text.Trim(),
                HeroSubline = txtHeroSubline.Text.Trim(),
                HeroNames = string.IsNullOrWhiteSpace(hidHeroNames.Value) ? "Kevs,Marc Kevin,Del Mundo" : hidHeroNames.Value.Trim(),
                RoleSummary = txtRoleSummary.Text.Trim(),
                RoleTitle = txtRoleTitle.Text.Trim(),
                FocusArea = txtFocusArea.Text.Trim(),
                BasedIn = txtBasedIn.Text.Trim(),
                AvatarPath = avatarPath,
                LocationAddress = txtLocationAddress.Text.Trim(),
                ExperienceYears = exp,
                GithubUrl = txtGithubUrl.Text.Trim(),
                LinkedinUrl = txtLinkedinUrl.Text.Trim()
            };

            bool success = PortfolioService.SaveProfile(profile, userId: currentUid);

            RenderHeroChips(profile.HeroNames);
            LoadProfileData();

            string script;
            if (success)
            {
                script = "if(window.AdminToast) AdminToast.success('Public profile, birth date, and contact email have been saved successfully.', 'Profile Saved');";
            }
            else
            {
                script = "if(window.AdminToast) AdminToast.error('Failed to save profile changes to database.', 'Save Failed');";
            }
            Page.ClientScript.RegisterStartupScript(GetType(), "profileSavedToast", script, true);
        }
    }
}
