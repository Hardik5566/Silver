using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Unit_Master : System.Web.UI.Page
{
    public enum MessageType { Success, Error, Info, Warning };
    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), System.Guid.NewGuid().ToString(), "ShowMessage('" + Message + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bind_data();
        }
    }

    public void bind_data()
    {
        DataSet ds = BAL_Unit.sel_unit_grid();
        if (ds.Tables.Count > 0)
        {
            grid_unit.DataSource = ds.Tables[0];
            grid_unit.DataBind();
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            string by = Session["user_id"].ToString();
            DataSet ds;

            if (hd_action.Value == "save")
            {
                ds = BAL_Unit.ins_unit(txt_unit_name.Text.Trim(), by);
            }
            else
            {
                ds = BAL_Unit.upd_unit(hd_unit_id.Value, txt_unit_name.Text.Trim(), by);
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

    protected void grid_unit_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "btn_edit")
        {
            DataSet ds = BAL_Unit.sel_unit_by_id(id);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                txt_unit_name.Text = dr["unit_name"].ToString();
                hd_unit_id.Value = id;
                hd_action.Value = "update";
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showModal();", true);
            }
        }
        else if (e.CommandName == "btn_delete")
        {
            DataSet ds = BAL_Unit.dlt_unit(id, Session["user_id"].ToString());
            if (ds.Tables[0].Rows[0]["Success"].ToString() == "True")
            {
                ShowMessage("Unit deleted.", MessageType.Success);
                bind_data();
            }
            else
            {
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
            }
        }
    }
}
