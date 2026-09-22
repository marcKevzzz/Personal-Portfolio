<%@ Page Title="Admin Console" Language="C#" MasterPageFile="~/Pages/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="_24_1639DelMundoPersonalPortfolio.Admin" ValidateRequest="false" %>

<%@ Register Src="~/Pages/Admin/Components/DashboardPanel.ascx" TagPrefix="admin" TagName="DashboardPanel" %>
<%@ Register Src="~/Pages/Admin/Components/ProfilePanel.ascx" TagPrefix="admin" TagName="ProfilePanel" %>
<%@ Register Src="~/Pages/Admin/Components/TechStackPanel.ascx" TagPrefix="admin" TagName="TechStackPanel" %>
<%@ Register Src="~/Pages/Admin/Components/SkillsPanel.ascx" TagPrefix="admin" TagName="SkillsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/ExperiencePanel.ascx" TagPrefix="admin" TagName="ExperiencePanel" %>
<%@ Register Src="~/Pages/Admin/Components/ProjectsPanel.ascx" TagPrefix="admin" TagName="ProjectsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/EducationPanel.ascx" TagPrefix="admin" TagName="EducationPanel" %>
<%@ Register Src="~/Pages/Admin/Components/AwardsPanel.ascx" TagPrefix="admin" TagName="AwardsPanel" %>
<%@ Register Src="~/Pages/Admin/Components/HobbiesPanel.ascx" TagPrefix="admin" TagName="HobbiesPanel" %>
<%@ Register Src="~/Pages/Admin/Components/UsersPanel.ascx" TagPrefix="admin" TagName="UsersPanel" %>
<%@ Register Src="~/Pages/Admin/Components/AdminProfilePanel.ascx" TagPrefix="admin" TagName="AdminProfilePanel" %>

<asp:Content ID="Content1" ContentPlaceHolderID="adminHead" runat="server">
    <!-- Page-specific head tags or stylesheet overrides if needed -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="AdminMainContent" runat="server">
    <!-- 0. STATISTIC REPORTS DASHBOARD -->
    <admin:DashboardPanel runat="server" ID="ucDashboardPanel" />

    <!-- 1. USERS -->
    <admin:UsersPanel runat="server" ID="ucUsersPanel" />

    <!-- 2. ADMIN ACCOUNT & CREDENTIALS -->
    <admin:AdminProfilePanel runat="server" ID="ucAdminProfilePanel" />
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="adminScripts" runat="server">
    <!-- Specific inline page scripts if needed -->
</asp:Content>
