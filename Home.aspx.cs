using System;
using System.Data;
using System.Globalization;
using System.Web.UI;

public partial class Home : System.Web.UI.Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            LoadCounts();
    }

    private void LoadCounts()
    {
        DataSet ds = BAL_Dashboard.sel_dashboard_counts();
        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            return;

        DataRow r = ds.Tables[0].Rows[0];

        lit_count_party.Text = F(r, "total_party");
        lit_count_part.Text = F(r, "total_part");
        lit_count_jobwork_party.Text = F(r, "total_jobwork_party");
        lit_count_jobwork_part.Text = F(r, "total_jobwork_part");

        lit_total_debit.Text = FMoney(r, "total_debit");
        lit_total_credit.Text = FMoneyAbs(r, "total_credit");

        lit_count_active_challan.Text = F(r, "total_active_challan");
        lit_count_active_item.Text = F(r, "total_active_item_qty");

        lit_jw_active_challan.Text = F(r, "jw_active_challan");
        lit_jw_pending_qty.Text = F(r, "jw_active_pending_qty");

        lit_out_today_item.Text = F(r, "today_outward_item");
        lit_out_month_item.Text = F(r, "month_outward_item");

        lit_jw_today_recv_qty.Text = F(r, "jw_today_receive_qty");
        lit_jw_month_recv_qty.Text = F(r, "jw_month_receive_qty");
    }

    private static string F(DataRow r, string col)
    {
        if (r == null || r.Table == null || !r.Table.Columns.Contains(col) || r[col] == DBNull.Value)
            return "0";
        return r[col].ToString();
    }

    private static string FMoney(DataRow r, string col)
    {
        if (r == null || r.Table == null || !r.Table.Columns.Contains(col) || r[col] == DBNull.Value)
            return "₹0.00";
        decimal amt;
        if (r[col] is decimal)
            amt = (decimal)r[col];
        else if (!decimal.TryParse(r[col].ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt))
            return "₹0.00";
        return "₹" + amt.ToString("N2", Ci);
    }

    private static string FMoneyAbs(DataRow r, string col)
    {
        if (r == null || r.Table == null || !r.Table.Columns.Contains(col) || r[col] == DBNull.Value)
            return "₹0.00";
        decimal amt;
        if (r[col] is decimal)
            amt = (decimal)r[col];
        else if (!decimal.TryParse(r[col].ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt))
            return "₹0.00";
        return "₹" + Math.Abs(amt).ToString("N2", Ci);
    }
}
