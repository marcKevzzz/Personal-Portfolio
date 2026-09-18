<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.UsersPanel" %>

<div class="admin-panel" data-panel="users">
    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; gap: 16px; flex-wrap: wrap;">
        <div>
            <h2 style="margin: 0 0 6px 0;">User Management</h2>
            <p class="admin-sub" style="margin: 0;">Registered accounts. Deactivating prevents sign-in while preserving user records.</p>
        </div>
        <asp:LinkButton ID="btnRefreshUsers" runat="server" CssClass="btn btn-secondary" OnClick="btnRefreshUsers_Click" ToolTip="Reload all users and reset requests from database" style="display: inline-flex; align-items: center; gap: 8px; padding: 10px 18px; font-size: var(--t-xs);">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="23 4 23 10 17 10"></polyline>
                <polyline points="1 20 1 14 7 14"></polyline>
                <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
            </svg>
            <span>Refresh</span>
        </asp:LinkButton>
    </div>

    <div style="margin-bottom: 32px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; gap: 12px; flex-wrap: wrap;">
            <div style="display: flex; align-items: center; gap: 12px;">
                <h3 style="font-family: var(--f-display); font-size: var(--t-md); font-weight: 500; color: var(--blue-light); margin: 0;">
                    PASSWORD RESET REQUESTS
                </h3>
                <asp:Label ID="lblPendingRequestsCount" runat="server" CssClass="status-pill active" Visible="false" />
            </div>
            <asp:LinkButton ID="btnRefreshResetRequests" runat="server" CssClass="btn btn-secondary" OnClick="btnRefreshResetRequests_Click" ToolTip="Reload password reset requests from database" style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; font-size: var(--t-xs);">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="23 4 23 10 17 10"></polyline>
                    <polyline points="1 20 1 14 7 14"></polyline>
                    <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
                </svg>
                <span>Refresh Requests</span>
            </asp:LinkButton>
        </div>
        <p class="admin-sub" style="margin-bottom: 16px;">Review account password removal requests submitted by users.</p>

        <div class="data-table-wrap">
            <asp:Panel ID="pnlNoRequests" runat="server" Visible="false" style="padding: 20px; text-align: center; color: var(--text-dim); background: var(--bg-1); border: 1px solid var(--line);">
                <span>No password reset requests found.</span>
            </asp:Panel>
            <asp:Repeater ID="rptResetRequests" runat="server" OnItemCommand="rptResetRequests_ItemCommand">
                <HeaderTemplate>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th style="width: 40px; text-align: center;">#</th>
                                <th>User / Email</th>
                                <th>Reason / Note</th>
                                <th>Status</th>
                                <th>Requested</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                        <td>
                            <strong><%# Server.HtmlEncode((string)Eval("UserName")) %></strong>
                            <div style="font-size: var(--t-xs); color: var(--text-dim);"><%# Server.HtmlEncode((string)Eval("Email")) %></div>
                        </td>
                        <td style="max-width: 250px; word-break: break-word;"><%# Server.HtmlEncode((string)Eval("Reason")) %></td>
                        <td>
                            <span class='<%# GetStatusBadgeClass((string)Eval("Status")) %>'>
                                <%# ((string)Eval("Status")).ToUpper() %>
                            </span>
                        </td>
                        <td><%# ((DateTime)Eval("CreatedAt")).ToString("MMM d, yyyy h:mm tt") %></td>
                        <td>
                            <asp:PlaceHolder ID="phPendingActions" runat="server" Visible='<%# ((string)Eval("Status")).Trim().ToLowerInvariant() == "pending" %>'>
                                <asp:LinkButton ID="btnApproveReset" runat="server" 
                                    CommandName="ApproveReset" 
                                    CommandArgument='<%# Eval("ResetId") %>'
                                    data-confirm-title="Approve Password Reset"
                                    data-confirm-msg='<%# "Approve password reset for " + Eval("Email") + "? Their password will be removed so they can create a new one." %>'
                                    data-confirm-type="primary"
                                    data-confirm-btn="Approve &amp; Remove">
                                    Approve (Remove Password)
                                </asp:LinkButton>
                                &nbsp;|&nbsp;
                                <asp:LinkButton ID="btnRejectReset" runat="server" CssClass="danger"
                                    CommandName="RejectReset" 
                                    CommandArgument='<%# Eval("ResetId") %>'
                                    data-confirm-title="Dismiss Request"
                                    data-confirm-msg='<%# "Dismiss password reset request for " + Eval("Email") + "?" %>'
                                    data-confirm-type="danger"
                                    data-confirm-btn="Dismiss">
                                    Dismiss
                                </asp:LinkButton>
                            </asp:PlaceHolder>
                            <asp:PlaceHolder ID="phResolvedState" runat="server" Visible='<%# ((string)Eval("Status")).Trim().ToLowerInvariant() != "pending" %>'>
                                <span style="font-size: var(--t-xs); color: var(--text-dim);">-</span>
                            </asp:PlaceHolder>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>

    <div style="margin-top: 24px;">
        <h3 style="font-family: var(--f-display); font-size: var(--t-md); font-weight: 500; color: var(--blue-light); margin-bottom: 12px;">
            ALL REGISTERED USERS
        </h3>
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
                                    <asp:LinkButton ID="btnResetUserPassword" runat="server"
                                        CommandName="ResetUserPassword"
                                        CommandArgument='<%# Eval("UserId") %>'
                                        data-confirm-title="Reset User Password"
                                        data-confirm-msg='<%# "Reset the password for " + Eval("FirstName") + " " + Eval("LastName") + " (" + Eval("Email") + ")? Their password will be removed and they will be prompted to set a new password on their next sign-in." %>'
                                        data-confirm-type="primary"
                                        data-confirm-btn="Reset Password">
                                        Reset Password
                                    </asp:LinkButton>
                                    &nbsp;|&nbsp;
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
</div>
