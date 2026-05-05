using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Inward_Challan_Report : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
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
            BindParty();
            BindGrid();
        }
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
        DataSet ds = BAL_Inward.dis_inward_report(txt_from.Text, txt_to.Text, ddl_party.SelectedValue, "0");
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
        lit.Text = InwardChallanLineHtml.BuildPartsSheet(drv);
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
