using System;
using System.Collections.Generic;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class HobbiesSection : UserControl
    {
        public List<HobbyDto> Hobbies { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<HobbyDto> hobbies)
        {
            Hobbies = hobbies ?? new List<HobbyDto>();
            bool hasItems = Hobbies.Count > 0;
            pnlEmpty.Visible = !hasItems;
            hobbiesList.Visible = hasItems;

            if (hasItems)
            {
                rptHobbies.DataSource = Hobbies;
                rptHobbies.DataBind();
            }
        }
    }
}
