using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class ProjectsSection : UserControl
    {
        public List<ProjectDto> Projects { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<ProjectDto> projects)
        {
            Projects = projects ?? new List<ProjectDto>();
            bool hasItems = Projects.Count > 0;
            pnlEmpty.Visible = !hasItems;
            projectsBento.Visible = hasItems;

            if (hasItems)
            {
                rptProjects.DataSource = Projects;
                rptProjects.DataBind();
            }
        }

        protected void rptProjects_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var proj = (ProjectDto)e.Item.DataItem;
                int index = e.Item.ItemIndex;
                int totalCount = Projects != null ? Projects.Count : 0;

                var lnkProject = (HyperLink)e.Item.FindControl("lnkProject");
                var imgThumb = (Image)e.Item.FindControl("imgThumb");
                var litNum = (Literal)e.Item.FindControl("litNum");
                var litTitle = (Literal)e.Item.FindControl("litTitle");
                var rptTags = (Repeater)e.Item.FindControl("rptTags");

                if (lnkProject != null)
                {
                    string spanClass = GetProjectSpanClass(index, totalCount);
                    lnkProject.CssClass = $"tile {spanClass} reveal";
                    lnkProject.NavigateUrl = proj.ProjectUrl ?? "#";
                }

                if (imgThumb != null)
                {
                    string imgPath = proj.ImagePath ?? "Assets/Images/samsondentalcenter.png";
                    imgThumb.ImageUrl = ResolveUrl("~/" + imgPath.TrimStart('~', '/'));
                    imgThumb.AlternateText = proj.Title ?? "Project thumbnail";
                    imgThumb.Attributes["loading"] = "lazy";
                }

                if (litNum != null)
                {
                    litNum.Text = "P." + (index + 1).ToString("D2");
                }

                if (litTitle != null)
                {
                    litTitle.Text = Server.HtmlEncode(proj.Title ?? "");
                }

                if (rptTags != null && !string.IsNullOrWhiteSpace(proj.Tags))
                {
                    var tagList = proj.Tags.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                                          .Select(t => t.Trim())
                                          .Where(t => !string.IsNullOrEmpty(t))
                                          .ToList();
                    rptTags.DataSource = tagList;
                    rptTags.DataBind();
                }
            }
        }

        public string GetProjectSpanClass(int index, int totalCount)
        {
            if (totalCount % 2 != 0 && index == totalCount - 1)
            {
                return "span-12";
            }

            int rowIndex = index / 2;
            bool isSecondInRow = (index % 2 == 1);

            if (rowIndex % 2 == 0)
            {
                return isSecondInRow ? "span-5" : "span-7";
            }
            else
            {
                return "span-6";
            }
        }
    }
}
