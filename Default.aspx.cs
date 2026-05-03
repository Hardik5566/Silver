using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

public partial class _Default : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
           

            if (!IsPostBack)
            {
                HttpCookie ck_user_id = new HttpCookie("user_id");
                ck_user_id.Expires = DateTime.Now.AddDays(-1);
                Response.Cookies.Add(ck_user_id);
               
            }
        }
        catch (Exception)
        {

            throw;
        }

    }
    protected void btn_login_Click(object sender, EventArgs e)
    {
        try
        {
            DataSet ds = BAL_User.user_login(txt_email.Text.Trim(), txt_pass.Text);
            if (ds.Tables.Count > 0)
            {
                if (ds.Tables[0].Rows.Count > 0)
                {


                    HttpCookie ck_user_id = new HttpCookie("user_id");
                    ck_user_id.Expires = DateTime.Now.AddDays(30);
                   
                    ck_user_id.Value = ds.Tables[0].Rows[0]["user_id"].ToString();
                   
                    Response.Cookies.Add(ck_user_id);
                   

                    Session["user_id"] = ds.Tables[0].Rows[0]["user_id"].ToString();
                    Session["name"] = ds.Tables[0].Rows[0]["full_name"].ToString();
                   
                    Response.Redirect("Home.aspx");
                }
                else
                {
                    string script = "alert('Invalid Credential !');";
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
                }
            }
            else
            {
                string script = "alert('Invalid Credential !');";
                ClientScript.RegisterStartupScript(this.GetType(), "alert", script, true);
            }
        }
        catch (Exception)
        {

            throw;
        }
    }
}