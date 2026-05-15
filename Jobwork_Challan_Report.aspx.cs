using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Challan_Report : Page
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
        {
            string mode = (Request.QueryString["mode"] ?? "").Trim().ToLowerInvariant();
            if (mode == "today")
            {
                txt_from.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
            else
            {
                txt_from.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
                txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
            BindJobworkParty();
            BindGrid();
        }
    }

    private void BindJobworkParty()
    {
        ddl_jobwork_party.Items.Clear();
        ddl_jobwork_party.Items.Add(new ListItem("All jobwork parties", "0"));
        DataSet ds = BAL_JobworkParty.dis_jobwork_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_jobwork_party.Items.Add(new ListItem(r["party_name"].ToString(), r["jobwork_party_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_JobworkChallan.dis_jobwork_challan_report(txt_from.Text, txt_to.Text, ddl_jobwork_party.SelectedValue, "0");
        grid_rpt.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_rpt.DataBind();
    }

    protected void grid_rpt_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow) return;
        var lit = (Literal)e.Row.FindControl("lit_rpt_parts");
        if (lit == null) return;
        var drv = e.Row.DataItem as DataRowView;
        if (drv == null) return;
        lit.Text = InwardChallanLineHtml.BuildJobworkPartsSheet(drv);
    }

    protected void grid_rpt_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument != null ? e.CommandArgument.ToString() : "";
        if (e.CommandName == "edit")
        {
            Response.Redirect("Jobwork_Challan_Entry.aspx?id=" + id);
            return;
        }
        if (e.CommandName == "del")
        {
            DataSet ds = BAL_JobworkChallan.dlt_jobwork_challan(id, Session["user_id"].ToString());
            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
                {
                    ShowMsg("Deleted.", Msg.Success);
                    BindGrid();
                }
                else
                    ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
            }
        }
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
