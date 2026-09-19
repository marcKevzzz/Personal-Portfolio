<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ProjectsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ProjectsPanel" %>

<div class="admin-panel" data-panel="projects">
    <h2>Projects</h2>
    <p class="admin-sub">Manage portfolio showcase projects, live URLs, and technology tags.</p>

    <asp:HiddenField ID="hidEditingProjectId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field">
            <label>Project Title</label>
            <div class="input-row">
                <asp:TextBox ID="txtProjectTitle" runat="server" placeholder="e.g. Samson Dental Center" />
            </div>
        </div>
        <div class="field">
            <label>Project Image &amp; Preview</label>
            <div style="display: flex; gap: 10px; align-items: center;">
                <div class="input-row" style="flex: 1; border: none;">
                    <asp:FileUpload ID="fuProjectImage" runat="server" accept="image/*" CssClass="admin-file-input" />
                    <asp:HiddenField ID="hidExistingImagePath" runat="server" Value="" />
                </div>
                <div id="projectImgPreviewBox" runat="server" style="width: 52px; height: 32px; border: 1px solid var(--line); background: var(--bg-2); flex: none; display: none; align-items: center; justify-content: center; overflow: hidden; border-radius: 3px;">
                    <img id="projectFormImgPreview" runat="server" src="/Assets/Images/samsondentalcenter.png" style="width: 100%; height: 100%; object-fit: cover;" onerror="this.src='/Assets/Images/samsondentalcenter.png';" alt="Preview" />
                </div>
            </div>
        </div>
        <div class="field">
            <label>Project URL / GitHub Repo</label>
            <div class="input-row">
                <asp:TextBox ID="txtProjectUrl" runat="server" placeholder="https://github.com/marcKevzzz/..." />
            </div>
        </div>
        <div class="field" style="grid-column: 1 / -1;">
            <label>Technology Tags (Hit Enter or comma to add)</label>
            <div class="chips-container" id="projectTagChips" data-input-target="hidProjectTags">
                <asp:Literal ID="litProjectChips" runat="server" />
                <input type="text" class="chip-input" placeholder="Type tag & hit Enter..." />
            </div>
            <asp:HiddenField ID="hidProjectTags" runat="server" ClientIDMode="Static" Value="HTML5,CSS3,JavaScript" />
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddProject" runat="server" Text="Add Project" CssClass="btn btn-primary" OnClick="btnAddProject_Click" data-confirm-title="Add Project" data-confirm-msg="Are you sure you want to add this project?" data-confirm-btn="Add Project" />
            <asp:Button ID="btnCancelProjectEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelProjectEdit_Click" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th style="width: 70px; text-align: center;">Image</th>
                    <th>Title</th>
                    <th>URL</th>
                    <th>Tags</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptProjectsTable" runat="server" OnItemCommand="rptProjectsTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td style="text-align: center;">
                                <img src='<%# ResolveUrl("~/" + ((string)Eval("ImagePath")).TrimStart('~', '/')) %>' class="project-table-thumb" style="margin: 0 auto;" alt="Project Screenshot" title='<%# Eval("ImagePath") %>' onerror="this.src='/Assets/Images/samsondentalcenter.png';" />
                            </td>
                            <td><strong><%# Eval("Title") %></strong></td>
                            <td>
                                <%# !string.IsNullOrWhiteSpace((string)Eval("ProjectUrl")) 
                                    ? "<a href=\"" + Eval("ProjectUrl") + "\" target=\"_blank\" rel=\"noopener noreferrer\" style=\"color: inherit; text-decoration: underline; text-underline-offset: 3px; word-break: break-all;\" title=\"Open URL\">" + Server.HtmlEncode((string)Eval("ProjectUrl")) + "</a>" 
                                    : "<span style=\"color: var(--muted);\">-</span>" %>
                            </td>
                            <td><%# Eval("Tags") %></td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditProject" CommandArgument='<%# Eval("ProjectId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteProject" CommandArgument='<%# Eval("ProjectId") %>' data-confirm-title="Delete Project" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("Title") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
