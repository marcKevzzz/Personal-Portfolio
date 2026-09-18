<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="BasicInfoSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.BasicInfoSection" %>

<!-- ============================================================ BASIC INFO -->
<section id="info">
  <div class="wrap">
    <div class="field-label reveal">01 / BASIC INFO</div>
    <h2 class="section-title reveal">The short version</h2>

    <div class="info-grid">
      <div class="info-row reveal">
        <span class="field-label">Name</span>
        <p id="infoName"><asp:Literal ID="litName" runat="server" /></p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Location</span>
        <p class="placeholder" id="infoLocation"><asp:Literal ID="litLocation" runat="server" /></p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Age</span>
        <p class="placeholder" id="infoAge"><asp:Literal ID="litAge" runat="server" /></p>
      </div>
      <div class="info-row reveal">
        <span class="field-label">Experience</span>
        <p id="infoExperience"><asp:Literal ID="litExperience" runat="server" /></p>
      </div>
    </div>
  </div>
</section>
