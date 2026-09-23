using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class ContactSection : UserControl
    {
        public ProfileDto ProfileData { get; set; }
        public List<ContactDto> ContactsData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(ProfileDto profile)
        {
            BindData(null, profile);
        }

        public void BindData(List<ContactDto> contacts, ProfileDto profile = null)
        {
            ProfileData = profile ?? new ProfileDto();
            ContactsData = contacts != null ? new List<ContactDto>(contacts) : new List<ContactDto>();

            // If contacts list is empty, synthesize from ProfileData legacy fields if available
            if (ContactsData.Count == 0 && profile != null)
            {
                var user = _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetCurrentUser();
                string email = string.IsNullOrWhiteSpace(ProfileData.Email) ? (user?.Email ?? "") : ProfileData.Email;
                string github = string.IsNullOrWhiteSpace(ProfileData.GithubUrl) ? "" : ProfileData.GithubUrl.Trim();
                string linkedin = string.IsNullOrWhiteSpace(ProfileData.LinkedinUrl) ? "" : ProfileData.LinkedinUrl.Trim();

                int order = 1;
                if (!string.IsNullOrWhiteSpace(email))
                {
                    ContactsData.Add(new ContactDto
                    {
                        Platform = "Email",
                        ContactLabel = "Email",
                        ContactValue = email,
                        ContactUrl = "mailto:" + email,
                        DisplayOrder = order++,
                        IsActive = true
                    });
                }
                if (!string.IsNullOrWhiteSpace(github))
                {
                    ContactsData.Add(new ContactDto
                    {
                        Platform = "GitHub",
                        ContactLabel = "GitHub",
                        ContactValue = github,
                        ContactUrl = github,
                        DisplayOrder = order++,
                        IsActive = true
                    });
                }
                if (!string.IsNullOrWhiteSpace(linkedin))
                {
                    ContactsData.Add(new ContactDto
                    {
                        Platform = "LinkedIn",
                        ContactLabel = "LinkedIn",
                        ContactValue = linkedin,
                        ContactUrl = linkedin,
                        DisplayOrder = order++,
                        IsActive = true
                    });
                }
            }

            // Filter active contacts
            var activeContacts = ContactsData
                .Where(c => c.IsActive)
                .OrderBy(c => c.DisplayOrder)
                .ThenBy(c => c.ContactId)
                .ToList();

            if (activeContacts.Count > 0)
            {
                rptContacts.DataSource = activeContacts;
                rptContacts.DataBind();
                rptContacts.Visible = true;
                litContactsEmpty.Visible = false;
            }
            else
            {
                rptContacts.Visible = false;
                litContactsEmpty.Visible = true;
            }
        }
    }
}
