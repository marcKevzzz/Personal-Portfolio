<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AdminProfilePanel" %>

<div class="admin-panel" data-panel="admin-profile">
    <h2>Admin Account &amp; Credentials</h2>
    <p class="admin-sub">Update administrator sign-in details, email, and password security credentials.</p>

    <div class="admin-profile-card">
        <div class="admin-profile-header">
            <div class="avatar-preview-container">
                <asp:Image ID="imgAdminAvatar" runat="server" CssClass="account-avatar-img" Visible="false" ClientIDMode="Static" onerror="this.style.display='none'; var ph = document.getElementById('adminAvatarSvgPlaceholder'); if (ph) ph.style.display='flex';" />
                <div id="adminAvatarSvgPlaceholder" runat="server" class="avatar-svg-placeholder" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:rgba(61,127,255,0.08);" ClientIDMode="Static">
                    <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="currentColor" style="width:48px; height:48px; color:var(--text-dim);">
                        <rect x="9" y="4" width="6" height="6" />
                        <rect x="11" y="10" width="2" height="2" />
                        <rect x="6" y="12" width="12" height="3" />
                        <rect x="4" y="15" width="16" height="5" />
                    </svg>
                </div>
                <label for="adminAvatarUpload" class="avatar-edit-overlay" title="Change Avatar">
                    <svg class="camera-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                        <circle cx="12" cy="13" r="4"></circle>
                    </svg>
                    <span>Change Photo</span>
                </label>
                <asp:FileUpload ID="adminAvatarUpload" runat="server" ClientIDMode="Static" accept="image/*" style="display:none;" />
            </div>
            <div>
                <h3 style="font-size: var(--t-md); font-weight: 500;">
                    <asp:Literal ID="litAdminDisplayName" runat="server" Text="Marc Kevin Del Mundo" />
                </h3>
                <span class="status-pill active" style="margin-top: 6px;">SYSTEM ADMINISTRATOR</span>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin-bottom: 16px;">ADMIN DETAILS</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>FULL NAME</label>
                <div class="input-row">
                    <asp:TextBox ID="txtAdminFullName" runat="server" placeholder="Marc Kevin Del Mundo" />
                </div>
            </div>
            <div class="field">
                <label>SIGN-IN EMAIL</label>
                <div class="input-row">
                    <asp:TextBox ID="txtAdminEmail" runat="server" TextMode="Email" placeholder="admin@example.com" />
                </div>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 24px 0 16px;">SECURITY &amp; PASSWORD</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>NEW PASSWORD (LEAVE BLANK TO KEEP CURRENT)</label>
                <div class="input-row has-toggle">
                    <asp:TextBox ID="txtAdminNewPassword" runat="server" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
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
                <div class="strength" id="adminStrengthMeter" data-level="0">
                    <i></i><i></i><i></i>
                </div>
            </div>
            <div class="field">
                <label>CONFIRM NEW PASSWORD</label>
                <div class="input-row has-toggle">
                    <asp:TextBox ID="txtAdminConfirmPassword" runat="server" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
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

        <div style="margin-top: 24px;">
            <asp:Button ID="btnSaveAdminProfile" runat="server" Text="Save Admin Credentials" CssClass="btn btn-primary" OnClick="btnSaveAdminProfile_Click" data-confirm-title="Update Admin Profile" data-confirm-msg="Are you sure you want to update your administrative credentials?" data-confirm-btn="Save Credentials" />
        </div>
    </div>
</div>
