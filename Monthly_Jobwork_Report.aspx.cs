using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Monthly_Jobwork_Report : Page
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
            BindJobworkParty();
            BindMonthDropdown();
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

        int partyId = int.Parse(ddl_jobwork_party.SelectedValue, NumberStyles.Integer, CultureInfo.InvariantCulture);
        DataSet ds = BAL_Report.dis_jobwork_monthly_report(fromStr, toStr, partyId);
        DataTable table = ds.Tables.Count > 0 ? ds.Tables[0] : null;

        grid_rpt.DataSource = table;
        grid_rpt.DataBind();

        long sumQty = 0;
        decimal sumAmt = 0m;
        if (table != null)
        {
            foreach (DataRow r in table.Rows)
            {
                if (r["total_qty_sent"] != DBNull.Value)
                    sumQty += Convert.ToInt64(r["total_qty_sent"], CultureInfo.InvariantCulture);
                if (r["total_amount"] != DBNull.Value)
                    sumAmt += Convert.ToDecimal(r["total_amount"], CultureInfo.InvariantCulture);
            }
        }

        if (grid_rpt.FooterRow != null)
        {
            bool hasRows = table != null && table.Rows.Count > 0;
            grid_rpt.FooterRow.Visible = hasRows;
            if (hasRows)
            {
                grid_rpt.FooterRow.TableSection = TableRowSection.TableFooter;

                grid_rpt.FooterRow.Cells[0].ColumnSpan = 3;
                grid_rpt.FooterRow.Cells[0].Text = "Month total";
                grid_rpt.FooterRow.Cells[0].HorizontalAlign = HorizontalAlign.Right;
                grid_rpt.FooterRow.Cells[0].CssClass = "mjr-ft-label";
                grid_rpt.FooterRow.Cells.RemoveAt(2);
                grid_rpt.FooterRow.Cells.RemoveAt(1);

                grid_rpt.FooterRow.Cells[1].Text = sumQty.ToString("N0", Ci);
                grid_rpt.FooterRow.Cells[1].HorizontalAlign = HorizontalAlign.Right;
                grid_rpt.FooterRow.Cells[1].CssClass = "mjr-ft-val";

                grid_rpt.FooterRow.Cells[2].Text = sumAmt.ToString("N2", Ci);
                grid_rpt.FooterRow.Cells[2].HorizontalAlign = HorizontalAlign.Right;
                grid_rpt.FooterRow.Cells[2].CssClass = "mjr-ft-val";
            }
        }

        RenderChart(table);
    }

    private void RenderChart(DataTable table)
    {
        var labels = new List<string>();
        var amounts = new List<decimal>();

        if (table != null)
        {
            foreach (DataRow r in table.Rows)
            {
                DateTime dt = Convert.ToDateTime(r["report_date"], CultureInfo.InvariantCulture);
                labels.Add(dt.ToString("dd MMM", Ci));
                amounts.Add(r["total_amount"] == DBNull.Value
                    ? 0m
                    : Convert.ToDecimal(r["total_amount"], CultureInfo.InvariantCulture));
            }
        }

        var js = new JavaScriptSerializer();
        string labelsJson = js.Serialize(labels);
        string amtJson = js.Serialize(amounts);

        var sb = new StringBuilder();
        sb.Append("<script type=\"text/javascript\">");
        sb.Append("(function(){");
        sb.Append("var el=document.getElementById('mjrChart');if(!el)return;");
        sb.Append("if(window.mjrApexChart){window.mjrApexChart.destroy();window.mjrApexChart=null;}");
        sb.Append("var labels=").Append(labelsJson).Append(";");
        sb.Append("if(!labels.length){el.innerHTML='<div class=\"text-center text-muted p-5\">No data for chart.</div>';return;}");
        sb.Append("var options={");
        sb.Append("chart:{type:'area',height:420,fontFamily:'Roboto, sans-serif',toolbar:{show:false},zoom:{enabled:false}},");
        sb.Append("stroke:{curve:'smooth',width:3},");
        sb.Append("fill:{type:'gradient',gradient:{shadeIntensity:1,opacityFrom:0.35,opacityTo:0.05,stops:[0,90,100]}},");
        sb.Append("dataLabels:{enabled:false},");
        sb.Append("colors:['#0d6efd'],");
        sb.Append("series:[{name:'Amount',data:").Append(amtJson).Append("}],");
        sb.Append("xaxis:{categories:labels,labels:{rotate:-45,hideOverlappingLabels:true}},");
        sb.Append("yaxis:{title:{text:'Amount'},labels:{formatter:function(v){return v.toLocaleString('en-IN',{minimumFractionDigits:0,maximumFractionDigits:0});}}},");
        sb.Append("tooltip:{y:{formatter:function(v){return v.toLocaleString('en-IN',{minimumFractionDigits:2,maximumFractionDigits:2});}}},");
        sb.Append("markers:{size:4,strokeWidth:2,hover:{size:6}},");
        sb.Append("grid:{borderColor:'#edf0f3',strokeDashArray:4}");
        sb.Append("};");
        sb.Append("window.mjrApexChart=new ApexCharts(el,options);");
        sb.Append("window.mjrApexChart.render();");
        sb.Append("})();");
        sb.Append("</script>");

        lit_chart_boot.Text = sb.ToString();
    }

    protected void btn_apply_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
