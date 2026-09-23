using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Helpers;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class ContactsPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindContacts();
            }
        }

        public void BindContacts()
        {
            int currentUid = AuthHelper.GetCurrentUserId();
            var contacts = PortfolioService.GetContacts(currentUid);
            rptContactsTable.DataSource = contacts;
            rptContactsTable.DataBind();
        }

        protected void btnAddContact_Click(object sender, EventArgs e)
        {
            if (DuplicateSubmissionGuard.IsDuplicate(this.Page))
            {
                ClearInputs();
                BindContacts();
                return;
            }

            string platform = ddlPlatform.SelectedValue?.Trim() ?? "Other";
            string value = txtContactValue.Text.Trim();
            string label = txtContactLabel.Text.Trim();
            string customUrl = txtContactUrl.Text.Trim();

            if (string.IsNullOrWhiteSpace(value))
            {
                string warnScript = "if(window.AdminToast) AdminToast.warning('Please enter a contact value, handle, or link.', 'Required');";
                Page.ClientScript.RegisterStartupScript(GetType(), "contactWarn", warnScript, true);
                return;
            }

            int currentUid = AuthHelper.GetCurrentUserId();
            int contactId = int.TryParse(hidEditingContactId.Value, out int id) ? id : 0;

            var contact = new ContactDto
            {
                ContactId = contactId,
                UserId = currentUid,
                Platform = platform,
                ContactLabel = !string.IsNullOrWhiteSpace(label) ? label : platform,
                ContactValue = value,
                ContactUrl = !string.IsNullOrWhiteSpace(customUrl) ? customUrl : null,
                IsActive = true
            };

            bool success = PortfolioService.SaveContact(contact, currentUid);
            ClearInputs();
            BindContacts();

            string msg = contactId > 0 ? "Contact channel updated successfully." : "Contact / social channel added successfully.";
            string script = success
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Contacts');"
                : "if(window.AdminToast) AdminToast.error('Failed to save contact. Please check your database migration 012.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "contactSavedToast", script, true);
        }

        protected void rptContactsTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int contactId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteContact")
            {
                int currentUid = AuthHelper.GetCurrentUserId();
                bool ok = PortfolioService.DeleteContact(contactId, currentUid);
                BindContacts();
                string script = ok
                    ? "if(window.AdminToast) AdminToast.success('Contact channel removed successfully.', 'Removed');"
                    : "if(window.AdminToast) AdminToast.error('Failed to remove contact channel.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "contactDelToast", script, true);
            }
            else if (e.CommandName == "EditContact")
            {
                int currentUid = AuthHelper.GetCurrentUserId();
                var contacts = PortfolioService.GetContacts(currentUid);
                var item = contacts?.FirstOrDefault(x => x.ContactId == contactId);
                if (item != null)
                {
                    hidEditingContactId.Value = item.ContactId.ToString();
                    var matchItem = ddlPlatform.Items.FindByValue(item.Platform);
                    if (matchItem != null)
                        ddlPlatform.SelectedValue = item.Platform;
                    else
                        ddlPlatform.SelectedValue = "Other";

                    txtContactValue.Text = item.ContactValue;
                    txtContactLabel.Text = item.ContactLabel;
                    txtContactUrl.Text = item.ContactUrl ?? "";

                    btnAddContact.Text = "Update Contact";
                    btnAddContact.Attributes["data-confirm-title"] = "Update Contact";
                    btnAddContact.Attributes["data-confirm-msg"] = $"Save changes to \"{item.DisplayLabel}\"?";
                    btnCancelContactEdit.Visible = true;
                }
            }
        }

        protected void btnCancelContactEdit_Click(object sender, EventArgs e)
        {
            ClearInputs();
        }

        private void ClearInputs()
        {
            hidEditingContactId.Value = "0";
            txtContactValue.Text = "";
            txtContactLabel.Text = "";
            txtContactUrl.Text = "";
            ddlPlatform.SelectedIndex = 0;
            btnAddContact.Text = "Add Contact";
            btnAddContact.Attributes["data-confirm-title"] = "Add Contact";
            btnAddContact.Attributes["data-confirm-msg"] = "Are you sure you want to add this contact or social channel?";
            btnCancelContactEdit.Visible = false;
        }

        public string GetPlatformIconHtml(string platform)
        {
            string p = (platform ?? "").Trim().ToLowerInvariant();
            switch (p)
            {
                case "email":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z\"></path><polyline points=\"22,6 12,13 2,6\"></polyline></svg>";
                case "phone":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z\"></path></svg>";
                case "github":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z\"/></svg>";
                case "linkedin":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z\"/></svg>";
                case "facebook":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z\"/></svg>";
                case "instagram":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><rect x=\"2\" y=\"2\" width=\"20\" height=\"20\" rx=\"5\" ry=\"5\"></rect><path d=\"M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z\"></path><line x1=\"17.5\" y1=\"6.5\" x2=\"17.51\" y2=\"6.5\"></line></svg>";
                case "discord":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M20.317 4.37a19.791 19.791 0 0 0-4.885-1.515.074.074 0 0 0-.079.037c-.21.375-.444.864-.608 1.25a18.27 18.27 0 0 0-5.487 0 12.64 12.64 0 0 0-.617-1.25.077.077 0 0 0-.079-.037A19.736 19.736 0 0 0 3.677 4.37a.07.07 0 0 0-.032.027C.533 9.046-.32 13.58.099 18.057a.082.082 0 0 0 .031.057 19.9 19.9 0 0 0 5.993 3.03.078.078 0 0 0 .084-.028c.462-.63.874-1.295 1.226-1.994.021-.041.001-.09-.041-.106a13.107 13.107 0 0 1-1.872-.892.077.077 0 0 1-.008-.128 10.2 10.2 0 0 0 .372-.292.074.074 0 0 1 .077-.01c3.928 1.793 8.18 1.793 12.061 0a.074.074 0 0 1 .078.01c.12.098.246.198.373.292a.077.077 0 0 1-.006.127 12.299 12.299 0 0 1-1.873.894.077.077 0 0 0-.041.107c.36.698.772 1.362 1.225 1.993a.076.076 0 0 0 .084.028 19.839 19.839 0 0 0 6.002-3.03.077.077 0 0 0 .032-.054c.5-5.177-.838-9.674-3.549-13.66a.061.061 0 0 0-.031-.028zM8.02 15.33c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.956-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.956 2.418-2.157 2.418zm7.975 0c-1.183 0-2.157-1.085-2.157-2.419 0-1.333.955-2.419 2.157-2.419 1.21 0 2.176 1.096 2.157 2.42 0 1.333-.946 2.418-2.157 2.418z\"/></svg>";
                case "twitter":
                case "x":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z\"/></svg>";
                case "youtube":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z\"/></svg>";
                case "telegram":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"currentColor\"><path d=\"M11.944 0A12 12 0 0 0 0 12a12 12 0 0 0 12 12 12 12 0 0 0 12-12A12 12 0 0 0 12 0a12 12 0 0 0-.056 0zm4.962 7.224c.1-.002.321.023.465.14a.506.506 0 0 1 .171.325c.016.093.036.306.02.472-.18 1.898-.962 6.502-1.36 8.627-.168.9-.499 1.201-.82 1.23-.696.065-1.225-.46-1.9-.902-1.056-.693-1.653-1.124-2.678-1.8-1.185-.78-.417-1.21.258-1.91.177-.184 3.247-2.977 3.307-3.23.007-.032.014-.15-.056-.212s-.174-.041-.249-.024c-.106.024-1.793 1.14-5.061 3.345-.48.33-.913.49-1.302.48-.428-.008-1.252-.241-1.865-.44-.752-.245-1.349-.374-1.297-.789.027-.216.325-.437.893-.663 3.498-1.524 5.83-2.529 6.998-3.014 3.332-1.386 4.025-1.627 4.476-1.635z\"/></svg>";
                case "website":
                    return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"></circle><line x1=\"2\" y1=\"12\" x2=\"22\" y2=\"12\"></line><path d=\"M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z\"></path></svg>";
                default:
                    return "<svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71\"></path><path d=\"M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71\"></path></svg>";
            }
        }
    }
}
