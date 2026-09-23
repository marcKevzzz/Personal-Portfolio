<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProfilePanel" %>

<div class="admin-panel active" data-panel="profile">
    <h2>Public Profile &amp; Hero</h2>
    <p class="admin-sub">Configure hero heading, profile image, presentation highlights, date of birth, contact email, and social links for your portfolio website.</p>

    <!-- Public Profile Avatar Card on Top (matching Admin Profile design) -->
    <div class="admin-profile">
        <div class="admin-profile-header">
            <div class="avatar-preview-container">
                <asp:Image ID="imgProfileAvatarThumb" runat="server" CssClass="account-avatar-img" ClientIDMode="Static" onerror="this.style.display='none'; var ph = document.getElementById('profileAvatarSvgPlaceholder'); if (ph) ph.style.display='flex';" />
                <div id="profileAvatarSvgPlaceholder" runat="server" class="avatar-svg-placeholder" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:rgba(61,127,255,0.08);" ClientIDMode="Static">
                    <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="currentColor" style="width:48px; height:48px; color:var(--text-dim);">
                        <rect x="9" y="4" width="6" height="6" />
                        <rect x="11" y="10" width="2" height="2" />
                        <rect x="6" y="12" width="12" height="3" />
                        <rect x="4" y="15" width="16" height="5" />
                    </svg>
                </div>
            </div>
            <div style="flex: 1;">
                <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 0 0 16px;">PUBLIC PORTFOLIO PROFILE</h4>
                <div style="display: flex; gap: 12px; align-items: center; max-width: 440px;">
                    <asp:FileUpload ID="fuProfileAvatar" runat="server" accept="image/*" CssClass="admin-file-input" onchange="previewPublicAvatar(this);" />
                    <asp:HiddenField ID="hidExistingAvatarPath" runat="server" ClientIDMode="Static" Value="" />
                </div>
            </div>
        </div>
    </div>

    <!-- Personal Details: First & Last Name -->
    <div class="admin-fieldgroup">
        <div class="field">
            <label>First name <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtProfileFirstName" runat="server" placeholder="e.g. John" />
            </div>
        </div>
        <div class="field">
            <label>Last name <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtProfileLastName" runat="server" placeholder="e.g. Doe" />
            </div>
        </div>
    </div>

    <!-- Hero & Presentation (All 2 Columns) -->
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero subline</label>
            <div class="input-row">
                <asp:TextBox ID="txtHeroSubline" runat="server" placeholder="e.g. builds interfaces, solves problems" />
            </div>
        </div>
        <div class="field">
            <label>Role title <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtRoleTitle" runat="server" placeholder="e.g. Web Developer" />
            </div>
        </div>
    </div>

    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero names <span class="req-star">*</span></label>
            <div class="chips-container" id="heroNameChips" data-input-target="hidHeroNames">
                <asp:Literal ID="litHeroChips" runat="server" />
                <input type="text" class="chip-input" placeholder="Type name & hit Enter..." />
            </div>
            <asp:HiddenField ID="hidHeroNames" runat="server" ClientIDMode="Static" Value="" />
        </div>
        <div class="field">
            <label>Role summary paragraph</label>
            <asp:TextBox ID="txtRoleSummary" runat="server" TextMode="MultiLine" Rows="3" CssClass="hero-txtarea" placeholder="Brief introduction or background summary..." />
        </div>
    </div>

    <div class="admin-fieldgroup">
        <div class="field">
            <label>Focus area</label>
            <div class="input-row">
                <asp:TextBox ID="txtFocusArea" runat="server" placeholder="e.g. Interfaces & Data Systems" />
            </div>
        </div>
        <div class="field">
            <label>Based in</label>
            <div class="input-row">
                <asp:TextBox ID="txtBasedIn" runat="server" placeholder="e.g. Quezon City" />
            </div>
        </div>
    </div>

    <div class="admin-fieldgroup">
        <div class="field">
            <label>Location address</label>
            <div class="input-row">
                <asp:TextBox ID="txtLocationAddress" runat="server" placeholder="e.g. Novaliches Proper, Quezon City" />
            </div>
        </div>
        <div class="field">
            <label>Experience (Years)</label>
            <div class="input-row">
                <asp:TextBox ID="txtExperienceYears" runat="server" TextMode="Number" min="0" max="100" placeholder="0" />
            </div>
        </div>
    </div>

      <!-- Personal Profile Details: Date of Birth -->
    <div class="admin-fieldgroup" style="margin-bottom: 24px;">
        <div class="field">
            <label>Date of Birth</label>
            <div class="input-row">
                <asp:TextBox ID="txtProfileBirthDate" runat="server" TextMode="Date" placeholder="YYYY-MM-DD" onchange="updateLiveProfileAge(this.value);" />
            </div>
            <asp:Label ID="lblProfileAgeHint" runat="server" CssClass="derived-age-hint" style="font-size: var(--t-xs); color: var(--text-dim); margin-top: 6px; display: block;" />
        </div>
    </div>

    <script>
        function previewPublicAvatar(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var img = document.getElementById('imgProfileAvatarThumb');
                    var ph = document.getElementById('profileAvatarSvgPlaceholder');
                    if (img) {
                        img.src = e.target.result;
                        img.style.display = 'block';
                    }
                    if (ph) {
                        ph.style.display = 'none';
                    }
                };
                reader.readAsDataURL(input.files[0]);
            }
        }

        function updateLiveProfileAge(dateStr) {
            var hint = document.getElementById('<%= lblProfileAgeHint.ClientID %>');
            if (!hint) return;
            if (!dateStr) {
                hint.textContent = 'Set your birth date to display your age on your portfolio.';
                return;
            }
            var bday = new Date(dateStr);
            if (isNaN(bday.getTime())) return;
            var today = new Date();
            var age = today.getFullYear() - bday.getFullYear();
            var m = today.getMonth() - bday.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < bday.getDate())) {
                age--;
            }
            if (age >= 0 && age <= 130) {
                hint.textContent = 'Calculated Portfolio Age: ' + age + ' years old';
            } else {
                hint.textContent = 'Please enter a valid birth date.';
            }
        }
    </script>

    <div style="margin-top: 24px;">
        <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile Settings" CssClass="btn btn-primary" OnClick="btnSaveProfile_Click" data-confirm-title="Save Profile" data-confirm-msg="Are you sure you want to update your public profile settings, birth date, and presentation details?" data-confirm-btn="Save Profile" />
    </div>
</div>
