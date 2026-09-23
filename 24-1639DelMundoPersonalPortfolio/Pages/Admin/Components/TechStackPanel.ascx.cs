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
            if (_24_1639DelMundoPersonalPortfolio.Helpers.DuplicateSubmissionGuard.IsDuplicate(this.Page))
            {
                ResetForm();
                BindTechStack();
                return;
            }

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
            if (rawSvg.StartsWith("base64:", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    byte[] bytes = Convert.FromBase64String(rawSvg.Substring(7));
                    rawSvg = System.Text.Encoding.UTF8.GetString(bytes).Trim();
                }
                catch { }
            }

            bool success = PortfolioService.SaveTechStack(item, rawSvg);

            ResetForm();
            BindTechStack();

            string msg = techId > 0 ? "Tech stack item updated successfully." : "New tech stack item added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Tech Stack');"
                : "if(window.AdminToast) AdminToast.error('Could not save tech stack item.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "techSavedToast", script, true);
        }

        public string RenderTechTableIcon(object iconPathObj, object labelObj)
        {
            return _24_1639DelMundoPersonalPortfolio.Helpers.SvgHelper.RenderInlineSvg(iconPathObj, labelObj, "tech-table-icon");
        }

        protected void rptTechTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int techId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteTech")
            {
                if (_24_1639DelMundoPersonalPortfolio.Helpers.DuplicateSubmissionGuard.IsDuplicate(this.Page))
                {
                    BindTechStack();
                    return;
                }

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

                    // Display the actual SVG tag inside the textbox
                    string svgContent = _24_1639DelMundoPersonalPortfolio.Helpers.SvgHelper.GetSvgContent(item.IconPath);
                    txtTechSvgCode.Text = svgContent;

                    btnAddTech.Text = "Update Tech Item";
                    btnAddTech.Attributes["data-confirm-title"] = "Update Tech Item";
                    btnAddTech.Attributes["data-confirm-msg"] = $"Save updates for {item.Label}?";
                    btnCancelTechEdit.Visible = true;

                    string safeJson = Newtonsoft.Json.JsonConvert.SerializeObject(svgContent);
                    Page.ClientScript.RegisterStartupScript(GetType(), "previewSvgEdit_" + techId, $"if(window.updateLiveTechSvgPreview) updateLiveTechSvgPreview({safeJson});", true);
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
            Page.ClientScript.RegisterStartupScript(GetType(), "previewSvgReset", "if(window.updateLiveTechSvgPreview) updateLiveTechSvgPreview('');", true);
        }
    }
}
