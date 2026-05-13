using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Part_Master : Page
{
    public enum MessageType { Success, Error, Info, Warning }

    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + Message.Replace("'", "\\'") + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            bind_dropdowns();
            bind_data();
        }
    }

    private void bind_dropdowns()
    {
        DataSet dsJw = BAL_JobworkParty.dis_jobwork_party();
        if (dsJw.Tables.Count > 0)
        {
            ddl_jobwork_party.DataSource = dsJw.Tables[0];
            ddl_jobwork_party.DataTextField = "party_name";
            ddl_jobwork_party.DataValueField = "jobwork_party_id";
            ddl_jobwork_party.DataBind();
            ddl_jobwork_party.Items.Insert(0, new ListItem("-- Select jobwork party --", "0"));

            ddl_filter_jobwork_party.DataSource = dsJw.Tables[0];
            ddl_filter_jobwork_party.DataTextField = "party_name";
            ddl_filter_jobwork_party.DataValueField = "jobwork_party_id";
            ddl_filter_jobwork_party.DataBind();
            ddl_filter_jobwork_party.Items.Insert(0, new ListItem("All", "0"));
        }

        DataSet ds_unit = BAL_JobworkPart.dis_unit();
        if (ds_unit.Tables.Count > 0)
        {
            ddl_unit.DataSource = ds_unit.Tables[0];
            ddl_unit.DataTextField = "unit_name";
            ddl_unit.DataValueField = "unit_id";
            ddl_unit.DataBind();
            ddl_unit.Items.Insert(0, new ListItem("-- Select unit --", "0"));
        }
    }

    private void bind_data()
    {
        DataSet ds = BAL_JobworkPart.dis_jobwork_part(ddl_filter_jobwork_party.SelectedValue);
        grid_jw_part.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_jw_part.DataBind();
    }

    protected void ddl_filter_jobwork_party_SelectedIndexChanged(object sender, EventArgs e)
    {
        bind_data();
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            string by = Session["user_id"].ToString();
            string taxVal = string.IsNullOrEmpty(txt_tax_per.Text.Trim()) ? "0" : txt_tax_per.Text.Trim();
            DataSet ds;
            if (hd_action.Value == "save")
                ds = BAL_JobworkPart.ins_jobwork_part(ddl_jobwork_party.SelectedValue, txt_part_name.Text, ddl_unit.SelectedValue, txt_rate.Text, taxVal, by);
            else
                ds = BAL_JobworkPart.upd_jobwork_part(hd_jobwork_part_id.Value, ddl_jobwork_party.SelectedValue, txt_part_name.Text, ddl_unit.SelectedValue, txt_rate.Text, taxVal, by);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
                {
                    ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Success);
                    bind_data();
                    txt_part_name.Text = txt_tax_per.Text = txt_rate.Text = "";
                    txt_tax_per.Text = "0";
                }
                else
                    ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
            }
        }
        catch (Exception ex)
        {
            ShowMessage(ex.Message, MessageType.Error);
        }
    }

    protected void grid_jw_part_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "btn_edit")
        {
            DataSet ds = BAL_JobworkPart.sel_jobwork_part_by_id(id);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                ddl_jobwork_party.SelectedValue = dr["jobwork_party_id"].ToString();
                txt_part_name.Text = dr["part_name"].ToString();
                ddl_unit.SelectedValue = dr["unit_id"] != DBNull.Value ? dr["unit_id"].ToString() : "0";
                txt_rate.Text = dr["rate"].ToString();
                txt_tax_per.Text = dr["tax_per"].ToString();
                hd_jobwork_part_id.Value = id;
                hd_action.Value = "update";
                ScriptManager.RegisterStartupScript(this, GetType(), "jwModal", "showJwModal();", true);
            }
        }
        else if (e.CommandName == "btn_delete")
        {
            DataSet ds = BAL_JobworkPart.dlt_jobwork_part(id, Session["user_id"].ToString());
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMessage("Deleted.", MessageType.Success);
                bind_data();
            }
            else if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
        }
    }
}
