using System;
using System.Web;
using System.Web.UI;

public partial class Logout : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();

        var ck = new HttpCookie("user_id")
        {
            Expires = DateTime.Now.AddDays(-1),
            Path = "/"
        };
        Response.Cookies.Add(ck);

        Response.Redirect("~/Default.aspx", true);
    }
}
