using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class TechStackSection : UserControl
    {
        public List<TechStackItemDto> TechStacks { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<TechStackItemDto> techStacks)
        {
            TechStacks = techStacks ?? new List<TechStackItemDto>();
            var grouped = GetGroupedStacks();
            rptGroups.DataSource = grouped;
            rptGroups.DataBind();
        }

        protected void rptGroups_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var rptIcons = (Repeater)e.Item.FindControl("rptIcons");
                if (rptIcons != null)
                {
                    var kvp = (KeyValuePair<string, List<TechStackItemDto>>)e.Item.DataItem;
                    rptIcons.DataSource = kvp.Value;
                    rptIcons.DataBind();
                }
            }
        }

        private IEnumerable<KeyValuePair<string, List<TechStackItemDto>>> GetGroupedStacks()
        {
            var items = TechStacks ?? new List<TechStackItemDto>();
            var preferredOrder = new[] { "Frontend", "3D & Motion", "Backend & Database", "Tools & DevOps" };
            
            var dict = new Dictionary<string, List<TechStackItemDto>>();
            foreach (var g in preferredOrder)
            {
                dict[g] = new List<TechStackItemDto>();
            }

            foreach (var item in items)
            {
                string grp = string.IsNullOrEmpty(item.GroupName) ? "Frontend" : item.GroupName;
                if (!dict.ContainsKey(grp))
                {
                    dict[grp] = new List<TechStackItemDto>();
                }
                dict[grp].Add(item);
            }

            return dict.Where(kvp => kvp.Value.Count > 0);
        }
    }
}
