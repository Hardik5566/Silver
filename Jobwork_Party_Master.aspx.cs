using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Party_Master : Page
{
    public enum MessageType { Success, Error, Info, Warning };

    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), "ShowMessage('" + Message.Replace("'", "\\'") + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
            bind_data();
    }

    public void bind_data()
    {
        DataSet ds = BAL_JobworkParty.dis_jobwork_party();
        if (ds.Tables.Count > 0)
        {
            grid_party.DataSource = ds.Tables[0];
            grid_party.DataBind();
        }
        else
        {
            grid_party.DataSource = null;
            grid_party.DataBind();
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            string by = Session["user_id"].ToString();
            DataSet ds;

            if (hd_action.Value == "save")
                ds = BAL_JobworkParty.ins_jobwork_party(txt_party_name.Text, txt_contact.Text, txt_mobile.Text, txt_address.Text, txt_gst.Text, by);
            else
                ds = BAL_JobworkParty.upd_jobwork_party(hd_party_id.Value, txt_party_name.Text, txt_contact.Text, txt_mobile.Text, txt_address.Text, txt_gst.Text, by);

            if (ds.Tables[0].Rows[0]["Success"].ToString() == "True")
            {
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Success);
                bind_data();
            }
            else
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
        }
        catch (Exception ex)
        {
            ShowMessage(ex.Message, MessageType.Error);
        }
    }

    protected void grid_party_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "btn_edit")
        {
            DataSet ds = BAL_JobworkParty.sel_jobwork_party_by_id(id);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                txt_party_name.Text = dr["party_name"].ToString();
                txt_contact.Text = dr["contact_person"].ToString();
                txt_mobile.Text = dr["mobile_no"].ToString();
                txt_gst.Text = dr["gst_no"].ToString();
                txt_address.Text = dr["address"].ToString();
                hd_party_id.Value = id;
                hd_action.Value = "update";
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowModalJw", "showModal();", true);
            }
        }
        else if (e.CommandName == "btn_delete")
        {
            DataSet ds = BAL_JobworkParty.dlt_jobwork_party(id, Session["user_id"].ToString());
            if (ds.Tables[0].Rows[0]["Success"].ToString() == "True")
            {
                ShowMessage("Jobwork party deleted.", MessageType.Success);
                bind_data();
            }
            else
                ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
        }
    }
}
