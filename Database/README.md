# Personal Portfolio Database Documentation

This folder contains database migrations, schemas, and setup instructions for the **`personal_portfolio_db`** (Local) and **`db68942`** (Remote Production) databases on Microsoft SQL Server (MSSQL).

---

## 🗄️ Database Details

- **Local Database Name:** `personal_portfolio_db`
- **Remote Database Name:** `db68942` (databaseasp.net)
- **Database Engine:** Microsoft SQL Server / SQL Server Express (`.\SQLEXPRESS`)
- **Naming Convention:** `snake_case` for all table names (`*_tbl`) and column names (`user_id`, `first_name`, etc.)

---

## 📂 Folder Structure

```
Database/
│
├── README.md               # Main database documentation and setup guide
│
├── Migration/              # Sequential SQL migration files
│   ├── 001_create_database_and_users_tbl.sql
│   ├── 002_create_portfolio_tables_and_password_resets.sql
│   ├── 003_add_profile_image_to_users_tbl.sql
│   ├── 004_seed_default_portfolio_data.sql
│   └── 005_portfolio_stored_procedures.sql
│
└── Schema/                 # Schema dictionary and table documentation
    └── schema.md
```

---

## 🚀 Migration Workflow & Guidelines

Whenever a new query or schema modification is created:

1. **Create a Migration File in `Database/Migration/`**:
   - Use the naming format: `###_<action>_<table_name>.sql`
   - *Example:* `001_create_database_and_users_tbl.sql`, `005_portfolio_stored_procedures.sql`
2. **Update the Schema Documentation in `Database/Schema/schema.md`**:
   - Add the table structure, column data types, constraints, nullability, and default values.
3. **Execute the Migration in SSMS**:
   - Run the script against your SQL Server instance (`.\SQLEXPRESS` for local or `db68942.databaseasp.net` for remote).

---

## 💻 Connection Strings

### `Web.config` Configuration:

```xml
<connectionStrings>
  <!-- Local Development Connection String (SQL Express) -->
  <add name="PortfolioDB_Local" 
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=personal_portfolio_db;Integrated Security=True;Persist Security Info=False;Pooling=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Application Name=&quot;SQL Server Management Studio&quot;;" 
       providerName="System.Data.SqlClient" />

  <!-- Remote Production Connection String (databaseasp.net) -->
  <add name="PortfolioDB_Remote" 
       connectionString="Server=db68942.databaseasp.net;Database=db68942;User Id=db68942;Password=Xm7-!Ae5Ys4_;TrustServerCertificate=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

---

## 📋 Migration History

| Version | File | Description | Applied Date |
| :---: | :--- | :--- | :---: |
| `001` | [`001_create_database_and_users_tbl.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/001_create_database_and_users_tbl.sql) | Initializes `personal_portfolio_db` and creates `users_tbl` | 2026-09-17 |
| `002` | [`002_create_portfolio_tables_and_password_resets.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/002_create_portfolio_tables_and_password_resets.sql) | Creates `password_resets_tbl` and dynamic portfolio tables (`profile_tbl`, `tech_stacks_tbl`, `skills_tbl`, `experiences_tbl`, `projects_tbl`, `educations_tbl`, `awards_tbl`, `hobbies_tbl`) | 2026-09-17 |
| `003` | [`003_add_profile_image_to_users_tbl.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/003_add_profile_image_to_users_tbl.sql) | Adds `profile_image` column to `users_tbl` | 2026-09-17 |
| `004` | [`004_seed_default_portfolio_data.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/004_seed_default_portfolio_data.sql) | Seeds initial showcase data extracted from `Default.aspx` | 2026-09-17 |
| `005` | [`005_portfolio_stored_procedures.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/005_portfolio_stored_procedures.sql) | Complete MSSQL Stored Procedures for all portfolio operations, auth workflows, user management, and `sp_GetDashboardStatistics` | 2026-09-20 |
| `006` | [`006_add_user_activity_and_login_metrics.sql`](file:///c:/Users/QCU/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/006_add_user_activity_and_login_metrics.sql) | Adds `last_login_at`, `login_count` columns to `users_tbl`, creates `user_logins_tbl`, and adds `sp_RecordUserLogin` | 2026-09-20 |


