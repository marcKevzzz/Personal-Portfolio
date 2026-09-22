<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ExperiencePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ExperiencePanel" %>

<div class="admin-panel" data-panel="experience">
    <h2>Experience</h2>
    <p class="admin-sub">Professional roles, company positions, and technology tags.</p>

    <asp:HiddenField ID="hidEditingExpId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field ">
            <label>Role</label>
            <div class="input-row">
                <asp:TextBox ID="txtExpRole" runat="server" placeholder="Front-End Developer" />
            </div>
        </div>
        <div class="field ">
            <label>Company</label>
            <div class="input-row">
                <asp:TextBox ID="txtExpCompany" runat="server" placeholder="Samson Dental Center" />
            </div>
        </div>
        <div class="field ">
            <label>Year Started</label>
            <div class="input-row">
                <asp:TextBox ID="txtExpStartYear" runat="server" TextMode="Number" min="1950" max="2100" placeholder="e.g. 2021" />
            </div>
        </div>
        <div class="field ">
            <label>Year Ended</label>
            <div class="input-row">
                <asp:TextBox ID="txtExpEndYear" runat="server" TextMode="Number" min="1950" max="2100" placeholder="e.g. 2024" />
            </div>
        </div>
        <div class="field field-col-3">
            <label>Tags (Hit Enter or comma to add)</label>
            <div class="chips-container" id="expTagChips" data-input-target="hidExpTags">
                <asp:Literal ID="litExpChips" runat="server" />
                <input type="text" class="chip-input" placeholder="Type tag & hit Enter..." />
            </div>
            <asp:HiddenField ID="hidExpTags" runat="server" ClientIDMode="Static" Value="React,Tailwind CSS" />
        </div>
        <div class="field field-col-3">
            <label>Description</label>
            <asp:TextBox ID="txtExpDescription" runat="server" TextMode="MultiLine" Rows="3" placeholder="Describe responsibilities and impact..." />
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddExp" runat="server" Text="Add Experience" CssClass="btn btn-primary" OnClick="btnAddExp_Click" data-confirm-title="Add Experience" data-confirm-msg="Are you sure you want to add this experience record?" data-confirm-btn="Add Experience" />
            <asp:Button ID="btnCancelExpEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelExpEdit_Click" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th>Role</th>
                    <th>Company</th>
                    <th>Period</th>
                    <th>Description</th>
                    <th>Tags</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptExpTable" runat="server" OnItemCommand="rptExpTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><strong><%# Eval("RoleTitle") %></strong></td>
                            <td><%# Eval("CompanyName") %></td>
                            <td><%# Eval("PeriodRange") %></td>
                            <td><%# Eval("DescriptionText") %></td>
                            <td><%# Eval("Tags") %></td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditExp" CommandArgument='<%# Eval("ExpId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteExp" CommandArgument='<%# Eval("ExpId") %>' data-confirm-title="Delete Experience" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("RoleTitle") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
