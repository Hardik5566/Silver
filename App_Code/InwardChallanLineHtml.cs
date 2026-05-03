using System;
using System.Data;
using System.Text;

/// <summary>Renders the parts / qty / out / pending sheet used on inward list and report (matches STRING_AGG format in list/report SPs).</summary>
public static class InwardChallanLineHtml
{
    private const string AggItemSep = " | ";
    private const string NameQtySep = " \u00D7 ";

    public static string BuildPartsSheet(DataRowView drv)
    {
        if (drv == null) return "";
        string itemList = drv["item_list"] != DBNull.Value ? drv["item_list"].ToString() : "";
        string itemsOut = drv["items_out"] != DBNull.Value ? drv["items_out"].ToString() : "";
        string itemsPend = drv["items_pending"] != DBNull.Value ? drv["items_pending"].ToString() : "";

        string[] ins = SplitAgg(itemList);
        string[] outs = SplitAgg(itemsOut);
        string[] pends = SplitAgg(itemsPend);
        int n = Math.Max(Math.Max(ins.Length, outs.Length), pends.Length);

        if (n == 0)
            return "<span class=\"text-muted small\">No lines</span>";

        var sb = new StringBuilder();
        sb.Append("<div class=\"inward-line-box\"><div class=\"inward-sheet\" role=\"group\" aria-label=\"Challan lines\"><div class=\"inward-sheet__body\">");

        for (int i = 0; i < n; i++)
        {
            string nIn, qIn, nOut, qOut, nPen, qPen;
            SplitNameQty(i < ins.Length ? ins[i] : "", out nIn, out qIn);
            SplitNameQty(i < outs.Length ? outs[i] : "", out nOut, out qOut);
            SplitNameQty(i < pends.Length ? pends[i] : "", out nPen, out qPen);

            string item = !string.IsNullOrEmpty(nIn) ? nIn : (!string.IsNullOrEmpty(nPen) ? nPen : nOut);

            sb.Append("<div class=\"inward-sheet__row\"><span class=\"inward-sheet__item\">").Append(Enc(item)).Append("</span>");
            AppendNumCell(sb, qIn, "qty");
            AppendNumCell(sb, qOut, "out");
            AppendNumCell(sb, qPen, "pend");
            sb.Append("</div>");
        }

        sb.Append("</div></div></div>");
        return sb.ToString();
    }

    private static string[] SplitAgg(string raw)
    {
        string s = raw == null ? "" : raw.Trim();
        if (s.Length == 0) return new string[0];
        return s.Split(new[] { AggItemSep }, StringSplitOptions.None);
    }

    private static void SplitNameQty(string segment, out string name, out string qty)
    {
        name = "";
        qty = "";
        if (string.IsNullOrWhiteSpace(segment)) return;
        string seg = segment.Trim();
        int idx = seg.LastIndexOf(NameQtySep, StringComparison.Ordinal);
        if (idx <= 0)
        {
            name = seg;
            return;
        }
        name = seg.Substring(0, idx).Trim();
        qty = seg.Substring(idx + NameQtySep.Length).Trim();
    }

    private static string Enc(string s)
    {
        return System.Web.HttpUtility.HtmlEncode(s ?? "");
    }

    private static string ColTitle(string col)
    {
        if (col == "qty") return "Quantity received";
        if (col == "out") return "Quantity sent out";
        return "Quantity pending";
    }

    private static string ColIconHtml(string col)
    {
        if (col == "qty") return "<i class=\"bi bi-arrow-down-circle inward-sheet__ico\" aria-hidden=\"true\"></i>";
        if (col == "out") return "<i class=\"bi bi-box-arrow-right inward-sheet__ico\" aria-hidden=\"true\"></i>";
        return "<i class=\"bi bi-hourglass-split inward-sheet__ico\" aria-hidden=\"true\"></i>";
    }

    private static void AppendNumCell(StringBuilder sb, string q, string col)
    {
        sb.Append("<span class=\"inward-sheet__num inward-sheet__num--").Append(col);
        if (string.IsNullOrEmpty(q)) sb.Append(" inward-sheet__num--empty");
        sb.Append("\" title=\"").Append(System.Web.HttpUtility.HtmlAttributeEncode(ColTitle(col))).Append("\">");
        sb.Append(ColIconHtml(col));
        sb.Append(string.IsNullOrEmpty(q) ? "<span class=\"inward-sheet__dash\">&#8211;</span>" : Enc(q));
        sb.Append("</span>");
    }
}
