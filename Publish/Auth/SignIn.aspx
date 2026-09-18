<%@ Page Title="Sign In" Language="C#" MasterPageFile="~/Auth/Auth.Master" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.SignIn" %>
<asp:Content ID="Content1" ContentPlaceHolderID="authHead" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="authContent" runat="server">
    <div class="screen">

  <!-- ============ BRAND PANEL ============ -->
  <div class="brand-panel">
    <div class="grid-bg"></div>
    <div class="brand-mark "><span class="dot"></span>KEVS</div>

    <div class="brand-copy">
      <h1 class="">Welcome<br>back to the <span class="accent">system</span>.</h1>
      <p class="">Sign in to pick up where you left off &mdash; projects, datasets, and everything
      structured in between.</p>
    </div>

    <div class="brand-foot ">KEVS &mdash; 2026 / SESSION AUTH</div>
  </div>

  <!-- ============ FORM PANEL ============ -->
  <div class="form-panel">
    <div class="form-card">
      <div class="field-label kicker ">AUTH / SIGN IN</div>
      <h2 class="">Sign in</h2>
      <p class="sub ">Don't have an account? <a href="SignUp.aspx">Create one</a></p>

      <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="save-toast " style="margin-bottom: 20px;">
        <asp:Literal ID="litAlertIcon" runat="server">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
            <polyline points="20 6 9 17 4 12"></polyline>
          </svg>
        </asp:Literal>
        <asp:Literal ID="litAlertMsg" runat="server"></asp:Literal>
      </asp:Panel>

      <div id="signinForm" novalidate>
        <div class="field ">
          <label for="email">Email</label>
          <div class="input-row">
            <asp:TextBox ID="email" runat="server" ClientIDMode="Static" TextMode="Email" placeholder="you@example.com" autocomplete="email" />
          </div>
          <div class="field-error">Enter a valid email address.</div>
        </div>

        <div class="field ">
          <label for="password">Password</label>
          <div class="input-row">
            <asp:TextBox ID="password" runat="server" ClientIDMode="Static" TextMode="Password" placeholder="••••••••" autocomplete="current-password" />
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>

        <div class="row-between ">
          <label class="checkbox-row">
            <asp:CheckBox ID="remember" runat="server" ClientIDMode="Static" Text="Remember me" />
          </label>
          <a href="javascript:void(0)" id="forgotPasswordLink">Forgot password?</a>
        </div>

        <asp:Button ID="signInBtn" runat="server" ClientIDMode="Static" CssClass="submit " Text="Sign in" OnClick="btnSignIn_Click" UseSubmitBehavior="true" />
      </div>

      <p class="foot-note ">Protected by standard session auth &mdash; KEVS 2026</p>
    </div>
  </div>

  <!-- ============ FORGOT PASSWORD / ADMIN REMOVAL MODAL ============ -->
  <div id="forgotPasswordModal" class="modal-backdrop" aria-hidden="true" style="display: none;">
    <div class="modal-dialog password" role="dialog" aria-modal="true" aria-labelledby="forgotTitle">
      <div class="modal-header">
        <div>
          <div class="modal-kicker">ACCOUNT RECOVERY / ADMIN CLEARANCE</div>
          <h3 id="forgotTitle" class="modal-title">Forgot Password</h3>
        </div>
        <button type="button" class="modal-close-btn" id="closeForgotBtn" aria-label="Close modal">&times;</button>
      </div>

      <div class="modal-info-box">
        <span>Account passwords can be removed by the system administrator upon request. Once removed, you can create a new password.</span>
      </div>

      <!-- State 1: Submit Request View -->
      <div id="forgotReqFormView">
        <div class="field" style="margin-top: 16px;">
          <label for="forgotEmail">Account Email</label>
          <div class="input-row">
            <asp:TextBox ID="forgotEmail" runat="server" ClientIDMode="Static" TextMode="Email" placeholder="you@example.com" autocomplete="email" />
          </div>
          <div class="field-error" id="forgotEmailError">Enter the registered email for this account.</div>
        </div>

        <div class="field" style="margin-top: 12px;">
          <label for="forgotReason">Request Note (Optional)</label>
          <div class="input-row">
            <asp:TextBox ID="forgotReason" runat="server" ClientIDMode="Static" placeholder="e.g. Forgotten password, request removal" />
          </div>
        </div>

        <div class="modal-footer" style="margin-top: 24px;">
          <button type="button" class="modal-btn-cancel" id="cancelForgotBtn">Cancel</button>
          <asp:Button ID="submitForgotReqBtn" runat="server" ClientIDMode="Static" CssClass="modal-btn-accept submit" Text="Submit Request to Admin" OnClick="btnSubmitForgotReq_Click" />
        </div>
      </div>

      <!-- State 2: Request Sent / Status Tracking View -->
      <div id="forgotReqStatusView" style="display: none;">
        <div class="status-tracker-card" id="statusTrackerCard">
          <div class="tracker-header">
            <span class="tracker-badge" id="trackerBadge">PENDING ADMIN REMOVAL</span>
            <span class="tracker-time" id="trackerTime">Just now</span>
          </div>
          <div class="tracker-detail" id="trackerDetail">
            A password removal request has been submitted to the administrator for <strong id="trackerEmail"></strong>.
          </div>
        </div>

        <!-- Simulation Card for testing/demonstration -->
        <div class="admin-sim-card" id="adminSimCard">
          <div class="admin-sim-title">ADMIN INTERVENTION</div>
          <p class="admin-sim-desc">You can simulate administrator action here to test the removal process:</p>
          <button type="button" class="admin-btn-remove" id="adminQuickRemoveBtn">
            <span>Simulate Admin: Remove Password Now</span>
          </button>
        </div>

        <!-- State 3: Password Removed & Action to Create New Password -->
        <div id="passwordRemovedActionView" style="display: none; margin-top: 20px;">
          <div class="success-callout">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
              <polyline points="20 6 9 17 4 12"></polyline>
            </svg>
            <div>
              <strong>Password Removed!</strong>
              <p>The administrator has removed the password for your account. You can now create a new password.</p>
            </div>
          </div>
          <a href="NewPassword.aspx" id="goToNewPasswordBtn" class="submit" style="display: block; text-align: center; margin-top: 16px; text-decoration: none;">
            <span>Create New Password &rarr;</span>
          </a>
        </div>

        <div class="modal-footer" style="margin-top: 20px;">
          <button type="button" class="modal-btn-cancel" id="closeForgotStatusBtn">Close</button>
        </div>
      </div>

    </div>
  </div>

</div>
</asp:Content>
