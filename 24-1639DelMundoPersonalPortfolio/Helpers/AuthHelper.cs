using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using _24_1639DelMundoPersonalPortfolio.Data;
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

        public const string AuthCookieName = "KEVS_AUTH_TOKEN";

        /// <summary>
        /// Sets user session data upon successful login with configurable expiration based on rememberMe.
        /// Also sets an encrypted auth cookie so sessions survive AppPool recycles on cloud hosting.
        /// </summary>
        public static void SetUserSession(User user, bool rememberMe = false)
        {
            var context = HttpContext.Current;
            var session = context?.Session;
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

            SetAuthCookie(user, rememberMe);
        }

        /// <summary>
        /// Sets an encrypted authentication cookie using FormsAuthenticationTicket.
        /// </summary>
        private static void SetAuthCookie(User user, bool rememberMe)
        {
            try
            {
                var context = HttpContext.Current;
                if (context == null || user == null) return;

                var ticket = new System.Web.Security.FormsAuthenticationTicket(
                    1,
                    user.Email,
                    DateTime.UtcNow,
                    rememberMe ? DateTime.UtcNow.AddDays(14) : DateTime.UtcNow.AddHours(8),
                    rememberMe,
                    $"{user.UserId}|{user.Role}"
                );

                string encrypted = System.Web.Security.FormsAuthentication.Encrypt(ticket);
                var cookie = new HttpCookie(AuthCookieName, encrypted)
                {
                    HttpOnly = true,
                    Path = "/"
                };

                if (rememberMe)
                {
                    cookie.Expires = ticket.Expiration;
                }

                context.Response.Cookies.Set(cookie);
            }
            catch
            {
                // Cookie generation failed non-critically
            }
        }

        /// <summary>
        /// Clears active session and logs out the current user, removing all cookies.
        /// </summary>
        public static void Logout()
        {
            var session = HttpContext.Current?.Session;
            if (session != null)
            {
                session.Clear();
                session.Abandon();
            }

            var context = HttpContext.Current;
            if (context?.Response != null)
            {
                if (context.Request?.Cookies["ASP.NET_SessionId"] != null)
                {
                    var sessionCookie = new HttpCookie("ASP.NET_SessionId", "")
                    {
                        Expires = DateTime.UtcNow.AddYears(-1),
                        Path = "/"
                    };
                    context.Response.Cookies.Set(sessionCookie);
                }

                if (context.Request?.Cookies[AuthCookieName] != null)
                {
                    var authCookie = new HttpCookie(AuthCookieName, "")
                    {
                        Expires = DateTime.UtcNow.AddYears(-1),
                        Path = "/"
                    };
                    context.Response.Cookies.Set(authCookie);
                }
            }
        }

        /// <summary>
        /// Checks if a user is currently logged into the session, or restores it via auth cookie if session was dropped.
        /// </summary>
        public static bool IsAuthenticated()
        {
            var context = HttpContext.Current;
            if (context?.Session?[SessionUserKey] != null || context?.Session?[SessionEmailKey] != null)
                return true;

            return TryRestoreSessionFromCookie();
        }

        /// <summary>
        /// Attempts to restore session state from the encrypted authentication cookie if IIS recycled the app pool.
        /// </summary>
        public static bool TryRestoreSessionFromCookie()
        {
            try
            {
                var context = HttpContext.Current;
                var cookie = context?.Request?.Cookies[AuthCookieName];
                if (cookie == null || string.IsNullOrEmpty(cookie.Value))
                    return false;

                var ticket = System.Web.Security.FormsAuthentication.Decrypt(cookie.Value);
                if (ticket == null || ticket.Expired || string.IsNullOrEmpty(ticket.Name))
                    return false;

                string emailVal = ticket.Name.Trim().ToLowerInvariant();

                string query = @"SELECT user_id, first_name, last_name, email, password_hash, user_role, is_active, created_at 
                                 FROM users_tbl 
                                 WHERE LOWER(email) = LOWER(@Email);";

                var dt = DatabaseHelper.ExecuteQuery(query, new System.Data.SqlClient.SqlParameter("@Email", emailVal));
                if (dt == null || dt.Rows.Count == 0)
                    return false;

                var row = dt.Rows[0];
                bool isActive = Convert.ToBoolean(row["is_active"]);
                if (!isActive) return false;

                var user = new User
                {
                    UserId = Convert.ToInt32(row["user_id"]),
                    FirstName = row["first_name"] != DBNull.Value ? row["first_name"].ToString() : "",
                    LastName = row["last_name"] != DBNull.Value ? row["last_name"].ToString() : "",
                    Email = emailVal,
                    PasswordHash = row["password_hash"] != DBNull.Value ? row["password_hash"].ToString() : "",
                    Role = row["user_role"] != DBNull.Value ? row["user_role"].ToString() : "User",
                    IsActive = isActive,
                    CreatedAt = Convert.ToDateTime(row["created_at"])
                };

                var session = context.Session;
                if (session != null)
                {
                    session.Timeout = ticket.IsPersistent ? 20160 : 240;
                    session[SessionUserIdKey] = user.UserId;
                    session[SessionEmailKey] = user.Email;
                    session[SessionNameKey] = $"{user.FirstName} {user.LastName}".Trim();
                    session[SessionRoleKey] = user.Role;
                    session[SessionUserKey] = user;
                }

                return true;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Checks if the current session belongs to an Admin.
        /// </summary>
        public static bool IsAdmin()
        {
            if (!IsAuthenticated()) return false;
            var context = HttpContext.Current;
            var role = context?.Session?[SessionRoleKey] as string;
            return string.Equals(role, "Admin", StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Gets the logged-in user's role ("Admin", "User", or empty string).
        /// </summary>
        public static string GetCurrentRole()
        {
            if (!IsAuthenticated()) return string.Empty;
            var context = HttpContext.Current;
            return context?.Session?[SessionRoleKey] as string ?? string.Empty;
        }

        /// <summary>
        /// Gets the logged-in User model from session if present.
        /// </summary>
        public static User GetCurrentUser()
        {
            if (!IsAuthenticated()) return null;
            var context = HttpContext.Current;
            return context?.Session?[SessionUserKey] as User;
        }

        /// <summary>
        /// Gets the logged-in user's display name.
        /// </summary>
        public static string GetCurrentUserName()
        {
            if (!IsAuthenticated()) return string.Empty;
            var context = HttpContext.Current;
            return context?.Session?[SessionNameKey] as string ?? string.Empty;
        }

        /// <summary>
        /// Gets the logged-in user's unique ID.
        /// </summary>
        public static int GetCurrentUserId()
        {
            if (!IsAuthenticated()) return 0;
            var context = HttpContext.Current;
            var uidObj = context?.Session?[SessionUserIdKey];
            if (uidObj != null && int.TryParse(uidObj.ToString(), out int id))
            {
                return id;
            }
            var user = GetCurrentUser();
            return user?.UserId ?? 0;
        }

        /// <summary>
        /// Gets the logged-in user's email.
        /// </summary>
        public static string GetCurrentEmail()
        {
            if (!IsAuthenticated()) return string.Empty;
            var context = HttpContext.Current;
            return context?.Session?[SessionEmailKey] as string ?? string.Empty;
        }

        /// <summary>
        /// Generates an avatar circle HTML element: an img tag if a custom avatar image exists,
        /// falling back to a span with the user's initial.
        /// </summary>
        public static string GetUserAvatarHtml(string avatarPath, string fullName, string email = "")
        {
            string initial = !string.IsNullOrWhiteSpace(fullName)
                ? fullName.Substring(0, 1).ToUpper()
                : (!string.IsNullOrWhiteSpace(email) ? email.Substring(0, 1).ToUpper() : "U");

            bool hasRealAvatar = !string.IsNullOrWhiteSpace(avatarPath)
                && !avatarPath.Contains("image_placeholder")
                && !avatarPath.Contains("pixelart_portrait");

            if (hasRealAvatar)
            {
                string rel = avatarPath.TrimStart('~', '/');
                string url = VirtualPathUtility.ToAbsolute("~/" + rel);
                string encUrl = HttpUtility.HtmlAttributeEncode(url);
                string encInitial = HttpUtility.HtmlEncode(initial);
                return $"<img src=\"{encUrl}\" class=\"user-avatar-initials\" alt=\"Avatar\" onerror=\"this.style.display='none'; if(this.nextElementSibling) this.nextElementSibling.style.display='flex';\" /><span class=\"user-avatar-initials\" style=\"display:none;\">{encInitial}</span>";
            }

            return $"<span class=\"user-avatar-initials\">{HttpUtility.HtmlEncode(initial)}</span>";
        }
    }
}
