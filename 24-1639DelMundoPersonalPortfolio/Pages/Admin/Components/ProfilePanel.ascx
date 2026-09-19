<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProfilePanel" %>

<div class="admin-panel active" data-panel="profile">
    <h2>Public Profile &amp; Hero</h2>
    <p class="admin-sub">Configure hero heading, basic personal information, and social links for the public portfolio page.</p>

    <div class="admin-fieldgroup">
        <div class="field">
            <label>Hero kicker</label>
            <div class="input-row">
                <asp:TextBox ID="txtHeroKicker" runat="server" Text="PERSONAL PORTFOLIO" />
            </div>
        </div>
        <div class="field">
            <label>Hero subline</label>
            <div class="input-row">
                <asp:TextBox ID="txtHeroSubline" runat="server" Text="builds interfaces" />
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
            <asp:HiddenField ID="hidHeroNames" runat="server" ClientIDMode="Static" Value="Kevs,Marc Kevin,Del Mundo" />
        </div>
        <div class="field">
            <label>Role summary paragraph</label>
            <asp:TextBox ID="txtRoleSummary" runat="server" TextMode="MultiLine" Rows="3" CssClass="hero-txtarea" />
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Role title</label>
            <div class="input-row">
                <asp:TextBox ID="txtRoleTitle" runat="server" Text="Web Developer" />
            </div>
        </div>
        <div class="field">
            <label>Focus area</label>
            <div class="input-row">
                <asp:TextBox ID="txtFocusArea" runat="server" Text="Interfaces & Data Systems" />
            </div>
        </div>
        <div class="field">
            <label>Based in</label>
            <div class="input-row">
                <asp:TextBox ID="txtBasedIn" runat="server" Text="Quezon City" />
            </div>
        </div>
        <div class="field">
            <label>Avatar image &amp; preview</label>
            <div style="display: flex; gap: 12px; align-items: center;">
                <div class="input-row" style="flex: 1; border: none;">
                    <asp:FileUpload ID="fuProfileAvatar" runat="server" accept="image/*" CssClass="admin-file-input" />
                    <asp:HiddenField ID="hidExistingAvatarPath" runat="server" ClientIDMode="Static" Value="" />
                </div>
                <div id="profileAvatarPreviewBox" runat="server" style="width: 36px; height: 36px; border: 1px solid var(--line); background: var(--bg-3); flex: none; display: none; align-items: center; justify-content: center; overflow: hidden; border-radius: 4px;">
                    <asp:Image ID="imgProfileAvatarThumb" runat="server" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='/Assets/Images/pixelart_portrait.png';" />
                </div>
            </div>
        </div>
    </div>
    <div class="admin-fieldgroup">
        <div class="field">
            <label>Full name</label>
            <div class="input-row">
                <asp:TextBox ID="txtFullName" runat="server" Text="Marc Kevin Del Mundo" />
            </div>
        </div>
        <div class="field">
            <label>Location address</label>
            <div class="input-row">
                <asp:TextBox ID="txtLocationAddress" runat="server" Text="B2 L6 Emerald St. Novaliches Proper, Q.C." />
            </div>
        </div>
        <div class="field">
            <label>Age</label>
            <div class="input-row">
                <asp:TextBox ID="txtAge" runat="server" TextMode="Number" min="0" max="150" Text="19" />
            </div>
        </div>
        <div class="field">
            <label>Experience (Years)</label>
            <div class="input-row">
                <asp:TextBox ID="txtExperienceYears" runat="server" TextMode="Number" min="0" max="100" Text="3" />
            </div>
        </div>
    </div>
    <div class="admin-fieldgroup three-col">
        <div class="field">
            <label>Email</label>
            <div class="input-row">
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" Text="delmundo.marckevin.ferolino@gmail.com" />
            </div>
        </div>
        <div class="field">
            <label>GitHub URL</label>
            <div class="input-row">
                <asp:TextBox ID="txtGithubUrl" runat="server" Text="https://github.com/marcKevzzz" />
            </div>
        </div>
        <div class="field">
            <label>LinkedIn URL</label>
            <div class="input-row">
                <asp:TextBox ID="txtLinkedinUrl" runat="server" Text="https://www.linkedin.com/in/del-mundo-marc-kevin-f-ba5050436" />
            </div>
        </div>
    </div>

    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile Settings" CssClass="btn btn-primary" OnClick="btnSaveProfile_Click" data-confirm-title="Save Profile" data-confirm-msg="Are you sure you want to update your public profile and hero data?" data-confirm-btn="Save Profile" />
</div>

