using System;
using System.Web;
using System.Web.UI;

namespace _24_1639DelMundoPersonalPortfolio.Helpers
{
    public static class DuplicateSubmissionGuard
    {
        private const string TokenFieldName = "__SUBMISSION_TOKEN";
        private const string SessionTokenKey = "__LAST_SUBMISSION_TOKEN";

        /// <summary>
        /// Registers a fresh submission token in the page hidden fields and stores it in Session.
        /// Should be called during OnPreRender.
        /// </summary>
        public static void RegisterToken(Page page)
        {
            if (page == null || HttpContext.Current?.Session == null)
                return;

            string token = Guid.NewGuid().ToString("N");
            HttpContext.Current.Session[SessionTokenKey] = token;
            page.ClientScript.RegisterHiddenField(TokenFieldName, token);
        }

        /// <summary>
        /// Validates if the current postback is a duplicate submission (e.g., caused by browser page refresh/F5).
        /// Returns true if it is a duplicate and should be ignored; false if it is a valid fresh postback.
        /// </summary>
        public static bool IsDuplicate(Page page)
        {
            if (page == null || HttpContext.Current?.Session == null)
                return false;

            if (!page.IsPostBack)
                return false;

            string clientToken = page.Request.Form[TokenFieldName];
            string serverToken = HttpContext.Current.Session[SessionTokenKey] as string;

            if (string.IsNullOrEmpty(clientToken) || string.IsNullOrEmpty(serverToken) ||
                !string.Equals(clientToken, serverToken, StringComparison.Ordinal))
            {
                return true;
            }

            // Invalidate the current session token so a page refresh with the same client token will be blocked
            HttpContext.Current.Session[SessionTokenKey] = Guid.NewGuid().ToString("N");
            return false;
        }
    }
}
