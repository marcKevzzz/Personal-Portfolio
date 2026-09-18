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
            string name = txtHobbyName.Text.Trim();
            if (string.IsNullOrWhiteSpace(name))
            {
                string warnScript = "if(window.AdminToast) AdminToast.warning('Please enter a hobby name.', 'Required');";
                Page.ClientScript.RegisterStartupScript(GetType(), "hobbyWarn", warnScript, true);
                return;
            }

            var currentData = PortfolioService.GetPortfolioData();
            int sort = (currentData?.Hobbies != null && currentData.Hobbies.Count > 0)
                ? currentData.Hobbies.Max(h => h.SortOrder) + 1
                : 1;

            var hobby = new HobbyDto
            {
                HobbyName = name,
                SortOrder = sort,
                IsActive = true
            };

            bool success = PortfolioService.SaveHobby(hobby);
            txtHobbyName.Text = "";
            BindHobbies();

            string script = success 
                ? "if(window.AdminToast) AdminToast.success('New hobby added successfully.', 'Hobbies');"
                : "if(window.AdminToast) AdminToast.error('Failed to add hobby.', 'Error');";
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
        }
    }
}
