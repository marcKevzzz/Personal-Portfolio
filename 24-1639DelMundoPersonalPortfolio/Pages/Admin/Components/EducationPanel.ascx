<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EducationPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.EducationPanel" %>

<div class="admin-panel" data-panel="education">
    <h2>Education</h2>
    <p class="admin-sub">Academic degrees, qualifications, and educational institutions.</p>

    <asp:HiddenField ID="hidEditingEduId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field">
            <label>Year Started</label>
            <div class="input-row">
                <asp:TextBox ID="txtEduStartYear" runat="server" TextMode="Number" min="1950" max="2100" placeholder="e.g. 2020" />
            </div>
        </div>
        <div class="field">
            <label>Year Ended</label>
            <div class="input-row">
                <asp:TextBox ID="txtEduEndYear" runat="server" TextMode="Number" min="1950" max="2100" placeholder="e.g. 2024" />
            </div>
            <label style="display: flex; align-items: center; gap: 6px; margin-top: 6px; cursor: pointer; font-size: var(--t-xs); color: var(--text-mid);">
                <asp:CheckBox ID="chkEduIsCurrent" runat="server" />
                <span>Present / Ongoing</span>
            </label>
        </div>
        <div class="field">
            <label>Degree / Level</label>
            <div class="input-row">
                <asp:TextBox ID="txtEduTitle" runat="server" placeholder="Collegiate Level" />
            </div>
        </div>
        <div class="field">
            <label>Course / Major</label>
            <div class="input-row">
                <asp:TextBox ID="txtEduSubtitle" runat="server" placeholder="B.S. Information Technology" />
            </div>
        </div>
        <div class="field">
            <label>Institution Name</label>
            <div class="input-row">
                <asp:TextBox ID="txtEduInstitution" runat="server" placeholder="Quezon City University" />
            </div>
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddEducation" runat="server" Text="Add Education" CssClass="btn btn-primary" OnClick="btnAddEducation_Click" data-confirm-title="Add Education" data-confirm-msg="Are you sure you want to add this education milestone?" data-confirm-btn="Add Education" />
            <asp:Button ID="btnCancelEduEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelEduEdit_Click" />
        </div>
    </div>

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
