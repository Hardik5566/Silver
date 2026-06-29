using System;
using System.Web.UI;

public partial class Logout : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        AuthHelper.ClearLogin(Context);
        Response.Redirect("~/Default.aspx", true);
    }
}
