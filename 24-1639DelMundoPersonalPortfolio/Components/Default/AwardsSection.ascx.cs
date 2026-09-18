using System;
using System.Collections.Generic;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class AwardsSection : UserControl
    {
        public List<AwardDto> Awards { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<AwardDto> awards)
        {
            Awards = awards ?? new List<AwardDto>();
            rptAwards.DataSource = Awards;
            rptAwards.DataBind();
        }
    }
}
