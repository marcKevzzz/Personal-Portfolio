<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserAccountPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.User.Components.UserAccountPanel" %>

<div class="admin-panel" data-panel="account">
    <h2>My Account &amp; Credentials</h2>
    <p class="admin-sub">Manage your personal identification details, account security, and sign-in password.</p>

    <div class="admin-profile-card">
        <div class="admin-profile-header">
            <div class="avatar-svg-placeholder" style="width:72px; height:72px; border-radius:12px; display:flex; align-items:center; justify-content:center; background:rgba(61,127,255,0.12); border: 1px solid rgba(61,127,255,0.25);">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width:36px; height:36px; color:var(--blue-light);">
                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                    <circle cx="12" cy="7" r="4"></circle>
                </svg>
            </div>
            <div>
                <h3 style="font-size: var(--t-md); font-weight: 500; margin: 0 0 4px;">
                    <asp:Literal ID="litUserDisplayName" runat="server" Text="User" />
                </h3>
                <span class="status-pill active" style="margin-top: 2px;">CREATOR ACCOUNT</span>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 20px 0 16px;">PERSONAL INFORMATION</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>FIRST NAME</label>
                <div class="input-row">
                    <asp:TextBox ID="txtUserFirstName" runat="server" placeholder="First Name" />
                </div>
            </div>
            <div class="field">
                <label>LAST NAME</label>
                <div class="input-row">
                    <asp:TextBox ID="txtUserLastName" runat="server" placeholder="Last Name" />
                </div>
            </div>
        </div>

        <div class="admin-fieldgroup" style="margin-top: 14px;">
            <div class="field" style="grid-column: 1 / -1;">
                <label>SIGN-IN EMAIL</label>
                <div class="input-row">
                    <asp:TextBox ID="txtUserEmail" runat="server" ReadOnly="true" CssClass="readonly-input" style="opacity: 0.75; cursor: not-allowed; background: rgba(255,255,255,0.03);" />
                </div>
                <span class="email-span">
                    Account sign-in email is permanent and cannot be modified. To change your public portfolio contact email, visit your <strong>Profile</strong> panel.
                </span>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 28px 0 16px;">SECURITY &amp; PASSWORD</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>NEW PASSWORD (LEAVE BLANK TO KEEP CURRENT)</label>
                <div class="input-row has-toggle">
                    <asp:TextBox ID="txtUserNewPassword" runat="server" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                    <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility" title="Show/Hide password" tabindex="-1">
                        <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M9.88 9.88 a3 3 0 1 0 4.24 4.24"></path>
                            <path d="M10.73 5.08 A10.43 10.43 0 0 1 12 5 c7 0 10 7 10 7 a13.16 13.16 0 0 1-1.67 2.68"></path>
                            <path d="M6.61 6.61 A13.526 13.526 0 0 0 2 12 s3 7 10 7 a9.74 9.74 0 0 0 5.39-1.61"></path>
                            <line x1="2" y1="2" x2="22" y2="22"></line>
                        </svg>
                        <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="display: none;">
                            <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>
            <div class="field">
                <label>CONFIRM NEW PASSWORD</label>
                <div class="input-row has-toggle">
                    <asp:TextBox ID="txtUserConfirmPassword" runat="server" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
                    <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility" title="Show/Hide password" tabindex="-1">
                        <svg class="eye-icon eye-closed" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M9.88 9.88 a3 3 0 1 0 4.24 4.24"></path>
                            <path d="M10.73 5.08 A10.43 10.43 0 0 1 12 5 c7 0 10 7 10 7 a13.16 13.16 0 0 1-1.67 2.68"></path>
                            <path d="M6.61 6.61 A13.526 13.526 0 0 0 2 12 s3 7 10 7 a9.74 9.74 0 0 0 5.39-1.61"></path>
                            <line x1="2" y1="2" x2="22" y2="22"></line>
                        </svg>
                        <svg class="eye-icon eye-open" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" style="display: none;">
                            <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7"></path>
                            <circle cx="12" cy="12" r="3"></circle>
                        </svg>
                    </button>
                </div>
            </div>
        </div>

        <div style="margin-top: 28px;">
            <asp:Button ID="btnSaveAccountDetails" runat="server" Text="Save Account Details" CssClass="btn btn-primary" OnClick="btnSaveAccountDetails_Click" data-confirm-title="Update Account Details" data-confirm-msg="Are you sure you want to update your user account information and credentials?" data-confirm-btn="Update Details" />
        </div>
    </div>
</div>
