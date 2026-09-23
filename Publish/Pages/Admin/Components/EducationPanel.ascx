<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.EducationPanel" %>

<div class="admin-panel" data-panel="education">
    <h2>Education</h2>
    <p class="admin-sub">Academic degrees, qualifications, and educational institutions.</p>

    <asp:HiddenField ID="hidEditingEduId" runat="server" Value="0" />

    <div class="add-form three-col">
        <div class="field">
            <label>Year Started <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtEduStartYear" runat="server" placeholder="e.g. 2020" />
            </div>
        </div>
        <div class="field">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <label style="margin: 0;">Year Ended</label>
                <label style="margin: 0; font-size: 11px; cursor: pointer; color: var(--blue-light); display: inline-flex; align-items: center; gap: 6px; font-weight: 500;">
                    <input type="checkbox" id="chkEduPresent" onchange="toggleEduPresent(this);" />
                    <span>Present</span>
                </label>
            </div>
            <div class="input-row">
                <asp:TextBox ID="txtEduEndYear" runat="server" placeholder="e.g. 2024 or Present" />
            </div>
        </div>
        <div class="field">
            <label>Degree / Level <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtEduTitle" runat="server" placeholder="Collegiate Level" />
            </div>
        </div>
        <div class="field">
            <label>Course / Major <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtEduSubtitle" runat="server" placeholder="B.S. Information Technology" />
            </div>
        </div>
        <div class="field">
            <label>Institution Name <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtEduInstitution" runat="server" placeholder="Quezon City University" />
            </div>
        </div>
        <div class="field" style="display: flex; gap: 12px; align-items: flex-start; margin-top: auto; padding-bottom: 2px;">
            <asp:Button ID="btnAddEducation" runat="server" Text="Add Education" CssClass="btn btn-primary" OnClick="btnAddEducation_Click" data-confirm-title="Add Education" data-confirm-msg="Are you sure you want to add this education milestone?" data-confirm-btn="Add Education" />
            <asp:Button ID="btnCancelEduEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelEduEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
        </div>
    </div>

    <script>
        function toggleEduPresent(chk) {
            var txt = document.getElementById('<%= txtEduEndYear.ClientID %>');
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
                    <th>Year / Period</th>
                    <th>Degree / Level</th>
                    <th>Course / Major</th>
                    <th>Institution</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptEduTable" runat="server" OnItemCommand="rptEduTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><%# Eval("YearPeriod") %></td>
                            <td><strong><%# Eval("Title") %></strong></td>
                            <td><%# Eval("Subtitle") %></td>
                            <td><%# Eval("InstitutionName") %></td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditEdu" CommandArgument='<%# Eval("EduId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteEdu" CommandArgument='<%# Eval("EduId") %>' data-confirm-title="Delete Education" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("Title") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
