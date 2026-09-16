<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.UsersPanel" %>

<div class="admin-panel" data-panel="users">
    <h2>User Management</h2>
    <p class="admin-sub">Registered accounts. Deactivating prevents sign-in while preserving user records.</p>

    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr><th>Name</th><th>Email</th><th>Status</th><th>Joined</th><th>Actions</th></tr>
            </thead>
            <tbody>
                <tr>
                    <td>Sample User</td>
                    <td>sample.user@example.com</td>
                    <td><span class="status-pill active">ACTIVE</span></td>
                    <td>Sep 12, 2026</td>
                    <td><a href="javascript:void(0)" class="danger user-status-toggle">Deactivate</a></td>
                </tr>
                <tr>
                    <td>Another Visitor</td>
                    <td>another@example.com</td>
                    <td><span class="status-pill inactive">DEACTIVATED</span></td>
                    <td>Sep 3, 2026</td>
                    <td><a href="javascript:void(0)" class="user-status-toggle">Reactivate</a></td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
