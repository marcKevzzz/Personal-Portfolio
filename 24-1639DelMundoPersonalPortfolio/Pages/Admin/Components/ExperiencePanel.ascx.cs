using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class ExperiencePanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindExperiences();
                RenderChips(hidExpTags.Value);
            }
        }

        public void BindExperiences()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Experiences ?? new System.Collections.Generic.List<ExperienceDto>();
            rptExpTable.DataSource = list;
            rptExpTable.DataBind();
        }

        private void RenderChips(string tags)
        {
            if (string.IsNullOrWhiteSpace(tags)) tags = "React,Tailwind CSS";
            var sb = new StringBuilder();
            sb.Append("<div class=\"chips-list\">");
            var parts = tags.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (var part in parts)
            {
                string clean = part.Trim();
                if (!string.IsNullOrEmpty(clean))
                {
                    sb.AppendFormat("<span class=\"chip-tag\"><span>{0}</span><span class=\"chip-remove\" title=\"Remove\">&times;</span></span>", Server.HtmlEncode(clean));
                }
            }
            sb.Append("</div>");
            litExpChips.Text = sb.ToString();
        }

        protected void btnAddExp_Click(object sender, EventArgs e)
        {
            int expId = int.TryParse(hidEditingExpId.Value, out int id) ? id : 0;

            var exp = new ExperienceDto
            {
                ExpId = expId,
                RoleTitle = txtExpRole.Text.Trim(),
                CompanyName = txtExpCompany.Text.Trim(),
                PeriodRange = txtExpPeriod.Text.Trim(),
                DescriptionText = txtExpDescription.Text.Trim(),
                Tags = hidExpTags.Value.Trim(),
                SortOrder = 1,
                IsActive = true
            };

            bool success = PortfolioService.SaveExperience(exp);

            ResetForm();
            BindExperiences();

            string msg = expId > 0 ? "Experience record updated successfully." : "New experience record added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Experience');"
                : "if(window.AdminToast) AdminToast.error('Failed to save experience record.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "expSavedToast", script, true);
        }

        protected void rptExpTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int expId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteExp")
            {
                bool ok = PortfolioService.DeleteExperience(expId);
                BindExperiences();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Experience record deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete experience record.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "expDelToast", script, true);
            }
            else if (e.CommandName == "EditExp")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Experiences?.FirstOrDefault(x => x.ExpId == expId);
                if (item != null)
                {
                    hidEditingExpId.Value = item.ExpId.ToString();
                    txtExpRole.Text = item.RoleTitle;
                    txtExpCompany.Text = item.CompanyName;
                    txtExpPeriod.Text = item.PeriodRange;
                    txtExpDescription.Text = item.DescriptionText;
                    hidExpTags.Value = item.Tags;
                    RenderChips(item.Tags);

                    btnAddExp.Text = "Update Experience";
                    btnAddExp.Attributes["data-confirm-title"] = "Update Experience";
                    btnAddExp.Attributes["data-confirm-msg"] = $"Save changes to {item.RoleTitle} at {item.CompanyName}?";
                    btnCancelExpEdit.Visible = true;
                }
            }
        }

        protected void btnCancelExpEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingExpId.Value = "0";
            txtExpRole.Text = "";
            txtExpCompany.Text = "";
            txtExpPeriod.Text = "";
            txtExpDescription.Text = "";
            hidExpTags.Value = "React,Tailwind CSS";
            RenderChips("React,Tailwind CSS");
            btnAddExp.Text = "Add Experience";
            btnAddExp.Attributes["data-confirm-title"] = "Add Experience";
            btnAddExp.Attributes["data-confirm-msg"] = "Are you sure you want to add this experience record?";
            btnCancelExpEdit.Visible = false;
        }
    }
}
