using System;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class ProjectsPanel : UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindProjects();
                RenderChips(hidProjectTags.Value);
            }
        }

        public void BindProjects()
        {
            var data = PortfolioService.GetPortfolioData(forceRefresh: true);
            var list = data?.Projects ?? new System.Collections.Generic.List<ProjectDto>();
            rptProjectsTable.DataSource = list;
            rptProjectsTable.DataBind();
        }

        private void RenderChips(string tags)
        {
            if (string.IsNullOrWhiteSpace(tags)) tags = "HTML5,CSS3,JavaScript";
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
            litProjectChips.Text = sb.ToString();
        }

        protected void btnAddProject_Click(object sender, EventArgs e)
        {
            int projId = int.TryParse(hidEditingProjectId.Value, out int id) ? id : 0;
            var currentData = PortfolioService.GetPortfolioData();
            
            int sort = 1;
            if (projId > 0)
            {
                var existing = currentData?.Projects?.FirstOrDefault(p => p.ProjectId == projId);
                sort = existing?.SortOrder ?? 1;
            }
            else
            {
                sort = (currentData?.Projects != null && currentData.Projects.Count > 0)
                    ? currentData.Projects.Max(p => p.SortOrder) + 1
                    : 1;
            }

            var proj = new ProjectDto
            {
                ProjectId = projId,
                Title = txtProjectTitle.Text.Trim(),
                ImagePath = string.IsNullOrWhiteSpace(txtProjectImagePath.Text) ? "Assets/Images/samsondentalcenter.png" : txtProjectImagePath.Text.Trim(),
                ProjectUrl = txtProjectUrl.Text.Trim(),
                Tags = hidProjectTags.Value.Trim(),
                SortOrder = sort,
                IsActive = true
            };

            bool success = PortfolioService.SaveProject(proj);

            ResetForm();
            BindProjects();

            string msg = projId > 0 ? "Project updated successfully." : "New project added successfully.";
            string script = success 
                ? $"if(window.AdminToast) AdminToast.success('{msg}', 'Projects');"
                : "if(window.AdminToast) AdminToast.error('Failed to save project.', 'Error');";
            Page.ClientScript.RegisterStartupScript(GetType(), "projSavedToast", script, true);
        }

        protected void rptProjectsTable_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int projId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteProject")
            {
                bool ok = PortfolioService.DeleteProject(projId);
                BindProjects();
                string script = ok 
                    ? "if(window.AdminToast) AdminToast.success('Project deleted successfully.', 'Deleted');"
                    : "if(window.AdminToast) AdminToast.error('Failed to delete project.', 'Error');";
                Page.ClientScript.RegisterStartupScript(GetType(), "projDelToast", script, true);
            }
            else if (e.CommandName == "EditProject")
            {
                var data = PortfolioService.GetPortfolioData();
                var item = data?.Projects?.FirstOrDefault(p => p.ProjectId == projId);
                if (item != null)
                {
                    hidEditingProjectId.Value = item.ProjectId.ToString();
                    txtProjectTitle.Text = item.Title;
                    txtProjectImagePath.Text = item.ImagePath;
                    txtProjectUrl.Text = item.ProjectUrl;
                    hidProjectTags.Value = item.Tags;
                    RenderChips(item.Tags);

                    btnAddProject.Text = "Update Project";
                    btnAddProject.Attributes["data-confirm-title"] = "Update Project";
                    btnAddProject.Attributes["data-confirm-msg"] = $"Save changes to project {item.Title}?";
                    btnCancelProjectEdit.Visible = true;
                }
            }
        }

        protected void btnCancelProjectEdit_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        private void ResetForm()
        {
            hidEditingProjectId.Value = "0";
            txtProjectTitle.Text = "";
            txtProjectImagePath.Text = "";
            txtProjectUrl.Text = "";
            hidProjectTags.Value = "HTML5,CSS3,JavaScript";
            RenderChips("HTML5,CSS3,JavaScript");
            btnAddProject.Text = "Add Project";
            btnAddProject.Attributes["data-confirm-title"] = "Add Project";
            btnAddProject.Attributes["data-confirm-msg"] = "Are you sure you want to add this project?";
            btnCancelProjectEdit.Visible = false;
        }
    }
}
