<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProjectsSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.ProjectsSection" %>

<!-- ============================================================ PROJECTS -->
<section id="projects">
  <div class="wrap">
    <div class="field-label reveal">05 / PROJECTS</div>
    <h2 class="section-title reveal">Selected work</h2>
  </div>
 
  <div class="wrap">
    <div class="bento" id="projectsBento">
      <asp:Repeater ID="rptProjects" runat="server" OnItemDataBound="rptProjects_ItemDataBound">
        <ItemTemplate>
          <asp:HyperLink ID="lnkProject" runat="server" Target="_blank" rel="noopener noreferrer">
            <div class="tile-thumb">
              <asp:Image ID="imgThumb" runat="server" />
            </div>
            <span class="tile-num"><asp:Literal ID="litNum" runat="server" /></span>
            <div class="tile-arrow" title="Open repository in new tab">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <line x1="7" y1="17" x2="17" y2="7"></line>
                <polyline points="7 7 17 7 17 17"></polyline>
              </svg>
            </div>
            <div class="tile-content">
              <div class="tile-body-top">
                <h3><asp:Literal ID="litTitle" runat="server" /></h3>
              </div>
              <div class="tile-meta">
                <asp:Repeater ID="rptTags" runat="server">
                  <ItemTemplate>
                    <span><%# Server.HtmlEncode(Container.DataItem.ToString()) %></span>
                  </ItemTemplate>
                </asp:Repeater>
              </div>
            </div>
          </asp:HyperLink>
        </ItemTemplate>
      </asp:Repeater>
    </div>
  </div>
</section>
