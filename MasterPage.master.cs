using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class MasterPage : System.Web.UI.MasterPage
{


    protected void Page_Init(object sender, EventArgs e)
    {
        // Require login for every page that uses this master (Dashboard, masters, lists, etc.)
        string uid = Session["user_id"] != null ? Session["user_id"].ToString().Trim() : "";
        if (string.IsNullOrEmpty(uid) || uid == "0")
        {
            Response.Redirect("~/Default.aspx", true);
            return;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && Session["name"] != null)
        {
            lbl_name_master.Text = Session["name"].ToString();
        }
    }
}
