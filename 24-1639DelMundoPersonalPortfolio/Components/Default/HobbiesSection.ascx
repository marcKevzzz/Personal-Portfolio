<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.HobbiesSection" %>

<!-- ============================================================ HOBBIES -->
<section id="hobbies">
  <div class="wrap">
    <div class="field-label reveal">08 / HOBBIES</div>
    <h2 class="section-title reveal">Off the clock</h2>
 
    <div class="chip-row" id="hobbiesList">
      <asp:Repeater ID="rptHobbies" runat="server">
        <ItemTemplate>
          <span class="chip real reveal"><%# Server.HtmlEncode(Eval("HobbyName").ToString()) %></span>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
