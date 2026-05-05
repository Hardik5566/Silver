using System;
using System.Data;
using System.Web;
using System.Web.UI;

public partial class Home : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCounts();
            LoadTrend();
        }
    }

    private void LoadCounts()
    {
        DataSet ds = BAL_Dashboard.sel_dashboard_counts();
        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return;

        DataRow r = ds.Tables[0].Rows[0];
        lit_count_party.Text = r["total_party"].ToString();
        lit_count_part.Text = r["total_part"].ToString();

        lit_count_active_challan.Text = r["total_active_challan"].ToString();
        lit_count_active_item.Text = r["total_active_item_qty"].ToString();

        lit_count_today_challan.Text = r["today_challan_received"].ToString();
        lit_count_today_item.Text = r["today_item_received"].ToString();

        lit_count_month_challan.Text = r["month_challan_received"].ToString();
        lit_count_month_item.Text = r["month_item_received"].ToString();

        lit_out_today_challan.Text = r["today_outward_challan"].ToString();
        lit_out_today_item.Text = r["today_outward_item"].ToString();
        lit_out_month_challan.Text = r["month_outward_challan"].ToString();
        lit_out_month_item.Text = r["month_outward_item"].ToString();
    }

    private void LoadTrend()
    {
        DataTable dt = BAL_Dashboard.sel_dashboard_trend_30days();
        if (dt.Rows.Count == 0) return;

        System.Text.StringBuilder labels = new System.Text.StringBuilder();
        System.Text.StringBuilder inQty = new System.Text.StringBuilder();
        System.Text.StringBuilder outQty = new System.Text.StringBuilder();

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (i > 0) { labels.Append(","); inQty.Append(","); outQty.Append(","); }
            // Output JSON-safe strings because Home.aspx uses JSON.parse(...)
            string label = dt.Rows[i]["date_label"].ToString();
            labels.Append("\"").Append(HttpUtility.JavaScriptStringEncode(label)).Append("\"");
            inQty.Append(dt.Rows[i]["in_qty"].ToString());
            outQty.Append(dt.Rows[i]["out_qty"].ToString());
        }

        lit_tr30_labels.Text = labels.ToString();
        lit_tr30_in.Text = inQty.ToString();
        lit_tr30_out.Text = outQty.ToString();
    }
}
