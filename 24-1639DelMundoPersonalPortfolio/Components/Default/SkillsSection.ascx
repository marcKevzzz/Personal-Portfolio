<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SkillsSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.SkillsSection" %>

<!-- ============================================================ SKILLS -->
<section id="skills">
  <div class="wrap">
    <div class="field-label reveal">03 / SKILLS</div>
    <h2 class="section-title reveal">Where the time goes</h2>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="section-empty-state">
      <span>No skills added yet.</span>
    </asp:Panel>
    <div class="skills-list" id="skillsList" runat="server">
      <asp:Repeater ID="rptSkills" runat="server">
        <ItemTemplate>
          <div class="skill-row reveal">
            <span class="skill-name"><%# Server.HtmlEncode(Eval("SkillName").ToString()) %></span>
            <div class="skill-track"><div class="skill-fill" data-val="<%# Eval("ProficiencyVal") %>"></div></div>
            <span class="skill-val"><%# Eval("ProficiencyVal") %></span>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
