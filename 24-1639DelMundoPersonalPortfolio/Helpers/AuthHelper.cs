using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using _24_1639DelMundoPersonalPortfolio.Models;

namespace _24_1639DelMundoPersonalPortfolio.Helpers
{
    /// <summary>
    /// Helper utilities for authentication, password hashing, and session management.
    /// </summary>
    public static class AuthHelper
    {
        public const string SessionUserKey = "CurrentUser";
        public const string SessionRoleKey = "UserRole";
        public const string SessionEmailKey = "UserEmail";
        public const string SessionNameKey = "UserName";
        public const string SessionUserIdKey = "UserId";

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
        /// Verifies whether an input password matches the stored SHA256 hash.
        /// </summary>
        public static bool VerifyPassword(string inputPassword, string storedHash)
        {
            if (string.IsNullOrEmpty(inputPassword) || string.IsNullOrEmpty(storedHash))
                return false;

            string hashedInput = HashPassword(inputPassword);
            return string.Equals(hashedInput, storedHash, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Sets user session data upon successful login with configurable expiration based on rememberMe.
        /// </summary>
        public static void SetUserSession(User user, bool rememberMe = false)
        {
            var session = HttpContext.Current?.Session;
            if (session != null && user != null)
            {
                // Remember Me: 14 days (20,160 mins), Standard: 4 hours (240 mins)
                session.Timeout = rememberMe ? 20160 : 240;

                session[SessionUserIdKey] = user.UserId;
                session[SessionEmailKey] = user.Email;
                session[SessionNameKey] = $"{user.FirstName} {user.LastName}".Trim();
                session[SessionRoleKey] = user.Role;
                session[SessionUserKey] = user;
            }
        }

        /// <summary>
        /// Clears active session and logs out the current user.
        /// </summary>
        public static void Logout()
        {
            var session = HttpContext.Current?.Session;
            if (session != null)
            {
                session.Clear();
                session.Abandon();
            }

            var response = HttpContext.Current?.Response;
            if (response != null && HttpContext.Current?.Request?.Cookies["ASP.NET_SessionId"] != null)
            {
                var cookie = new HttpCookie("ASP.NET_SessionId", "")
                {
                    Expires = DateTime.UtcNow.AddYears(-1)
                };
                response.Cookies.Add(cookie);
            }
        }

        /// <summary>
        /// Checks if a user is currently logged into the session.
        /// </summary>
        public static bool IsAuthenticated()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionUserKey] != null || context?.Session?[SessionEmailKey] != null;
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

        /// <summary>
        /// Gets the logged-in user's role ("Admin", "User", or empty string).
        /// </summary>
        public static string GetCurrentRole()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionRoleKey] as string ?? string.Empty;
        }

        /// <summary>
        /// Gets the logged-in User model from session if present.
        /// </summary>
        public static User GetCurrentUser()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionUserKey] as User;
        }

        /// <summary>
        /// Gets the logged-in user's display name.
        /// </summary>
        public static string GetCurrentUserName()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionNameKey] as string ?? string.Empty;
        }

        /// <summary>
        /// Gets the logged-in user's email.
        /// </summary>
        public static string GetCurrentEmail()
        {
            var context = HttpContext.Current;
            return context?.Session?[SessionEmailKey] as string ?? string.Empty;
        }
    }
}
