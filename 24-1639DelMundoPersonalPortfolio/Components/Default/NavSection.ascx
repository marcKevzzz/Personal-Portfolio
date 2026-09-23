<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.NavSection" %>

<!-- ============================================================ PRELOADER OVERLAY -->
<div id="preloader" class="preloader-overlay">
  <span id="preloaderCounter" class="preloader-counter">0</span>
</div>

<div id="progress"></div>

<nav class="index-nav" aria-label="Section index">
  <asp:HyperLink ID="lnkNavProfile" runat="server" NavigateUrl="~/Pages/User/PortfolioBuilder.aspx" CssClass="nav-profile-btn" aria-label="Manage Website Console" ToolTip="Website Builder">
    <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M12 20h9"></path>
      <path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"></path>
    </svg>
  </asp:HyperLink>
  <a href="#hero" data-label="Intro"><span>Intro</span></a>
  <a href="#info" data-label="Info"><span>Info</span></a>
  <a href="#stack" data-label="Stack"><span>Stack</span></a>
  <a href="#skills" data-label="Skills"><span>Skills</span></a>
  <a href="#experience" data-label="Experience"><span>Experience</span></a>
  <a href="#projects" data-label="Projects"><span>Projects</span></a>
  <a href="#education" data-label="Education"><span>Education</span></a>
  <a href="#awards" data-label="Awards"><span>Awards</span></a>
  <a href="#hobbies" data-label="Hobbies"><span>Hobbies</span></a>
  <a href="#contact" data-label="Contact"><span>Contact</span></a>
</nav>
