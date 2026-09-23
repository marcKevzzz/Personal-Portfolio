<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ExperiencePanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ExperiencePanel" %>

<div class="admin-panel" data-panel="experience">
    <h2>Experience</h2>
    <p class="admin-sub">Professional roles, company positions, and technology tags.</p>

    <asp:HiddenField ID="hidEditingExpId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field ">
            <label>Role <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtExpRole" runat="server" placeholder="Front-End Developer" />
            </div>
        </div>
        <div class="field ">
            <label>Company <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtExpCompany" runat="server" placeholder="Samson Dental Center" />
            </div>
        </div>
        <div class="field ">
            <label>Year Started <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtExpStartYear" runat="server" placeholder="e.g. 2021" />
            </div>
        </div>
        <div class="field ">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <label style="margin: 0;">Year Ended</label>
                <label style="margin: 0; font-size: 11px; cursor: pointer; color: var(--blue-light); display: inline-flex; align-items: center; gap: 6px; font-weight: 500;">
                    <input type="checkbox" id="chkExpPresent" onchange="toggleExpPresent(this);" />
                    <span>Present</span>
                </label>
            </div>
            <div class="input-row">
                <asp:TextBox ID="txtExpEndYear" runat="server" placeholder="e.g. 2024 or Present" />
            </div>
        </div>
        <div class="field field-col-3">
            <label>Tags</label>
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
            <asp:Button ID="btnCancelExpEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelExpEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
        </div>
    </div>

    <script>
        function toggleExpPresent(chk) {
            var txt = document.getElementById('<%= txtExpEndYear.ClientID %>');
            if (!txt) return;
            if (chk.checked) {
                txt.value = 'Present';
            } else {
                if (txt.value.trim().toLowerCase() === 'present') {
                    txt.value = '';
                }
            }
        }
    </script>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th style="width: 180px;">Role</th>
                    <th style="width: 150px;">Company</th>
                    <th style="width: 130px;">Period</th>
                    <th>Description</th>
                    <th>Tags</th>
                    <th style="width: 150px;">Actions</th>
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
