using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Challan_List : Page
{
    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
            BindMainGrid();
    }

    private void BindMainGrid()
    {
        DataSet ds = BAL_JobworkChallan.dis_active_jobwork_challan_list();
        grid_jobwork.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_jobwork.DataBind();
    }

    protected void grid_jobwork_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        var lit = (Literal)e.Row.FindControl("lit_lines");
        if (lit == null) return;
        var drv = e.Row.DataItem as DataRowView;
        if (drv == null) return;
        lit.Text = InwardChallanLineHtml.BuildJobworkPartsSheet(drv);
    }

    protected void grid_jobwork_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "edit")
        {
            Response.Redirect("Jobwork_Challan_Entry.aspx?id=" + id);
            return;
        }
        if (e.CommandName == "del")
        {
            DataSet ds = BAL_JobworkChallan.dlt_jobwork_challan(id, Session["user_id"].ToString());
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
            return;
        }
        if (e.CommandName == "recv")
        {
            hd_recv_jobwork_challan_id.Value = id;
            txt_recv_slip.Text = "";
            txt_recv_remarks.Text = "";
            BindReceiveGrids(id);
            ScriptManager.RegisterStartupScript(this, GetType(), "recvm", "showRecvModal();", true);
        }
    }

    private void BindReceiveGrids(string jobworkChallanId)
    {
        hd_recv_jobwork_challan_id.Value = jobworkChallanId;
        SetReceiveModalHeader(jobworkChallanId);

        DataSet dsL = BAL_JobworkChallan.sel_jobwork_lines_for_return(jobworkChallanId);
        gv_recv_lines.DataSource = dsL.Tables.Count > 0 ? dsL.Tables[0] : null;
        gv_recv_lines.DataBind();

        DataSet dsH = BAL_JobworkChallan.dis_jobwork_return_history_by_challan(jobworkChallanId);
        gv_recv_hist.DataSource = dsH.Tables.Count > 0 ? dsH.Tables[0] : null;
        gv_recv_hist.DataBind();
    }

    private void SetReceiveModalHeader(string jobworkChallanId)
    {
        if (lit_recv_meta == null) return;
        lit_recv_meta.Text = "";
        DataSet ds = BAL_JobworkChallan.get_jobwork_challan_for_edit(jobworkChallanId);
        if (ds.Tables.Count < 1 || ds.Tables[0].Rows.Count == 0) return;
        DataRow h = ds.Tables[0].Rows[0];
        string challan = System.Web.HttpUtility.HtmlEncode(h["challan_no"].ToString());
        string dateStr = System.Web.HttpUtility.HtmlEncode(Convert.ToDateTime(h["challan_date"]).ToString("dd-MMM-yyyy"));
        string partyId = h["party_id"].ToString();
        string jwPartyId = h["jobwork_party_id"].ToString();
        string itemPartyName = "";
        DataSet dsp = BAL_Party.dis_party();
        if (dsp.Tables.Count > 0)
        {
            foreach (DataRow r in dsp.Tables[0].Rows)
            {
                if (r["party_id"].ToString() == partyId)
                {
                    itemPartyName = System.Web.HttpUtility.HtmlEncode(r["party_name"].ToString());
                    break;
                }
            }
        }
        string jwName = "";
        DataSet dsj = BAL_JobworkParty.dis_jobwork_party();
        if (dsj.Tables.Count > 0)
        {
            foreach (DataRow r in dsj.Tables[0].Rows)
            {
                if (r["jobwork_party_id"].ToString() == jwPartyId)
                {
                    jwName = System.Web.HttpUtility.HtmlEncode(r["party_name"].ToString());
                    break;
                }
            }
        }
        lit_recv_meta.Text = "<strong>" + challan + "</strong> &nbsp;|&nbsp; Items: " + itemPartyName + " &nbsp;|&nbsp; Jobwork: " + jwName + " &nbsp;|&nbsp; " + dateStr;
    }

    protected void btn_save_all_receive_Click(object sender, EventArgs e)
    {
        string challanId = hd_recv_jobwork_challan_id.Value;
        if (string.IsNullOrEmpty(challanId))
        {
            ShowMsg("Open receive from the list first.", Msg.Warning);
            return;
        }

        int saved = 0;
        int attempted = 0;
        string firstErr = null;
        string by = Session["user_id"].ToString();
        string slip = txt_recv_slip != null ? txt_recv_slip.Text.Trim() : "";
        string remarks = txt_recv_remarks != null ? txt_recv_remarks.Text.Trim() : "";

        foreach (GridViewRow r in gv_recv_lines.Rows)
        {
            if (r.RowType != DataControlRowType.DataRow) continue;
            var txtP = (TextBox)r.FindControl("txt_perfect");
            var txtR = (TextBox)r.FindControl("txt_reject");
            if (txtP == null || txtR == null) continue;

            string sp = txtP.Text != null ? txtP.Text.Trim() : "";
            string sr = txtR.Text != null ? txtR.Text.Trim() : "";
            if (string.IsNullOrEmpty(sp) && string.IsNullOrEmpty(sr)) continue;

            int qp = 0, qr = 0;
            if (!string.IsNullOrEmpty(sp) && !int.TryParse(sp, out qp))
            {
                ShowMsg("Invalid perfect qty.", Msg.Warning);
                ScriptManager.RegisterStartupScript(this, GetType(), "recv1", "showRecvModal();", true);
                return;
            }
            if (!string.IsNullOrEmpty(sr) && !int.TryParse(sr, out qr))
            {
                ShowMsg("Invalid reject qty.", Msg.Warning);
                ScriptManager.RegisterStartupScript(this, GetType(), "recv2", "showRecvModal();", true);
                return;
            }
            if (qp < 0 || qr < 0)
            {
                ShowMsg("Quantities cannot be negative.", Msg.Warning);
                ScriptManager.RegisterStartupScript(this, GetType(), "recv3", "showRecvModal();", true);
                return;
            }
            if (qp == 0 && qr == 0) continue;

            attempted++;
            object key = gv_recv_lines.DataKeys[r.RowIndex].Value;
            if (key == null) continue;
            string detailId = key.ToString();

            DataSet ds = BAL_JobworkChallan.ins_jobwork_return_line(detailId, qp.ToString(), qr.ToString(), slip, remarks, by);
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
            ShowMsg("Enter perfect and/or reject qty on at least one line.", Msg.Warning);
            ScriptManager.RegisterStartupScript(this, GetType(), "recv4", "showRecvModal();", true);
            return;
        }

        if (saved > 0)
        {
            BindReceiveGrids(challanId);
            BindMainGrid();
            string msg = saved + " line(s) saved.";
            if (firstErr != null) msg += " " + firstErr;
            ShowMsg(msg, firstErr != null ? Msg.Warning : Msg.Success);
        }
        else if (firstErr != null)
            ShowMsg(firstErr, Msg.Warning);
        else
            ShowMsg("Nothing saved. Check quantities.", Msg.Warning);

        ScriptManager.RegisterStartupScript(this, GetType(), "recv5", "showRecvModal();", true);
    }

    protected void gv_recv_hist_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "delrethist") return;
        string hid = e.CommandArgument.ToString();
        DataSet ds = BAL_JobworkChallan.dlt_jobwork_return_history(hid, Session["user_id"].ToString());
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0 && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
        {
            ShowMsg("Return reversed.", Msg.Success);
            BindReceiveGrids(hd_recv_jobwork_challan_id.Value);
            BindMainGrid();
            ScriptManager.RegisterStartupScript(this, GetType(), "recv6", "showRecvModal();", true);
        }
        else if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
            ScriptManager.RegisterStartupScript(this, GetType(), "recv6b", "showRecvModal();", true);
        }
    }
}
