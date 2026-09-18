<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TechStackPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.TechStackPanel" %>

<div class="admin-panel" data-panel="techstack">
    <h2>Tech Stack</h2>
    <p class="admin-sub">Grouped by category. Provide a tech label and paste raw SVG tag text to automatically save and link the icon.</p>

    <asp:HiddenField ID="hidEditingTechId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field" style="flex: 1;">
            <label>Group / Category</label>
            <div class="input-row">
                <asp:DropDownList ID="ddlTechGroup" runat="server">
                    <asp:ListItem Text="Frontend" Value="Frontend" />
                    <asp:ListItem Text="3D & Motion" Value="3D & Motion" />
                    <asp:ListItem Text="Backend & Database" Value="Backend & Database" />
                    <asp:ListItem Text="Tools & DevOps" Value="Tools & DevOps" />
                </asp:DropDownList>
            </div>
        </div>
        <div class="field" style="flex: 2;">
            <label>Tech Label (e.g. React, C#, HTML5)</label>
            <div class="input-row">
                <asp:TextBox ID="txtTechLabel" runat="server" placeholder="e.g. React" required="required" />
            </div>
        </div>
        <div class="field full" style="grid-column: 1 / -1;">
            <label>Paste SVG Tag Text (Optional — Auto-saved as SVG in Assets/Icons)</label>
            <asp:TextBox ID="txtTechSvgCode" runat="server" TextMode="MultiLine" Rows="2" placeholder="<svg viewBox='0 0 24 24' ...>...</svg>" />
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddTech" runat="server" Text="Add Tech Item" CssClass="btn btn-primary" OnClick="btnAddTech_Click" data-confirm-title="Add Tech Stack" data-confirm-msg="Are you sure you want to add this technology to your stack?" data-confirm-btn="Add Item" />
            <asp:Button ID="btnCancelTechEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelTechEdit_Click" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th style="width: 50px;">Icon</th>
                    <th>Label</th>
                    <th>Group</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptTechTable" runat="server" OnItemCommand="rptTechTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td>
                                <div class="tech-table-icon-wrap">
                                    <img src='<%# ResolveUrl("~/" + ((string)Eval("IconPath")).TrimStart('~', '/')) %>' alt='<%# Eval("Label") %>' class="tech-table-icon" onerror="this.src='../../Assets/Icons/csharp.svg';" />
                                </div>
                            </td>
                            <td><strong><%# Eval("Label") %></strong></td>
                            <td><%# Eval("GroupName") %></td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditTech" CommandArgument='<%# Eval("TechId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteTech" CommandArgument='<%# Eval("TechId") %>' data-confirm-title="Delete Technology" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("Label") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
