# Personal Portfolio Database Documentation

This folder contains database migrations, schemas, and setup instructions for the **`personal_portfolio_db`** database on Microsoft SQL Server (MSSQL).

---

## 🗄️ Database Details

- **Database Name:** `personal_portfolio_db`
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
│   └── 002_create_portfolio_tables_and_password_resets.sql
│
└── Schema/                 # Schema dictionary and table documentation
    └── schema.md
```

---

## 🚀 Migration Workflow & Guidelines

Whenever a new query or schema modification is created:

1. **Create a Migration File in `Database/Migration/`**:
   - Use the naming format: `###_<action>_<table_name>.sql`
   - *Example:* `001_create_database_and_users_tbl.sql`, `002_create_portfolio_tables_and_password_resets.sql`
2. **Update the Schema Documentation in `Database/Schema/schema.md`**:
   - Add the table structure, column data types, constraints, nullability, and default values.
3. **Execute the Migration in SSMS**:
   - Run the script against your SQL Server instance (`.\SQLEXPRESS`).

---

## 💻 Connection Strings

### Local Development (`Web.config`):
```xml
<connectionStrings>
  <add name="PortfolioDB" 
       connectionString="Server=.\SQLEXPRESS;Database=personal_portfolio_db;Integrated Security=True;TrustServerCertificate=True;" 
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

---

## 📋 Migration History

| Version | File | Description | Applied Date |
| :---: | :--- | :--- | :---: |
| `001` | [`001_create_database_and_users_tbl.sql`](file:///c:/Users/Admin/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/001_create_database_and_users_tbl.sql) | Initializes `personal_portfolio_db` and creates `users_tbl` | 2026-09-17 |
| `002` | [`002_create_portfolio_tables_and_password_resets.sql`](file:///c:/Users/Admin/source/repos/24-1639DelMundoPersonalPortfolio/Database/Migration/002_create_portfolio_tables_and_password_resets.sql) | Creates `password_resets_tbl` and dynamic portfolio tables (`profile_tbl`, `tech_stacks_tbl`, `skills_tbl`, `experiences_tbl`, `projects_tbl`, `educations_tbl`, `awards_tbl`, `hobbies_tbl`) | 2026-09-17 |
