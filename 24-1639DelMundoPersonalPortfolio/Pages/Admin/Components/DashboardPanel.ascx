<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="DashboardPanel.ascx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.Admin.Components.DashboardPanel" %>

<div class="admin-panel active" data-panel="dashboard">
    <!-- Header with System Status and Refresh Action -->
    <div class="dash-header-row">
        <div>
            <h2>Statistics &amp; Reports Dashboard</h2>
            <p class="admin-sub">Real-time portfolio telemetry, content inventory, user activity, and MSSQL database metrics.</p>
        </div>
        <div class="dash-header-actions">
            <div class="dash-db-pill <%= Stats.IsDatabaseConnected ? "is-connected" : "is-offline" %>">
                <span class="status-indicator"></span>
                <span><%= Stats.IsDatabaseConnected ? "MSSQL Active" : "Cache Fallback" %></span>
            </div>
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
                <strong>Action Required:</strong> You have <strong><%= Stats.PendingPasswordResets %> pending password reset request(s)</strong> awaiting administrator review.
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

        <!-- 4. User Portfolio Adoption & Status -->
        <div class="dash-kpi-card" data-card="completeness">
            <div class="kpi-header">
                <span class="kpi-label">PORTFOLIO ADOPTION</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path>
                        <path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.PortfolioCreationRate %>%</div>
            <div class="kpi-footer">
                <div class="dash-progress-track">
                    <div class="dash-progress-fill" style="width: <%= Math.Min(100, Math.Max(0, Stats.PortfolioCreationRate)) %>%;"></div>
                </div>
                <span class="kpi-meta"><%= Stats.TotalPortfolios %> created &bull; <%= Stats.ConfiguredPortfolios %> configured</span>
            </div>
        </div>
    </div>

    <!-- Unified 2-Column Analytics & Activity Flow -->
    <div class="dash-analytics-grid">
        <!-- Column 1: Portfolio Content Inventory by Section -->
        <div class="dash-card">
            <div class="dash-card-header" style="flex-wrap: wrap; gap: 10px; min-height: auto;">
                <div>
                    <div class="dash-card-title">
                        <span class="dash-title-dot"></span>
                        <span>Portfolio Content by Section</span>
                    </div>
                    <% 
                        int totalContentItems = Stats.TotalProjects + Stats.TotalTechStacks + Stats.TotalSkills + Stats.TotalExperiences + Stats.TotalEducations + Stats.TotalAwards + Stats.TotalHobbies;
                    %>
                    <div class="dash-sub-label" style="font-size: 11px; display: block; margin-top: 2px;">
                        Distribution of <%= totalContentItems %> items across portfolio sections
                    </div>
                </div>
                <span class="dash-pill-counter"><%= totalContentItems %> Total Items</span>
            </div>
            <div class="dash-card-body">
                <div class="dash-bars-list">
                    <!-- 1. Projects -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Projects Showcase</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalProjects %></strong> items <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalProjects * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalProjects * 100 / totalContentItems, 6) : 6 %>%; background: var(--cyan);"></div>
                        </div>
                    </div>

                    <!-- 2. Tech Stack -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Tech Stack &amp; Tools</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalTechStacks %></strong> items <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalTechStacks * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalTechStacks * 100 / totalContentItems, 6) : 6 %>%;"></div>
                        </div>
                    </div>

                    <!-- 3. Skills -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Core Skills</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalSkills %></strong> items <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalSkills * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalSkills * 100 / totalContentItems, 6) : 6 %>%; background: var(--blue-light);"></div>
                        </div>
                    </div>

                    <!-- 4. Experience -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Work Experience</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalExperiences %></strong> roles <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalExperiences * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalExperiences * 100 / totalContentItems, 6) : 6 %>%;"></div>
                        </div>
                    </div>

                    <!-- 5. Education -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Education Milestones</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalEducations %></strong> milestones <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalEducations * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalEducations * 100 / totalContentItems, 6) : 6 %>%; background: var(--cyan);"></div>
                        </div>
                    </div>

                    <!-- 6. Awards -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Awards &amp; Recognitions</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalAwards %></strong> awards <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalAwards * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalAwards * 100 / totalContentItems, 6) : 6 %>%; background: var(--blue-light);"></div>
                        </div>
                    </div>

                    <!-- 7. Hobbies -->
                    <div class="dash-bar-row">
                        <div class="dash-bar-meta">
                            <span class="dash-bar-name">Hobbies &amp; Interests</span>
                            <span class="dash-bar-count"><strong style="color: var(--text);"><%= Stats.TotalHobbies %></strong> hobbies <span style="color: var(--text-dim); font-size: 11px;">&bull; <%= totalContentItems > 0 ? (Stats.TotalHobbies * 100 / totalContentItems) : 0 %>% of total</span></span>
                        </div>
                        <div class="dash-bar-track">
                            <div class="dash-bar-fill" style="width: <%= totalContentItems > 0 ? Math.Max(Stats.TotalHobbies * 100 / totalContentItems, 6) : 6 %>%;"></div>
                        </div>
                    </div>
                </div>

                <!-- Explanation Note -->
                <div style="font-size: 11px; color: var(--text-dim); margin-top: 14px; display: flex; align-items: center; gap: 6px; line-height: 1.4;">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink: 0; color: var(--blue-light);"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>
                    <span>Percentage indicates each section's share of all <%= totalContentItems %> items published on the platform.</span>
                </div>

                <!-- Quick Content Balance Summary -->
                <div class="dash-mini-stats-box" style="margin-top: 16px;">
                    <div class="mini-stat-item">
                        <span class="mini-stat-num"><%= Stats.TotalProjects %></span>
                        <span class="mini-stat-desc">Projects</span>
                    </div>
                    <div class="mini-stat-item">
                        <span class="mini-stat-num"><%= Stats.TotalExperiences %></span>
                        <span class="mini-stat-desc">Career Roles</span>
                    </div>
                    <div class="mini-stat-item">
                        <span class="mini-stat-num"><%= Stats.TotalAwards %></span>
                        <span class="mini-stat-desc">Awards</span>
                    </div>
                    <div class="mini-stat-item">
                        <span class="mini-stat-num"><%= Stats.TotalEducations %></span>
                        <span class="mini-stat-desc">Education</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Column 2: User Engagement & Recent Activity Stream -->
        <div class="dash-card">
            <div class="dash-card-header" style="flex-wrap: wrap; gap: 10px;">
                <div>
                    <div class="dash-card-title">
                        <span class="dash-title-dot"></span>
                        <span>User Activity &amp; Sign-in Stream</span>
                    </div>
                    <div class="dash-sub-label" style="font-size: 11px; display: block; margin-top: 2px;">
                        Recent logins &amp; platform account metrics
                    </div>
                </div>
                <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="users">Manage Users &rarr;</button>
            </div>
            <div class="dash-card-body">
                <!-- User Growth Micro Badges -->
                <div class="dash-sub-kpi-grid" style="margin-bottom: 16px;">
                    <div class="sub-kpi-box">
                        <div class="sub-kpi-label">ACTIVE / INACTIVE</div>
                        <div class="sub-kpi-value"><%= Stats.ActiveUsers %> <span style="font-size: 13px; color: var(--text-dim); font-weight: 400;">/ <%= Stats.InactiveUsers %></span></div>
                    </div>
                    <div class="sub-kpi-box">
                        <div class="sub-kpi-label">NEW THIS MONTH</div>
                        <div class="sub-kpi-value highlight-cyan"><%= Stats.SignUpsThisMonth %></div>
                    </div>
                    <div class="sub-kpi-box">
                        <div class="sub-kpi-label">ADMIN ACCOUNTS</div>
                        <div class="sub-kpi-value highlight-blue"><%= Stats.AdminUsers %></div>
                    </div>
                </div>

                <!-- Recent User Sign-ins Table -->
                <div class="dash-table-wrap user-activity">
                    <table class="data-table dash-inventory-table">
                        <thead>
                            <tr>
                                <th>USER</th>
                                <th>ROLE</th>
                                <th>LOGINS</th>
                                <th>LAST SIGN-IN</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (Stats.RecentUsers != null && Stats.RecentUsers.Count > 0) { 
                                foreach (var u in Stats.RecentUsers.Take(5)) { %>
                                <tr>
                                    <td>
                                        <div class="dash-module-cell">
                                            <span class="user-avatar-initials"><%= (!string.IsNullOrEmpty(u.FullName) ? u.FullName.Substring(0, 1).ToUpper() : "U") %></span>
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
                                        <strong style="color: var(--text);"><%= u.LoginCount %></strong>
                                    </td>
                                    <td>
                                        <% if (u.LastLoginAt.HasValue) { %>
                                            <span style="font-size: 11px; color: var(--text);"><%= u.LastLoginAt.Value.ToString("MMM dd, HH:mm") %></span>
                                        <% } else { %>
                                            <span style="font-size: 11px; color: var(--text-dim); font-style: italic;">Never</span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } } else { %>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-dim); padding: 16px;">No user activity recorded yet.</td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- User Portfolios & Showcase Report Section -->
    <div class="dash-card" style="margin-top: 24px;">
        <div class="dash-card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 12px;">
            <div>
                <div class="dash-card-title">
                    <span class="dash-title-dot"></span>
                    <span>User Portfolios &amp; Showcase Report</span>
                </div>
                <span class="dash-sub-label">Multi-tenant portfolio registry. Review each user's portfolio status and preview their live website.</span>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <span class="dash-pill-counter"><%= Stats.UserPortfolioReports != null ? Stats.UserPortfolioReports.Count : 0 %> Registered Users</span>
                <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="users">Manage Users &rarr;</button>
            </div>
        </div>

        <!-- Platform Portfolio Aggregates Banner -->
        <div class="dash-sub-kpi-grid" style="margin: 16px 20px;">
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">PUBLISHED PORTFOLIOS</div>
                <div class="sub-kpi-value highlight-cyan"><%= Stats.TotalPortfolios %> <span style="font-size: 13px; color: var(--text-dim); font-weight: 400;">/ <%= Stats.TotalUsers %> users</span></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">TOTAL PROJECTS HOSTED</div>
                <div class="sub-kpi-value"><%= Stats.TotalProjects %></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">TOTAL SKILLS LISTED</div>
                <div class="sub-kpi-value"><%= Stats.TotalSkills %></div>
            </div>
            <div class="sub-kpi-box">
                <div class="sub-kpi-label">TECH STACKS USED</div>
                <div class="sub-kpi-value highlight-blue"><%= Stats.TotalTechStacks %></div>
            </div>
        </div>

        <div class="dash-table-wrap user-portfolio">
            <table class="data-table dash-inventory-table">
                <thead>
                    <tr>
                        <th>USER</th>
                        <th>PORTFOLIO STATUS</th>
                        <th>ROLE TITLE</th>
                        <th>CONTENT SUMMARY</th>
                        <th>LAST UPDATE</th>
                        <th style="text-align: right;">QUICK ACTION</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (Stats.UserPortfolioReports != null && Stats.UserPortfolioReports.Count > 0) {
                        foreach (var u in Stats.UserPortfolioReports) { %>
                        <tr>
                            <td>
                                <div class="dash-module-cell">
                                    <span class="user-avatar-initials"><%= (!string.IsNullOrEmpty(u.FullName) ? u.FullName.Substring(0, 1).ToUpper() : "U") %></span>
                                    <div>
                                        <strong><%= Server.HtmlEncode(u.FullName) %></strong>
                                        <div class="module-meta"><%= Server.HtmlEncode(u.Email) %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <% if (u.PortfolioStatus == "Configured") { %>
                                    <span class="status-pill status-active" style="background: rgba(0, 210, 106, 0.12); color: #00d26a; border-color: rgba(0, 210, 106, 0.3);">Configured</span>
                                <% } else if (u.PortfolioStatus == "In Progress") { %>
                                    <span class="status-pill" style="background: rgba(61, 127, 255, 0.12); color: var(--blue-light); border-color: rgba(61, 127, 255, 0.3);">In Progress</span>
                                <% } else { %>
                                    <span class="status-pill status-inactive">Not Started</span>
                                <% } %>
                            </td>
                            <td>
                                <span style="font-size: var(--t-xs); color: var(--text);"><%= Server.HtmlEncode(u.RoleTitle) %></span>
                            </td>
                            <td>
                                <div style="font-size: var(--t-xs); display: flex; gap: 8px; flex-wrap: wrap;">
                                    <span class="kpi-badge kpi-badge-cyan" style="padding: 2px 6px; font-size: 11px;"><%= u.ProjectsCount %> Projects</span>
                                    <span class="kpi-badge kpi-badge-blue" style="padding: 2px 6px; font-size: 11px;"><%= u.SkillsCount %> Skills</span>
                                    <span style="color: var(--text-dim); padding-top: 2px;"><%= u.TechCount %> Techs</span>
                                </div>
                            </td>
                            <td>
                                <% if (u.LastProfileUpdate.HasValue) { %>
                                    <span style="font-size: 11px; color: var(--text);"><%= u.LastProfileUpdate.Value.ToString("MMM dd, yyyy") %></span>
                                <% } else { %>
                                    <span style="font-size: 11px; color: var(--text-dim); font-style: italic;">Never</span>
                                <% } %>
                            </td>
                            <td style="text-align: right;">
                                <a href='<%= ResolveUrl("~/Default.aspx?userId=" + u.UserId) %>' target="_blank" class="btn btn-secondary btn-sm" style="display: inline-flex; align-items: center; gap: 6px; text-decoration: none;">
                                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                                        <circle cx="12" cy="12" r="3"></circle>
                                    </svg>
                                    <span>Preview Website</span>
                                </a>
                            </td>
                        </tr>
                    <% } } else { %>
                        <tr>
                            <td colspan="6" style="text-align: center; color: var(--text-dim); padding: 24px;">No user portfolios registered yet.</td>
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
