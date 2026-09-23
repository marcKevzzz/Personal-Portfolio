using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class HobbiesPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindHobbies();
            }
        }

        public void BindHobbies()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Hobbies ?? new System.Collections.Generic.List<HobbyDto>();
            rptHobbiesTable.DataSource = list;
            rptHobbiesTable.DataBind();
        }

        protected void btnAddHobby_Click(object sender, EventArgs e)
        {
            if (_24_1639DelMundoPersonalPortfolio.Helpers.DuplicateSubmissionGuard.IsDuplicate(this.Page))
            {
                ResetForm();
                BindHobbies();
                return;
            }

            string name = txtHobbyName.Text.Trim();
            if (string.IsNullOrWhiteSpace(name))
            {
                string warnScript = "if(window.AdminToast) AdminToast.warning('Please enter a hobby name.', 'Required');";
                Page.ClientScript.RegisterStartupScript(GetType(), "hobbyWarn", warnScript, true);
                return;
            }

            int hobbyId = int.TryParse(hidEditingHobbyId.Value, out int id) ? id : 0;

            var hobby = new HobbyDto
            {
                HobbyId = hobbyId,
                HobbyName = name,
                HobbyDescription = txtHobbyDescription.Text.Trim(),
                IsActive = true
            };

            bool success = PortfolioService.SaveHobby(hobby);
            ResetForm();
            BindHobbies();

            string msg = hobbyId > 0 ? "Hobby updated successfully." : "New hobby added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Hobbies');"
                : "if(window.AdminToast) AdminToast.error('Failed to save hobby.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "hobbySavedToast", script, true);
        }

        protected void rptHobbiesTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int hobbyId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteHobby")
            {
                bool ok = PortfolioService.DeleteHobby(hobbyId);
                BindHobbies();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Hobby removed successfully.', 'Removed');"
                    : "if(window.AdminToast) AdminToast.error('Failed to remove hobby.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "hobbyDelToast", script, true);
            }
            else if (e.CommandName == "EditHobby")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Hobbies?.FirstOrDefault(x => x.HobbyId == hobbyId);
                if (item != null)
                {
                    hidEditingHobbyId.Value = item.HobbyId.ToString();
                    txtHobbyName.Text = item.HobbyName;
                    txtHobbyDescription.Text = item.HobbyDescription;
                    btnAddHobby.Text = "Update Hobby";
                    btnAddHobby.Attributes["data-confirm-title"] = "Update Hobby";
                    btnAddHobby.Attributes["data-confirm-msg"] = $"Save changes to \"{item.HobbyName}\"?";
                    btnCancelHobbyEdit.Visible = true;
                }
            }
        }

        protected void btnCancelHobbyEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingHobbyId.Value = "0";
            txtHobbyName.Text = "";
            txtHobbyDescription.Text = "";
            btnAddHobby.Text = "Add Hobby";
            btnAddHobby.Attributes["data-confirm-title"] = "Add Hobby";
            btnAddHobby.Attributes["data-confirm-msg"] = "Are you sure you want to add this hobby?";
            btnCancelHobbyEdit.Visible = false;
        }
    }
}
