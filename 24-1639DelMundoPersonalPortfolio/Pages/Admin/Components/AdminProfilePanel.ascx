<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminProfilePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AdminProfilePanel" %>

<div class="admin-panel" data-panel="admin-profile">
    <h2>Admin Account &amp; Credentials</h2>
    <p class="admin-sub">Update administrator sign-in details, email, and password security credentials.</p>

    <div class="admin-profile-card">
        <div class="admin-profile-header">
            <div class="avatar-preview-container">
                <img id="adminAvatarPreview" src="<%= ResolveUrl("~/Assets/Images/pixelart_portrait.png") %>" alt="Admin Avatar" class="account-avatar-img" />
                <label for="adminAvatarUpload" class="avatar-edit-overlay" title="Change Avatar">
                    <svg class="camera-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                        <circle cx="12" cy="13" r="4"></circle>
                    </svg>
                    <span>Change Photo</span>
                </label>
                <input type="file" id="adminAvatarUpload" name="adminAvatarUpload" accept="image/*" style="display:none;" />
            </div>
            <div>
                <h3 style="font-size: var(--t-md); font-weight: 500;">Del Mundo, Marc Kevin F.</h3>
                <span class="status-pill active" style="margin-top: 6px;">SYSTEM ADMINISTRATOR</span>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin-bottom: 16px;">ADMIN DETAILS</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>FULL NAME</label>
                <div class="input-row">
                    <input type="text" id="adminFullName" value="Del Mundo, Marc Kevin F." required />
                </div>
            </div>
            <div class="field">
                <label>SIGN-IN EMAIL</label>
                <div class="input-row">
                    <input type="email" id="adminEmail" value="delmundo.marckevin.ferolino@gmail.com" required />
                </div>
            </div>
        </div>

        <h4 style="font-family: var(--f-display); font-size: var(--t-xs); color: var(--blue-light); margin: 24px 0 16px;">SECURITY &amp; PASSWORD</h4>
        <div class="admin-fieldgroup">
            <div class="field">
                <label>NEW PASSWORD</label>
                <div class="input-row">
                    <input type="password" id="adminNewPassword" placeholder="••••••••" minlength="8" />
                </div>
                <div class="strength" id="adminStrengthMeter" data-level="0">
                    <i></i><i></i><i></i>
                </div>
            </div>
            <div class="field">
                <label>CONFIRM NEW PASSWORD</label>
                <div class="input-row">
                    <input type="password" id="adminConfirmPassword" placeholder="••••••••" />
                </div>
            </div>
        </div>

        <div style="margin-top: 24px;">
            <button type="button" id="btnSaveAdminProfile" class="btn btn-primary"><span>Save Admin Credentials</span></button>
        </div>
    </div>
</div>
