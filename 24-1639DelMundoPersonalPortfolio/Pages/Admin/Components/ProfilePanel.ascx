<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProfilePanel" %>

<div class="admin-panel active" data-panel="profile">
    <h2>Public Profile &amp; Hero</h2>
    <p class="admin-sub">Configure hero heading, profile image, presentation highlights, date of birth, contact email, and social links for your portfolio website.</p>


    <!-- Personal Profile Details: Date of Birth & Modifiable Contact Email -->
    <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 0 0 16px;">PROFILE CONTACT &amp; AGE</h4>
    <div class="admin-fieldgroup" style="margin-bottom: 24px;">
        <div class="field">
            <label>DATE OF BIRTH (CALCULATES PORTFOLIO AGE)</label>
            <div class="input-row">
                <asp:TextBox ID="txtProfileBirthDate" runat="server" TextMode="Date" placeholder="YYYY-MM-DD" onchange="updateLiveProfileAge(this.value);" />
            </div>
            <asp:Label ID="lblProfileAgeHint" runat="server" CssClass="derived-age-hint" style="font-size: var(--t-xs); color: var(--blue-light); margin-top: 6px; display: block;" />
        </div>
        <div class="field">
            <label>PORTFOLIO CONTACT EMAIL (EDITABLE)</label>
            <div class="input-row">
                <asp:TextBox ID="txtProfileEmail" runat="server" placeholder="contact@example.com" />
            </div>
            <span style="font-size: var(--t-xs); color: var(--text-dim); margin-top: 6px; display: block;">
                Public contact email shown on your portfolio website. You may modify this anytime.
            </span>
        </div>
    </div>

    <script>
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

    <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 28px 0 16px;">HERO &amp; PRESENTATION</h4>
    <div class="admin-fieldgroup">
        <div class="field" style="grid-column: 1 / -1;">
            <label>Hero subline</label>
            <div class="input-row">
                <asp:TextBox ID="txtHeroSubline" runat="server" placeholder="e.g. builds interfaces, solves problems" />
            </div>
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero names / aliases (Hit Enter or comma to add)</label>
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
            <label>Role title</label>
            <div class="input-row">
                <asp:TextBox ID="txtRoleTitle" runat="server" placeholder="e.g. Web Developer" />
            </div>
        </div>
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
        <div class="field">
            <label>Profile image &amp; preview</label>
            <div style="display: flex; gap: 12px; align-items: center;">
                <div class="input-row" style="flex: 1; border: none;">
                    <asp:FileUpload ID="fuProfileAvatar" runat="server" accept="image/*" CssClass="admin-file-input" />
                    <asp:HiddenField ID="hidExistingAvatarPath" runat="server" ClientIDMode="Static" Value="" />
                </div>
                <div id="profileAvatarPreviewBox" runat="server" style="width: 36px; height: 36px; border: 1px solid var(--line); background: var(--bg-3); flex: none; display: none; align-items: center; justify-content: center; overflow: hidden; border-radius: 4px;">
                    <asp:Image ID="imgProfileAvatarThumb" runat="server" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='/Assets/Images/image_placeholder.png';" />
                </div>
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
    <div class="admin-fieldgroup">
        <div class="field">
            <label>GitHub URL</label>
            <div class="input-row">
                <asp:TextBox ID="txtGithubUrl" runat="server" placeholder="https://github.com/username" />
            </div>
        </div>
        <div class="field">
            <label>LinkedIn URL</label>
            <div class="input-row">
                <asp:TextBox ID="txtLinkedinUrl" runat="server" placeholder="https://linkedin.com/in/username" />
            </div>
        </div>
    </div>

    <div style="margin-top: 24px;">
        <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile Settings" CssClass="btn btn-primary" OnClick="btnSaveProfile_Click" data-confirm-title="Save Profile" data-confirm-msg="Are you sure you want to update your public profile settings, birth date, contact email, and profile image?" data-confirm-btn="Save Profile" />
    </div>
</div>
