using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class AwardsPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindAwards();
            }
        }

        public void BindAwards()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Awards ?? new System.Collections.Generic.List<AwardDto>();
            rptAwardsTable.DataSource = list;
            rptAwardsTable.DataBind();
        }

        protected void btnAddAward_Click(object sender, EventArgs e)
        {
            if (_24_1639DelMundoPersonalPortfolio.Helpers.DuplicateSubmissionGuard.IsDuplicate(this.Page))
            {
                ResetForm();
                BindAwards();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtAwardTitle.Text))
            {
                Page.ClientScript.RegisterStartupScript(GetType(), "awardWarn", "if(window.AdminToast) AdminToast.warning('Please enter an award or recognition title.', 'Validation Error');", true);
                return;
            }

            int awardId = int.TryParse(hidEditingAwardId.Value, out int id) ? id : 0;

            var award = new AwardDto
            {
                AwardId = awardId,
                AwardYear = txtAwardYear.Text.Trim(),
                Title = txtAwardTitle.Text.Trim(),
                Subtitle = txtAwardSubtitle.Text.Trim(),
                OrganizationName = txtAwardOrg.Text.Trim(),
                IsActive = true
            };

            bool success = PortfolioService.SaveAward(award);

            ResetForm();
            BindAwards();

            string msg = awardId > 0 ? "Award updated successfully." : "New award added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Awards');"
                : "if(window.AdminToast) AdminToast.error('Failed to save award.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "awardSavedToast", script, true);
        }

        protected void rptAwardsTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int awardId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteAward")
            {
                bool ok = PortfolioService.DeleteAward(awardId);
                BindAwards();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Award deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete award.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "awardDelToast", script, true);
            }
            else if (e.CommandName == "EditAward")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Awards?.FirstOrDefault(a => a.AwardId == awardId);
                if (item != null)
                {
                    hidEditingAwardId.Value = item.AwardId.ToString();
                    txtAwardYear.Text = item.AwardYear;
                    txtAwardTitle.Text = item.Title;
                    txtAwardSubtitle.Text = item.Subtitle;
                    txtAwardOrg.Text = item.OrganizationName;

                    btnAddAward.Text = "Update Award";
                    btnAddAward.Attributes["data-confirm-title"] = "Update Award";
                    btnAddAward.Attributes["data-confirm-msg"] = $"Save changes to {item.Title}?";
                    btnCancelAwardEdit.Visible = true;
                }
            }
        }

        protected void btnCancelAwardEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingAwardId.Value = "0";
            txtAwardYear.Text = "";
            txtAwardTitle.Text = "";
            txtAwardSubtitle.Text = "";
            txtAwardOrg.Text = "";
            btnAddAward.Text = "Add Award";
            btnAddAward.Attributes["data-confirm-title"] = "Add Award";
            btnAddAward.Attributes["data-confirm-msg"] = "Are you sure you want to add this award / certificate?";
            btnCancelAwardEdit.Visible = false;
        }
    }
}
