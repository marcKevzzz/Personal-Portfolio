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
            <span>Viewing <strong><asp:Literal ID="litViewingUserName" runat="server" /></strong>'s Personal Website (Admin Mode)</span>
            <a href="<%= ResolveUrl("~/Pages/Admin/Admin.aspx") %>" class="btn btn-secondary" style="padding: 4px 12px; font-size: 11px; text-decoration: none;">&larr; Back to Admin Console</a>
        </div>
    </asp:Panel>
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
