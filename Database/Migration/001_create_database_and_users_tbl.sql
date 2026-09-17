-- =============================================================
-- Migration: 001_create_database_and_users_tbl.sql
-- Description: Initializes personal_portfolio_db and creates users_tbl
-- Created: 2026-09-17
-- =============================================================

-- 1. Create Database if not exists
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'personal_portfolio_db')
BEGIN
    CREATE DATABASE personal_portfolio_db;
END
GO

USE personal_portfolio_db;
GO

-- 2. Create users_tbl with Enum Role CHECK Constraint
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users_tbl]') AND type in (N'U'))
BEGIN
    CREATE TABLE users_tbl (
        user_id INT IDENTITY(1,1) PRIMARY KEY,
        first_name NVARCHAR(150) NOT NULL,
        last_name NVARCHAR(150) NOT NULL,
        email NVARCHAR(150) NOT NULL UNIQUE,
        password_hash NVARCHAR(256) NOT NULL,
        user_role NVARCHAR(50) DEFAULT 'User' CHECK (user_role IN ('Admin', 'User')),
        is_active BIT DEFAULT 1,
        created_at DATETIME DEFAULT GETDATE()
    );
END
GO
