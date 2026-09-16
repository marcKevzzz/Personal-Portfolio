<%@ Page Title="Set New Password" Language="C#" MasterPageFile="~/Auth/Auth.Master" AutoEventWireup="true" CodeBehind="NewPassword.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.NewPassword" %>
<asp:Content ID="Content1" ContentPlaceHolderID="authHead" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="authContent" runat="server">
    <div class="screen">

  <!-- ============ BRAND PANEL ============ -->
  <div class="brand-panel">
    <div class="grid-bg"></div>
    <div class="brand-mark"><span class="dot"></span>KEVS</div>

    <div class="brand-copy">
      <h1>Reset<br>your <span class="accent">password</span>.</h1>
      <p>Your previous password was removed by the administrator. Set a new password below to regain full access.</p>
    </div>

    <div class="brand-foot">KEVS &mdash; 2026 / SESSION AUTH</div>
  </div>

  <!-- ============ FORM PANEL ============ -->
  <div class="form-panel">
    <div class="form-card">
      <div class="field-label kicker">AUTH / NEW PASSWORD</div>
      <h2>Set new password</h2>
      <p class="sub">Remember your password? <a href="SignIn.aspx">Sign in</a></p>

      <div id="newPasswordForm" novalidate>
        <div class="field">
          <label for="resetEmail">Account Email</label>
          <div class="input-row">
            <input type="email" id="resetEmail" name="email" placeholder="you@example.com" autocomplete="email" required>
          </div>
          <div class="field-error">Enter a valid email address.</div>
        </div>

        <div class="field">
          <label for="password">New Password</label>
          <div class="input-row">
            <input type="password" id="password" name="password" placeholder="••••••••" autocomplete="new-password" required minlength="8">
          </div>
          <div class="strength" id="strengthMeter" data-level="0">
            <i></i><i></i><i></i>
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>

        <div class="field">
          <label for="confirm">Confirm New Password</label>
          <div class="input-row">
            <input type="password" id="confirm" name="confirm" placeholder="••••••••" autocomplete="new-password" required>
          </div>
          <div class="field-error">Passwords don't match.</div>
        </div>

        <button type="button" class="submit" id="setNewPasswordBtn"><span>Save New Password &amp; Sign In</span></button>

        <div style="margin-top: 14px; text-align: center;">
          <a href="javascript:void(0)" id="fillMockNewPassBtn" style="font-size: var(--t-xs); color: var(--blue-light); border-bottom: 1px dashed var(--blue);">⚡ Fill Demo New Password</a>
        </div>
      </div>

      <p class="foot-note">Protected by standard session auth &mdash; KEVS 2026</p>
    </div>
  </div>

</div>
</asp:Content>
