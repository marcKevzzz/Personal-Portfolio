<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="HobbiesPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.HobbiesPanel" %>

<div class="admin-panel" data-panel="hobbies">
    <h2>Hobbies</h2>
    <p class="admin-sub">Personal interests and recreational tags displayed on the public page.</p>

    <div class="add-form">
        <div class="field" style="flex: 1; min-width: 200px;">
            <label>New Hobby Name</label>
            <div class="input-row">
                <asp:TextBox ID="txtHobbyName" runat="server" placeholder="e.g. Basketball, Reading Manhwa" />
            </div>
        </div>
        <div class="field" style="flex: 2; min-width: 250px;">
            <label>Hobby Description</label>
            <div class="input-row">
                <asp:TextBox ID="txtHobbyDescription" runat="server" placeholder="Describe what you enjoy about this hobby..." />
            </div>
        </div>
        <div style="display: flex; align-items: flex-end;">
            <asp:Button ID="btnAddHobby" runat="server" Text="Add Hobby" CssClass="btn btn-primary" OnClick="btnAddHobby_Click" data-confirm-title="Add Hobby" data-confirm-msg="Are you sure you want to add this hobby?" data-confirm-btn="Add Hobby" />
        </div>
    </div>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th>Hobby</th>
                    <th>Description</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptHobbiesTable" runat="server" OnItemCommand="rptHobbiesTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><strong><%# Eval("HobbyName") %></strong></td>
                            <td style="color: var(--text-mid); font-size: var(--t-xs);"><%# Eval("HobbyDescription") %></td>
                            <td>
                                <asp:LinkButton ID="btnDelete" runat="server" CssClass="danger" CommandName="DeleteHobby" CommandArgument='<%# Eval("HobbyId") %>' data-confirm-title="Remove Hobby" data-confirm-msg='<%# "Are you sure you want to remove \"" + Eval("HobbyName") + "\"?" %>' data-confirm-type="danger" data-confirm-btn="Remove">Remove</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
