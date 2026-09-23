<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TechStackPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.TechStackPanel" %>

<div class="admin-panel" data-panel="techstack">
    <h2>Tech Stack</h2>
    <p class="admin-sub">Grouped by category. Provide a tech label and paste raw SVG tag text to display the icon directly as an inline SVG tag.</p>

    <asp:HiddenField ID="hidEditingTechId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field">
            <label>Group / Category <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:DropDownList ID="ddlTechGroup" runat="server">
                    <asp:ListItem Text="Frontend" Value="Frontend" />
                    <asp:ListItem Text="3D & Motion" Value="3D & Motion" />
                    <asp:ListItem Text="Backend & Database" Value="Backend & Database" />
                    <asp:ListItem Text="Tools & DevOps" Value="Tools & DevOps" />
                </asp:DropDownList>
            </div>
        </div>
        <div class="field">
            <label>Tech Label (e.g. React, C#, HTML5) <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtTechLabel" runat="server" placeholder="e.g. React" />
            </div>
        </div>
        <div class="field">
            <label>SVG Tag Markup (Direct &lt;svg&gt; Tag) <span class="req-star">*</span></label>
            <div style="display: flex; gap: 10px; align-items: flex-start;">
                <div class="input-row" style="flex: 1;max-height: 33px">
                    <asp:TextBox ID="txtTechSvgCode" runat="server" ClientIDMode="Static" TextMode="MultiLine" Rows="1" CssClass="tech-svg-input" placeholder="<svg viewBox='0 0 24 24' ...>...</svg>" oninput="updateLiveTechSvgPreview(this.value);" />
                </div>
                <div id="techSvgPreviewBox" style="width: 33px; height: 33px; border: 1px solid var(--line); background: var(--bg-2); border-radius: 4px; display: flex; align-items: center; justify-content: center; overflow: hidden; flex-shrink: 0;" title="Live SVG Preview">
                    <span id="techSvgPreviewEmpty" style="font-size: 9px; color: var(--text-dim); text-transform: uppercase;">SVG</span>
                    <div id="techSvgPreviewContent" style="width: 100%; height: 100%; display: none; align-items: center; justify-content: center; padding: 4px;"></div>
                </div>
            </div>
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddTech" runat="server" Text="Add Tech Item" CssClass="btn btn-primary" OnClick="btnAddTech_Click" data-confirm-title="Add Tech Stack" data-confirm-msg="Are you sure you want to add this technology to your stack?" data-confirm-btn="Add Item" />
            <asp:Button ID="btnCancelTechEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelTechEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
        </div>
    </div>

    <script>
        function updateLiveTechSvgPreview(svgStr) {
            var box = document.getElementById('techSvgPreviewContent');
            var empty = document.getElementById('techSvgPreviewEmpty');
            if (!box || !empty) return;
            svgStr = (svgStr || '').trim();
            if (svgStr.startsWith('base64:')) {
                try {
                    svgStr = decodeURIComponent(escape(atob(svgStr.substring(7))));
                } catch(e) {}
            }
            var sIdx = svgStr.toLowerCase().indexOf('<svg');
            if (sIdx >= 0) {
                var eIdx = svgStr.toLowerCase().lastIndexOf('</svg>');
                var cleanSvg = (eIdx > sIdx) ? svgStr.substring(sIdx, eIdx + 6) : svgStr.substring(sIdx);
                box.innerHTML = cleanSvg;
                var svgEl = box.querySelector('svg');
                if (svgEl) {
                    svgEl.style.width = '100%';
                    svgEl.style.height = '100%';
                    svgEl.style.maxWidth = '24px';
                    svgEl.style.maxHeight = '24px';
                    svgEl.style.display = 'block';
                }
                box.style.display = 'flex';
                empty.style.display = 'none';
            } else {
                box.innerHTML = '';
                box.style.display = 'none';
                empty.style.display = 'block';
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            var txt = document.getElementById('txtTechSvgCode');
            if (txt && txt.value) {
                updateLiveTechSvgPreview(txt.value);
            }
        });
    </script>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th style="width: 60px;">Icon</th>
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
                                    <%# RenderTechTableIcon(Eval("IconPath"), Eval("Label")) %>
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
