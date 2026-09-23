using System;
using System.Web.UI;
using _24_1639DelMundoPersonalPortfolio.Models;
using _24_1639DelMundoPersonalPortfolio.Services;

namespace _24_1639DelMundoPersonalPortfolio.Pages.Admin.Components
{
    public partial class DashboardPanel : UserControl
    {
        public DashboardStatsDto Stats { get; set; } = new DashboardStatsDto();

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            try
            {
                Stats = PortfolioService.GetDashboardStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[DashboardPanel] Load error: {ex.Message}");
                Stats = new DashboardStatsDto
                {
                    IsDatabaseConnected = false,
                    DatabaseSource = "Cache Fallback",
                    ReportGeneratedAt = DateTime.UtcNow
                };
            }
        }

        protected void btnRefreshDashboard_Click(object sender, EventArgs e)
        {
            PortfolioService.InvalidateCache();
            LoadDashboardData();

            string script = "if(window.AdminToast) AdminToast.success('Dashboard metrics refreshed from live database.', 'Telemetry Updated');";
            ScriptManager.RegisterStartupScript(this, GetType(), "DashboardRefreshed", script, true);
        }
    }
}
