using System;
using System.Data;
using System.Web;
/// <summary>
/// Keeps the user signed in via cookies when ASP.NET session expires (e.g. long form entry).
/// </summary>
public static class AuthHelper
{
    public const string CookieUserId = "user_id";
    public const string CookieUserName = "user_name";
    public const int CookieDays = 30;

    public static void SetLogin(HttpContext context, string userId, string userName)
    {
        if (context == null || string.IsNullOrWhiteSpace(userId))
            return;

        context.Session["user_id"] = userId.Trim();
        context.Session["name"] = userName ?? "";

        WriteCookie(context, CookieUserId, userId.Trim());
        WriteCookie(context, CookieUserName, userName ?? "");
    }

    public static void ClearLogin(HttpContext context)
    {
        if (context == null)
            return;

        context.Session.Clear();
        context.Session.Abandon();

        ExpireCookie(context, CookieUserId);
        ExpireCookie(context, CookieUserName);
    }

    /// <summary>
    /// If session is empty, restore user_id and name from login cookies (validates user is still active).
    /// </summary>
    public static bool RestoreSessionFromCookie(HttpContext context)
    {
        if (context == null || context.Session == null)
            return false;

        string sessionUid = GetSessionUserId(context);
        if (!string.IsNullOrEmpty(sessionUid))
            return true;

        HttpCookie ck = context.Request.Cookies[CookieUserId];
        if (ck == null || string.IsNullOrWhiteSpace(ck.Value))
            return false;

        string userId = ck.Value.Trim();
        if (userId == "0")
            return false;

        try
        {
            DataSet ds = BAL_User.sel_user_by_id(userId);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                ExpireCookie(context, CookieUserId);
                ExpireCookie(context, CookieUserName);
                return false;
            }

            DataRow row = ds.Tables[0].Rows[0];
            string name = row["full_name"].ToString();

            context.Session["user_id"] = userId;
            context.Session["name"] = name;

            WriteCookie(context, CookieUserId, userId);
            WriteCookie(context, CookieUserName, name);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public static bool IsLoggedIn(HttpContext context)
    {
        return !string.IsNullOrEmpty(GetSessionUserId(context));
    }

    public static void EnsureLoggedIn(HttpContext context)
    {
        if (context == null)
            return;

        RestoreSessionFromCookie(context);
        if (!IsLoggedIn(context))
            context.Response.Redirect("~/Default.aspx", true);
    }

    public static string GetSessionUserId(HttpContext context)
    {
        if (context == null || context.Session == null || context.Session["user_id"] == null)
            return "";
        string uid = context.Session["user_id"].ToString().Trim();
        return uid == "0" ? "" : uid;
    }

    private static void WriteCookie(HttpContext context, string name, string value)
    {
        var ck = new HttpCookie(name, value)
        {
            Expires = DateTime.Now.AddDays(CookieDays),
            Path = "/",
            HttpOnly = true
        };
        context.Response.Cookies.Set(ck);
    }

    private static void ExpireCookie(HttpContext context, string name)
    {
        var ck = new HttpCookie(name, "")
        {
            Expires = DateTime.Now.AddDays(-1),
            Path = "/",
            HttpOnly = true
        };
        context.Response.Cookies.Set(ck);
    }
}
