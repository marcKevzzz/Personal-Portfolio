-- ============================================================================
-- Migration 011: Expand tech_stacks_tbl.icon_path to NVARCHAR(MAX) & Support Direct SVG Tags
-- ============================================================================
-- Description:
-- Modifies tech_stacks_tbl.icon_path from NVARCHAR(255) to NVARCHAR(MAX) so that
-- direct inline SVG markup can be saved in the database rather than writing SVG files
-- to disk and saving file paths. Also updates dbo.sp_SaveTechStack to accept NVARCHAR(MAX).
-- ============================================================================

IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'tech_stacks_tbl' 
      AND COLUMN_NAME = 'icon_path' 
      AND (CHARACTER_MAXIMUM_LENGTH <> -1 OR DATA_TYPE <> 'nvarchar')
)
BEGIN
    ALTER TABLE dbo.tech_stacks_tbl ALTER COLUMN icon_path NVARCHAR(MAX) NOT NULL;
    PRINT 'Altered tech_stacks_tbl.icon_path to NVARCHAR(MAX).';
END
ELSE
BEGIN
    PRINT 'tech_stacks_tbl.icon_path is already NVARCHAR(MAX).';
END
GO

-- ----------------------------------------------------------------------------
-- Update sp_SaveTechStack to use NVARCHAR(MAX) for @icon_path
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_SaveTechStack
    @tech_id INT = 0,
    @user_id INT,
    @group_name NVARCHAR(100),
    @label NVARCHAR(100),
    @icon_path NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    IF @tech_id > 0 AND EXISTS (SELECT 1 FROM dbo.tech_stacks_tbl WHERE tech_id = @tech_id AND user_id = @user_id)
    BEGIN
        UPDATE dbo.tech_stacks_tbl
        SET group_name = @group_name,
            label = @label,
            icon_path = @icon_path
        WHERE tech_id = @tech_id AND user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.tech_stacks_tbl (user_id, group_name, label, icon_path, is_active)
        VALUES (@user_id, @group_name, @label, @icon_path, 1);
    END
END;
GO

PRINT 'dbo.sp_SaveTechStack procedure updated successfully.';
GO
