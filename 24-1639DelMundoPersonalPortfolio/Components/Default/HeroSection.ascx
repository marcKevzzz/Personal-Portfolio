<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HeroSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.HeroSection" %>

<!-- ============================================================ HERO -->
<section id="hero">
  <div class="grid-bg" id="heroGrid"></div>
  <div class="wrap-wide">
    <div class="hero-inner">
      <div class="hero-left">
       <div class="field-label" style="padding-left: 4px">PERSONAL WEBSITE</div>
        <h1 class="hero-name" id="heroName">
          <span class="hero-name-primary" id="heroDynamicName" runat="server" clientidmode="Static">
            <asp:Literal ID="litHeroDynamicName" runat="server" />
          </span>
          <span class="hero-name-sub" id="heroSubline">
            <asp:Literal ID="litHeroSubline" runat="server" />
          </span>
        </h1>
        <p class="hero-role" id="heroRoleSummary">
          <asp:Literal ID="litHeroRoleSummary" runat="server" />
        </p>
        <div class="hero-meta">
          <div>ROLE<strong id="heroMetaRole"><asp:Literal ID="litRoleTitle" runat="server" /></strong></div>
          <div>FOCUS<strong id="heroMetaFocus"><asp:Literal ID="litFocusArea" runat="server" /></strong></div>
          <div>BASED IN<strong id="heroMetaBasedIn"><asp:Literal ID="litBasedIn" runat="server" /></strong></div>
        </div>
      </div>

      <div class="avatar" id="avatar">
        <asp:Image ID="imgAvatar" runat="server" CssClass="avatar-img" ClientIDMode="Static" />
      </div>
    </div>
  </div>

  <div class="scroll-cue"><div class="bar"></div>SCROLL</div>
</section>
