<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AwardsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AwardsPanel" %>

<div class="admin-panel" data-panel="awards">
    <h2>Awards &amp; Recognitions</h2>
    <p class="admin-sub">Competitions, certificates, achievements, and milestones.</p>

    <asp:HiddenField ID="hidEditingAwardId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field">
            <label>Year / Date</label>
            <div class="input-date-wrap">
                <asp:TextBox ID="txtAwardYear" runat="server" CssClass="date-picker" placeholder="e.g. 2026" required="required" />
                <svg class="input-date-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                    <line x1="16" y1="2" x2="16" y2="6"></line>
                    <line x1="8" y1="2" x2="8" y2="6"></line>
                    <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
            </div>
        </div>
        <div class="field">
            <label>Award / Competition Title</label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardTitle" runat="server" placeholder="DevCup 2026" required="required" />
            </div>
        </div>
        <div class="field">
            <label>Subtitle / Recognition</label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardSubtitle" runat="server" placeholder="2nd Place QCU" />
            </div>
        </div>
        <div class="field">
            <label>Issuing Organization</label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardOrg" runat="server" placeholder="Quezon City University" required="required" />
            </div>
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddAward" runat="server" Text="Add Award" CssClass="btn btn-primary" OnClick="btnAddAward_Click" data-confirm-title="Add Award" data-confirm-msg="Are you sure you want to add this award / certificate?" data-confirm-btn="Add Award" />
            <asp:Button ID="btnCancelAwardEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelAwardEdit_Click" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th>Year</th>
                    <th>Title</th>
                    <th>Subtitle</th>
                    <th>Organization</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptAwardsTable" runat="server" OnItemCommand="rptAwardsTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><%# Eval("AwardYear") %></td>
                            <td><strong><%# Eval("Title") %></strong></td>
                            <td><%# Eval("Subtitle") %></td>
                            <td><%# Eval("OrganizationName") %></td>
                            <td>
                                <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditAward" CommandArgument='<%# Eval("AwardId") %>'>Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteAward" CommandArgument='<%# Eval("AwardId") %>' data-confirm-title="Delete Award" data-confirm-msg='<%# "Are you sure you want to delete \"" + Eval("Title") + "\"? This action cannot be undone." %>' data-confirm-type="danger" data-confirm-btn="Delete">Delete</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
