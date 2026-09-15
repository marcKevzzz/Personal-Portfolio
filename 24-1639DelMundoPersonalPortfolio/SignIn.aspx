<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SignIn.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.SignIn" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="screen">
 
  <!-- ============ BRAND PANEL ============ -->
  <div class="brand-panel">
    <div class="grid-bg"></div>
    <div class="brand-mark"><span class="dot"></span>KEVS</div>
 
    <div class="brand-copy">
      <h1>Welcome<br>back to the <span class="accent">system</span>.</h1>
      <p>Sign in to pick up where you left off &mdash; projects, datasets, and everything
      structured in between.</p>
    </div>
 
    <div class="brand-foot">KEVS &mdash; 2026 / SESSION AUTH</div>
  </div>
 
  <!-- ============ FORM PANEL ============ -->
  <div class="form-panel">
    <div class="form-card">
      <div class="field-label kicker reveal">AUTH / SIGN IN</div>
      <h2 class="reveal">Sign in</h2>
      <p class="sub reveal">Don't have an account? <a href="sign-up.html">Create one</a></p>
 
      <div id="signinForm" novalidate>
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
          <div class="field-error">Password must be at least 8 characters.</div>
        </div>
 
        <div class="row-between reveal">
          <label class="checkbox-row">
            <input type="checkbox" name="remember">
            Remember me
          </label>
          <a href="#">Forgot password?</a>
        </div>
 
        <button type="submit" class="submit reveal"><span>Sign in</span></button>
      </div>
 
      <p class="foot-note reveal">Protected by standard session auth. [ add your terms / privacy links here ]</p>
    </div>
  </div>
 
</div>
</asp:Content>
