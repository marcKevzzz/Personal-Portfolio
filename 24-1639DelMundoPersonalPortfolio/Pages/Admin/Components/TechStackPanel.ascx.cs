using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class TechStackPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindTechStack();
            }
        }

        public void BindTechStack()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.TechStacks ?? new System.Collections.Generic.List<TechStackItemDto>();
            rptTechTable.DataSource = list;
            rptTechTable.DataBind();
        }

        protected void btnAddTech_Click(object sender, EventArgs e)
        {
            string label = txtTechLabel.Text.Trim();
            if (string.IsNullOrWhiteSpace(label))
            {
                Page.ClientScript.RegisterStartupScript(GetType(), "techVal", "if(window.AdminToast) AdminToast.warning('Please enter a technology label.', 'Validation Error');", true);
                return;
            }

            int techId = int.TryParse(hidEditingTechId.Value, out int id) ? id : 0;

            var item = new TechStackItemDto
            {
                TechId = techId,
                GroupName = ddlTechGroup.SelectedValue,
                Label = label,
                IsActive = true
            };

            string rawSvg = txtTechSvgCode.Text.Trim();
            bool success = PortfolioService.SaveTechStack(item, rawSvg);

            ResetForm();
            BindTechStack();

            string msg = techId > 0 ? "Tech stack item updated successfully." : "New tech stack item added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Tech Stack');"
                : "if(window.AdminToast) AdminToast.error('Could not save tech stack item.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "techSavedToast", script, true);
        }

        protected void rptTechTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int techId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteTech")
            {
                bool ok = PortfolioService.DeleteTechStack(techId);
                BindTechStack();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Tech item deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete tech item.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "techDelToast", script, true);
            }
            else if (e.CommandName == "EditTech")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.TechStacks?.FirstOrDefault(t => t.TechId == techId);
                if (item != null)
                {
                    hidEditingTechId.Value = item.TechId.ToString();
                    ddlTechGroup.SelectedValue = item.GroupName;
                    txtTechLabel.Text = item.Label;
                    txtTechSvgCode.Text = "";

                    btnAddTech.Text = "Update Tech Item";
                    btnAddTech.Attributes["data-confirm-title"] = "Update Tech Item";
                    btnAddTech.Attributes["data-confirm-msg"] = $"Save updates for {item.Label}?";
                    btnCancelTechEdit.Visible = true;
                }
            }
        }

        protected void btnCancelTechEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingTechId.Value = "0";
            txtTechLabel.Text = "";
            txtTechSvgCode.Text = "";
            btnAddTech.Text = "Add Tech Item";
            btnAddTech.Attributes["data-confirm-title"] = "Add Tech Stack";
            btnAddTech.Attributes["data-confirm-msg"] = "Are you sure you want to add this technology to your stack?";
            btnCancelTechEdit.Visible = false;
        }
    }
}
