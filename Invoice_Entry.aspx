<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Invoice_Entry.aspx.cs" Inherits="Invoice_Entry" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Invoice</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .inv-entry-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; }
        .inv-line-grid { margin: 0; font-size: 13px; }
        .inv-line-grid thead th { background: #e9ecef; font-weight: 600; border: 1px solid #ced4da; padding: 8px 10px; white-space: nowrap; }
        .inv-line-grid tbody td { border: 1px solid #dee2e6; padding: 6px 8px; vertical-align: middle; }
        .inv-line-grid tbody tr:nth-child(even) { background: #f8f9fa; }
        .inv-totals-card { border: 1px solid #0d6efd33; border-radius: 8px; background: linear-gradient(180deg, #f0f7ff 0%, #fff 100%); }
        .inv-totals-card .lbl { font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.06em; color: #6c757d; font-weight: 600; }
        .inv-totals-card .val { font-size: 1.25rem; font-weight: 700; color: #0d6efd; font-variant-numeric: tabular-nums; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h1 class="h5 mb-0 fw-semibold text-dark"><asp:Literal ID="lit_page_title" runat="server" Text="New invoice" /></h1>
        <div class="d-flex flex-wrap gap-2 align-items-center">
            <asp:HyperLink ID="lnk_print" runat="server" Visible="false" CssClass="btn btn-sm btn-outline-primary" Target="_blank">Print invoice</asp:HyperLink>
            <a href="Invoice_List.aspx" class="btn btn-sm btn-outline-secondary">Back to invoice list</a>
        </div>
    </div>

    <asp:Panel ID="pnl_pick_lines" runat="server" CssClass="card inv-entry-card shadow-sm mb-3">
        <div class="card-body row g-3">
            <div class="col-12"><span class="text-muted small">Select party and date range, optionally one challan, then load billable lines. Use checkboxes to choose lines; quantity defaults to full billable qty when checked.</span></div>
            <div class="col-lg-4 col-md-6">
                <label class="form-label">Party</label>
                <asp:DropDownList ID="ddl_party" runat="server" CssClass="form-select"></asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">From</label>
                <asp:TextBox ID="txt_from" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">To</label>
                <asp:TextBox ID="txt_to" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="col-lg-4 col-md-6">
                <label class="form-label">Challan</label>
                <asp:DropDownList ID="ddl_inward" runat="server" CssClass="form-select"></asp:DropDownList>
            </div>
            <div class="col-12">
                <asp:Button ID="btn_load_lines" runat="server" CssClass="btn btn-outline-primary" Text="Load billable lines" OnClick="btn_load_lines_Click" />
            </div>
        </div>
    </asp:Panel>

    <div class="card inv-entry-card shadow-sm mb-3">
        <div class="card-body row g-3">
            <div class="col-12" runat="server" id="pnl_invoice_no_hint" visible="true">
                <p class="small text-muted mb-0">Invoice number is generated automatically when you save (format INV-yyyyMM-00001).</p>
            </div>
            <div class="col-12" runat="server" id="pnl_invoice_no_edit" visible="false">
                <label class="form-label">Invoice number</label>
                <div class="form-control-plaintext fw-semibold"><asp:Literal ID="lit_invoice_no" runat="server" /></div>
            </div>
            <div class="col-lg-3 col-md-4">
                <label class="form-label">Invoice kind</label>
                <asp:DropDownList ID="ddl_invoice_kind" runat="server" CssClass="form-select" ClientIDMode="Static">
                    <asp:ListItem Value="GST" Text="GST" Selected="True"></asp:ListItem>
                    <asp:ListItem Value="NON_GST" Text="Non-GST"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4">
                <label class="form-label">Invoice date</label>
                <asp:TextBox ID="txt_invoice_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
            </div>
            <div class="col-12">
                <label class="form-label">Remarks</label>
                <asp:TextBox ID="txt_remarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
            </div>
        </div>
    </div>

    <div class="inv-entry-card shadow-sm mb-2">
        <div class="table-responsive">
            <asp:GridView ID="gv_lines" runat="server" ClientIDMode="Static" CssClass="table inv-line-grid mb-0" AutoGenerateColumns="false"
                DataKeyNames="InwardDetailId" GridLines="None" ShowHeaderWhenEmpty="true"
                OnRowDataBound="gv_lines_RowDataBound"
                EmptyDataText="No lines loaded. Use Load billable lines for a new invoice, or open a saved invoice.">
                <Columns>
                    <asp:TemplateField HeaderText="" HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center align-middle" ItemStyle-Width="40px">
                        <HeaderTemplate>
                            <input type="checkbox" id="inv_cb_all" class="form-check-input" title="Select all" aria-label="Select all lines" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="cb_line" runat="server" CssClass="form-check-input inv-line-cb" Checked='<%# Eval("LineChecked") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="ChallanNo" HeaderText="Challan" ItemStyle-CssClass="text-nowrap" />
                    <asp:BoundField DataField="InwardDateDisp" HeaderText="Ch. date" ItemStyle-CssClass="text-nowrap" />
                    <asp:BoundField DataField="PartName" HeaderText="Part" />
                    <asp:BoundField DataField="QtyInward" HeaderText="Qty in" ItemStyle-CssClass="text-end" HeaderStyle-CssClass="text-end" />
                    <asp:BoundField DataField="QtyInvoicedSoFar" HeaderText="Already billed" ItemStyle-CssClass="text-end" HeaderStyle-CssClass="text-end" />
                    <asp:BoundField DataField="QtyAvailable" HeaderText="Can bill" ItemStyle-CssClass="text-end fw-semibold" HeaderStyle-CssClass="text-end" />
                    <asp:TemplateField HeaderText="Qty this invoice" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end" ItemStyle-Width="140px">
                        <ItemTemplate>
                            <asp:TextBox ID="txt_inv_qty" runat="server" CssClass="form-control form-control-sm text-end inv-qty-inp" Text='<%# Eval("InvoiceQty") %>'></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>

    <div class="card inv-totals-card shadow-sm mb-3">
        <div class="card-body py-3">
            <div class="row g-3 text-center text-md-start">
                <div class="col-md-4">
                    <div class="lbl">Total invoice (taxable)</div>
                    <div class="val" id="inv_total_taxable">0.00</div>
                </div>
                <div class="col-md-4">
                    <div class="lbl">Total tax</div>
                    <div class="val" id="inv_total_tax">0.00</div>
                </div>
                <div class="col-md-4">
                    <div class="lbl">Total payment</div>
                    <div class="val text-success" id="inv_total_payment">0.00</div>
                </div>
            </div>
            <p class="small text-muted mb-0 mt-2">Totals update as you tick lines, change quantities, or switch GST / Non-GST.</p>
        </div>
    </div>

    <asp:HiddenField ID="hd_invoice_id" runat="server" />

    <div class="d-flex flex-wrap gap-2 align-items-center">
        <asp:Button ID="btn_save" runat="server" CssClass="btn btn-primary px-4" Text="Save invoice" OnClick="btn_save_Click" />
        <a href="Invoice_List.aspx" class="btn btn-outline-secondary">Cancel</a>
    </div>

    <script type="text/javascript">
        (function () {
            function invParseNum(v) {
                if (v == null || v === '') return 0;
                var n = parseFloat(String(v).replace(/,/g, '.').replace(/\s/g, ''));
                return isNaN(n) ? 0 : n;
            }
            function invFmtMoney(n) {
                return (Math.round(n * 100) / 100).toFixed(2);
            }
            function invIsNonGst() {
                var el = document.getElementById('ddl_invoice_kind');
                return el && String(el.value || '').toUpperCase() === 'NON_GST';
            }
            function invRowCb(tr) {
                var s = tr.querySelector('span.inv-line-cb input[type="checkbox"]');
                if (s) return s;
                return tr.querySelector('input[type="checkbox"].inv-line-cb') || tr.querySelector('input.inv-line-cb') || tr.querySelector('input[type="checkbox"]');
            }
            function invSyncSelectAll() {
                var all = document.getElementById('inv_cb_all');
                if (!all) return;
                var table = document.getElementById('gv_lines');
                if (!table) return;
                var rows = table.querySelectorAll('tbody tr.inv-line-row');
                if (!rows.length) { all.checked = false; all.indeterminate = false; return; }
                var c = 0, t = 0;
                for (var i = 0; i < rows.length; i++) {
                    var cb = invRowCb(rows[i]);
                    if (cb && cb.checked) c++;
                    t++;
                }
                all.checked = c === t && t > 0;
                all.indeterminate = c > 0 && c < t;
            }
            window.invRecalcTotals = function () {
                var taxableSum = 0, taxSum = 0, paySum = 0;
                var table = document.getElementById('gv_lines');
                var nonGst = invIsNonGst();
                if (table) {
                    var rows = table.querySelectorAll('tbody tr.inv-line-row');
                    for (var i = 0; i < rows.length; i++) {
                        var tr = rows[i];
                        var cb = invRowCb(tr);
                        var qtyEl = tr.querySelector('input.inv-qty-inp');
                        if (!qtyEl) continue;
                        var q = invParseNum(qtyEl.value);
                        if (!cb || !cb.checked || q <= 0) continue;
                        var rate = invParseNum(tr.getAttribute('data-rate'));
                        var taxper = nonGst ? 0 : invParseNum(tr.getAttribute('data-tax'));
                        var lineTaxable = Math.round(q * rate * 100) / 100;
                        var lineTax = Math.round(lineTaxable * taxper / 100 * 100) / 100;
                        var linePay = Math.round((lineTaxable + lineTax) * 100) / 100;
                        taxableSum += lineTaxable;
                        taxSum += lineTax;
                        paySum += linePay;
                    }
                }
                var e1 = document.getElementById('inv_total_taxable');
                var e2 = document.getElementById('inv_total_tax');
                var e3 = document.getElementById('inv_total_payment');
                if (e1) e1.textContent = invFmtMoney(taxableSum);
                if (e2) e2.textContent = invFmtMoney(taxSum);
                if (e3) e3.textContent = invFmtMoney(paySum);
                invSyncSelectAll();
            };
            function invOnLineCbChange(cb) {
                if (!cb) return;
                var tr = cb;
                while (tr && tr.tagName !== 'TR') tr = tr.parentElement;
                if (!tr || !tr.classList.contains('inv-line-row')) return;
                var avail = parseInt(tr.getAttribute('data-qty-avail') || '0', 10) || 0;
                var qtyInp = tr.querySelector('input.inv-qty-inp');
                if (cb.checked) {
                    var cur = qtyInp ? String(qtyInp.value || '').trim() : '';
                    if (!cur || cur === '0') {
                        if (qtyInp && avail > 0) qtyInp.value = String(avail);
                    }
                } else {
                    if (qtyInp) qtyInp.value = '';
                }
                window.invRecalcTotals();
            }
            function invToggleAll(checked) {
                var table = document.getElementById('gv_lines');
                if (!table) return;
                var rows = table.querySelectorAll('tbody tr.inv-line-row');
                for (var i = 0; i < rows.length; i++) {
                    var tr = rows[i];
                    var cb = invRowCb(tr);
                    var qtyInp = tr.querySelector('input.inv-qty-inp');
                    var avail = parseInt(tr.getAttribute('data-qty-avail') || '0', 10) || 0;
                    if (cb) cb.checked = !!checked;
                    if (qtyInp) {
                        if (checked && avail > 0) qtyInp.value = String(avail);
                        else if (!checked) qtyInp.value = '';
                    }
                }
                var all = document.getElementById('inv_cb_all');
                if (all) { all.checked = !!checked; all.indeterminate = false; }
                window.invRecalcTotals();
            }
            function invBindTotals() {
                var table = document.getElementById('gv_lines');
                if (table && !table._invBound) {
                    table._invBound = true;
                    table.addEventListener('change', function (e) {
                        var t = e.target;
                        if (!t || t.type !== 'checkbox') return;
                        var tr = t.closest ? t.closest('tr.inv-line-row') : null;
                        if (!tr) {
                            var p = t.parentElement;
                            while (p && p.tagName !== 'TR') p = p.parentElement;
                            tr = p && p.classList && p.classList.contains('inv-line-row') ? p : null;
                        }
                        if (tr && tr.classList.contains('inv-line-row') && t.id !== 'inv_cb_all')
                            invOnLineCbChange(t);
                    });
                    table.addEventListener('input', function (e) {
                        if (e.target && e.target.classList && e.target.classList.contains('inv-qty-inp'))
                            window.invRecalcTotals();
                    });
                }
                var all = document.getElementById('inv_cb_all');
                if (all && !all._invBound) {
                    all._invBound = true;
                    all.addEventListener('change', function () { invToggleAll(all.checked); });
                }
                var kind = document.getElementById('ddl_invoice_kind');
                if (kind && !kind._invBound) {
                    kind._invBound = true;
                    kind.addEventListener('change', window.invRecalcTotals);
                }
                window.invRecalcTotals();
            }
            if (window.jQuery) { jQuery(invBindTotals); } else { document.addEventListener('DOMContentLoaded', invBindTotals); }
        })();
    </script>
</asp:Content>
