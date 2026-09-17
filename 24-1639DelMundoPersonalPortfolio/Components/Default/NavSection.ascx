<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.NavSection" %>

<!-- ============================================================ PRELOADER OVERLAY -->
<div id="preloader" class="preloader-overlay">
  <span id="preloaderCounter" class="preloader-counter">0</span>
</div>

<div id="progress"></div>

<nav class="index-nav" aria-label="Section index">
  <a href="<%= ResolveUrl("~/Pages/Profile.aspx") %>" class="nav-profile-btn" aria-label="Account Profile">
    <% if (!string.IsNullOrEmpty(ProfileAvatarUrl)) { %>
      <img src="<%= ResolveUrl(ProfileAvatarUrl) %>" class="nav-avatar-img" alt="Profile Avatar" />
    <% } else { %>
      <svg class="profile-icon-svg" viewBox="0 0 24 24" fill="currentColor">
        <rect x="9" y="4" width="6" height="6" />
        <rect x="11" y="10" width="2" height="2" />
        <rect x="6" y="12" width="12" height="3" />
        <rect x="4" y="15" width="16" height="5" />
      </svg>
    <% } %>
  </a>
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
