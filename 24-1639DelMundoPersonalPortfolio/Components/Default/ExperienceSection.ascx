<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ExperienceSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.ExperienceSection" %>

<!-- ============================================================ EXPERIENCE -->
<section id="experience">
  <div class="wrap">
    <div class="field-label reveal">04 / EXPERIENCE</div>
    <h2 class="section-title reveal">Where I've worked</h2>

    <div class="exp-list" id="expList">
      <asp:Repeater ID="rptExperiences" runat="server" OnItemDataBound="rptExperiences_ItemDataBound">
        <ItemTemplate>
          <div class="exp-card reveal">
            <div class="exp-header">
              <div class="exp-role-group">
                <h3 class="exp-role"><%# Server.HtmlEncode(Eval("RoleTitle").ToString()) %></h3>
                <span class="exp-company"><%# Server.HtmlEncode(Eval("CompanyName").ToString()) %></span>
              </div>
              <span class="exp-period"><%# Server.HtmlEncode(Eval("PeriodRange").ToString()) %></span>
            </div>
            <asp:PlaceHolder ID="phDesc" runat="server">
              <p class="exp-desc"><asp:Literal ID="litDesc" runat="server" /></p>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phTags" runat="server">
              <div class="exp-tags">
                <asp:Repeater ID="rptTags" runat="server">
                  <ItemTemplate>
                    <span><%# Server.HtmlEncode(Container.DataItem.ToString()) %></span>
                  </ItemTemplate>
                </asp:Repeater>
              </div>
            </asp:PlaceHolder>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
