<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.UsersPanel" %>

<div class="admin-panel" data-panel="users">
    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; gap: 16px; flex-wrap: wrap;">
        <div>
            <h2 style="margin: 0 0 6px 0;">User Management</h2>
            <p class="admin-sub" style="margin: 0;">Registered creator and administrator accounts. Deactivating prevents sign-in while preserving user records.</p>
        </div>
    </div>

    <div>
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px; gap: 12px; flex-wrap: wrap;">
            <div>
                <div style="display: flex; align-items: center; gap: 10px;">
                    <h3 style="font-family: var(--f-display); font-size: var(--t-md); font-weight: 500; color: var(--blue-light); margin: 0;">
                        ALL REGISTERED USERS
                    </h3>
                    <asp:Label ID="lblPendingResetBadge" runat="server" CssClass="status-pill active" style="background: rgba(255, 171, 0, 0.15); border-color: rgba(255, 171, 0, 0.4); color: #ffab00; font-size: 10px;" Visible="false" />
                </div>
                <span class="dash-sub-label" style="margin-top: 4px; display: block;">Manage user permissions, password resets, and account statuses.</span>
            </div>
            <div class="dash-table-filter-bar" style="margin: 0; padding: 0; border: none; background: transparent;">
                <div class="dash-search-box">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                    </svg>
                    <input type="text" class="table-filter-input" data-table="tblAllUsers" placeholder="Search users &amp; admins..." />
                </div>
                <div class="dash-filter-pills" data-table="tblAllUsers">
                    <button type="button" class="filter-pill active" data-filter="all">All</button>
                    <button type="button" class="filter-pill" data-filter="admin">Admin</button>
                    <button type="button" class="filter-pill" data-filter="user">User</button>
                    <button type="button" class="filter-pill" data-filter="active">Active</button>
                    <button type="button" class="filter-pill" data-filter="deactivated">Deactivated</button>
                </div>
            </div>
        </div>

        <div class="data-table-wrap all-users-table-wrap">
            <table class="data-table" id="tblAllUsers">
                <thead>
                    <tr>
                        <th style="width: 40px; text-align: center;">#</th>
                        <th>User</th>
                        <th>Email</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Joined</th>
                        <th style="text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptUsersTable" runat="server" OnItemCommand="rptUsersTable_ItemCommand">
                        <ItemTemplate>
                            <tr>
                                <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                                <td>
                                    <div class="dash-module-cell" style="display: flex; align-items: center; gap: 10px;">
                                        <%# _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetUserAvatarHtml(Eval("AvatarPath") as string, (string)Eval("FullName"), (string)Eval("Email")) %>
                                        <div style="display: flex; flex-direction: column; gap: 2px;">
                                            <div style="display: flex; align-items: center; gap: 6px;">
                                                <strong style="color: var(--text);"><%# Server.HtmlEncode((string)Eval("FullName")) %></strong>
                                                <%# ((int)Eval("UserId") == CurrentUserId) ? "<span class=\"badge badge-admin\" style=\"font-size: 9px; padding: 1px 6px;\">YOU</span>" : "" %>
                                            </div>
                                            <%# ((bool)Eval("HasPendingReset")) ? "<a href=\"javascript:void(0);\" onclick=\"openResetRequestModal(" + Eval("PendingResetId") + ", '" + Server.HtmlEncode((string)Eval("FullName")) + "', '" + Server.HtmlEncode((string)Eval("Email")) + "', '" + Server.HtmlEncode(((string)Eval("PendingResetReason") ?? "").Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ")) + "', '" + (Eval("PendingResetRequestedAt") != null ? ((DateTime)Eval("PendingResetRequestedAt")).ToString("MMM d, yyyy h:mm tt") : "") + "'); return false;\" class=\"status-pill active\" style=\"font-size: 9px; padding: 1px 6px; width: fit-content; text-decoration: none; cursor: pointer; background: rgba(255, 171, 0, 0.15); border-color: rgba(255, 171, 0, 0.4); color: #ffab00;\" title=\"Click to view password reset request\"><svg width=\"10\" height=\"10\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" style=\"vertical-align: -1px; margin-right: 3px;\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"12\" y1=\"8\" x2=\"12\" y2=\"12\"></line><line x1=\"12\" y1=\"16\" x2=\"12.01\" y2=\"16\"></line></svg>RESET REQUEST</a>" : "" %>
                                        </div>
                                    </div>
                                </td>
                                <td><%# Server.HtmlEncode((string)Eval("Email")) %></td>
                                <td>
                                    <span class='badge <%# string.Equals((string)Eval("Role"), "Admin", StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user" %>'>
                                        <%# Server.HtmlEncode((string)Eval("Role")) %>
                                    </span>
                                </td>
                                <td>
                                    <span class='<%# ((bool)Eval("IsActive")) ? "status-pill active" : "status-pill inactive" %>'>
                                        <%# ((bool)Eval("IsActive")) ? "ACTIVE" : "DEACTIVATED" %>
                                    </span>
                                </td>
                                <td><%# ((DateTime)Eval("CreatedAt")).ToString("MMM d, yyyy") %></td>
                                <td style="text-align: right;">
                                    <%# !string.Equals((string)Eval("Role"), "Admin", StringComparison.OrdinalIgnoreCase) 
                                        ? "<a href=\"" + ResolveUrl("~/Default.aspx?userId=" + Eval("UserId")) + "\" target=\"_blank\" class=\"btn btn-secondary btn-sm\" style=\"display: inline-flex; align-items: center; gap: 5px; text-decoration: none;\"><svg width=\"11\" height=\"11\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\"><path d=\"M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z\"></path><circle cx=\"12\" cy=\"12\" r=\"3\"></circle></svg><span>Website</span></a>" 
                                        : "<span style=\"font-size: var(--t-xs); color: var(--text-dim); font-style: italic;\">No Public Site</span>" %>
                                    
                                    <asp:PlaceHolder ID="phResetAction" runat="server" Visible='<%# ((bool)Eval("HasPendingReset")) %>'>
                                        |&nbsp;
                                        <button type="button" class="btn-sm" style="display: inline-flex; align-items: center; gap: 5px; color: #ffab00; background: transparent; font-size: 10px; margin-top: 4px; outline: none; border: none;"
                                            onclick="openResetRequestModal(<%# Eval("PendingResetId") %>, '<%# Server.HtmlEncode((string)Eval("FullName")) %>', '<%# Server.HtmlEncode((string)Eval("Email")) %>', '<%# Server.HtmlEncode(((string)Eval("PendingResetReason") ?? "").Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ")) %>', '<%# Eval("PendingResetRequestedAt") != null ? ((DateTime)Eval("PendingResetRequestedAt")).ToString("MMM d, yyyy h:mm tt") : "" %>'); return false;">
                                            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                            </svg>
                                            <span>Review Reset</span>
                                        </button>
                                    </asp:PlaceHolder>

                                    <asp:PlaceHolder ID="phSelfLockoutNotice" runat="server" Visible='<%# ((int)Eval("UserId")) == CurrentUserId %>'>
                                        &nbsp;|&nbsp;
                                        <span style="font-size: var(--t-xs); color: var(--text-dim); font-style: italic;">Current Session</span>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder ID="phOtherUserActions" runat="server" Visible='<%# ((int)Eval("UserId")) != CurrentUserId %>'>
                                        &nbsp;|&nbsp;
                                        <asp:LinkButton ID="btnResetUserPassword" runat="server"
                                            CommandName="ResetUserPassword"
                                            CommandArgument='<%# Eval("UserId") %>'
                                            data-confirm-title="Reset User Password"
                                            data-confirm-msg='<%# "Reset the password for " + Eval("FirstName") + " " + Eval("LastName") + " (" + Eval("Email") + ")? Their password will be removed and they will be prompted to set a new password on their next sign-in." %>'
                                            data-confirm-type="primary"
                                            data-confirm-btn="Reset Password">
                                            Reset Password
                                        </asp:LinkButton>
                                       |&nbsp;
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
                                    </asp:PlaceHolder>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Password Reset Request Modal -->
    <div class="admin-modal-overlay" id="resetRequestModal" style="display: none;" aria-hidden="true">
        <div class="admin-modal-dialog" style="max-width: 480px;">
            <div class="admin-modal-header">
                <div class="admin-modal-title">
                    <span class="admin-modal-title-icon" style="color: #ffab00;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                        </svg>
                    </span>
                    <span>Password Reset Request</span>
                </div>
                <button type="button" class="admin-modal-close-btn" onclick="closeResetRequestModal()">&times;</button>
            </div>
            <div class="admin-modal-body" style="padding: 20px 24px;">
                <div style="margin-bottom: 14px;">
                    <div style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-dim); font-family: var(--f-display);">User Account</div>
                    <div id="modalResetUserName" style="font-weight: 600; font-size: var(--t-sm); color: var(--text); margin-top: 2px;"></div>
                    <div id="modalResetUserEmail" style="font-size: var(--t-xs); color: var(--blue-bright);"></div>
                </div>
                <div style="margin-bottom: 14px;">
                    <div style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-dim); font-family: var(--f-display);">Submitted On</div>
                    <div id="modalResetRequestedAt" style="font-size: var(--t-xs); color: var(--text-mid); margin-top: 2px;"></div>
                </div>
                <div style="margin-bottom: 14px;">
                    <div style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-dim); font-family: var(--f-display);">Reason / User Explanation</div>
                    <div id="modalResetReason" style="font-size: var(--t-xs); color: var(--text); background: var(--bg-1); border: 1px solid var(--line); border-radius: var(--radius-sm); padding: 10px 12px; margin-top: 4px; min-height: 44px; max-height: 120px; overflow-y: auto; word-break: break-word;"></div>
                </div>
                <p style="font-size: var(--t-xs); color: var(--text-dim); margin: 0; line-height: 1.4;">
                    Approving removes the user's current password so they can set a new one upon their next sign-in. Dismissing keeps their existing password unchanged.
                </p>
            </div>
            <div class="admin-modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeResetRequestModal()">Cancel</button>
                <asp:Button ID="btnModalRejectReset" runat="server" CssClass="btn btn-secondary danger" Text="Dismiss Request" OnClick="btnModalRejectReset_Click" UseSubmitBehavior="false" />
                <asp:Button ID="btnModalApproveReset" runat="server" CssClass="btn btn-primary" Text="Approve &amp; Clear" OnClick="btnModalApproveReset_Click" UseSubmitBehavior="false" />
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hfSelectedResetId" runat="server" ClientIDMode="Static" />

    <script type="text/javascript">
        function openResetRequestModal(resetId, userName, email, reason, requestedAt) {
            var hf = document.getElementById('hfSelectedResetId');
            if (hf) hf.value = resetId;
            var nameEl = document.getElementById('modalResetUserName');
            if (nameEl) nameEl.textContent = userName || 'User';
            var emailEl = document.getElementById('modalResetUserEmail');
            if (emailEl) emailEl.textContent = email || '';
            var reasonEl = document.getElementById('modalResetReason');
            if (reasonEl) reasonEl.textContent = reason || 'No explanation provided.';
            var dateEl = document.getElementById('modalResetRequestedAt');
            if (dateEl) dateEl.textContent = requestedAt || 'N/A';

            var modal = document.getElementById('resetRequestModal');
            if (modal) {
                modal.style.display = 'flex';
                modal.classList.add('active');
                modal.setAttribute('aria-hidden', 'false');
            }
        }
        function closeResetRequestModal() {
            var modal = document.getElementById('resetRequestModal');
            if (modal) {
                modal.classList.remove('active');
                modal.style.display = 'none';
                modal.setAttribute('aria-hidden', 'true');
            }
        }
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') closeResetRequestModal();
        });
        document.addEventListener('click', function (e) {
            var modal = document.getElementById('resetRequestModal');
            if (modal && e.target === modal) {
                closeResetRequestModal();
            }
        });
    </script>
</div>
