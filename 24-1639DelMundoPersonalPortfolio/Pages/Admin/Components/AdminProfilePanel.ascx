<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AdminProfilePanel" %>

<div class="admin-panel" data-panel="admin-profile">
    <h2>Admin Account &amp; Credentials</h2>
    <p class="admin-sub">Update administrator sign-in details, email, and password security credentials.</p>

    <div class="admin-profile-card">
        <div class="admin-profile-header">
            <div class="avatar-preview-container">
                <asp:Image ID="imgAdminAvatar" runat="server" CssClass="account-avatar-img" Visible="false" ClientIDMode="Static" />
                <div id="adminAvatarSvgPlaceholder" runat="server" class="avatar-svg-placeholder" style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:rgba(61,127,255,0.08);" ClientIDMode="Static">
                    <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="currentColor" style="width:48px; height:48px; color:var(--text-dim);">
                        <rect x="9" y="4" width="6" height="6" />
                        <rect x="11" y="10" width="2" height="2" />
                        <rect x="6" y="12" width="12" height="3" />
                        <rect x="4" y="15" width="16" height="5" />
                    </svg>
                </div>
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
                    <asp:TextBox ID="txtAdminFullName" runat="server" placeholder="Marc Kevin Del Mundo" required="required" />
                </div>
            </div>
            <div class="field">
                <label>SIGN-IN EMAIL</label>
                <div class="input-row">
                    <asp:TextBox ID="txtAdminEmail" runat="server" TextMode="Email" placeholder="admin@example.com" required="required" />
                </div>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 24px 0 16px;">SECURITY &amp; PASSWORD</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>NEW PASSWORD (LEAVE BLANK TO KEEP CURRENT)</label>
                <div class="input-row">
                    <asp:TextBox ID="txtAdminNewPassword" runat="server" TextMode="Password" placeholder="••••••••" />
                </div>
                <div class="strength" id="adminStrengthMeter" data-level="0">
                    <i></i><i></i><i></i>
                </div>
            </div>
            <div class="field">
                <label>CONFIRM NEW PASSWORD</label>
                <div class="input-row">
                    <asp:TextBox ID="txtAdminConfirmPassword" runat="server" TextMode="Password" placeholder="••••••••" />
                </div>
            </div>
        </div>

        <div style="margin-top: 24px;">
            <asp:Button ID="btnSaveAdminProfile" runat="server" Text="Save Admin Credentials" CssClass="btn btn-primary" OnClick="btnSaveAdminProfile_Click" data-confirm-title="Update Admin Profile" data-confirm-msg="Are you sure you want to update your administrative credentials?" data-confirm-btn="Save Credentials" />
        </div>
    </div>
</div>
