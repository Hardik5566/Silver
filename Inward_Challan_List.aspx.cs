using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Inward_Challan_List : Page
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
            BindMainGrid();
    }

    private void BindMainGrid()
    {
        DataSet ds = BAL_Inward.dis_active_inward_list();
        grid_inward.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_inward.DataBind();
    }

    protected void grid_inward_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        var lit = (Literal)e.Row.FindControl("lit_lines");
        if (lit == null) return;
        var drv = e.Row.DataItem as DataRowView;
        if (drv == null) return;
        lit.Text = InwardChallanLineHtml.BuildPartsSheet(drv);
    }

    protected void grid_inward_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "edit")
        {
            Response.Redirect("Inward_Challan_Entry.aspx?id=" + id);
            return;
        }
        if (e.CommandName == "del")
        {
            DataSet ds = BAL_Inward.dlt_inward_challan(id, Session["user_id"].ToString());
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
                {
                    ShowMsg("Deleted.", Msg.Success);
                    BindMainGrid();
                }
                else
                    ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
            }
        }
        else if (e.CommandName == "out")
        {
            hd_out_inward_id.Value = id;
            BindOutGrids(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "outm", "showOutModal();", true);
        }
    }

    private void BindOutGrids(string inwardId)
    {
        hd_out_inward_id.Value = inwardId;
        SetOutModalHeader(inwardId);

        DataSet dsL = BAL_Inward.sel_inward_lines_for_out(inwardId);
        gv_out_lines.DataSource = dsL.Tables.Count > 0 ? dsL.Tables[0] : null;
        gv_out_lines.DataBind();

        DataSet dsH = BAL_Inward.dis_outward_history_by_inward(inwardId);
        gv_history.DataSource = dsH.Tables.Count > 0 ? dsH.Tables[0] : null;
        gv_history.DataBind();
    }

    private void SetOutModalHeader(string inwardId)
    {
        if (lit_out_meta == null) return;
        lit_out_meta.Text = "";
        DataSet ds = BAL_Inward.get_inward_for_edit(inwardId);
        if (ds.Tables.Count < 1 || ds.Tables[0].Rows.Count == 0) return;
        DataRow h = ds.Tables[0].Rows[0];
        string challan = System.Web.HttpUtility.HtmlEncode(h["challan_no"].ToString());
        string dateStr = System.Web.HttpUtility.HtmlEncode(Convert.ToDateTime(h["inward_date"]).ToString("dd-MMM-yyyy"));
        string partyId = h["party_id"].ToString();
        string partyName = "";
        DataSet dsp = BAL_Party.dis_party();
        if (dsp.Tables.Count > 0)
        {
            foreach (DataRow r in dsp.Tables[0].Rows)
            {
                if (r["party_id"].ToString() == partyId)
                {
                    partyName = System.Web.HttpUtility.HtmlEncode(r["party_name"].ToString());
                    break;
                }
            }
        }
        lit_out_meta.Text = "<strong>" + challan + "</strong> &nbsp;|&nbsp; " + partyName + " &nbsp;|&nbsp; " + dateStr;
    }

    protected void btn_save_all_outward_Click(object sender, EventArgs e)
    {
        string inwardId = hd_out_inward_id.Value;
        if (string.IsNullOrEmpty(inwardId))
        {
            ShowMsg("Open outward from the list first.", Msg.Warning);
            return;
        }

        int saved = 0;
        int attempted = 0;
        string firstErr = null;
        string by = Session["user_id"].ToString();

        foreach (GridViewRow r in gv_out_lines.Rows)
        {
            if (r.RowType != DataControlRowType.DataRow) continue;
            var txtQ = (TextBox)r.FindControl("txt_out_qty");
            if (txtQ == null || string.IsNullOrWhiteSpace(txtQ.Text)) continue;

            int q;
            if (!int.TryParse(txtQ.Text.Trim(), out q) || q <= 0) continue;

            attempted++;
            object key = gv_out_lines.DataKeys[r.RowIndex].Value;
            if (key == null) continue;
            string detailId = key.ToString();

            DataSet ds = BAL_Inward.ins_outward_line(detailId, txtQ.Text.Trim(), "", "", by);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                bool ok = ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true";
                if (ok)
                    saved++;
                else if (firstErr == null)
                    firstErr = ds.Tables[0].Rows[0]["Message"].ToString();
            }
        }

        if (attempted == 0)
        {
            ShowMsg("Enter out quantity on at least one line.", Msg.Warning);
            ScriptManager.RegisterStartupScript(this, GetType(), "outv1", "showOutModal();", true);
            return;
        }

        if (saved > 0)
        {
            BindOutGrids(inwardId);
            BindMainGrid();
            string msg = saved + " line(s) saved.";
            if (firstErr != null) msg += " " + firstErr;
            ShowMsg(msg, firstErr != null ? Msg.Warning : Msg.Success);
        }
        else if (firstErr != null)
            ShowMsg(firstErr, Msg.Warning);
        else
            ShowMsg("Nothing saved. Check quantities.", Msg.Warning);

        ScriptManager.RegisterStartupScript(this, GetType(), "outv2", "showOutModal();", true);
    }

    protected void gv_history_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "delhist") return;
        string hid = e.CommandArgument.ToString();
        DataSet ds = BAL_Inward.dlt_outward_history(hid, Session["user_id"].ToString());
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0 && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
        {
            ShowMsg("Outward reversed.", Msg.Success);
            BindOutGrids(hd_out_inward_id.Value);
            BindMainGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "h1", "showOutModal();", true);
        }
        else if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
    }
}
