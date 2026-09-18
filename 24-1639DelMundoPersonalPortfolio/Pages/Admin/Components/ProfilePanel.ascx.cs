using System;
using System.Text;
using System.Web.UI;
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
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var p = data?.Profile ?? new ProfileDto();

            txtHeroSubline.Text = p.HeroSubline ?? "builds interfaces";
            hidHeroNames.Value = p.HeroNames ?? "Kevs,Marc Kevin,Del Mundo";
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
            txtFullName.Text = p.FullName ?? "Marc Kevin Del Mundo";
            txtLocationAddress.Text = p.LocationAddress ?? "B2 L6 Emerald St. Novaliches Proper, Q.C.";
            txtAge.Text = p.Age.ToString();
            txtExperienceYears.Text = p.ExperienceYears.ToString();
            txtEmail.Text = p.Email ?? "delmundo.marckevin.ferolino@gmail.com";
            txtGithubUrl.Text = p.GithubUrl ?? "https://github.com/marcKevzzz";
            txtLinkedinUrl.Text = p.LinkedinUrl ?? "https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436";

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
            string fullName = txtFullName.Text.Trim();
            if (string.IsNullOrWhiteSpace(fullName))
            {
                Page.ClientScript.RegisterStartupScript(GetType(), "profileWarn", "if(window.AdminToast) AdminToast.warning('Please enter your full name.', 'Validation Error');", true);
                return;
            }

            int age = int.TryParse(txtAge.Text, out int a) ? a : 19;
            int exp = int.TryParse(txtExperienceYears.Text, out int ex) ? ex : 3;

            string firstName = fullName;
            string lastName = "";
            int lastSpace = fullName.LastIndexOf(' ');
            if (lastSpace > 0)
            {
                firstName = fullName.Substring(0, lastSpace);
                lastName = fullName.Substring(lastSpace + 1);
            }

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

            var profile = new ProfileDto
            {
                FirstName = firstName,
                LastName = lastName,
                HeroSubline = txtHeroSubline.Text.Trim(),
                HeroNames = string.IsNullOrWhiteSpace(hidHeroNames.Value) ? "Kevs,Marc Kevin,Del Mundo" : hidHeroNames.Value.Trim(),
                RoleSummary = txtRoleSummary.Text.Trim(),
                RoleTitle = txtRoleTitle.Text.Trim(),
                FocusArea = txtFocusArea.Text.Trim(),
                BasedIn = txtBasedIn.Text.Trim(),
                AvatarPath = avatarPath,
                LocationAddress = txtLocationAddress.Text.Trim(),
                Age = age,
                ExperienceYears = exp,
                Email = txtEmail.Text.Trim(),
                GithubUrl = txtGithubUrl.Text.Trim(),
                LinkedinUrl = txtLinkedinUrl.Text.Trim()
            };

            bool success = PortfolioService.SaveProfile(profile);

            RenderHeroChips(profile.HeroNames);

            string script;
            if (success)
            {
                script = "if(window.AdminToast) AdminToast.success('Public profile settings have been updated successfully.', 'Profile Saved');";
            }
            else
            {
                script = "if(window.AdminToast) AdminToast.error('Failed to save profile changes to database.', 'Save Failed');";
            }
            Page.ClientScript.RegisterStartupScript(GetType(), "profileSavedToast", script, true);
        }
    }
}
