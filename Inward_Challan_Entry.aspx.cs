using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Inward_Challan_Entry : Page
{
    private const string VsLines = "InwardLineRowsEntry";

    private sealed class InwardLineJson
    {
        public string partId { get; set; }
        public string qty { get; set; }
        public string rate { get; set; }
    }

    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

    private List<InwardLineVm> Lines
    {
        get
        {
            object o = ViewState[VsLines];
            if (o != null && o is List<InwardLineVm>)
                return (List<InwardLineVm>)o;
            return new List<InwardLineVm>();
        }
        set { ViewState[VsLines] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        string id = Request.QueryString["id"];
        if (!string.IsNullOrEmpty(id))
            hd_inward_id.Value = id;

        if (!IsPostBack)
        {
            BindParty();
            if (!string.IsNullOrEmpty(id))
            {
                lit_page_title.Text = "Edit challan";
                LoadForEdit(id);
            }
            else
            {
                hd_inward_id.Value = "";
                lit_page_title.Text = "New challan";
                txt_inward_date.Text = DateTime.Today.ToString("yyyy-MM-dd");
                Lines = new List<InwardLineVm> { new InwardLineVm() };
                BindRepeater();
            }
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        RegisterPartRatesMap();
        ApplyHeaderTabOrder();
        ApplyFooterTabOrder();
    }

    private void RegisterPartRatesMap()
    {
        var sb = new StringBuilder("window.inwardPartRates={");
        if (ddl_party.SelectedValue != "0")
        {
            DataSet ds = BAL_Part.dis_part(ddl_party.SelectedValue);
            if (ds.Tables.Count > 0)
            {
                bool first = true;
                foreach (DataRow r in ds.Tables[0].Rows)
                {
                    string id = r["part_id"].ToString();
                    decimal rate = r["rate"] != DBNull.Value ? Convert.ToDecimal(r["rate"], CultureInfo.InvariantCulture) : 0m;
                    string rateStr = rate.ToString(CultureInfo.InvariantCulture);
                    if (!first) sb.Append(",");
                    first = false;
                    sb.Append("\"").Append(EscapeJson(id)).Append("\":\"").Append(EscapeJson(rateStr)).Append("\"");
                }
            }
        }
        sb.Append("};");
        ScriptManager.RegisterStartupScript(this, GetType(), "inwardPartRatesMap", sb.ToString(), true);
    }

    private static string EscapeJson(string s)
    {
        if (s == null) return "";
        return s.Replace("\\", "\\\\").Replace("\"", "\\\"");
    }

    private void ApplyHeaderTabOrder()
    {
        ddl_party.TabIndex = (short)1;
        txt_challan_no.TabIndex = (short)2;
        txt_inward_date.TabIndex = (short)3;
        txt_remarks.TabIndex = (short)4;
    }

    private void ApplyFooterTabOrder()
    {
        int n = rep_lines.Items.Count;
        int lastFieldTab = n > 0 ? 10 + (n - 1) * 3 + 2 : 4;
        btn_save.TabIndex = (short)(lastFieldTab + 2);
    }

    private void BindParty()
    {
        ddl_party.Items.Clear();
        ddl_party.Items.Add(new ListItem("-- Select party --", "0"));
        DataSet ds = BAL_Party.dis_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_party.Items.Add(new ListItem(r["party_name"].ToString(), r["party_id"].ToString()));
        }
    }

    private void LoadForEdit(string inwardId)
    {
        DataSet ds = BAL_Inward.get_inward_for_edit(inwardId);
        if (ds.Tables.Count < 2 || ds.Tables[0].Rows.Count == 0)
        {
            ShowMsg("Challan not found.", Msg.Warning);
            return;
        }
        DataRow h = ds.Tables[0].Rows[0];
        ddl_party.SelectedValue = h["party_id"].ToString();
        txt_challan_no.Text = h["challan_no"].ToString();
        txt_inward_date.Text = Convert.ToDateTime(h["inward_date"]).ToString("yyyy-MM-dd");
        txt_remarks.Text = h["remarks"] != DBNull.Value ? h["remarks"].ToString() : "";
        var list = new List<InwardLineVm>();
        foreach (DataRow r in ds.Tables[1].Rows)
        {
            list.Add(new InwardLineVm
            {
                PartId = r["part_id"].ToString(),
                Qty = r["qty_inward"].ToString(),
                Rate = r["rate_at_time"] != DBNull.Value ? r["rate_at_time"].ToString() : "0"
            });
        }
        if (list.Count == 0) list.Add(new InwardLineVm());
        Lines = list;
        BindRepeater();
    }

    private void BindRepeater()
    {
        rep_lines.DataSource = Lines;
        rep_lines.DataBind();
    }

    private void SyncLinesFromRepeater()
    {
        var list = new List<InwardLineVm>();
        foreach (RepeaterItem it in rep_lines.Items)
        {
            var ddl = (DropDownList)it.FindControl("ddl_line_part");
            var tq = (TextBox)it.FindControl("txt_line_qty");
            var tr = (TextBox)it.FindControl("txt_line_rate");
            if (ddl == null) continue;
            list.Add(new InwardLineVm
            {
                PartId = ddl.SelectedValue,
                Qty = tq != null ? tq.Text.Trim() : "",
                Rate = tr != null && !string.IsNullOrWhiteSpace(tr.Text) ? tr.Text.Trim() : "0"
            });
        }
        Lines = list;
    }

    protected void ddl_party_SelectedIndexChanged(object sender, EventArgs e)
    {
        SyncLinesFromRepeater();
        Lines = new List<InwardLineVm> { new InwardLineVm() };
        BindRepeater();
    }

    protected void rep_lines_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
        var ddl = (DropDownList)e.Item.FindControl("ddl_line_part");
        if (ddl == null) return;
        string partyId = ddl_party.SelectedValue;
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("-- Part --", "0"));
        if (partyId == "0") return;
        DataSet ds = BAL_Part.dis_part(partyId);
        if (ds.Tables.Count == 0) return;
        foreach (DataRow r in ds.Tables[0].Rows)
            ddl.Items.Add(new ListItem(r["part_name"].ToString(), r["part_id"].ToString()));
        var row = (InwardLineVm)e.Item.DataItem;
        if (row != null && !string.IsNullOrEmpty(row.PartId) && row.PartId != "0")
        {
            var li = ddl.Items.FindByValue(row.PartId);
            if (li != null) ddl.SelectedValue = row.PartId;
        }

        var tq = (TextBox)e.Item.FindControl("txt_line_qty");
        var tr = (TextBox)e.Item.FindControl("txt_line_rate");
        int rowIdx = e.Item.ItemIndex;
        int tBase = 10 + rowIdx * 3;
        ddl.TabIndex = (short)tBase;
        if (tq != null) tq.TabIndex = (short)(tBase + 1);
        if (tr != null) tr.TabIndex = (short)(tBase + 2);
    }

    private static List<InwardLineVm> ParseLinesFromJson(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return null;
        try
        {
            var ser = new JavaScriptSerializer { MaxJsonLength = 500000 };
            List<InwardLineJson> arr = ser.Deserialize<List<InwardLineJson>>(json);
            if (arr == null) return null;
            var list = new List<InwardLineVm>();
            foreach (InwardLineJson j in arr)
            {
                list.Add(new InwardLineVm
                {
                    PartId = j != null && j.partId != null ? j.partId : "0",
                    Qty = j != null && j.qty != null ? j.qty.Trim() : "",
                    Rate = j != null && j.rate != null && !string.IsNullOrWhiteSpace(j.rate) ? j.rate.Trim() : "0"
                });
            }
            return list;
        }
        catch
        {
            return null;
        }
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            List<InwardLineVm> lineList = ParseLinesFromJson(hd_lines_json.Value);
            if (lineList == null || lineList.Count == 0)
            {
                SyncLinesFromRepeater();
                lineList = Lines;
            }
            if (ddl_party.SelectedValue == "0")
            {
                ShowMsg("Select party.", Msg.Warning);
                return;
            }
            string partIds = "", qtys = "", rates = "";
            foreach (InwardLineVm ln in lineList)
            {
                if (ln.PartId == "0" || string.IsNullOrWhiteSpace(ln.Qty)) continue;
                int q;
                string qtyTrim = ln.Qty.Trim();
                if (!int.TryParse(qtyTrim, NumberStyles.Integer, CultureInfo.InvariantCulture, out q) || q <= 0)
                {
                    decimal dq;
                    if (!decimal.TryParse(qtyTrim, NumberStyles.Number, CultureInfo.InvariantCulture, out dq) || dq <= 0m
                        || dq != decimal.Truncate(dq) || dq > int.MaxValue)
                        continue;
                    q = (int)dq;
                }
                string rateOut = "0";
                if (!string.IsNullOrWhiteSpace(ln.Rate))
                {
                    decimal rv;
                    if (decimal.TryParse(ln.Rate.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out rv))
                        rateOut = rv.ToString(CultureInfo.InvariantCulture);
                }
                partIds += ln.PartId + ",";
                qtys += q.ToString(CultureInfo.InvariantCulture) + ",";
                rates += rateOut + ",";
            }
            if (partIds.Length == 0)
            {
                ShowMsg("Add at least one row with part and qty.", Msg.Warning);
                return;
            }

            string by = Session["user_id"].ToString();
            DataSet ds;
            if (string.IsNullOrEmpty(hd_inward_id.Value))
                ds = BAL_Inward.ins_inward_challan(ddl_party.SelectedValue, txt_challan_no.Text.Trim(), txt_inward_date.Text, txt_remarks.Text, by, partIds, qtys, rates);
            else
                ds = BAL_Inward.upd_inward_challan(hd_inward_id.Value, ddl_party.SelectedValue, txt_challan_no.Text.Trim(), txt_inward_date.Text, txt_remarks.Text, by, partIds, qtys, rates);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                ShowMsg("No response from server. Try again.", Msg.Error);
                return;
            }

            string ok = ds.Tables[0].Rows[0]["Success"].ToString().ToLower();
            string msg = ds.Tables[0].Rows[0]["Message"].ToString();
            if (ok == "true")
            {
                bool linesLocked = msg.IndexOf("lines locked", StringComparison.OrdinalIgnoreCase) >= 0
                    || msg.IndexOf("header only", StringComparison.OrdinalIgnoreCase) >= 0;
                ShowMsg(msg, Msg.Success);
                if (linesLocked)
                    return;
                Response.Redirect("Inward_Challan_List.aspx");
            }
            else
                ShowMsg(msg, Msg.Warning);
        }
        catch (Exception ex)
        {
            ShowMsg(ex.Message, Msg.Error);
        }
    }
}
