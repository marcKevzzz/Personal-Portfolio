<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SkillsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.SkillsPanel" %>

<div class="admin-panel" data-panel="skills">
    <h2>Skills</h2>
    <p class="admin-sub">Manage technical competencies and proficiency percentage values (0–100%) matching the public portfolio landing page.</p>

    <asp:HiddenField ID="hidEditingSkillId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field field-col-3" style="flex: 2;">
            <label>Skill Name <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtSkillName" runat="server" placeholder="e.g. Frontend Development" />
            </div>
        </div>
        <div class="field field-col-3" style="flex: 1;">
            <label>Proficiency Percentage (0–100%) <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtProficiencyVal" runat="server" TextMode="Number" min="0" max="100" placeholder="e.g. 85" />
            </div>
        </div>
        <div class=" field-col-3" style="display: flex; gap: 12px; align-items: center; margin-top: auto;">
            <asp:Button ID="btnAddSkill" runat="server" Text="Add Skill" CssClass="btn btn-primary" OnClick="btnAddSkill_Click" data-confirm-title="Add Skill" data-confirm-msg="Are you sure you want to add this skill?" data-confirm-btn="Add Skill" />
            <asp:Button ID="btnCancelSkillEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelSkillEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th>Skill Name</th>
                    <th>Proficiency</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptSkillsTable" runat="server" OnItemCommand="rptSkillsTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><strong><%# Eval("SkillName") %></strong></td>
                            <td>
                                <div class="admin-skill-cell">
                                    <div class="admin-skill-bar-wrap">
                                        <div class="admin-skill-fill" style='<%# "width:" + Eval("ProficiencyVal") + "%;" %>'></div>
                                    </div>
                                    <span class="admin-skill-pct"><%# Eval("ProficiencyVal") %>%</span>
                                </div>
                            </td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditSkill" CommandArgument='<%# Eval("SkillId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteSkill" CommandArgument='<%# Eval("SkillId") %>' data-confirm-title="Delete Skill" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("SkillName") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
