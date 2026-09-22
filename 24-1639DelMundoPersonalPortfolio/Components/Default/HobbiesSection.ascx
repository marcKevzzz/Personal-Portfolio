<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.HobbiesSection" %>

<!-- ============================================================ HOBBIES -->
<section id="hobbies">
  <div class="wrap">
    <div class="field-label reveal">08 / HOBBIES</div>
    <h2 class="section-title reveal">Off the clock</h2>
 
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="section-empty-state">
      <span>No hobbies added yet.</span>
    </asp:Panel>
    <div class="hobby-cards-grid" id="hobbiesList" runat="server">
      <asp:Repeater ID="rptHobbies" runat="server">
        <ItemTemplate>
          <div class="hobby-card reveal">
            <div class="hobby-card-title"><%# Server.HtmlEncode(Eval("HobbyName").ToString()) %></div>
            <%# !string.IsNullOrWhiteSpace(Eval("HobbyDescription") as string) ? "<div class=\"hobby-card-desc\">" + Server.HtmlEncode(Eval("HobbyDescription").ToString()) + "</div>" : "" %>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
