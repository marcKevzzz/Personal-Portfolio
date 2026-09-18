using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class ExperienceSection : UserControl
    {
        public List<ExperienceDto> Experiences { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<ExperienceDto> experiences)
        {
            Experiences = experiences ?? new List<ExperienceDto>();
            rptExperiences.DataSource = Experiences;
            rptExperiences.DataBind();
        }

        protected void rptExperiences_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var exp = (ExperienceDto)e.Item.DataItem;
                var phDesc = (PlaceHolder)e.Item.FindControl("phDesc");
                var litDesc = (Literal)e.Item.FindControl("litDesc");
                var phTags = (PlaceHolder)e.Item.FindControl("phTags");
                var rptTags = (Repeater)e.Item.FindControl("rptTags");

                if (phDesc != null && litDesc != null)
                {
                    if (!string.IsNullOrWhiteSpace(exp.DescriptionText))
                    {
                        phDesc.Visible = true;
                        litDesc.Text = Server.HtmlEncode(exp.DescriptionText);
                    }
                    else
                    {
                        phDesc.Visible = false;
                    }
                }

                if (phTags != null && rptTags != null)
                {
                    if (!string.IsNullOrWhiteSpace(exp.Tags))
                    {
                        var tagList = exp.Tags.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)
                                              .Select(t => t.Trim())
                                              .Where(t => !string.IsNullOrEmpty(t))
                                              .ToList();
                        if (tagList.Count > 0)
                        {
                            phTags.Visible = true;
                            rptTags.DataSource = tagList;
                            rptTags.DataBind();
                        }
                        else
                        {
                            phTags.Visible = false;
                        }
                    }
                    else
                    {
                        phTags.Visible = false;
                    }
                }
            }
        }
    }
}
