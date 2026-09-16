<%@ Page Title="Create Account" Language="C#" MasterPageFile="~/Auth/Auth.Master" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.SignUp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="authHead" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="authContent" runat="server">
    <div class="screen">

  <!-- ============ BRAND PANEL ============ -->
  <div class="brand-panel">
    <div class="grid-bg"></div>
    <div class="brand-mark"><span class="dot"></span>KEVS</div>

    <div class="brand-copy">
      <h1>Set up<br>your <span class="accent">account</span>.</h1>
      <p>A few fields and you're in &mdash; same system, same structure, your own workspace.</p>
    </div>

    <div class="brand-foot">KEVS &mdash; 2026 / SESSION AUTH</div>
  </div>

  <!-- ============ FORM PANEL ============ -->
  <div class="form-panel">
    <div class="form-card">
      <div class="field-label kicker">AUTH / SIGN UP</div>
      <h2>Create account</h2>
      <p class="sub">Already have one? <a href="SignIn.aspx">Sign in</a></p>

      <div id="signUpSuccessToast" class="save-toast" style="display: none; margin-bottom: 20px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
          <polyline points="20 6 9 17 4 12"></polyline>
        </svg>
        <span>Account created successfully! Redirecting to sign in...</span>
      </div>

      <div id="signupForm" novalidate>
        <div class="field">
          <label for="name">Full name</label>
          <div class="input-row">
            <input type="text" id="name" name="name" placeholder="Your name" autocomplete="name" required>
          </div>
          <div class="field-error">Enter your name.</div>
        </div>

        <div class="field">
          <label for="email">Email</label>
          <div class="input-row">
            <input type="email" id="email" name="email" placeholder="you@example.com" autocomplete="email" required>
          </div>
          <div class="field-error">Enter a valid email address.</div>
        </div>

        <div class="field">
          <label for="password">Password</label>
          <div class="input-row">
            <input type="password" id="password" name="password" placeholder="••••••••" autocomplete="new-password" required minlength="8">
          </div>
          <div class="strength" id="strengthMeter" data-level="0">
            <i></i><i></i><i></i>
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>

        <div class="field">
          <label for="confirm">Confirm password</label>
          <div class="input-row">
            <input type="password" id="confirm" name="confirm" placeholder="••••••••" autocomplete="new-password" required>
          </div>
          <div class="field-error">Passwords don't match.</div>
        </div>

        <button type="button" class="submit" id="createAccountBtn"><span>Create account</span></button>
      </div>

      <p class="foot-note">By clicking Create account, the Terms &amp; Conditions modal will appear for your review.</p>
    </div>
  </div>
  </div>

  <!-- ============ TERMS & CONDITIONS MODAL ============ -->
  <div id="termsModal" class="modal-backdrop" aria-hidden="true" style="display: none;">
    <div class="modal-dialog terms-condition" role="dialog" aria-modal="true" aria-labelledby="termsTitle">
      <div class="modal-header">
        <div>
          <div class="modal-kicker">LEGAL / AGREEMENT</div>
          <h3 id="termsTitle" class="modal-title">Terms &amp; Conditions</h3>
        </div>
        <button type="button" class="modal-close-btn" id="closeTermsBtn" aria-label="Close modal">&times;</button>
      </div>

     
      <div class="terms-scroll-box" id="termsScrollBox" tabindex="0">
        <h4>1. Platform Acceptance</h4>
        <p>By registering for an account on the KEVS Portfolio &amp; Systems Platform, you agree to comply with and be bound by the following terms, privacy commitments, and operational protocols. If you do not accept these conditions, you may not proceed with account creation or access restricted datasets.</p>

        <h4>2. User Identity &amp; Account Responsibility</h4>
        <p>You are solely responsible for maintaining the strict confidentiality of your authentication credentials, session tokens, and passwords. Any activity that originates under your verified profile will be attributed to your identity. If unauthorized access is suspected, notify the system administrator immediately.</p>

        <h4>3. Security &amp; Administrative Interventions</h4>
        <p>In the event of forgotten credentials, security incidents, or profile lockout, password resets are processed strictly through authorized administrative channels. Submitting a recovery request authorises the administrator to inspect account security status, remove obsolete access credentials, and issue clearance for new password generation.</p>

        <h4>4. Data Processing &amp; Privacy Policy</h4>
        <p>We process personal data, email records, and activity telemetry in accordance with standard privacy frameworks. Your account details are securely encrypted and will never be distributed, sold, or shared with unauthorized third-party commercial entities.</p>

        <h4>5. Acceptable System Utilization</h4>
        <p>Users agree not to engage in malicious exploitation, unauthorized penetration testing, denial-of-service attempts, automated scraping of protected resources, or reverse engineering of proprietary interfaces and system modules.</p>

        <h4>6. System Availability &amp; Modifications</h4>
        <p>The KEVS platform reserves the right to periodically alter, upgrade, or temporarily suspend access to certain features, database models, and interface styles for performance enhancements and maintenance without prior notice.</p>

        <h4>7. Governing Terms &amp; Acknowledgment</h4>
        <p>By proceeding to accept these terms, you confirm that you have read, understood, and consented to each provision outlined above. This agreement constitutes the full understanding between you and the platform administration.</p>
      </div>


      <div class="modal-footer">
        <button type="button" class="modal-btn-cancel" id="declineTermsBtn">Decline</button>
        <button type="button" class="modal-btn-accept submit" id="acceptTermsBtn" disabled>
          <span>I Agree &amp; Continue</span>
        </button>
      </div>
    </div>
  </div>

</asp:Content>
