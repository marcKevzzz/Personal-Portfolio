<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AwardsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.AwardsPanel" %>

<div class="admin-panel" data-panel="awards">
    <h2>Awards &amp; Recognitions</h2>
    <p class="admin-sub">Competitions, certificates, achievements, and milestones.</p>

    <asp:HiddenField ID="hidEditingAwardId" runat="server" Value="0" />

    <div class="add-form">
        <div class="field">
            <label>Year <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardYear" runat="server" TextMode="Number" min="1950" max="2100" placeholder="e.g. 2026" />
            </div>
        </div>
        <div class="field">
            <label>Award / Competition Title <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardTitle" runat="server" placeholder="DevCup 2026" />
            </div>
        </div>
        <div class="field">
            <label>Subtitle / Recognition</label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardSubtitle" runat="server" placeholder="2nd Place QCU" />
            </div>
        </div>
        <div class="field">
            <label>Issuing Organization <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtAwardOrg" runat="server" placeholder="Quezon City University" />
            </div>
        </div>
        <div style="grid-column: 1 / -1; display: flex; gap: 12px; align-items: center;">
            <asp:Button ID="btnAddAward" runat="server" Text="Add Award" CssClass="btn btn-primary" OnClick="btnAddAward_Click" data-confirm-title="Add Award" data-confirm-msg="Are you sure you want to add this award / certificate?" data-confirm-btn="Add Award" />
            <asp:Button ID="btnCancelAwardEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelAwardEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
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
