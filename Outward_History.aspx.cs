using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Outward_History : Page
{
    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ApplyPresetFromQuery();
            BindParty();
            BindGrid();
        }
    }

    private void ApplyPresetFromQuery()
    {
        string mode = (Request.QueryString["mode"] ?? "").Trim().ToLowerInvariant();
        if (mode == "today")
        {
            txt_from.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            return;
        }

        txt_from.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
        txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
    }

    private void BindParty()
    {
        ddl_party.Items.Clear();
        ddl_party.Items.Add(new ListItem("All parties", "0"));
        DataSet ds = BAL_Party.dis_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_party.Items.Add(new ListItem(r["party_name"].ToString(), r["party_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_Inward.dis_outward_history(txt_from.Text, txt_to.Text, ddl_party.SelectedValue);
        grid_out.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_out.DataBind();
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void grid_out_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "editout")
        {
            LoadEditModal(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "edmo", "showEditModal();", true);
            return;
        }
        if (e.CommandName == "delout")
        {
            DataSet ds = BAL_Inward.dlt_outward_history(id, Session["user_id"].ToString());
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
                && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMsg("Outward reversed.", Msg.Success);
                BindGrid();
            }
            else if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
        }
    }

    private void LoadEditModal(string outwardHistoryId)
    {
        hd_edit_id.Value = outwardHistoryId;
        txt_edit_qty.Text = "";
        txt_edit_slip.Text = "";
        txt_edit_remarks.Text = "";
        lit_edit_meta.Text = "";
        lit_edit_hint.Text = "";

        DataSet ds = BAL_Inward.get_outward_for_edit(outwardHistoryId);
        if (ds.Tables.Count < 1 || ds.Tables[0].Rows.Count == 0)
        {
            ShowMsg("Outward entry not found.", Msg.Warning);
            return;
        }

        DataRow r = ds.Tables[0].Rows[0];
        string challan = HttpUtility.HtmlEncode(r["challan_no"].ToString());
        string party = HttpUtility.HtmlEncode(r["party_name"].ToString());
        string part = HttpUtility.HtmlEncode(r["part_name"].ToString());
        string dateStr = HttpUtility.HtmlEncode(Convert.ToDateTime(r["outward_date"]).ToString("dd-MMM-yyyy HH:mm"));
        lit_edit_meta.Text = "<strong>" + challan + "</strong> &nbsp;|&nbsp; " + party + " &nbsp;|&nbsp; " + part + " &nbsp;|&nbsp; " + dateStr;

        txt_edit_qty.Text = r["qty_out"].ToString();
        txt_edit_slip.Text = r["slip_no"].ToString();
        txt_edit_remarks.Text = r["remarks"].ToString();
        lit_edit_hint.Text = "Max qty for this line: <strong>" + r["qty_max"].ToString() + "</strong> (pending on challan: " + r["qty_pending"].ToString() + ").";
    }

    protected void btn_save_edit_Click(object sender, EventArgs e)
    {
        string id = hd_edit_id.Value;
        if (string.IsNullOrEmpty(id))
        {
            ShowMsg("Select an outward entry to edit.", Msg.Warning);
            return;
        }

        int q;
        if (!int.TryParse(txt_edit_qty.Text.Trim(), out q) || q <= 0)
        {
            ShowMsg("Enter a valid quantity.", Msg.Warning);
            LoadEditModal(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "edmo2", "showEditModal();", true);
            return;
        }

        DataSet ds = BAL_Inward.upd_outward_history(id, txt_edit_qty.Text.Trim(), txt_edit_slip.Text.Trim(), txt_edit_remarks.Text.Trim(), Session["user_id"].ToString());
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0
            && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
        {
            ShowMsg("Outward updated.", Msg.Success);
            BindGrid();
        }
        else if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
            LoadEditModal(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "edmo3", "showEditModal();", true);
        }
    }
}
