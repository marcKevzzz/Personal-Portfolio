using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;

namespace _24_1639DelMundoPersonalPortfolio.Helpers
{
    /// <summary>
    /// Helper utilities for authentication, password hashing, and session management.
    /// </summary>
    public static class AuthHelper
    {
        public const string SessionUserKey = "CurrentUser";
        public const string SessionRoleKey = "UserRole";

        /// <summary>
        /// Computes a SHA256 hash of the input string.
        /// </summary>
        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password)) return string.Empty;

            using (var sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                var builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        /// <summary>
        /// Checks if a user is currently logged into the session.
        /// </summary>
        public static bool IsAuthenticated()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionUserKey] != null;
        }

        /// <summary>
        /// Checks if the current session belongs to an Admin.
        /// </summary>
        public static bool IsAdmin()
        {
            var context = HttpContext.Current;
            var role = context?.Session?[SessionRoleKey] as string;
            return string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
        }
    }
}
