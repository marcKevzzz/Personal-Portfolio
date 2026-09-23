<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DashboardPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.DashboardPanel" %>

<div class="admin-panel active" data-panel="dashboard">
    <!-- Header with System Status and Refresh Action -->
    <div class="dash-header-row">
        <div>
            <h2>Dashboard</h2>
            <p class="admin-sub">Platform metrics, user activity, and portfolio showcases.</p>
        </div>
        <div class="dash-header-actions">
            <asp:LinkButton ID="btnRefreshDashboard" runat="server" CssClass="btn btn-secondary btn-sm" OnClick="btnRefreshDashboard_Click">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 14px; height: 14px; margin-right: 6px;">
                    <polyline points="23 4 23 10 17 10"></polyline>
                    <polyline points="1 20 1 14 7 14"></polyline>
                    <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path>
                </svg>
                Refresh Data
            </asp:LinkButton>
        </div>
    </div>

    <!-- Alert Banner for Pending Password Resets (if any) -->
    <% if (Stats.PendingPasswordResets > 0) { %>
    <div class="dash-alert-banner">
        <div class="dash-alert-left">
            <span class="dash-alert-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <circle cx="12" cy="12" r="10"></circle>
                    <line x1="12" y1="8" x2="12" y2="12"></line>
                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
            </span>
            <div>
                <strong>Action Required:</strong> You have <strong><%= Stats.PendingPasswordResets %> pending password reset request(s)</strong> awaiting review.
            </div>
        </div>
        <button type="button" class="btn btn-sm btn-primary jump-panel-btn" data-target="users">Review Requests &rarr;</button>
    </div>
    <% } %>

    <!-- 4 Core High-Level KPI Metric Cards -->
    <div class="dash-kpi-grid">
        <!-- 1. Portfolio Inventory -->
        <div class="dash-kpi-card" data-card="projects">
            <div class="kpi-header">
                <span class="kpi-label">PORTFOLIO ITEMS</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.TotalProjects + Stats.TotalTechStacks + Stats.TotalSkills %></div>
            <div class="kpi-footer">
                <span class="kpi-badge kpi-badge-cyan"><%= Stats.TotalProjects %> Projects</span>
                <span class="kpi-meta"><%= Stats.TotalTechStacks %> Techs &bull; <%= Stats.TotalSkills %> Skills</span>
            </div>
        </div>

        <!-- 2. User Accounts & Growth -->
        <div class="dash-kpi-card" data-card="users">
            <div class="kpi-header">
                <span class="kpi-label">USER ACCOUNTS</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.TotalUsers %></div>
            <div class="kpi-footer">
                <span class="kpi-badge kpi-badge-cyan"><%= Stats.ActiveUsers %> Active</span>
                <span class="kpi-meta">+<%= Stats.SignUpsToday %> today &bull; +<%= Stats.SignUpsThisWeek %> this wk</span>
            </div>
        </div>

        <!-- 3. Traffic & Engagement -->
        <div class="dash-kpi-card" data-card="experience">
            <div class="kpi-header">
                <span class="kpi-label">ENGAGEMENT &amp; LOGINS</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.TotalLogins %><span class="kpi-unit" style="font-size: 13px; margin-left: 4px;">sessions</span></div>
            <div class="kpi-footer">
                <span class="kpi-badge kpi-badge-blue">DAU: <%= Stats.DailyActiveUsers %></span>
                <span class="kpi-meta">MAU: <%= Stats.MonthlyActiveUsers %> active (30d)</span>
            </div>
        </div>

        <!-- 4. Published User Websites -->
        <div class="dash-kpi-card" data-card="completeness">
            <div class="kpi-header">
                <span class="kpi-label">PUBLISHED WEBSITES</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.TotalPortfolios %> <span class="kpi-unit" style="font-size: 15px; color: var(--text-dim); font-weight: 400; margin-left: 6px;">/ <%= Stats.TotalUsers %> users</span></div>
            <div class="kpi-footer">
                <span class="kpi-badge kpi-badge-cyan"><%= Stats.PortfolioCreationRate %>% Adoption</span>
                <span class="kpi-meta"><%= Stats.ConfiguredPortfolios %> configured &bull; <%= Math.Max(0, Stats.TotalUsers - Stats.TotalPortfolios) %> not started</span>
            </div>
        </div>
    </div>

    <!-- Unified User Websites & Activity Stream -->
    <div class="dash-card dash-master-card" style="margin-top: 24px;">
        <div class="dash-card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div class="dash-card-title">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--blue-light);">
                    <circle cx="12" cy="12" r="10"></circle>
                    <polyline points="12 6 12 12 16 14"></polyline>
                </svg>
                <span>User Websites &amp; Activity Stream</span>
            </div>
            <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                <span class="dash-pill-counter"><%= Stats.UserPortfolioReports != null ? Stats.UserPortfolioReports.Count : 0 %> Accounts</span>
                <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="users">Manage Users &rarr;</button>
            </div>
        </div>

        <!-- Micro-KPI Summary Strip -->
        <div class="dash-sub-kpi-grid" style="padding: 16px 20px 0 20px;">
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">ACTIVE / INACTIVE</div>
                <div class="sub-kpi-value"><%= Stats.ActiveUsers %> <span style="font-size: 13px; color: var(--text-dim); font-weight: 400;">/ <%= Stats.InactiveUsers %></span></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">ADMIN ACCOUNTS</div>
                <div class="sub-kpi-value highlight-blue"><%= Stats.AdminUsers %></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">CONFIGURED WEBSITES</div>
                <div class="sub-kpi-value highlight-cyan"><%= Stats.ConfiguredPortfolios %> <span style="font-size: 13px; color: var(--text-dim); font-weight: 400;">/ <%= Stats.TotalUsers %></span></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">TOTAL SESSIONS</div>
                <div class="sub-kpi-value"><%= Stats.TotalLogins %></div>
            </div>
        </div>

        <!-- Master Stream Filter Bar -->
        <div class="dash-table-filter-bar" style="padding: 14px 20px; border-bottom: 1px solid var(--line-soft); margin-top: 14px;">
            <div class="dash-search-box">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
                <input type="text" class="table-filter-input" data-table="tblUserActivityStream" placeholder="Search by name, email, role, or website status..." />
            </div>
            <div class="dash-filter-pills" data-table="tblUserActivityStream">
                <button type="button" class="filter-pill active" data-filter="all">All</button>
                <button type="button" class="filter-pill" data-filter="configured">Configured</button>
                <button type="button" class="filter-pill" data-filter="in progress">In Progress</button>
                <button type="button" class="filter-pill" data-filter="not started">Not Started</button>
                <button type="button" class="filter-pill" data-filter="admin">Admins</button>
                <button type="button" class="filter-pill" data-filter="user">Users</button>
            </div>
        </div>

        <!-- Master Scrollable Table -->
        <div class="dash-table-wrap user-activity-stream">
            <table class="data-table dash-inventory-table" id="tblUserActivityStream">
                <thead>
                    <tr>
                        <th style="width: 40px; text-align: center;">#</th>
                        <th>USER</th>
                        <th>ROLE</th>
                        <th>WEBSITE STATUS</th>
                        <th style="text-align: center;">LOGINS</th>
                        <th>LAST SIGN-IN</th>
                        <th>LAST SITE UPDATE</th>
                        <th style="text-align: right;">ACTION</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (Stats.UserPortfolioReports != null && Stats.UserPortfolioReports.Count > 0) {
                        int rowIdx = 1;
                        foreach (var u in Stats.UserPortfolioReports) { %>
                        <tr data-status="<%= u.PortfolioStatus.ToLower() %>" data-role="<%= u.Role.ToLower() %>">
                            <td class="table-row-index" style="text-align: center; color: var(--text-dim); font-size: 11px;"><%= rowIdx++ %></td>
                            <td>
                                <div class="dash-module-cell">
                                    <%= _24_1639DelMundoPersonalPortfolio.Helpers.AuthHelper.GetUserAvatarHtml(u.AvatarPath, u.FullName, u.Email) %>
                                    <div>
                                        <strong><%= Server.HtmlEncode(u.FullName) %></strong>
                                        <div class="module-meta"><%= Server.HtmlEncode(u.Email) %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge <%= u.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase) ? "badge-admin" : "badge-user" %>">
                                    <%= Server.HtmlEncode(u.Role) %>
                                </span>
                            </td>
                            <td>
                                <% if (u.Role.Equals("Admin", StringComparison.OrdinalIgnoreCase)) { %>
                                    <span class="status-pill" style="background: rgba(255, 255, 255, 0.05); color: var(--text-dim); border-color: var(--line);">N/A (Admin)</span>
                                <% } else if (u.PortfolioStatus == "Configured") { %>
                                    <span class="status-pill status-active" style="background: rgba(0, 210, 106, 0.12); color: #00d26a; border-color: rgba(0, 210, 106, 0.3);">Configured</span>
                                <% } else if (u.PortfolioStatus == "In Progress") { %>
                                    <span class="status-pill" style="background: rgba(61, 127, 255, 0.12); color: var(--blue-light); border-color: rgba(61, 127, 255, 0.3);">In Progress</span>
                                <% } else { %>
                                    <span class="status-pill status-inactive">Not Started</span>
                                <% } %>
                            </td>
                            <td style="text-align: center;">
                                <strong style="color: var(--text);"><%= u.LoginCount %></strong>
                            </td>
                            <td>
                                <% if (u.LastLoginAt.HasValue) { %>
                                    <span style="font-size: 11px; color: var(--text);"><%= u.LastLoginAt.Value.ToString("MMM dd, yyyy HH:mm") %></span>
                                <% } else { %>
                                    <span style="font-size: 11px; color: var(--text-dim); font-style: italic;">Never</span>
                                <% } %>
                            </td>
                            <td>
                                <% if (u.LastProfileUpdate.HasValue) { %>
                                    <span style="font-size: 11px; color: var(--text);"><%= u.LastProfileUpdate.Value.ToString("MMM dd, yyyy") %></span>
                                <% } else { %>
                                    <span style="font-size: 11px; color: var(--text-dim); font-style: italic;">Never</span>
                                <% } %>
                            </td>
                            <td style="text-align: right;">
                                <% if (!string.Equals(u.Role, "Admin", StringComparison.OrdinalIgnoreCase) && !string.Equals(u.RoleTitle, "Admin", StringComparison.OrdinalIgnoreCase)) { %>
                                    <a href='<%= ResolveUrl("~/Default.aspx?userId=" + u.UserId) %>' target="_blank" class="btn btn-secondary btn-sm" style="display: inline-flex; align-items: center; gap: 6px; text-decoration: none;">
                                        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                            <circle cx="12" cy="12" r="3"></circle>
                                        </svg>
                                        <span>Preview</span>
                                    </a>
                                <% } else { %>
                                    <span style="font-size: 11px; color: var(--text-dim); font-style: italic;">No Public Site</span>
                                <% } %>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="8" style="text-align: center; color: var(--text-dim); padding: 24px;">No user activity or websites registered yet.</td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Diagnostic System Telemetry Footer Card -->
    <div class="dash-system-footer">
        <div class="diag-item">
            <span class="diag-label">DATABASE ENGINE</span>
            <span class="diag-val"><%= Stats.DatabaseSource %></span>
        </div>
        <div class="diag-item">
            <span class="diag-label">CACHE DURATION</span>
            <span class="diag-val">30 Minutes</span>
        </div>
        <div class="diag-item">
            <span class="diag-label">LAST GENERATED</span>
            <span class="diag-val"><%= Stats.ReportGeneratedAt.ToString("yyyy-MM-dd HH:mm:ss") %> UTC</span>
        </div>
        <div class="diag-item">
            <span class="diag-label">ENVIRONMENT</span>
            <span class="diag-val"><%= HttpContext.Current.Request.IsLocal ? "Local Development" : "Production Server" %></span>
        </div>
    </div>
</div>
