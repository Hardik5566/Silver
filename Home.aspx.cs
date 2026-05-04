using System;
using System.Data;
using System.Web.UI;

public partial class Home : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCounts();
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

        // Right-side quick stats
        lit_count_today_challan2.Text = lit_count_today_challan.Text;
        lit_count_today_item2.Text = lit_count_today_item.Text;
        lit_count_month_challan2.Text = lit_count_month_challan.Text;
        lit_count_month_item2.Text = lit_count_month_item.Text;

        // Part-wise section removed from UI (counts only).
    }

}
