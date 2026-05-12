using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class Jobwork_Challan_Print : Page
{
    private static readonly CultureInfo PrintCulture = CultureInfo.GetCultureInfo("en-IN");
    private const string PrintDateFormat = "dd/MM/yyyy";

    private const string SellerAddrDefault = "PLOT NO-253,2-ANKUR IND AREA,NEAR KOHINOOR PAINT\r\nSHAPER(VERAVAL) MO NO:-+91-9687822994";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        string id = Request.QueryString["id"];
        if (id != null)
            id = id.Trim();

        if (string.IsNullOrEmpty(id))
        {
            ShowError();
            return;
        }

        DataSet ds = BAL_JobworkChallan.get_jobwork_challan_for_edit(id);
        if (ds.Tables.Count < 2 || ds.Tables[0].Rows.Count == 0)
        {
            ShowError();
            return;
        }

        DataRow h = ds.Tables[0].Rows[0];
        string jwPartyId = h["jobwork_party_id"].ToString();

        DataRow jobworkParty = GetJobworkPartyRow(jwPartyId);

        string jobPartyName = jobworkParty != null ? jobworkParty["party_name"].ToString().Trim() : "";

        string challanNo = h["challan_no"].ToString();
        DateTime cDate = Convert.ToDateTime(h["challan_date"], CultureInfo.InvariantCulture);
        string dateStr = cDate.ToString(PrintDateFormat, PrintCulture);
        string remarks = h["remarks"] != DBNull.Value ? h["remarks"].ToString().Trim() : "";

        DataTable lineTbl = ds.Tables[1];
        int lineCount = lineTbl.Rows.Count;
        string linesHtml = BuildLinesTable(lineTbl);

        string logoHtml = "";
        string logoPath = Server.MapPath("~/image/thumbnail.jpg");
        if (File.Exists(logoPath))
        {
            string logoSrc = HttpUtility.HtmlAttributeEncode(ResolveUrl("~/image/thumbnail.jpg"));
            logoHtml = "<img class=\"jw-logo\" src=\"" + logoSrc + "\" alt=\"\" />";
        }

        string sellerAddr = HttpUtility.HtmlEncode(SellerAddrDefault);
        string inner = BuildSlipCore(
            logoHtml,
            sellerAddr,
            HttpUtility.HtmlEncode(challanNo),
            HttpUtility.HtmlEncode(dateStr),
            FormatSimpleFillLine("Job party name :", jobPartyName),
            linesHtml,
            FormatRemarks(remarks));

        /* One A4 (297mm / 11.69in): two vertical bands — jobwork party (top), company (bottom).
           Single line item: top band ~80%, company ~20%. Two+ items: ~50% / 50%. */
        string rootClass = lineCount <= 1 ? "jw-print-root jw-print-root--single-item" : "jw-print-root jw-print-root--equal";

        var page = new StringBuilder();
        page.Append("<div class=\"").Append(rootClass).Append("\">");

        page.Append("<section class=\"jw-pane jw-pane--jobwork\" aria-label=\"Jobwork party copy\">");
        page.Append("<div class=\"jw-copy-tag\">Jobwork party</div>");
        page.Append("<div class=\"jw-pane-body\">").Append(inner).Append("</div>");
        page.Append("</section>");

        page.Append("<div class=\"jw-cut-line\" role=\"separator\" aria-hidden=\"true\"></div>");

        page.Append("<section class=\"jw-pane jw-pane--company\" aria-label=\"Company copy\">");
        page.Append("<div class=\"jw-copy-tag\">Company</div>");
        page.Append("<div class=\"jw-pane-body\">").Append(inner).Append("</div>");
        page.Append("</section>");

        page.Append("</div>");

        lit_duplex_body.Text = page.ToString();
        pnl_error.Visible = false;
        pnl_print.Visible = true;
    }

    private void ShowError()
    {
        pnl_error.Visible = true;
        pnl_print.Visible = false;
    }

    private static DataRow GetJobworkPartyRow(string jobworkPartyId)
    {
        DataSet ds = BAL_JobworkParty.sel_jobwork_party_by_id(jobworkPartyId);
        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            return ds.Tables[0].Rows[0];
        return null;
    }

    /// <summary>Label + ruled space (name printed when known).</summary>
    private static string FormatSimpleFillLine(string label, string value)
    {
        string v = value != null ? value.Trim() : "";
        if (v.Length == 0)
            v = "\u00a0";

        var sb = new StringBuilder();
        sb.Append("<div class=\"jw-party-simple\">");
        sb.Append("<span class=\"jw-party-lbl\">").Append(HttpUtility.HtmlEncode(label)).Append("</span>");
        sb.Append("<span class=\"jw-party-value\">").Append(HttpUtility.HtmlEncode(v)).Append("</span>");
        sb.Append("</div>");
        return sb.ToString();
    }

    private static string FormatRemarks(string remarks)
    {
        if (string.IsNullOrEmpty(remarks))
            return "";
        return "<div class=\"jw-remarks\"><strong>Remarks:</strong> " + HttpUtility.HtmlEncode(remarks) + "</div>";
    }

    private static string BuildSlipCore(
        string logoHtml,
        string sellerAddrEncoded,
        string challanNoEnc,
        string dateEnc,
        string jobPartyLineHtml,
        string linesBlockHtml,
        string remarksHtml)
    {
        var sb = new StringBuilder();
        sb.Append("<div class=\"jw-topband\"><div class=\"jw-doc-title\">Jobwork delivery challan</div></div>");

        sb.Append("<div class=\"jw-head-row\">");
        sb.Append("<div class=\"jw-logo-cell\">").Append(logoHtml).Append("</div>");
        sb.Append("<div class=\"jw-co-addr\">").Append(sellerAddrEncoded).Append("</div>");
        sb.Append("<div class=\"jw-meta-cell\">");
        sb.Append("<table class=\"jw-meta-box\" role=\"presentation\"><tbody>");
        sb.Append("<tr><td class=\"k\">Challan no.</td><td class=\"v\">").Append(challanNoEnc).Append("</td></tr>");
        sb.Append("<tr><td class=\"k\">Date</td><td class=\"v\">").Append(dateEnc).Append("</td></tr>");
        sb.Append("</tbody></table>");
        sb.Append("</div>");
        sb.Append("</div>");

        sb.Append(jobPartyLineHtml);
        sb.Append(linesBlockHtml);
        sb.Append(remarksHtml);

        return sb.ToString();
    }

    private static string BuildLinesTable(DataTable lines)
    {
        var sb = new StringBuilder();
        sb.Append("<table class=\"jw-line-table\"><thead><tr>");
        sb.Append("<th class=\"jw-th-sr\">Sr</th>");
        sb.Append("<th>Item</th>");
        sb.Append("<th class=\"jw-th-qty\">Qty (sent)</th>");
        sb.Append("</tr></thead><tbody>");

        int sr = 0;
        int totalQty = 0;
        foreach (DataRow r in lines.Rows)
        {
            sr++;
            string part = r["part_name"] != DBNull.Value ? r["part_name"].ToString() : "";
            int qty = r["qty_sent"] != DBNull.Value ? Convert.ToInt32(r["qty_sent"], CultureInfo.InvariantCulture) : 0;
            totalQty += qty;

            sb.Append("<tr>");
            sb.Append("<td class=\"jw-td-sr\">").Append(sr).Append("</td>");
            sb.Append("<td class=\"jw-item\">").Append(HttpUtility.HtmlEncode(part)).Append("</td>");
            sb.Append("<td class=\"jw-td-qty\">").Append(qty.ToString(PrintCulture)).Append("</td>");
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");
        sb.Append("<div class=\"jw-total-qty\">Total qty. (sent) : <strong>").Append(totalQty.ToString(PrintCulture)).Append("</strong></div>");
        return sb.ToString();
    }
}
