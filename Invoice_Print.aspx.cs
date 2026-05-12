using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

public partial class Invoice_Print : Page
{
    private static readonly CultureInfo InvCulture = CultureInfo.GetCultureInfo("en-IN");
    /// <summary>Compact print format — single line, avoids awkward breaks in narrow columns.</summary>
    private const string PrintDateFormat = "dd/MM/yyyy";

    // Seller & footer defaults (layout only; safe to edit as per your letterhead).
    private const string SellerAddrDefault = "PLOT NO-253,2-ANKUR IND AREA,NEAR KOHINOOR PAINT\r\nSHAPER(VERAVAL) MO NO:-+91-9687822994";
    private const string SellerGstinDefault = "";
    private const string PlaceOfSupplyDefault = "24-Gujarat";

    private static readonly string[] NumUnits = { "", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten",
        "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen" };
    private static readonly string[] NumTens = { "", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety" };

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

        DataSet ds = BAL_Invoice.get_invoice_for_edit(id);
        if (ds.Tables.Count < 2 || ds.Tables[0].Rows.Count == 0)
        {
            ShowError();
            return;
        }

        DataRow inv = ds.Tables[0].Rows[0];
        string partyId = inv["party_id"].ToString();
        DataSet dsp = BAL_Party.sel_party_by_id(partyId);
        DataRow party = null;
        if (dsp.Tables.Count > 0 && dsp.Tables[0].Rows.Count > 0)
            party = dsp.Tables[0].Rows[0];

        bool isGst = string.Equals(inv["invoice_kind"].ToString(), "GST", StringComparison.OrdinalIgnoreCase);

        string logoPath = Server.MapPath("~/image/thumbnail.jpg");
        pnl_logo.Visible = File.Exists(logoPath);

        // Seller header (layout-only fields)
        // Company name is already in logo (per requirement)
        lit_seller_name2.Text = "";
        lit_seller_addr.Text = HttpUtility.HtmlEncode(SellerAddrDefault);
        lit_seller_gstin.Text = HttpUtility.HtmlEncode(SellerGstinDefault);
        //lit_place_supply.Text = HttpUtility.HtmlEncode(PlaceOfSupplyDefault);
        pnl_seller_gst.Visible = isGst;

        // GSTIN line below items table (as per reference image)
        if (isGst && !string.IsNullOrWhiteSpace(SellerGstinDefault))
        {
            pnl_gstin_bottom.Visible = true;
            lit_gstin_bottom.Text = HttpUtility.HtmlEncode(SellerGstinDefault.Trim());
        }
        else
        {
            pnl_gstin_bottom.Visible = false;
            lit_gstin_bottom.Text = "";
        }

        // Reference image shows "Debit Memo" at left for this invoice type
        lit_left_badge.Text = HttpUtility.HtmlEncode("");

        lit_doc_title.Text = isGst
            ? HttpUtility.HtmlEncode("Purchase Order")
            : HttpUtility.HtmlEncode("Purchase Order");

        lit_inv_no.Text = HttpUtility.HtmlEncode(inv["invoice_no"].ToString());
        DateTime invDate = Convert.ToDateTime(inv["invoice_date"], CultureInfo.InvariantCulture);
        lit_inv_date.Text = HttpUtility.HtmlEncode(invDate.ToString(PrintDateFormat, InvCulture));

        if (party != null)
        {
            lit_party_name.Text = HttpUtility.HtmlEncode(party["party_name"].ToString());
            string addr = party["address"] != DBNull.Value ? party["address"].ToString().Trim() : "";
            lit_party_addr.Text = HttpUtility.HtmlEncode(addr);
            string gst = party["gst_no"] != DBNull.Value ? party["gst_no"].ToString().Trim() : "";
            if (isGst && !string.IsNullOrEmpty(gst))
            {
                pnl_party_gst.Visible = true;
                lit_party_gst.Text = HttpUtility.HtmlEncode(gst);
            }
            else
                pnl_party_gst.Visible = false;
        }
        else
        {
            lit_party_name.Text = "";
            lit_party_addr.Text = "";
            pnl_party_gst.Visible = false;
        }

        string remarks = inv["remarks"] != DBNull.Value ? inv["remarks"].ToString().Trim() : "";
        if (!string.IsNullOrEmpty(remarks))
        {
            pnl_remarks.Visible = true;
            lit_remarks.Text = HttpUtility.HtmlEncode(remarks);
        }
        else
            pnl_remarks.Visible = false;

        decimal sub = inv["sub_total"] != DBNull.Value ? Convert.ToDecimal(inv["sub_total"], CultureInfo.InvariantCulture) : 0m;
        decimal tax = inv["tax_total"] != DBNull.Value ? Convert.ToDecimal(inv["tax_total"], CultureInfo.InvariantCulture) : 0m;
        decimal grand = inv["grand_total"] != DBNull.Value ? Convert.ToDecimal(inv["grand_total"], CultureInfo.InvariantCulture) : 0m;

        lit_lines_html.Text = BuildLinesTable(ds.Tables[1], isGst);

        if (isGst)
        {
            pnl_tot_gst.Visible = true;
            pnl_tot_nongst.Visible = false;
            lit_sub_total.Text = HttpUtility.HtmlEncode(sub.ToString("N2", InvCulture));
            lit_grand_total.Text = HttpUtility.HtmlEncode(grand.ToString("N2", InvCulture));

            decimal half = Math.Round(tax / 2m, 2, MidpointRounding.AwayFromZero);
            decimal roundOff = Math.Round(grand - (sub + tax), 2, MidpointRounding.AwayFromZero);
            lit_cgst.Text = HttpUtility.HtmlEncode(half.ToString("N2", InvCulture));
            lit_sgst.Text = HttpUtility.HtmlEncode((tax - half).ToString("N2", InvCulture));
            lit_roundoff.Text = HttpUtility.HtmlEncode(roundOff.ToString("N2", InvCulture));
        }
        else
        {
            pnl_tot_gst.Visible = false;
            pnl_tot_nongst.Visible = true;
            lit_grand_only.Text = HttpUtility.HtmlEncode(grand.ToString("N2", InvCulture));
            lit_sub_total_ng.Text = HttpUtility.HtmlEncode(sub.ToString("N2", InvCulture));
            decimal roundOff = Math.Round(grand - sub, 2, MidpointRounding.AwayFromZero);
            lit_roundoff_ng.Text = HttpUtility.HtmlEncode(roundOff.ToString("N2", InvCulture));
        }

        lit_amount_words.Text = HttpUtility.HtmlEncode(RupeesInWords(grand));

        pnl_error.Visible = false;
        pnl_invoice.Visible = true;
    }

    private void ShowError()
    {
        pnl_error.Visible = true;
        pnl_invoice.Visible = false;
    }

    private static string BuildLinesTable(DataTable lines, bool isGst)
    {
        var sb = new StringBuilder();
        sb.Append("<table class=\"inv-line-table\"><colgroup>");
        sb.Append("<col class=\"inv-col-sr\" /><col class=\"inv-col-date\" /><col class=\"inv-col-challan\" /><col class=\"inv-col-item\" />");
        sb.Append("<col class=\"inv-col-qty\" /><col class=\"inv-col-rate\" /><col class=\"inv-col-tax\" /><col class=\"inv-col-taxamt\" /><col class=\"inv-col-total\" />");
        sb.Append("</colgroup><thead><tr>");
        sb.Append("<th>Sr</th><th class=\"inv-th-date\">Date</th><th>Challan</th><th>Item</th>");
        sb.Append("<th class=\"inv-th-num\">Qty</th><th class=\"inv-th-num\">Rate</th>");
        sb.Append("<th class=\"inv-th-num\">Tax</th><th class=\"inv-th-num\">Tax amount</th><th class=\"inv-th-num\">Total amount</th>");
        sb.Append("</tr></thead><tbody>");

        int sr = 0;
        foreach (DataRow r in lines.Rows)
        {
            sr++;
            string trClass = (sr % 2 == 0) ? "inv-tr inv-tr--even" : "inv-tr";
            string part = r["part_name"] != DBNull.Value ? r["part_name"].ToString() : "";
            string challanNo = r.Table.Columns.Contains("challan_no") && r["challan_no"] != DBNull.Value ? r["challan_no"].ToString().Trim() : "";
            string chd = "";
            if (r["inward_date"] != DBNull.Value)
                chd = Convert.ToDateTime(r["inward_date"], CultureInfo.InvariantCulture).ToString(PrintDateFormat, InvCulture);
            int qty = r["qty_invoiced"] != DBNull.Value ? Convert.ToInt32(r["qty_invoiced"], CultureInfo.InvariantCulture) : 0;
            decimal rate = r["rate"] != DBNull.Value ? Convert.ToDecimal(r["rate"], CultureInfo.InvariantCulture) : 0m;
            decimal taxper = r["tax_per"] != DBNull.Value ? Convert.ToDecimal(r["tax_per"], CultureInfo.InvariantCulture) : 0m;
            decimal taxamt = r["tax_amount"] != DBNull.Value ? Convert.ToDecimal(r["tax_amount"], CultureInfo.InvariantCulture) : 0m;
            decimal lineTot = r["line_total"] != DBNull.Value ? Convert.ToDecimal(r["line_total"], CultureInfo.InvariantCulture) : 0m;

            string taxCell = isGst
                ? HttpUtility.HtmlEncode(taxper.ToString("N2", InvCulture)) + "%"
                : "\u2014";
            string taxAmtCell = isGst
                ? HttpUtility.HtmlEncode(taxamt.ToString("N2", InvCulture))
                : "\u2014";

            sb.Append("<tr class=\"").Append(trClass).Append("\">");
            sb.Append("<td class=\"inv-td-sno\">").Append(sr).Append("</td>");
            sb.Append("<td class=\"inv-td-date\">").Append(HttpUtility.HtmlEncode(chd)).Append("</td>");
            sb.Append("<td class=\"inv-td-challan\">")
                .Append(string.IsNullOrEmpty(challanNo) ? "\u2014" : HttpUtility.HtmlEncode(challanNo))
                .Append("</td>");
            sb.Append("<td class=\"inv-td-item\">").Append(HttpUtility.HtmlEncode(part)).Append("</td>");
            sb.Append("<td class=\"inv-td-num\">").Append(qty.ToString(InvCulture)).Append("</td>");
            sb.Append("<td class=\"inv-td-num\">").Append(HttpUtility.HtmlEncode(rate.ToString("N2", InvCulture))).Append("</td>");
            sb.Append("<td class=\"inv-td-num\">").Append(taxCell).Append("</td>");
            sb.Append("<td class=\"inv-td-num\">").Append(taxAmtCell).Append("</td>");
            sb.Append("<td class=\"inv-td-num inv-td-amt\">").Append(HttpUtility.HtmlEncode(lineTot.ToString("N2", InvCulture))).Append("</td>");
            sb.Append("</tr>");
        }

        sb.Append("</tbody></table>");
        return sb.ToString();
    }

    private static string RupeesInWords(decimal amount)
    {
        long rupees = (long)Math.Floor(amount + 0.005m);
        if (rupees == 0 && amount < 0.01m)
            return "Zero rupees only";
        return Capitalize(ConvertNumberToWords(rupees)) + " rupees only";
    }

    private static string Capitalize(string s)
    {
        if (string.IsNullOrEmpty(s)) return s;
        return char.ToUpperInvariant(s[0]) + (s.Length > 1 ? s.Substring(1) : "");
    }

    private static string UnderThousand(int x)
    {
        if (x == 0) return "";
        if (x < 20) return NumUnits[x];
        if (x < 100)
        {
            int t = x / 10, u = x % 10;
            return NumTens[t] + (u > 0 ? " " + NumUnits[u] : "");
        }
        int h = x / 100, r = x % 100;
        return NumUnits[h] + " hundred" + (r > 0 ? " " + UnderThousand(r) : "");
    }

    private static string ConvertNumberToWords(long n)
    {
        if (n == 0) return "zero";
        if (n < 0) return "minus " + ConvertNumberToWords(-n);

        var parts = new System.Collections.Generic.List<string>();
        int crore = (int)(n / 10000000);
        n %= 10000000;
        int lakh = (int)(n / 100000);
        n %= 100000;
        int thousand = (int)(n / 1000);
        n %= 1000;
        int rem = (int)n;

        if (crore > 0) parts.Add(UnderThousand(crore) + " crore");
        if (lakh > 0) parts.Add(UnderThousand(lakh) + " lakh");
        if (thousand > 0) parts.Add(UnderThousand(thousand) + " thousand");
        if (rem > 0) parts.Add(UnderThousand(rem));

        return string.Join(" ", parts.ToArray()).Trim();
    }
}
