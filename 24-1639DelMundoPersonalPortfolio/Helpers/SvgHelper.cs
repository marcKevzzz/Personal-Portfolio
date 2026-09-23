using System;
using System.Collections.Concurrent;
using System.IO;
using System.Text.RegularExpressions;
using System.Web;

namespace _24_1639DelMundoPersonalPortfolio.Helpers
{
    public static class SvgHelper
    {
        private static readonly ConcurrentDictionary<string, string> _svgCache =
            new ConcurrentDictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Retrieves the raw SVG markup either from an inline SVG string, base64 payload, or by reading a referenced .svg file from disk.
        /// </summary>
        public static string GetSvgContent(string iconPath)
        {
            if (string.IsNullOrWhiteSpace(iconPath))
                return string.Empty;

            string trimmed = iconPath.Trim();

            // Decode base64 payload if present
            if (trimmed.StartsWith("base64:", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    byte[] bytes = Convert.FromBase64String(trimmed.Substring(7));
                    trimmed = System.Text.Encoding.UTF8.GetString(bytes).Trim();
                }
                catch { }
            }

            // If it contains an <svg tag directly
            int svgStart = trimmed.IndexOf("<svg", StringComparison.OrdinalIgnoreCase);
            if (svgStart >= 0)
            {
                int svgEnd = trimmed.LastIndexOf("</svg>", StringComparison.OrdinalIgnoreCase);
                if (svgEnd > svgStart)
                {
                    return trimmed.Substring(svgStart, (svgEnd + 6) - svgStart);
                }
                return trimmed;
            }

            // Legacy disk file lookup (e.g. Assets/Icons/csharp.svg)
            try
            {
                if (HttpContext.Current != null && trimmed.IndexOf(".svg", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    if (_svgCache.TryGetValue(trimmed, out string cached))
                        return cached;

                    string relative = trimmed.TrimStart('~', '/');
                    string fullPath = HttpContext.Current.Server.MapPath("~/" + relative);

                    if (File.Exists(fullPath))
                    {
                        string content = File.ReadAllText(fullPath).Trim();
                        if (content.StartsWith("base64:", StringComparison.OrdinalIgnoreCase))
                        {
                            try
                            {
                                byte[] bytes = Convert.FromBase64String(content.Substring(7));
                                content = System.Text.Encoding.UTF8.GetString(bytes).Trim();
                            }
                            catch { }
                        }
                        _svgCache[trimmed] = content;
                        return content;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[SvgHelper] GetSvgContent error: " + ex.Message);
            }

            return string.Empty;
        }

        /// <summary>
        /// Renders an inline &lt;svg&gt; element directly for output in public components and admin previews,
        /// preventing browser file-download dialogs and allowing full CSS styling.
        /// Falls back to an &lt;img&gt; tag only if the icon is a raster image file path.
        /// </summary>
        public static string RenderInlineSvg(object iconPathObj, object labelObj, string cssClass = "tech-icon")
        {
            string iconPath = iconPathObj?.ToString() ?? string.Empty;
            string label = labelObj?.ToString() ?? "Technology";

            if (string.IsNullOrWhiteSpace(iconPath))
            {
                string initials = label.Length > 2 ? label.Substring(0, 2) : label;
                return $"<span class=\"{cssClass} text-fallback\" style=\"display:inline-flex;align-items:center;justify-content:center;font-weight:600;font-size:11px;\">{HttpUtility.HtmlEncode(initials)}</span>";
            }

            string svg = GetSvgContent(iconPath);
            if (!string.IsNullOrWhiteSpace(svg) && svg.IndexOf("<svg", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                string processed = svg;
                if (!Regex.IsMatch(processed, @"\bclass\s*=", RegexOptions.IgnoreCase))
                {
                    int insertPos = processed.IndexOf("<svg", StringComparison.OrdinalIgnoreCase) + 4;
                    processed = processed.Insert(insertPos, $" class=\"{cssClass}\" role=\"img\" aria-label=\"{HttpUtility.HtmlAttributeEncode(label)}\" ");
                }
                else
                {
                    processed = Regex.Replace(
                        processed,
                        @"(<svg\b[^>]*\bclass\s*=\s*[""'])([^""']*)([""'])",
                        $"$1$2 {cssClass}$3",
                        RegexOptions.IgnoreCase
                    );
                }
                return processed;
            }

            // Fallback to <img> tag only if icon is a legacy image path on disk
            string trimmedPath = iconPath.Trim();
            if (!trimmedPath.StartsWith("<") && (trimmedPath.EndsWith(".png", StringComparison.OrdinalIgnoreCase) || 
                                                trimmedPath.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase) || 
                                                trimmedPath.EndsWith(".webp", StringComparison.OrdinalIgnoreCase) || 
                                                trimmedPath.EndsWith(".svg", StringComparison.OrdinalIgnoreCase)))
            {
                string resolvedUrl = VirtualPathUtility.ToAbsolute("~/" + trimmedPath.TrimStart('~', '/'));
                return $"<img src=\"{resolvedUrl}\" alt=\"{HttpUtility.HtmlAttributeEncode(label)}\" class=\"{cssClass}\" onerror=\"this.style.display='none';\" />";
            }

            // Safe text badge fallback if no valid SVG or image could be rendered
            string fallbackText = label.Length > 2 ? label.Substring(0, 2) : label;
            return $"<span class=\"{cssClass} text-fallback\" style=\"display:inline-flex;align-items:center;justify-content:center;font-weight:600;font-size:11px;\">{HttpUtility.HtmlEncode(fallbackText)}</span>";
        }
    }
}
