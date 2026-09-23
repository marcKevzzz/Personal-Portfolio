<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.HobbiesSection" %>

<!-- ============================================================ HOBBIES -->
<section id="hobbies">
  <div class="wrap">
    <div class="field-label reveal">08 / HOBBIES &amp; INTERESTS</div>
    <h2 class="section-title reveal">Off the clock</h2>
 
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="section-empty-state">
      <span>No hobbies added yet.</span>
    </asp:Panel>
    <div class="hobbies-grid" id="hobbiesList" runat="server">
      <asp:Repeater ID="rptHobbies" runat="server">
        <ItemTemplate>
          <div class="hobby-card reveal">
            <div class="hobby-card-glow"></div>
            <div class="hobby-card-top">
              <span class="hobby-card-index">// <%# string.Format("{0:D2}", Container.ItemIndex + 1) %></span>
              <span class="hobby-tag">PASSION</span>
            </div>
            <div class="hobby-card-main">
              <h3 class="hobby-card-title"><%# Server.HtmlEncode(Eval("HobbyName").ToString()) %></h3>
              <%# !string.IsNullOrWhiteSpace(Eval("HobbyDescription") as string) ? "<p class=\"hobby-card-desc\">" + Server.HtmlEncode(Eval("HobbyDescription").ToString()) + "</p>" : "<p class=\"hobby-card-desc placeholder-desc\">No description provided.</p>" %>
            </div>
            <div class="hobby-card-bottom">
              <div class="hobby-status">
                <span class="hobby-pulse-dot"></span>
                <span class="hobby-status-label">ACTIVE PURSUIT</span>
              </div>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
