namespace _24_1639DelMundoPersonalPortfolio.Models
{
    /// <summary>
    /// User account role enum
    /// </summary>
    public enum UserRole
    {
        User,
        Admin
    }

    /// <summary>
    /// Tech Stack group categories enum
    /// </summary>
    public enum TechStackGroup
    {
        Frontend,
        Motion3D, // '3D & Motion'
        BackendDatabase, // 'Backend & Database'
        ToolsDevOps // 'Tools & DevOps'
    }

    /// <summary>
    /// Password reset request status enum
    /// </summary>
    public enum PasswordResetStatus
    {
        Pending,
        Approved,
        PasswordRemoved,
        Used,
        Expired
    }
}
