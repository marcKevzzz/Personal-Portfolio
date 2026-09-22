<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.EducationSection" %>

<!-- ============================================================ EDUCATION -->
<section id="education">
  <div class="wrap">
    <div class="field-label reveal">06 / EDUCATION</div>
    <h2 class="section-title reveal">Background</h2>
 
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="section-empty-state">
      <span>No education added yet.</span>
    </asp:Panel>
    <div class="edu-list" id="eduList" runat="server">
      <asp:Repeater ID="rptEducations" runat="server">
        <ItemTemplate>
          <div class="list-line reveal">
            <span class="yr"><%# Server.HtmlEncode(Eval("YearPeriod").ToString()) %></span>
            <div>
              <div class="ttl"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
              <div class="sub"><%# Server.HtmlEncode(Eval("Subtitle").ToString()) %></div>
            </div>
            <span class="org"><%# Server.HtmlEncode(Eval("InstitutionName").ToString()) %></span>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
