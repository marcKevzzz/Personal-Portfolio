<%@ Page Title="Portfolio Builder" Language="C#" MasterPageFile="~/Pages/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="PortfolioBuilder.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Pages.User.PortfolioBuilder" %>
<%@ MasterType VirtualPath="~/Pages/Admin/Admin.Master" %>

<%@ Register Src="~/Pages/User/Components/UserAccountPanel.ascx" TagPrefix="uc" TagName="UserAccountPanel" %>
<%@ Register Src="~/Pages/Admin/Components/ProfilePanel.ascx" TagPrefix="uc" TagName="ProfilePanel" %>
<%@ Register Src="~/Pages/Admin/Components/TechStackPanel.ascx" TagPrefix="uc" TagName="TechStackPanel" %>
<%@ Register Src="~/Pages/Admin/Components/SkillsPanel.ascx" TagPrefix="uc" TagName="SkillsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/ExperiencePanel.ascx" TagPrefix="uc" TagName="ExperiencePanel" %>
<%@ Register Src="~/Pages/Admin/Components/ProjectsPanel.ascx" TagPrefix="uc" TagName="ProjectsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/EducationPanel.ascx" TagPrefix="uc" TagName="EducationPanel" %>
<%@ Register Src="~/Pages/Admin/Components/AwardsPanel.ascx" TagPrefix="uc" TagName="AwardsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/HobbiesPanel.ascx" TagPrefix="uc" TagName="HobbiesPanel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="adminHead" runat="server">
    <!-- User Portfolio Builder Page Head Extensions -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="AdminMainContent" runat="server">
    <!-- User Account / Identification Settings -->
    <uc:UserAccountPanel ID="ucUserAccountPanel" runat="server" />

    <!-- Personal Portfolio Website Content Modules -->
    <uc:ProfilePanel ID="ucProfilePanel" runat="server" />
    <uc:TechStackPanel ID="ucTechStackPanel" runat="server" />
    <uc:SkillsPanel ID="ucSkillsPanel" runat="server" />
    <uc:ExperiencePanel ID="ucExperiencePanel" runat="server" />
    <uc:ProjectsPanel ID="ucProjectsPanel" runat="server" />
    <uc:EducationPanel ID="ucEducationPanel" runat="server" />
    <uc:AwardsPanel ID="ucAwardsPanel" runat="server" />
    <uc:HobbiesPanel ID="ucHobbiesPanel" runat="server" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="adminScripts" runat="server">
</asp:Content>
