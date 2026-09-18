using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class SkillsPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindSkills();
            }
        }

        public void BindSkills()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Skills ?? new System.Collections.Generic.List<SkillDto>();
            rptSkillsTable.DataSource = list;
            rptSkillsTable.DataBind();
        }

        protected void btnAddSkill_Click(object sender, EventArgs e)
        {
            string name = txtSkillName.Text.Trim();
            if (string.IsNullOrWhiteSpace(name))
            {
                Page.ClientScript.RegisterStartupScript(GetType(), "skillVal", "if(window.AdminToast) AdminToast.warning('Please enter a skill name.', 'Validation Error');", true);
                return;
            }

            int skillId = int.TryParse(hidEditingSkillId.Value, out int id) ? id : 0;
            int pct = int.TryParse(txtProficiencyVal.Text, out int p) ? Math.Max(0, Math.Min(100, p)) : 80;

            var currentList = PortfolioService.GetPortfolioData()?.Skills;
            int nextSort = (currentList != null && currentList.Count > 0) ? currentList.Max(s => s.SortOrder) + 1 : 1;

            var skill = new SkillDto
            {
                SkillId = skillId,
                SkillName = name,
                ProficiencyVal = pct,
                SortOrder = skillId > 0 && currentList != null ? (currentList.FirstOrDefault(s => s.SkillId == skillId)?.SortOrder ?? nextSort) : nextSort,
                IsActive = true
            };

            bool success = PortfolioService.SaveSkill(skill);

            ResetForm();
            BindSkills();

            string msg = skillId > 0 ? "Skill updated successfully." : "New skill added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Skills');"
                : "if(window.AdminToast) AdminToast.error('Failed to save skill.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "skillSavedToast", script, true);
        }

        protected void rptSkillsTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int skillId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteSkill")
            {
                bool ok = PortfolioService.DeleteSkill(skillId);
                BindSkills();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Skill deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete skill.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "skillDelToast", script, true);
            }
            else if (e.CommandName == "EditSkill")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Skills?.FirstOrDefault(s => s.SkillId == skillId);
                if (item != null)
                {
                    hidEditingSkillId.Value = item.SkillId.ToString();
                    txtSkillName.Text = item.SkillName;
                    txtProficiencyVal.Text = item.ProficiencyVal.ToString();

                    btnAddSkill.Text = "Update Skill";
                    btnAddSkill.Attributes["data-confirm-title"] = "Update Skill";
                    btnAddSkill.Attributes["data-confirm-msg"] = $"Save changes to skill {item.SkillName}?";
                    btnCancelSkillEdit.Visible = true;
                }
            }
        }

        protected void btnCancelSkillEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingSkillId.Value = "0";
            txtSkillName.Text = "";
            txtProficiencyVal.Text = "85";
            btnAddSkill.Text = "Add Skill";
            btnAddSkill.Attributes["data-confirm-title"] = "Add Skill";
            btnAddSkill.Attributes["data-confirm-msg"] = "Are you sure you want to add this skill?";
            btnCancelSkillEdit.Visible = false;
        }
    }
}
