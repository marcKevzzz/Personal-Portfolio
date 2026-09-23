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

            // Populate User First & Last Name
            txtProfileFirstName.Text = currentUser?.FirstName ?? "";
            txtProfileLastName.Text = currentUser?.LastName ?? "";

            // Populate Profile Birth Date and live age calculation hint
            if (p.BirthDate.HasValue)
            {
                txtProfileBirthDate.Text = p.BirthDate.Value.ToString("yyyy-MM-dd");
                lblProfileAgeHint.Text = $"{p.Age} years old";
            }
            else
            {
                txtProfileBirthDate.Text = "";
                lblProfileAgeHint.Text = "Set your birth date to display your age on your portfolio.";
            }

            txtHeroSubline.Text = p.HeroSubline ?? "";
            hidHeroNames.Value = !string.IsNullOrWhiteSpace(p.HeroNames) 
                ? p.HeroNames 
                : (currentUser != null ? $"{currentUser.FirstName},{currentUser.LastName}".Trim(',') : "");
            txtRoleSummary.Text = p.RoleSummary ?? "";
            txtRoleTitle.Text = p.RoleTitle ?? "";
            txtFocusArea.Text = p.FocusArea ?? "";
            txtBasedIn.Text = p.BasedIn ?? "";
            hidExistingAvatarPath.Value = p.AvatarPath ?? "";
            if (!string.IsNullOrWhiteSpace(p.AvatarPath))
            {
                imgProfileAvatarThumb.ImageUrl = ResolveUrl("~/" + p.AvatarPath.TrimStart('~', '/'));
                imgProfileAvatarThumb.Style["display"] = "block";
                profileAvatarSvgPlaceholder.Style["display"] = "none";
            }
            else
            {
                imgProfileAvatarThumb.Style["display"] = "none";
                profileAvatarSvgPlaceholder.Style["display"] = "flex";
            }

            txtLocationAddress.Text = p.LocationAddress ?? "";
            txtExperienceYears.Text = p.ExperienceYears > 0 ? p.ExperienceYears.ToString() : "";

            RenderHeroChips(hidHeroNames.Value);
        }

        private void RenderHeroChips(string names)
        {
            if (string.IsNullOrWhiteSpace(names))
            {
                var currentUser = AuthHelper.GetCurrentUser();
                names = currentUser != null ? $"{currentUser.FirstName},{currentUser.LastName}".Trim(',') : "";
            }
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
                imgProfileAvatarThumb.Style["display"] = "block";
                profileAvatarSvgPlaceholder.Style["display"] = "none";
            }
            else
            {
                imgProfileAvatarThumb.Style["display"] = "none";
                profileAvatarSvgPlaceholder.Style["display"] = "flex";
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

            // Update First and Last Name in users_tbl
            string newFirstName = txtProfileFirstName.Text.Trim();
            string newLastName = txtProfileLastName.Text.Trim();
            if (!string.IsNullOrEmpty(newFirstName) || !string.IsNullOrEmpty(newLastName))
            {
                PortfolioService.UpdateUserDetails(currentUid, newFirstName, newLastName);
            }

            var existingProfile = PortfolioService.GetPortfolioData(currentUid, false)?.Profile;
            var profile = new ProfileDto
            {
                UserId = currentUid,
                BirthDate = birthDate,
                Email = existingProfile?.Email ?? "",
                HeroSubline = txtHeroSubline.Text.Trim(),
                HeroNames = string.IsNullOrWhiteSpace(hidHeroNames.Value) 
                    ? (AuthHelper.GetCurrentUser() != null ? $"{AuthHelper.GetCurrentUser().FirstName},{AuthHelper.GetCurrentUser().LastName}".Trim(',') : "") 
                    : hidHeroNames.Value.Trim(),
                RoleSummary = txtRoleSummary.Text.Trim(),
                RoleTitle = txtRoleTitle.Text.Trim(),
                FocusArea = txtFocusArea.Text.Trim(),
                BasedIn = txtBasedIn.Text.Trim(),
                AvatarPath = avatarPath,
                LocationAddress = txtLocationAddress.Text.Trim(),
                ExperienceYears = exp,
                GithubUrl = existingProfile?.GithubUrl ?? "",
                LinkedinUrl = existingProfile?.LinkedinUrl ?? ""
            };

            bool success = PortfolioService.SaveProfile(profile, userId: currentUid);

            RenderHeroChips(profile.HeroNames);
            LoadProfileData();

            string script;
            if (success)
            {
                script = "if(window.AdminToast) AdminToast.success('Public profile, birth date, and presentation details have been saved successfully.', 'Profile Saved');";
            }
            else
            {
                script = "if(window.AdminToast) AdminToast.error('Failed to save profile changes to database.', 'Save Failed');";
            }
            Page.ClientScript.RegisterStartupScript(GetType(), "profileSavedToast", script, true);
        }
    }
}
