<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TechStackSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.TechStackSection" %>

<!-- ============================================================ TECH STACK -->
<section id="stack">
  <div class="wrap">
    <div class="field-label reveal">02 / TECH STACK</div>
    <h2 class="section-title reveal">What I build with</h2>
  </div>

  <div class="wrap">
    <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="section-empty-state">
      <span>No tech stack added yet.</span>
    </asp:Panel>
    <div class="stack-groups" id="techStackGroups" runat="server">
      <asp:Repeater ID="rptGroups" runat="server" OnItemDataBound="rptGroups_ItemDataBound">
        <ItemTemplate>
          <div class="stack-group reveal">
            <div class="stack-group-head">
              <h4><%# Server.HtmlEncode(Eval("Key").ToString()) %></h4>
            </div>
            <div class="tech-icons-grid">
              <asp:Repeater ID="rptIcons" runat="server">
                <ItemTemplate>
                  <div class="tech-card" data-label="<%# Server.HtmlEncode(Eval("Label").ToString()) %>" title="<%# Server.HtmlEncode(Eval("Label").ToString()) %>">
                    <%# RenderInlineSvg(Eval("IconPath"), Eval("Label")) %>
                  </div>
                </ItemTemplate>
              </asp:Repeater>
            </div>
          </div>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
