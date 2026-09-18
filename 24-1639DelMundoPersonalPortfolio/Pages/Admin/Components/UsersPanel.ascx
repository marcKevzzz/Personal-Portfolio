<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.UsersPanel" %>

<div class="admin-panel" data-panel="users">
    <h2>User Management</h2>
    <p class="admin-sub">Registered accounts. Deactivating prevents sign-in while preserving user records.</p>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Role</th>
                    <th>Status</th>
                    <th>Joined</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptUsersTable" runat="server" OnItemCommand="rptUsersTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td><strong><%# Server.HtmlEncode((string)Eval("FirstName") + " " + (string)Eval("LastName")) %></strong></td>
                            <td><%# Server.HtmlEncode((string)Eval("Email")) %></td>
                            <td><%# Server.HtmlEncode((string)Eval("Role")) %></td>
                            <td>
                                <span class='<%# ((bool)Eval("IsActive")) ? "status-pill active" : "status-pill inactive" %>'>
                                    <%# ((bool)Eval("IsActive")) ? "ACTIVE" : "DEACTIVATED" %>
                                </span>
                            </td>
                            <td><%# ((DateTime)Eval("CreatedAt")).ToString("MMM d, yyyy") %></td>
                            <td>
                                <asp:LinkButton ID="btnToggleStatus" runat="server" 
                                    CssClass='<%# ((bool)Eval("IsActive")) ? "danger" : "" %>' 
                                    CommandName="ToggleStatus" 
                                    CommandArgument='<%# Eval("UserId") + "|" + Eval("IsActive") %>'
                                    data-confirm-title='<%# ((bool)Eval("IsActive")) ? "Deactivate User" : "Reactivate User" %>'
                                    data-confirm-msg='<%# ((bool)Eval("IsActive")) ? "Are you sure you want to deactivate " + Eval("FirstName") + "? They will be unable to log in." : "Restore sign-in access for " + Eval("FirstName") + "?" %>'
                                    data-confirm-type='<%# ((bool)Eval("IsActive")) ? "danger" : "primary" %>'
                                    data-confirm-btn='<%# ((bool)Eval("IsActive")) ? "Deactivate" : "Reactivate" %>'>
                                    <%# ((bool)Eval("IsActive")) ? "Deactivate" : "Reactivate" %>
                                </asp:LinkButton>
                                &nbsp;|&nbsp;
                                <asp:LinkButton ID="btnDeleteUser" runat="server" CssClass="danger" CommandName="DeleteUser" CommandArgument='<%# Eval("UserId") %>'
                                    data-confirm-title="Delete User"
                                    data-confirm-msg='<%# "Are you sure you want to permanently delete user " + Eval("FirstName") + " " + Eval("LastName") + "? This action cannot be undone." %>'
                                    data-confirm-type="danger"
                                    data-confirm-btn="Delete">
                                    Delete
                                </asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>
