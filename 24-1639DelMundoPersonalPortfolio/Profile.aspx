<%@ Page Title="Account Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
  CodeBehind="Profile.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.AccountProfile" %>
  <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
  </asp:Content>
  <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="account-page-container wrap-wide">
      <!-- Left Sidebar / Header Section -->
      <aside class="account-top-bar">
        <div class="account-top-bar-header">
          <a href="Default.aspx" class="back-portfolio-link">&larr; Back to Portfolio</a>
          <div class="account-title-group">
            <div class="field-label">ACCOUNT / SETTINGS</div>
            <h1 class="account-page-title">Profile Settings</h1>
          </div>
        </div>

        <div class="account-avatar-wrapper">
          <div class="avatar-preview-container">
            <img id="avatarPreview" src="Images/pixelart_portrait.png" alt="Profile Avatar" class="account-avatar-img">
            <label for="avatarUpload" class="avatar-edit-overlay" title="Change Avatar">
              <svg class="camera-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path>
                <circle cx="12" cy="13" r="4"></circle>
              </svg>
              <span>Change Photo</span>
            </label>
            <input type="file" id="avatarUpload" name="avatarUpload" accept="image/*" style="display:none;">
          </div>
          <div class="avatar-info">
            <h3 id="profileHeaderName">Del Mundo, Marc Kevin F.</h3>
            <div class="account-badge-group">
              <span class="account-badge"><span class="status-dot"></span>Active Account</span>
            </div>
          </div>
        </div>

        <!-- Account Quick Metadata -->
        <div class="account-meta-box">
          <div class="meta-item">
            <span class="meta-label">Member Since</span>
            <span class="meta-value">September 2026</span>
          </div>
          <div class="meta-item">
            <span class="meta-label">Role / Access</span>
            <span class="meta-value">Administrator</span>
          </div>
        </div>

        <!-- Sign Out Button -->
        <div class="signout-section">
          <a href="SignIn.aspx" class="signout-btn" id="signoutBtn" title="Sign out of your session">
            <svg class="signout-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
              <polyline points="16 17 21 12 16 7"></polyline>
              <line x1="21" y1="12" x2="9" y2="12"></line>
            </svg>
            <span>Sign Out</span>
          </a>
        </div>
      </aside>

      <!-- Main Account Form Area -->
      <main class="account-card">

        <!-- Notification Toast -->
        <div id="saveToast" class="save-toast">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
          <span>Account details updated successfully.</span>
        </div>

        <!-- Account Form -->
        <div id="profileForm" novalidate>

          <!-- Section 1: Personal Information -->
          <div class="form-section">
            <div class="section-header">
              <h3 class="section-title">Personal Information</h3>
            </div>

            <div class="form-grid-2col">
              <!-- Col 1: Full name -->
              <div class="field">
                <label for="name">FULL NAME</label>
                <div class="input-row">
                  <input type="text" id="name" name="name" value="Del Mundo, Marc Kevin F." placeholder="Your full name" required>
                </div>
                <div class="field-error">Enter your name.</div>
              </div>

              <!-- Col 2: Email -->
              <div class="field">
                <label for="email">EMAIL ADDRESS</label>
                <div class="input-row">
                  <input type="email" id="email" name="email" value="delmundo.marckevin.ferolino@gmail.com" placeholder="you@example.com" required>
                </div>
                <div class="field-error">Enter a valid email address.</div>
              </div>
            </div>
          </div>

          <div class="section-divider"></div>

          <!-- Section 2: Security & Credentials -->
          <div class="form-section">
            <div class="section-header">
              <h3 class="section-title">Security & Credentials</h3>
            </div>

            <div class="form-grid-2col">
              <!-- Col 1: Password -->
              <div class="field">
                <label for="password">NEW PASSWORD</label>
                <div class="input-row">
                  <input type="password" id="password" name="password" placeholder="••••••••" minlength="8">
                </div>
                <div class="strength" id="strengthMeter" data-level="0">
                  <i></i><i></i><i></i>
                </div>
                <div class="field-error">Password must be at least 8 characters.</div>
              </div>

              <!-- Col 2: Confirm password -->
              <div class="field">
                <label for="confirm">CONFIRM NEW PASSWORD</label>
                <div class="input-row">
                  <input type="password" id="confirm" name="confirm" placeholder="••••••••">
                </div>
                <div class="field-error">Passwords don't match.</div>
              </div>
            </div>
          </div>

          <!-- Save Button Actions -->
          <div class="account-form-actions">
            <button type="button" id="saveProfileBtn" class="submit account-submit-btn"><span>Save Changes</span></button>
          </div>

        </div>

      </main>

    </div>
  </asp:Content>