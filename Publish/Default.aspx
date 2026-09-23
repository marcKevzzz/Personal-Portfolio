<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Default" %>

<%@ Register Src="~/Components/Default/NavSection.ascx" TagPrefix="portfolio" TagName="NavSection" %>
<%@ Register Src="~/Components/Default/HeroSection.ascx" TagPrefix="portfolio" TagName="HeroSection" %>
<%@ Register Src="~/Components/Default/BasicInfoSection.ascx" TagPrefix="portfolio" TagName="BasicInfoSection" %>
<%@ Register Src="~/Components/Default/TechStackSection.ascx" TagPrefix="portfolio" TagName="TechStackSection" %>
<%@ Register Src="~/Components/Default/SkillsSection.ascx" TagPrefix="portfolio" TagName="SkillsSection" %>
<%@ Register Src="~/Components/Default/ExperienceSection.ascx" TagPrefix="portfolio" TagName="ExperienceSection" %>
<%@ Register Src="~/Components/Default/ProjectsSection.ascx" TagPrefix="portfolio" TagName="ProjectsSection" %>
<%@ Register Src="~/Components/Default/EducationSection.ascx" TagPrefix="portfolio" TagName="EducationSection" %>
<%@ Register Src="~/Components/Default/AwardsSection.ascx" TagPrefix="portfolio" TagName="AwardsSection" %>
<%@ Register Src="~/Components/Default/HobbiesSection.ascx" TagPrefix="portfolio" TagName="HobbiesSection" %>
<%@ Register Src="~/Components/Default/ContactSection.ascx" TagPrefix="portfolio" TagName="ContactSection" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:Panel ID="pnlAdminViewingBanner" runat="server" Visible="false" CssClass="admin-viewing-banner">
        <div class="banner-inner">
            <span class="banner-text">Viewing <strong><asp:Literal ID="litViewingUserName" runat="server" /></strong>'s Portfolio</span>
            <div class="banner-actions">
                <asp:HyperLink ID="lnkReturnToSelf" runat="server" CssClass="banner-btn" Text="Return" />
                <button type="button" class="banner-btn" onclick="openPortfolioSwitcher();">
                    <span>Explore Portfolios</span>
                    <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"></path></svg>
                </button>
            </div>
        </div>
    </asp:Panel>

    <!-- Explore Portfolios Switcher Modal -->
    <div id="portfolioSwitcherModal" class="modal-backdrop" style="display: none;">
        <div class="modal-dialog" style="max-width: 480px; width: 100%;">
            <div class="modal-header">
                <div>
                    <div class="modal-kicker">COMMUNITY DIRECTORY</div>
                    <h3 class="modal-title">Explore User Portfolios</h3>
                </div>
                <button type="button" class="modal-close-btn" onclick="closePortfolioSwitcher();">&times;</button>
            </div>
            <div class="modal-scroll-body" style="max-height: 380px; overflow-y: auto; margin: 16px 0; padding-right: 4px;">
                <asp:Repeater ID="rptUserPortfolios" runat="server">
                    <ItemTemplate>
                        <a href='<%# ResolveUrl("~/Default.aspx?userId=" + Eval("UserId")) %>' class="user-portfolio-row" style="display: flex; align-items: center; justify-content: space-between; padding: 12px 14px; margin-bottom: 4px; background: var(--bg-1); border: 1px solid var(--line-soft); border-radius: 4px; color: var(--text); text-decoration: none; transition: all 0.2s ease;">
                            <div>
                                <strong style="display: block; font-size: 13px;"><%# Server.HtmlEncode(Eval("FullName").ToString()) %></strong>
                                <span style="font-size: 11px; color: var(--text-dim);"><%# Server.HtmlEncode(Eval("Email").ToString()) %></span>
                            </div>
                            <span style="font-size: 11px; color: var(--cyan); font-family: var(--f-display); letter-spacing: 0.04em;">VIEW &rarr;</span>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>

    <script>
        function openPortfolioSwitcher() {
            var modal = document.getElementById('portfolioSwitcherModal');
            if (modal) {
                modal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        }
        function closePortfolioSwitcher() {
            var modal = document.getElementById('portfolioSwitcherModal');
            if (modal) {
                modal.style.display = 'none';
                document.body.style.overflow = '';
            }
        }
    </script>

    <portfolio:NavSection ID="NavSectionControl" runat="server" />
    <portfolio:HeroSection ID="HeroSectionControl" runat="server" />
    <portfolio:BasicInfoSection ID="BasicInfoSectionControl" runat="server" />
    <portfolio:TechStackSection ID="TechStackSectionControl" runat="server" />
    <portfolio:SkillsSection ID="SkillsSectionControl" runat="server" />
    <portfolio:ExperienceSection ID="ExperienceSectionControl" runat="server" />
    <portfolio:ProjectsSection ID="ProjectsSectionControl" runat="server" />
    <portfolio:EducationSection ID="EducationSectionControl" runat="server" />
    <portfolio:AwardsSection ID="AwardsSectionControl" runat="server" />
    <portfolio:HobbiesSection ID="HobbiesSectionControl" runat="server" />
    <portfolio:ContactSection ID="ContactSectionControl" runat="server" />
</asp:Content>
