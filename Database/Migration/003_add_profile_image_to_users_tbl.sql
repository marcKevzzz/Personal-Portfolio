-- =============================================================
-- Migration: 003_add_profile_image_to_users_tbl.sql
-- Description: Adds profile_image column to users_tbl for avatar storage
-- Created: 2026-09-17
-- =============================================================

USE personal_portfolio_db;
GO

IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'[dbo].[users_tbl]') 
    AND name = 'profile_image'
)
BEGIN
    ALTER TABLE users_tbl
    ADD profile_image NVARCHAR(500) NULL;
END
GO
