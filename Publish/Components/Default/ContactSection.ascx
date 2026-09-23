<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ContactSection.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Components.Default.ContactSection" %>

<!-- ============================================================ CONTACT -->
<section id="contact">
  <div class="wrap">
    <div class="field-label reveal">09 / CONTACT</div>
    <h2 class="contact-cta reveal">Let's build<br>something <span class="accent">structured</span>.</h2>
 
    <div class="contact-links" id="contactLinksContainer" runat="server">
      <asp:Repeater ID="rptContacts" runat="server">
        <ItemTemplate>
          <a href='<%# Eval("ComputedUrl") %>' class="reveal contact-channel-link" <%# (Eval("Platform") != null && (Eval("Platform").ToString().Equals("email", StringComparison.OrdinalIgnoreCase) || Eval("Platform").ToString().Equals("phone", StringComparison.OrdinalIgnoreCase))) ? "" : "target=\"_blank\" rel=\"noopener noreferrer\"" %>>[ <%# Eval("DisplayLabel") %> ]</a>
        </ItemTemplate>
      </asp:Repeater>

      <asp:Literal ID="litContactsEmpty" runat="server" Visible="false">
        <span class="reveal" style="font-size: var(--t-sm);color: var(--text-mid);padding: 14px 0;margin-right: 32px;border-bottom: 1px solid var(--line);transition: color .2s ease, border-color .2s ease;">[ No contact channels added yet ]</span>
      </asp:Literal>

      <!-- Legacy controls maintained for complete backward compatibility -->
      <asp:HyperLink ID="contactEmailLink" runat="server" ClientIDMode="Static" CssClass="reveal" Visible="false">[ Email ]</asp:HyperLink>
      <asp:Literal ID="litEmailEmpty" runat="server" Visible="false"></asp:Literal>
      <asp:HyperLink ID="contactGithubLink" runat="server" ClientIDMode="Static" CssClass="reveal" Target="_blank" rel="noopener noreferrer" Visible="false">[ Github ]</asp:HyperLink>
      <asp:Literal ID="litGithubEmpty" runat="server" Visible="false"></asp:Literal>
      <asp:HyperLink ID="contactLinkedinLink" runat="server" ClientIDMode="Static" CssClass="reveal" Target="_blank" rel="noopener noreferrer" Visible="false">[ LinkedIn ]</asp:HyperLink>
      <asp:Literal ID="litLinkedinEmpty" runat="server" Visible="false"></asp:Literal>
    </div>
  </div>
</section>
 
<footer>
  <div class="wrap" style="display:flex; justify-content:space-between; width:100%;">
    <a href="https://github.com/marcKevzzz/Personal-Portfolio/" style="text-decoration:none !important; color:inherit; cursor:pointer;" title="Admin Console">KEVS &mdash; 2026</a>
    <a href="<%= ResolveUrl("~/Pages/Admin/Admin.aspx") %>" style="text-decoration:none !important; color:inherit; cursor:pointer;" title="Admin Console">BUILT WITH GEIST</a>
  </div>
</footer>
