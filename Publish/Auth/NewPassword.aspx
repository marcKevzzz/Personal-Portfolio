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
          <div class="input-row">
            <asp:TextBox ID="password" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
          </div>
          <div class="strength" id="strengthMeter" data-level="0">
            <i></i><i></i><i></i>
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>

        <div class="field reveal">
          <label for="confirm">Confirm New Password</label>
          <div class="input-row">
            <asp:TextBox ID="confirm" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="new-password" />
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
