using System;
using System.Collections.Generic;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class SkillsSection : UserControl
    {
        public List<SkillDto> Skills { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<SkillDto> skills)
        {
            Skills = skills ?? new List<SkillDto>();
            rptSkills.DataSource = Skills;
            rptSkills.DataBind();
        }
    }
}
