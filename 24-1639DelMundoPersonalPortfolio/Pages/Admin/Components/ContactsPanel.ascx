<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ContactsPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.ContactsPanel" %>

<div class="admin-panel" data-panel="contacts">
    <h2>Contacts &amp; Social Channels</h2>
    <p class="admin-sub">Manage your public contact information and social profiles (e.g. Email, Phone, GitHub, LinkedIn, Facebook, Instagram, Discord, X, and more) shown on your portfolio website.</p>

    <asp:HiddenField ID="hidEditingContactId" runat="server" Value="0" />

    <!-- Add Contact Form -->
    <div class="add-form" >
        <div class="field">
            <label>Platform / Channel <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:DropDownList ID="ddlPlatform" runat="server" CssClass="admin-dropdown" onchange="onContactPlatformChanged(this.value);">
                    <asp:ListItem Text="Email" Value="Email" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="Phone" Value="Phone"></asp:ListItem>
                    <asp:ListItem Text="GitHub" Value="GitHub"></asp:ListItem>
                    <asp:ListItem Text="LinkedIn" Value="LinkedIn"></asp:ListItem>
                    <asp:ListItem Text="Facebook" Value="Facebook"></asp:ListItem>
                    <asp:ListItem Text="Instagram" Value="Instagram"></asp:ListItem>
                    <asp:ListItem Text="Discord" Value="Discord"></asp:ListItem>
                    <asp:ListItem Text="Twitter / X" Value="Twitter"></asp:ListItem>
                    <asp:ListItem Text="YouTube" Value="YouTube"></asp:ListItem>
                    <asp:ListItem Text="Telegram" Value="Telegram"></asp:ListItem>
                    <asp:ListItem Text="Website / Blog" Value="Website"></asp:ListItem>
                    <asp:ListItem Text="Other" Value="Other"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <div class="field">
            <label id="lblContactValueTitle">Value / Handle / Link <span class="req-star">*</span></label>
            <div class="input-row">
                <asp:TextBox ID="txtContactValue" runat="server" placeholder="e.g. user@example.com, username, or +63 9..." />
            </div>
        </div>

        <div class="field">
            <label>Display Label </label>
            <div class="input-row">
                <asp:TextBox ID="txtContactLabel" runat="server" placeholder="e.g. Work Email, Personal Profile" />
            </div>
        </div>

        <div class="field">
            <label>Custom Link / Protocol </label>
            <div class="input-row">
                <asp:TextBox ID="txtContactUrl" runat="server" placeholder="Auto-computed if empty" />
            </div>
        </div>

        <div style="display: flex; align-items: flex-end; gap: 10px;">
            <asp:Button ID="btnAddContact" runat="server" Text="Add Contact" CssClass="btn btn-primary" OnClick="btnAddContact_Click" data-confirm-title="Add Contact" data-confirm-msg="Are you sure you want to add this contact or social channel?" data-confirm-btn="Add Contact" style="justify-content: center;" />
            <asp:Button ID="btnCancelContactEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-secondary" Visible="false" OnClick="btnCancelContactEdit_Click" data-confirm-title="Discard Changes" data-confirm-msg="Are you sure you want to discard your changes?" data-confirm-type="warning" data-confirm-btn="Discard" />
        </div>
    </div>

    <!-- Contacts Table -->
    <div class="data-table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center;">#</th>
                    <th style="width: 70px; text-align: center;">Platform</th>
                    <th>Label</th>
                    <th>Value / Handle</th>
                    <th>Direct Link Preview</th>
                    <th style="text-align: right; width: 140px;">Action</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptContactsTable" runat="server" OnItemCommand="rptContactsTable_ItemCommand">
                    <ItemTemplate>
                        <tr>
                            <td class="table-row-index"><%# Container.ItemIndex + 1 %></td>
                            <td style="text-align: center;">
                                <span class="contact-platform-icon-wrap" title='<%# Eval("Platform") %>'>
                                    <%# GetPlatformIconHtml(Eval("Platform") != null ? Eval("Platform").ToString() : "") %>
                                </span>
                            </td>
                            <td><strong><%# Eval("DisplayLabel") %></strong></td>
                            <td style="color: var(--text-mid); font-family: var(--f-mono, monospace); font-size: var(--t-xs);">
                                <%# Eval("ContactValue") %>
                            </td>
                            <td>
                                <a href='<%# Eval("ComputedUrl") %>' target="_blank" rel="noopener noreferrer" class="contact-preview-link" style="color: var(--blue-light); display: inline-flex; align-items: center; gap: 4px; font-size: var(--t-xs);">
                                    <span><%# Eval("ComputedUrl") %></span>
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 12px; height: 12px; flex-shrink: 0;"><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path><polyline points="15 3 21 3 21 9"></polyline><line x1="10" y1="14" x2="21" y2="3"></line></svg>
                                </a>
                            </td>
                            <td style="text-align: right;">
                                <asp:LinkButton ID="btnEditContact" runat="server" CommandName="EditContact" CommandArgument='<%# Eval("ContactId") %>' style="margin-right: 10px;">Edit</asp:LinkButton>
                                <asp:LinkButton ID="btnDeleteContact" runat="server" CssClass="danger" CommandName="DeleteContact" CommandArgument='<%# Eval("ContactId") %>' data-confirm-title="Remove Contact" data-confirm-msg='<%# "Are you sure you want to remove " + Eval("Platform") + " (" + Eval("DisplayLabel") + ")?" %>' data-confirm-type="danger" data-confirm-btn="Remove">Remove</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</div>

<script>
    function onContactPlatformChanged(platform) {
        var valInput = document.getElementById('<%= txtContactValue.ClientID %>');
        if (!valInput) return;
        switch ((platform || '').toLowerCase()) {
            case 'email':
                valInput.placeholder = 'e.g. contact@yourdomain.com';
                break;
            case 'phone':
                valInput.placeholder = 'e.g. +63 912 345 6789';
                break;
            case 'github':
                valInput.placeholder = 'e.g. yourusername or https://github.com/username';
                break;
            case 'linkedin':
                valInput.placeholder = 'e.g. linkedin username or https://linkedin.com/in/...';
                break;
            case 'facebook':
                valInput.placeholder = 'e.g. fb username or profile URL';
                break;
            case 'instagram':
                valInput.placeholder = 'e.g. @instagram_handle or profile URL';
                break;
            case 'discord':
                valInput.placeholder = 'e.g. username#1234 or invite link';
                break;
            case 'twitter':
                valInput.placeholder = 'e.g. @handle or profile URL';
                break;
            case 'youtube':
                valInput.placeholder = 'e.g. @channel or channel URL';
                break;
            case 'telegram':
                valInput.placeholder = 'e.g. @telegram_handle or t.me link';
                break;
            default:
                valInput.placeholder = 'e.g. contact value or URL';
                break;
        }
    }
</script>
