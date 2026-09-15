<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SignUp.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.SignUp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
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
      <div class="field-label kicker reveal">AUTH / SIGN UP</div>
      <h2 class="reveal">Create account</h2>
      <p class="sub reveal">Already have one? <a href="sign-in.html">Sign in</a></p>
 
      <div id="signupForm" novalidate>
        <div class="field reveal">
          <label for="name">Full name</label>
          <div class="input-row">
            <input type="text" id="name" name="name" placeholder="Your name" required>
          </div>
          <div class="field-error">Enter your name.</div>
        </div>
 
        <div class="field reveal">
          <label for="email">Email</label>
          <div class="input-row">
            <input type="email" id="email" name="email" placeholder="you@example.com" required>
          </div>
          <div class="field-error">Enter a valid email address.</div>
        </div>
 
        <div class="field reveal">
          <label for="password">Password</label>
          <div class="input-row">
            <input type="password" id="password" name="password" placeholder="••••••••" required minlength="8">
          </div>
          <div class="strength" id="strengthMeter" data-level="0">
            <i></i><i></i><i></i>
          </div>
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>
 
        <div class="field reveal">
          <label for="confirm">Confirm password</label>
          <div class="input-row">
            <input type="password" id="confirm" name="confirm" placeholder="••••••••" required>
          </div>
          <div class="field-error">Passwords don't match.</div>
        </div>
 
        <label class="checkbox-row reveal">
          <input type="checkbox" name="terms" required>
          I agree to the <a href="#">Terms</a> and <a href="#">Privacy Policy</a>.
        </label>
 
        <button type="submit" class="submit reveal"><span>Create account</span></button>
      </div>
 
      <p class="foot-note reveal">[ add your terms / privacy links here ]</p>
    </div>
  </div>
  </div>
 
</asp:Content>
