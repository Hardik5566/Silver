using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Monthly_Inward_Report : Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            BindParty();
            BindMonthDropdown();
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

    private void BindMonthDropdown()
    {
        ddl_month.Items.Clear();
        DateTime anchor = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
        for (int i = 0; i < 48; i++)
        {
            DateTime dt = anchor.AddMonths(-i);
            string text = dt.ToString("MMMM yyyy", Ci);
            string val = dt.ToString("yyyy-MM", Ci);
            ddl_month.Items.Add(new ListItem(text, val));
        }
        ddl_month.SelectedIndex = 0;
    }

    private static DateTime FirstDayOfMonth(string yyyyMm)
    {
        var parts = yyyyMm.Split('-');
        return new DateTime(int.Parse(parts[0], Ci), int.Parse(parts[1], Ci), 1);
    }

    private static DateTime LastDayOfMonth(string yyyyMm)
    {
        return FirstDayOfMonth(yyyyMm).AddMonths(1).AddDays(-1);
    }

    private void BindGrid()
    {
        string monthVal = ddl_month.SelectedValue;
        DateTime monthStart = FirstDayOfMonth(monthVal);
        DateTime monthEnd = LastDayOfMonth(monthVal);

        string fromStr = monthStart.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        string toStr = monthEnd.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

        int partyId = int.Parse(ddl_party.SelectedValue, NumberStyles.Integer, CultureInfo.InvariantCulture);
        DataSet ds = BAL_Report.dis_inward_monthly_report(fromStr, toStr, partyId);
        DataTable table = ds.Tables.Count > 0 ? ds.Tables[0] : null;

        grid_rpt.DataSource = table;
        grid_rpt.DataBind();

        long sumQty = 0;
        decimal sumAmt = 0m;
        if (table != null)
        {
            foreach (DataRow r in table.Rows)
            {
                if (r["total_qty_inward"] != DBNull.Value)
                    sumQty += Convert.ToInt64(r["total_qty_inward"], CultureInfo.InvariantCulture);
                if (r["total_amount"] != DBNull.Value)
                    sumAmt += Convert.ToDecimal(r["total_amount"], CultureInfo.InvariantCulture);
            }
        }

        if (grid_rpt.FooterRow != null)
        {
            bool hasRows = table != null && table.Rows.Count > 0;
            grid_rpt.FooterRow.Visible = hasRows;
            if (!hasRows)
                return;

            grid_rpt.FooterRow.TableSection = TableRowSection.TableFooter;

            grid_rpt.FooterRow.Cells[0].ColumnSpan = 3;
            grid_rpt.FooterRow.Cells[0].Text = "Month total";
            grid_rpt.FooterRow.Cells[0].HorizontalAlign = HorizontalAlign.Right;
            grid_rpt.FooterRow.Cells[0].CssClass = "mir-ft-label";
            grid_rpt.FooterRow.Cells.RemoveAt(2);
            grid_rpt.FooterRow.Cells.RemoveAt(1);

            grid_rpt.FooterRow.Cells[1].Text = sumQty.ToString("N0", Ci);
            grid_rpt.FooterRow.Cells[1].HorizontalAlign = HorizontalAlign.Right;
            grid_rpt.FooterRow.Cells[1].CssClass = "mir-ft-val";

            grid_rpt.FooterRow.Cells[2].Text = sumAmt.ToString("N2", Ci);
            grid_rpt.FooterRow.Cells[2].HorizontalAlign = HorizontalAlign.Right;
            grid_rpt.FooterRow.Cells[2].CssClass = "mir-ft-val";
        }
    }

    protected void btn_apply_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
