# 🌐 Personal Portfolio Platform

[![Live Demo](https://img.shields.io/badge/Live_Demo-marckevzzz.runasp.net-00d2ff?style=for-the-badge&logo=google-chrome&logoColor=white)](http://marckevzzz.runasp.net)
[![ASP.NET](https://img.shields.io/badge/ASP.NET_WebForms-4.7.2-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![MSSQL](https://img.shields.io/badge/SQL_Server-100%25_Stored_Procedures-CC292B?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)](https://www.microsoft.com/sql-server)

> 🔗 **Live Website:** [http://marckevzzz.runasp.net](http://marckevzzz.runasp.net)

A multi-user personal portfolio web application built with **ASP.NET WebForms (.NET Framework 4.7.2)** and **Microsoft SQL Server (MSSQL)**. It allows developers and creators to design, customize, and publish interactive portfolios, complete with an administrative supervision suite and a 100% stored-procedure database architecture.

---

## ✨ Features

- **Personalized Showcase Pages:** Unique public portfolio per user (`Default.aspx?userId={id}`).
- **Interactive Modules:** Tech stack badges, skills & proficiency meters, career experience timeline, project showcases, education, awards, hobbies, and social channels.
- **Admin Supervision Panel:**
  - Real-time KPI cards (portfolio items, active accounts, login engagement, website adoption rate).
  - User activity stream with instant site preview links and status filters.
  - User moderation: enable/disable accounts, cascade delete, and password reset approvals.
- **Security & Data Integrity:**
  - 100% Stored Procedure execution via ADO.NET (zero inline SQL).
  - Cryptographic password hashing (PBKDF2 / SHA-256).
  - Automatic database failover support between remote and local SQL Server instances.

---

## 🛠️ Tech Stack

- **Backend:** C#, ASP.NET WebForms (.NET Framework 4.7.2), ADO.NET
- **Database:** Microsoft SQL Server (MSSQL), Stored Procedures, Views
- **Frontend:** Vanilla HTML5, Modular CSS3 (Custom Variables, Glassmorphism), GSAP Animations
- **Hosting:** MonsterASP.NET (`marckevzzz.runasp.net`), IIS Express (Local)

---

## 🚀 Quick Setup

### 1. Prerequisites
- [Visual Studio 2022](https://visualstudio.microsoft.com/) with **ASP.NET and web development** workload.
- [Microsoft SQL Server](https://www.microsoft.com/sql-server) (or SQL Server Express `.\SQLEXPRESS`).

### 2. Clone Repository
```bash
git clone https://github.com/marcKevzzz/Personal-Portfolio.git
cd Personal-Portfolio
```

### 3. Database Setup
Execute `24-1639DelMundoPersonalPortfolio/Data/Portfolio_StoredProcedures.sql` in **SSMS** against your database (`personal_portfolio_db` or remote `db68942`).

### 4. Connection Strings (`connections.config`)
Configure `24-1639DelMundoPersonalPortfolio/connections.config`:

```xml
<connectionStrings>
  <!-- Remote Production Database (Public Host) -->
  <add name="PortfolioDB" 
       connectionString="Server=db68942.public.databaseasp.net;Database=db68942;User Id=db68942;Password=YOUR_PASSWORD;Encrypt=True;TrustServerCertificate=True;MultipleActiveResultSets=True;" 
       providerName="System.Data.SqlClient" />

  <!-- Local Development Database (Optional) -->
  <add name="PortfolioDB_Local" 
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=personal_portfolio_db;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

### 5. Run
Open `24-1639DelMundoPersonalPortfolio.slnx` in Visual Studio and press **F5** (or run via **IIS Express**).

---

## 👤 Author

**Marc Kevin Del Mundo**
- 🌐 Portfolio: [http://marckevzzz.runasp.net](http://marckevzzz.runasp.net)
- 🐙 GitHub: [@marcKevzzz](https://github.com/marcKevzzz)
