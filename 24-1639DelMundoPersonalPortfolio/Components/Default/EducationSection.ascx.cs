using System;
using System.Collections.Generic;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Components.Default
{
    public partial class EducationSection : UserControl
    {
        public List<EducationDto> Educations { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public void BindData(List<EducationDto> educations)
        {
            Educations = educations ?? new List<EducationDto>();
            rptEducations.DataSource = Educations;
            rptEducations.DataBind();
        }
    }
}
