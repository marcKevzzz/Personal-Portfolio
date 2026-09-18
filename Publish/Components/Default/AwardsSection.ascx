<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AwardsSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.AwardsSection" %>

<!-- ============================================================ AWARDS -->
<section id="awards">
  <div class="wrap">
    <div class="field-label reveal">07 / AWARDS</div>
    <h2 class="section-title reveal">Recognition</h2>
 
    <div class="award-list" id="awardList">
      <asp:Repeater ID="rptAwards" runat="server">
        <ItemTemplate>
          <div class="list-line reveal">
            <span class="yr"><%# Server.HtmlEncode(Eval("AwardYear").ToString()) %></span>
            <div>
              <div class="ttl"><%# Server.HtmlEncode(Eval("Title").ToString()) %></div>
              <div class="sub"><%# Server.HtmlEncode(Eval("Subtitle").ToString()) %></div>
            </div>
            <span class="org"><%# Server.HtmlEncode(Eval("OrganizationName").ToString()) %></span>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
