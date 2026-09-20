<%@ Page Title="Set New Password" Language="C#" MasterPageFile="~/Auth/Auth.Master" AutoEventWireup="true" CodeBehind="NewPassword.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.NewPassword" %>
<asp:Content ID="Content1" ContentPlaceHolderID="authHead" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="authContent" runat="server">
    <div class="screen">

  <!-- ============ BRAND PANEL ============ -->
  <div class="brand-panel">
    <div class="grid-bg"></div>
    <div class="brand-mark reveal"><span class="dot"></span>KEVS</div>

    <div class="brand-copy">
      <h1 class="reveal">Reset<br>your <span class="accent">password</span>.</h1>
      <p class="reveal">Your previous password was removed by the administrator. Set a new password below to regain full access.</p>
    </div>

    <div class="brand-foot reveal">KEVS &mdash; 2026 / SESSION AUTH</div>
  </div>

  <!-- ============ FORM PANEL ============ -->
  <div class="form-panel">
    <div class="form-card">
      <div class="field-label kicker reveal">AUTH / NEW PASSWORD</div>
      <h2 class="reveal">Set new password</h2>
      <p class="sub reveal">Remember your password? <a href="SignIn.aspx">Sign in</a></p>

      <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="save-toast" style="margin-bottom: 20px;">
        <asp:Literal ID="litAlertIcon" runat="server">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        </asp:Literal>
        <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
      </asp:Panel>

      <div id="newPasswordForm" novalidate>
        <div class="field reveal">
          <label for="resetEmail">Account Email</label>
          <div class="input-row">
            <asp:TextBox ID="resetEmail" runat="server" ClientIDMode="Static" TextMode="Email" placeholder="you@example.com" autocomplete="email" />
          </div>
          <div class="field-error">Enter a valid email address.</div>
        </div>

        <div class="field reveal">
          <label for="password">New Password</label>
          <div class="input-row has-toggle">
            <asp:TextBox ID="password" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
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
          <div class="strength" id="strengthMeter" data-level="0">
            <i></i><i></i><i></i>
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>

        <div class="field reveal">
          <label for="confirm">Confirm New Password</label>
          <div class="input-row has-toggle">
            <asp:TextBox ID="confirm" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
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
          <div class="field-error">Passwords don't match.</div>
        </div>

        <asp:Button ID="setNewPasswordBtn" runat="server" ClientIDMode="Static" CssClass="submit reveal" Text="Save New Password &amp; Sign In" OnClick="btnSetNewPassword_Click" UseSubmitBehavior="true" />

        <div class="reveal" style="margin-top: 14px; text-align: center;">
          <a href="javascript:void(0)" id="fillMockNewPassBtn" style="font-size: var(--t-xs); color: var(--blue-light); border-bottom: 1px dashed var(--blue);">⚡ Fill Demo New Password</a>
        </div>
      </div>

      <p class="foot-note reveal">Protected by standard session auth &mdash; KEVS 2026</p>
    </div>
  </div>

</div>
</asp:Content>
