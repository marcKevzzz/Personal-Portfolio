using System;

namespace _24_1639DelMundoPersonalPortfolio.Models
{
    /// <summary>
    /// Model representing a User account in the system.
    /// </summary>
    public class User
    {
        public int UserId { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string FullName { get; set; }
        public string Role { get; set; } // "Admin" or "User"
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }
    }
}
