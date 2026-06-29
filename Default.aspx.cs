using System;
using System.Data;
using System.Web.UI;

public partial class _Default : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            AuthHelper.RestoreSessionFromCookie(Context);
            if (AuthHelper.IsLoggedIn(Context))
                Response.Redirect("Home.aspx", true);
        }
    }

    protected void btn_login_Click(object sender, EventArgs e)
    {
        DataSet ds = BAL_User.user_login(txt_email.Text.Trim(), txt_pass.Text);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            DataRow row = ds.Tables[0].Rows[0];
            AuthHelper.SetLogin(Context, row["user_id"].ToString(), row["full_name"].ToString());
            Response.Redirect("Home.aspx", true);
        }

        string script = "alert('Invalid Credential !');";
        ClientScript.RegisterStartupScript(GetType(), "alert", script, true);
    }
}
