using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Invoice_Entry : Page
{
    private const string VsLineRows = "InvoiceEntryLineUi";

    public enum Msg { Success, Error, Warning }

    [Serializable]
    private sealed class InvoiceLineUiVm
    {
        public string InwardDetailId { get; set; }
        public string ChallanNo { get; set; }
        public string InwardDateDisp { get; set; }
        public string PartName { get; set; }
        public string QtyInward { get; set; }
        public string QtyInvoicedSoFar { get; set; }
        public string QtyAvailable { get; set; }
        public string InvoiceQty { get; set; }
        public string Rate { get; set; }
        public string TaxPer { get; set; }
        public bool LineChecked { get; set; }
    }

    private List<InvoiceLineUiVm> LineRows
    {
        get
        {
            object o = ViewState[VsLineRows];
            if (o is List<InvoiceLineUiVm>)
                return (List<InvoiceLineUiVm>)o;
            return new List<InvoiceLineUiVm>();
        }
        set { ViewState[VsLineRows] = value; }
    }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

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

        if (!IsPostBack)
        {
            hd_invoice_id.Value = id ?? "";
            BindParty();
            txt_invoice_date.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txt_from.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddl_inward.Items.Clear();
            ddl_inward.Items.Add(new ListItem("All challans in range", "0"));

            if (!string.IsNullOrEmpty(id))
            {
                lit_page_title.Text = "Edit invoice";
                pnl_pick_lines.Visible = false;
                pnl_invoice_no_hint.Visible = false;
                pnl_invoice_no_edit.Visible = true;
                LoadForEdit(id);
                lnk_print.Visible = true;
                lnk_print.NavigateUrl = "Invoice_Print.aspx?id=" + Server.UrlEncode(id);
            }
            else
            {
                lit_page_title.Text = "New invoice";
                pnl_pick_lines.Visible = true;
                pnl_invoice_no_hint.Visible = true;
                pnl_invoice_no_edit.Visible = false;
                LineRows = new List<InvoiceLineUiVm>();
                gv_lines.DataSource = null;
                gv_lines.DataBind();
            }
        }
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

    private void BindInwardDropdown()
    {
        ddl_inward.Items.Clear();
        ddl_inward.Items.Add(new ListItem("All challans in range", "0"));
        if (ddl_party.SelectedValue == "0") return;

        DataSet ds = BAL_Inward.dis_inward_report(txt_from.Text, txt_to.Text, ddl_party.SelectedValue, "0");
        if (ds.Tables.Count == 0) return;
        foreach (DataRow r in ds.Tables[0].Rows)
        {
            string iid = r["inward_id"].ToString();
            string cn = r["challan_no"] != DBNull.Value ? r["challan_no"].ToString() : "";
            string d = r["inward_date"] != DBNull.Value
                ? Convert.ToDateTime(r["inward_date"], CultureInfo.InvariantCulture).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture)
                : "";
            ddl_inward.Items.Add(new ListItem(cn + " - " + d, iid));
        }
    }

    private void BindLineGrid()
    {
        gv_lines.DataSource = LineRows;
        gv_lines.DataBind();
        ScriptManager.RegisterStartupScript(this, GetType(), "invRecalcAfterBind" + Guid.NewGuid().ToString("N"),
            "if (typeof window.invRecalcTotals === 'function') { window.invRecalcTotals(); }", true);
    }

    private void LoadForEdit(string invoiceId)
    {
        DataSet ds = BAL_Invoice.get_invoice_for_edit(invoiceId);
        if (ds.Tables.Count < 2 || ds.Tables[0].Rows.Count == 0)
        {
            ShowMsg("Invoice not found.", Msg.Warning);
            return;
        }

        DataRow h = ds.Tables[0].Rows[0];
        hd_invoice_id.Value = h["invoice_id"].ToString();
        ddl_party.SelectedValue = h["party_id"].ToString();
        ddl_party.Enabled = false;

        string kind = h["invoice_kind"].ToString();
        var liKind = ddl_invoice_kind.Items.FindByValue(kind);
        if (liKind != null) ddl_invoice_kind.SelectedValue = kind;

        lit_invoice_no.Text = System.Web.HttpUtility.HtmlEncode(h["invoice_no"].ToString());
        txt_invoice_date.Text = Convert.ToDateTime(h["invoice_date"], CultureInfo.InvariantCulture).ToString("yyyy-MM-dd");
        txt_remarks.Text = h["remarks"] != DBNull.Value ? h["remarks"].ToString() : "";

        var list = new List<InvoiceLineUiVm>();
        foreach (DataRow r in ds.Tables[1].Rows)
        {
            decimal rateVal = r["rate"] != DBNull.Value
                ? Convert.ToDecimal(r["rate"], CultureInfo.InvariantCulture)
                : 0m;
            decimal taxVal = r["tax_per"] != DBNull.Value
                ? Convert.ToDecimal(r["tax_per"], CultureInfo.InvariantCulture)
                : 0m;
            int qtyIn = r["qty_inward"] != DBNull.Value
                ? Convert.ToInt32(r["qty_inward"], CultureInfo.InvariantCulture)
                : 0;
            int qtySoFar = r["qty_invoiced_so_far"] != DBNull.Value
                ? Convert.ToInt32(r["qty_invoiced_so_far"], CultureInfo.InvariantCulture)
                : 0;
            int qtyCan = r["qty_can_bill_max"] != DBNull.Value
                ? Convert.ToInt32(r["qty_can_bill_max"], CultureInfo.InvariantCulture)
                : 0;
            if (qtyCan < 0)
                qtyCan = 0;
            string idate = "";
            if (r["inward_date"] != DBNull.Value)
                idate = Convert.ToDateTime(r["inward_date"], CultureInfo.InvariantCulture).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
            list.Add(new InvoiceLineUiVm
            {
                InwardDetailId = r["inward_detail_id"].ToString(),
                ChallanNo = r["challan_no"] != DBNull.Value ? r["challan_no"].ToString() : "",
                InwardDateDisp = idate,
                PartName = r["part_name"] != DBNull.Value ? r["part_name"].ToString() : "",
                QtyInward = qtyIn.ToString(CultureInfo.InvariantCulture),
                QtyInvoicedSoFar = qtySoFar.ToString(CultureInfo.InvariantCulture),
                QtyAvailable = qtyCan.ToString(CultureInfo.InvariantCulture),
                InvoiceQty = r["qty_invoiced"] != DBNull.Value ? r["qty_invoiced"].ToString() : "",
                Rate = rateVal.ToString(CultureInfo.InvariantCulture),
                TaxPer = taxVal.ToString(CultureInfo.InvariantCulture),
                LineChecked = true
            });
        }
        LineRows = list;
        BindLineGrid();
    }

    protected void gv_lines_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;
        var vm = e.Row.DataItem as InvoiceLineUiVm;
        if (vm == null)
            return;

        string rateStr = string.IsNullOrWhiteSpace(vm.Rate) ? "0" : vm.Rate.Trim();
        string taxStr = string.IsNullOrWhiteSpace(vm.TaxPer) ? "0" : vm.TaxPer.Trim();
        string availStr = vm.QtyAvailable;
        if (string.IsNullOrEmpty(availStr))
        {
            int iq;
            availStr = int.TryParse(vm.InvoiceQty, NumberStyles.Integer, CultureInfo.InvariantCulture, out iq)
                ? vm.InvoiceQty
                : "0";
        }

        e.Row.Attributes["data-rate"] = rateStr.Replace(",", ".");
        e.Row.Attributes["data-tax"] = taxStr.Replace(",", ".");
        e.Row.Attributes["data-qty-avail"] = availStr.Trim();
        e.Row.CssClass = (e.Row.CssClass + " inv-line-row").Trim();
    }

    protected void btn_load_lines_Click(object sender, EventArgs e)
    {
        if (ddl_party.SelectedValue == "0")
        {
            ShowMsg("Select party.", Msg.Warning);
            return;
        }

        BindInwardDropdown();

        DataSet ds = BAL_Invoice.sel_inward_lines_for_invoice(
            ddl_party.SelectedValue, txt_from.Text, txt_to.Text, ddl_inward.SelectedValue);

        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        {
            ShowMsg("No inward lines in this range.", Msg.Warning);
            LineRows = new List<InvoiceLineUiVm>();
            BindLineGrid();
            return;
        }

        var list = new List<InvoiceLineUiVm>();
        foreach (DataRow r in ds.Tables[0].Rows)
        {
            int avail = r["qty_available_for_invoice"] != DBNull.Value
                ? Convert.ToInt32(r["qty_available_for_invoice"], CultureInfo.InvariantCulture)
                : 0;
            if (avail <= 0)
                continue;

            string idate = "";
            if (r["inward_date"] != DBNull.Value)
                idate = Convert.ToDateTime(r["inward_date"], CultureInfo.InvariantCulture).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);

            decimal rateVal = r["suggest_rate"] != DBNull.Value
                ? Convert.ToDecimal(r["suggest_rate"], CultureInfo.InvariantCulture)
                : 0m;
            decimal taxVal = r["suggest_tax_per"] != DBNull.Value
                ? Convert.ToDecimal(r["suggest_tax_per"], CultureInfo.InvariantCulture)
                : 0m;
            list.Add(new InvoiceLineUiVm
            {
                InwardDetailId = r["inward_detail_id"].ToString(),
                ChallanNo = r["challan_no"] != DBNull.Value ? r["challan_no"].ToString() : "",
                InwardDateDisp = idate,
                PartName = r["part_name"] != DBNull.Value ? r["part_name"].ToString() : "",
                QtyInward = r["qty_inward"] != DBNull.Value ? r["qty_inward"].ToString() : "",
                QtyInvoicedSoFar = r["qty_invoiced_so_far"] != DBNull.Value ? r["qty_invoiced_so_far"].ToString() : "0",
                QtyAvailable = avail.ToString(CultureInfo.InvariantCulture),
                InvoiceQty = "",
                Rate = rateVal.ToString(CultureInfo.InvariantCulture),
                TaxPer = taxVal.ToString(CultureInfo.InvariantCulture),
                LineChecked = false
            });
        }

        if (list.Count == 0)
        {
            ShowMsg("No lines with quantity left to bill.", Msg.Warning);
        }

        LineRows = list;
        BindLineGrid();
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        if (ddl_party.SelectedValue == "0")
        {
            ShowMsg("Select party.", Msg.Warning);
            return;
        }

        string inwardIds = "";
        string qtys = "";

        foreach (GridViewRow row in gv_lines.Rows)
        {
            if (row.RowType != DataControlRowType.DataRow) continue;
            var cb = (CheckBox)row.FindControl("cb_line");
            if (cb == null || !cb.Checked)
                continue;

            object key = gv_lines.DataKeys[row.RowIndex].Value;
            if (key == null) continue;
            string did = key.ToString();
            var txt = (TextBox)row.FindControl("txt_inv_qty");
            if (txt == null || string.IsNullOrWhiteSpace(txt.Text)) continue;

            int q;
            if (!int.TryParse(txt.Text.Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out q) || q <= 0)
                continue;

            inwardIds += did + ",";
            qtys += q.ToString(CultureInfo.InvariantCulture) + ",";
        }

        if (inwardIds.Length == 0)
        {
            ShowMsg("Select at least one line (checkbox) and enter quantity.", Msg.Warning);
            return;
        }

        try
        {
            string by = Session["user_id"].ToString();
            DataSet ds;

            if (string.IsNullOrEmpty(hd_invoice_id.Value))
            {
                ds = BAL_Invoice.ins_invoice(
                    ddl_party.SelectedValue,
                    ddl_invoice_kind.SelectedValue,
                    txt_invoice_date.Text,
                    txt_remarks.Text,
                    by,
                    inwardIds,
                    qtys);
            }
            else
            {
                ds = BAL_Invoice.upd_invoice(
                    hd_invoice_id.Value,
                    ddl_party.SelectedValue,
                    ddl_invoice_kind.SelectedValue,
                    txt_invoice_date.Text,
                    txt_remarks.Text,
                    by,
                    inwardIds,
                    qtys);
            }

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                ShowMsg("No response from server.", Msg.Error);
                return;
            }

            string ok = ds.Tables[0].Rows[0]["Success"].ToString().ToLowerInvariant();
            string msg = ds.Tables[0].Rows[0]["Message"].ToString();
            if (ok == "true")
            {
                ShowMsg(msg, Msg.Success);
                Response.Redirect("Invoice_List.aspx");
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
