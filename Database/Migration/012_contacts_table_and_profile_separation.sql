-- ============================================================================
-- Migration 012: Dedicated contacts_tbl & Separation from profile_tbl
-- ============================================================================
-- Description:
-- 1. Creates dbo.contacts_tbl to support diverse contact and social media channels
--    (Email, Phone, GitHub, LinkedIn, Facebook, Instagram, Discord, Twitter / X, etc.).
-- 2. Migrates existing email, github_url, and linkedin_url records from profile_tbl
--    into contacts_tbl so no user contact details are lost.
-- 3. Modifies profile_tbl to ensure contact columns are nullable and decoupled.
-- 4. Creates stored procedures: sp_GetContacts, sp_SaveContact, sp_DeleteContact.
-- ============================================================================

-- 1. Create contacts_tbl if it does not already exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'contacts_tbl')
BEGIN
    CREATE TABLE dbo.contacts_tbl (
        contact_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        platform NVARCHAR(50) NOT NULL,
        contact_label NVARCHAR(100) NULL,
        contact_value NVARCHAR(500) NOT NULL,
        contact_url NVARCHAR(500) NULL,
        display_order INT NOT NULL DEFAULT 0,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE(),
        CONSTRAINT FK_contacts_tbl_users FOREIGN KEY (user_id) REFERENCES dbo.users_tbl(user_id) ON DELETE CASCADE
    );

    CREATE NONCLUSTERED INDEX IX_contacts_user_id ON dbo.contacts_tbl(user_id);
    PRINT 'Created dbo.contacts_tbl successfully.';
END
ELSE
BEGIN
    PRINT 'dbo.contacts_tbl already exists.';
END
GO

-- 2. Migrate existing profile_tbl contact channels into contacts_tbl
IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'contacts_tbl')
BEGIN
    -- Migrate Email
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'email')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'Email', 'Email', p.email, 'mailto:' + p.email, 1, 1
        FROM dbo.profile_tbl p
        WHERE p.email IS NOT NULL AND RTRIM(LTRIM(p.email)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'Email'
          );
    END

    -- Migrate GitHub URL
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'github_url')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'GitHub', 'GitHub', p.github_url, p.github_url, 2, 1
        FROM dbo.profile_tbl p
        WHERE p.github_url IS NOT NULL AND RTRIM(LTRIM(p.github_url)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'GitHub'
          );
    END

    -- Migrate LinkedIn URL
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'linkedin_url')
    BEGIN
        INSERT INTO dbo.contacts_tbl (user_id, platform, contact_label, contact_value, contact_url, display_order, is_active)
        SELECT p.user_id, 'LinkedIn', 'LinkedIn', p.linkedin_url, p.linkedin_url, 3, 1
        FROM dbo.profile_tbl p
        WHERE p.linkedin_url IS NOT NULL AND RTRIM(LTRIM(p.linkedin_url)) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM dbo.contacts_tbl c 
              WHERE c.user_id = p.user_id AND c.platform = 'LinkedIn'
          );
    END

    PRINT 'Migrated legacy profile contact records into contacts_tbl.';
END
GO

-- 3. Ensure profile_tbl contact columns are nullable (or optional)
IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'email' AND IS_NULLABLE = 'NO'
)
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN email NVARCHAR(255) NULL;
END
GO

IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'github_url' AND IS_NULLABLE = 'NO'
)
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN github_url NVARCHAR(255) NULL;
END
GO

IF EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'profile_tbl' AND COLUMN_NAME = 'linkedin_url' AND IS_NULLABLE = 'NO'
)
BEGIN
    ALTER TABLE dbo.profile_tbl ALTER COLUMN linkedin_url NVARCHAR(255) NULL;
END
GO

-- 4. Stored Procedure: sp_GetContacts
CREATE OR ALTER PROCEDURE dbo.sp_GetContacts
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        contact_id,
        user_id,
        platform,
        ISNULL(contact_label, '') AS contact_label,
        contact_value,
        ISNULL(contact_url, '') AS contact_url,
        display_order,
        is_active,
        created_at,
        updated_at
    FROM dbo.contacts_tbl
    WHERE user_id = @user_id AND is_active = 1
    ORDER BY display_order ASC, contact_id ASC;
END;
GO

-- 5. Stored Procedure: sp_SaveContact
CREATE OR ALTER PROCEDURE dbo.sp_SaveContact
    @contact_id INT = 0,
    @user_id INT,
    @platform NVARCHAR(50),
    @contact_label NVARCHAR(100) = NULL,
    @contact_value NVARCHAR(500),
    @contact_url NVARCHAR(500) = NULL,
    @display_order INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @contact_id > 0 AND EXISTS (SELECT 1 FROM dbo.contacts_tbl WHERE contact_id = @contact_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.contacts_tbl
        SET platform = @platform,
            contact_label = @contact_label,
            contact_value = @contact_value,
            contact_url = @contact_url,
            display_order = @display_order,
            updated_at = GETDATE()
        WHERE contact_id = @contact_id AND user_id = @user_id;

        SELECT @contact_id AS contact_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.contacts_tbl (
            user_id,
            platform,
            contact_label,
            contact_value,
            contact_url,
            display_order,
            is_active,
            created_at,
            updated_at
        )
        VALUES (
            @user_id,
            @platform,
            @contact_label,
            @contact_value,
            @contact_url,
            @display_order,
            1,
            GETDATE(),
            GETDATE()
        );

        SELECT SCOPE_IDENTITY() AS contact_id;
    END
END;
GO

-- 6. Stored Procedure: sp_DeleteContact
CREATE OR ALTER PROCEDURE dbo.sp_DeleteContact
    @contact_id INT,
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.contacts_tbl
    WHERE contact_id = @contact_id AND user_id = @user_id;

    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

PRINT 'Contacts procedures created successfully.';
GO
