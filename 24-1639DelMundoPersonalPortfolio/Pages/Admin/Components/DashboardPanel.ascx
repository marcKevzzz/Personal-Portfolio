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

        <!-- 4. Profile & System Health -->
        <div class="dash-kpi-card" data-card="completeness">
            <div class="kpi-header">
                <span class="kpi-label">PROFILE HEALTH</span>
                <span class="kpi-icon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                </span>
            </div>
            <div class="kpi-value"><%= Stats.ProfileCompletenessPct %>%</div>
            <div class="kpi-footer">
                <div class="dash-progress-track">
                    <div class="dash-progress-fill" style="width: <%= Stats.ProfileCompletenessPct %>%;"></div>
                </div>
                <span class="kpi-meta"><%= Stats.ExperienceYears %> yrs exp</span>
            </div>
        </div>
    </div>

    <!-- Unified 2-Column Analytics & Activity Flow -->
    <div class="dash-analytics-grid">
        <!-- Column 1: Technology & Content Domain Breakdown -->
        <div class="dash-card">
            <div class="dash-card-header">
                <div class="dash-card-title">
                    <span class="dash-title-dot"></span>
                    <span>Technology Distribution by Domain</span>
                </div>
                <span class="dash-pill-counter"><%= Stats.TotalTechStacks %> Items</span>
            </div>
            <div class="dash-card-body">
                <div class="dash-bars-list">
                    <% if (Stats.TechCategoryStats != null && Stats.TechCategoryStats.Count > 0) { 
                        foreach (var cat in Stats.TechCategoryStats) { %>
                        <div class="dash-bar-row">
                            <div class="dash-bar-meta">
                                <span class="dash-bar-name"><%= Server.HtmlEncode(cat.Category) %></span>
                                <span class="dash-bar-count"><%= cat.ItemCount %> items (<%= cat.Percentage %>%)</span>
                            </div>
                            <div class="dash-bar-track">
                                <div class="dash-bar-fill" style="width: <%= Math.Max(cat.Percentage, 5) %>%;"></div>
                            </div>
                        </div>
                    <% } } else { %>
                        <div class="dash-bar-row">
                            <div class="dash-bar-meta"><span class="dash-bar-name">Frontend</span><span class="dash-bar-count">5 items (28%)</span></div>
                            <div class="dash-bar-track"><div class="dash-bar-fill" style="width: 28%;"></div></div>
                        </div>
                        <div class="dash-bar-row">
                            <div class="dash-bar-meta"><span class="dash-bar-name">3D &amp; Motion</span><span class="dash-bar-count">4 items (22%)</span></div>
                            <div class="dash-bar-track"><div class="dash-bar-fill" style="width: 22%;"></div></div>
                        </div>
                        <div class="dash-bar-row">
                            <div class="dash-bar-meta"><span class="dash-bar-name">Backend &amp; Database</span><span class="dash-bar-count">5 items (28%)</span></div>
                            <div class="dash-bar-track"><div class="dash-bar-fill" style="width: 28%;"></div></div>
                        </div>
                        <div class="dash-bar-row">
                            <div class="dash-bar-meta"><span class="dash-bar-name">Tools &amp; DevOps</span><span class="dash-bar-count">4 items (22%)</span></div>
                            <div class="dash-bar-track"><div class="dash-bar-fill" style="width: 22%;"></div></div>
                        </div>
                    <% } %>
                </div>

                <!-- Quick Content Balance Summary -->
                <div class="dash-mini-stats-box" style="margin-top: 20px;">
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
                        <span class="mini-stat-desc">Milestones</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Column 2: User Engagement & Recent Activity Stream -->
        <div class="dash-card">
            <div class="dash-card-header">
                <div class="dash-card-title">
                    <span class="dash-title-dot"></span>
                    <span>User Activity &amp; Sign-in Stream</span>
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
                <div class="dash-table-wrap">
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

    <!-- Section Content Inventory Table & Management Routing -->
    <div class="dash-card" style="margin-top: 24px;">
        <div class="dash-card-header">
            <div class="dash-card-title">
                <span class="dash-title-dot"></span>
                <span>Portfolio Content Inventory &amp; Module Health</span>
            </div>
            <span class="dash-sub-label">Click 'Manage' to jump directly to any configuration panel</span>
        </div>
        <div class="dash-table-wrap">
            <table class="data-table dash-inventory-table">
                <thead>
                    <tr>
                        <th>MODULE / SECTION</th>
                        <th>STORED RECORDS</th>
                        <th>STATUS</th>
                        <th>DATA SOURCE</th>
                        <th>QUICK ACTION</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path><circle cx="12" cy="7" r="4"></circle></svg>
                                </span>
                                <div>
                                    <strong>Public Profile &amp; Hero</strong>
                                    <div class="module-meta">Hero headings, bio, aliases &amp; contact links</div>
                                </div>
                            </div>
                        </td>
                        <td><strong>1</strong> Profile Record</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td><%= Stats.DatabaseSource %></td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="profile">Manage Profile &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 2 7 12 12 22 7 12 2"></polygon><polyline points="2 17 12 22 22 17"></polyline><polyline points="2 12 12 17 22 12"></polyline></svg>
                                </span>
                                <div>
                                    <strong>Tech Stack</strong>
                                    <div class="module-meta">Frameworks, languages, database &amp; SVG icons</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalTechStacks %></strong> Tech Items</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>tech_stacks_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="techstack">Manage Tech Stack &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
                                </span>
                                <div>
                                    <strong>Skills &amp; Capabilities</strong>
                                    <div class="module-meta">Categorized technical and architecture skillsets</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalSkills %></strong> Skill Categories</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>skills_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="skills">Manage Skills &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path></svg>
                                </span>
                                <div>
                                    <strong>Projects &amp; Showcase</strong>
                                    <div class="module-meta">Case studies, live preview links &amp; screenshots</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalProjects %></strong> Projects</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>projects_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="projects">Manage Projects &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2" ry="2"></rect><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"></path></svg>
                                </span>
                                <div>
                                    <strong>Experience &amp; Work History</strong>
                                    <div class="module-meta">Career milestones, roles &amp; technical achievements</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalExperiences %></strong> Positions</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>experiences_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="experience">Manage Experience &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
                                </span>
                                <div>
                                    <strong>Education &amp; Background</strong>
                                    <div class="module-meta">Academic history and degrees</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalEducations %></strong> Entries</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>educations_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="education">Manage Education &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="8" r="7"></circle><polyline points="8.21 13.89 7 23 12 20 17 23 15.79 13.88"></polyline></svg>
                                </span>
                                <div>
                                    <strong>Awards &amp; Recognition</strong>
                                    <div class="module-meta">Honors, hackathons &amp; certifications</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalAwards %></strong> Honors</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>awards_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="awards">Manage Awards &rarr;</button>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <div class="dash-module-cell">
                                <span class="module-icon">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>
                                </span>
                                <div>
                                    <strong>Hobbies &amp; Interests</strong>
                                    <div class="module-meta">Personal passions and recreational activities</div>
                                </div>
                            </div>
                        </td>
                        <td><strong><%= Stats.TotalHobbies %></strong> Hobbies</td>
                        <td><span class="status-pill status-active">Active</span></td>
                        <td>hobbies_tbl</td>
                        <td>
                            <button type="button" class="btn btn-secondary btn-sm jump-panel-btn" data-target="hobbies">Manage Hobbies &rarr;</button>
                        </td>
                    </tr>
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
