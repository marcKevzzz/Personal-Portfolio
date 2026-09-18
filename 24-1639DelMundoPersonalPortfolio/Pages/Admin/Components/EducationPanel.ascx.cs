using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class EducationPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindEducations();
            }
        }

        public void BindEducations()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Educations ?? new System.Collections.Generic.List<EducationDto>();
            rptEduTable.DataSource = list;
            rptEduTable.DataBind();
        }

        protected void btnAddEducation_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtEduTitle.Text) || string.IsNullOrWhiteSpace(txtEduInstitution.Text))
            {
                Page.ClientScript.RegisterStartupScript(GetType(), "eduWarn", "if(window.AdminToast) AdminToast.warning('Please enter both degree/title and institution.', 'Validation Error');", true);
                return;
            }

            int eduId = int.TryParse(hidEditingEduId.Value, out int id) ? id : 0;
            var currentData = PortfolioService.GetPortfolioData();

            int sort = 1;
            if (eduId > 0)
            {
                var existing = currentData?.Educations?.FirstOrDefault(x => x.EduId == eduId);
                sort = existing?.SortOrder ?? 1;
            }
            else
            {
                sort = (currentData?.Educations != null && currentData.Educations.Count > 0)
                    ? currentData.Educations.Max(x => x.SortOrder) + 1
                    : 1;
            }

            var edu = new EducationDto
            {
                EduId = eduId,
                YearPeriod = txtEduPeriod.Text.Trim(),
                Title = txtEduTitle.Text.Trim(),
                Subtitle = txtEduSubtitle.Text.Trim(),
                InstitutionName = txtEduInstitution.Text.Trim(),
                SortOrder = sort,
                IsActive = true
            };

            bool success = PortfolioService.SaveEducation(edu);

            ResetForm();
            BindEducations();

            string msg = eduId > 0 ? "Education record updated successfully." : "New education record added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Education');"
                : "if(window.AdminToast) AdminToast.error('Failed to save education record.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "eduSavedToast", script, true);
        }

        protected void rptEduTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int eduId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteEdu")
            {
                bool ok = PortfolioService.DeleteEducation(eduId);
                BindEducations();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Education record deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete education record.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "eduDelToast", script, true);
            }
            else if (e.CommandName == "EditEdu")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Educations?.FirstOrDefault(x => x.EduId == eduId);
                if (item != null)
                {
                    hidEditingEduId.Value = item.EduId.ToString();
                    txtEduPeriod.Text = item.YearPeriod;
                    txtEduTitle.Text = item.Title;
                    txtEduSubtitle.Text = item.Subtitle;
                    txtEduInstitution.Text = item.InstitutionName;

                    btnAddEducation.Text = "Update Education";
                    btnAddEducation.Attributes["data-confirm-title"] = "Update Education";
                    btnAddEducation.Attributes["data-confirm-msg"] = $"Save changes to {item.Title}?";
                    btnCancelEduEdit.Visible = true;
                }
            }
        }

        protected void btnCancelEduEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingEduId.Value = "0";
            txtEduPeriod.Text = "";
            txtEduTitle.Text = "";
            txtEduSubtitle.Text = "";
            txtEduInstitution.Text = "";
            btnAddEducation.Text = "Add Education";
            btnAddEducation.Attributes["data-confirm-title"] = "Add Education";
            btnAddEducation.Attributes["data-confirm-msg"] = "Are you sure you want to add this education milestone?";
            btnCancelEduEdit.Visible = false;
        }
    }
}
