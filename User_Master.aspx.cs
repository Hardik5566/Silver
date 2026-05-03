using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class User_Master : System.Web.UI.Page
{
    public enum MessageType { Success, Error, Info, Warning };

    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), "ShowMessage('" + Message + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bind_data();
        }
    }

    private string CurrentUserId()
    {
        return Session["user_id"] != null ? Session["user_id"].ToString() : "1";
    }

    public void bind_data()
    {
        DataSet ds = BAL_User.dis_user();
        if (ds.Tables.Count > 0)
        {
            grid_user.DataSource = ds.Tables[0];
            grid_user.DataBind();
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            string by = CurrentUserId();
            DataSet ds;

            if (hd_action.Value == "save")
            {
                ds = BAL_User.ins_user(txt_full_name.Text.Trim(), txt_mobile.Text.Trim(), txt_email.Text.Trim(), txt_password.Text, by);
            }
            else
            {
                ds = BAL_User.upd_user(hd_user_id.Value, txt_full_name.Text.Trim(), txt_mobile.Text.Trim(), txt_email.Text.Trim(), txt_password.Text, by);
            }

            if (ds.Tables[0].Rows[0]["Success"].ToString() == "True")
            {
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Success);
                bind_data();
            }
            else
            {
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
            }
        }
        catch (Exception ex)
        {
            ShowMessage(ex.Message, MessageType.Error);
        }
    }

    protected void grid_user_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "btn_edit")
        {
            DataSet ds = BAL_User.sel_user_by_id(id);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                txt_full_name.Text = dr["full_name"].ToString();
                txt_mobile.Text = dr["mobile_no"].ToString();
                txt_email.Text = dr["email"] != DBNull.Value ? dr["email"].ToString() : "";
                txt_password.Text = "";
                hd_user_id.Value = id;
                hd_action.Value = "update";
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showUserModal();", true);
            }
        }
        else if (e.CommandName == "btn_delete")
        {
            DataSet ds = BAL_User.dlt_user(id, CurrentUserId());
            if (ds.Tables[0].Rows[0]["Success"].ToString() == "True")
            {
                ShowMessage("User deleted", MessageType.Success);
                bind_data();
            }
        }
    }
}
