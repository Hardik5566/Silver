<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Inward_Challan_Entry.aspx.cs" Inherits="Inward_Challan_Entry" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Challan entry</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .excel-wrap { background: #fff; border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; }
        .excel-grid { margin: 0; font-size: 13px; }
        .excel-grid thead th { background: #e9ecef; font-weight: 600; border: 1px solid #ced4da; padding: 8px 10px; white-space: nowrap; }
        .excel-grid tbody td { border: 1px solid #dee2e6; padding: 4px 6px; vertical-align: middle; }
        .excel-grid tbody tr:nth-child(even) { background: #f8f9fa; }
        .excel-grid .form-control, .excel-grid .form-select { border-radius: 2px; min-height: 34px; }
        .w-sr { width: 44px; text-align: center; }
        .w-qty { width: 110px; }
        .w-rate { width: 110px; }
        .w-amt { width: 120px; text-align: right; }
        .w-act { width: 72px; text-align: center; }
        .line-amt { font-weight: 600; color: #0d6efd; }
        .inward-tfoot td { background: #e7f1ff; font-weight: 600; border-top: 2px solid #0d6efd; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h1 class="h5 mb-0 fw-semibold text-dark"><asp:Literal ID="lit_page_title" runat="server" Text="New challan" /></h1>
        <a href="Inward_Challan_List.aspx" class="btn btn-sm btn-outline-secondary">← Active challans</a>
    </div>

    <div class="card mb-3 shadow-sm">
        <div class="card-body row g-3">
            <div class="col-lg-4 col-md-6">
                <label class="form-label">Party</label>
                <asp:DropDownList ID="ddl_party" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddl_party_SelectedIndexChanged" AccessKey="p"></asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">Challan no</label>
                <asp:TextBox ID="txt_challan_no" runat="server" CssClass="form-control" ClientIDMode="Static"></asp:TextBox>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">Date</label>
                <asp:TextBox ID="txt_inward_date" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
            </div>
            <div class="col-12">
                <label class="form-label">Remarks</label>
                <asp:TextBox ID="txt_remarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" ClientIDMode="Static"></asp:TextBox>
            </div>
        </div>
    </div>

    <div class="excel-wrap shadow-sm mb-3">
        <div class="table-responsive">
            <table class="table excel-grid mb-0">
                <thead>
                    <tr>
                        <th class="w-sr">#</th>
                        <th>Part</th>
                        <th class="w-qty">Qty</th>
                        <th class="w-rate">Rate</th>
                        <th class="w-amt">Amount</th>
                        <th class="w-act"></th>
                    </tr>
                </thead>
                <tbody id="inward_line_body">
                    <asp:Repeater ID="rep_lines" runat="server" OnItemDataBound="rep_lines_ItemDataBound">
                        <ItemTemplate>
                            <tr class="inward-line-row">
                                <td class="w-sr text-muted line-sr"><%# Container.ItemIndex + 1 %></td>
                                <td>
                                    <asp:DropDownList ID="ddl_line_part" runat="server" CssClass="form-select form-select-sm line-part-ddl"></asp:DropDownList>
                                </td>
                                <td class="w-qty">
                                    <asp:TextBox ID="txt_line_qty" runat="server" CssClass="form-control form-control-sm line-qty-inp" Text='<%# Eval("Qty") %>'></asp:TextBox>
                                </td>
                                <td class="w-rate">
                                    <asp:TextBox ID="txt_line_rate" runat="server" CssClass="form-control form-control-sm line-rate-inp" Text='<%# Eval("Rate") %>'></asp:TextBox>
                                </td>
                                <td class="w-amt line-amt text-end">0.00</td>
                                <td class="w-act">
                                    <button type="button" class="btn btn-sm btn-outline-danger py-0 line-rm-btn">✕</button>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </tbody>
                <tfoot class="inward-tfoot">
                    <tr>
                        <td colspan="4" class="text-end">Total</td>
                        <td class="w-amt text-end line-grand-total">0.00</td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="px-3 py-2 border-top bg-light">
            <button type="button" class="btn btn-sm btn-outline-primary" id="btn_add_row" accesskey="a">+ Add row</button>
        </div>
    </div>

    <asp:HiddenField ID="hd_inward_id" runat="server" />
    <asp:HiddenField ID="hd_lines_json" runat="server" ClientIDMode="Static" Value="" />

    <div class="d-flex flex-wrap gap-2 align-items-center">
        <asp:Button ID="btn_save" runat="server" CssClass="btn btn-primary px-4" Text="Save challan" OnClick="btn_save_Click" OnClientClick="return inwardBeforeSave();" AccessKey="s" />
        <a href="Inward_Challan_List.aspx" class="btn btn-outline-secondary" tabindex="9999">Cancel</a>
    </div>

    <script type="text/javascript">
        function inwardClosestTr(el) {
            while (el && el.tagName !== 'TR') el = el.parentElement;
            return el;
        }
        function inwardOnPartChange(ddl) {
            var tr = inwardClosestTr(ddl);
            if (!tr) return;
            var rateEl = tr.querySelector('input.line-rate-inp');
            if (!rateEl) return;
            var id = ddl.value;
            if (!id || id === '0') { rateEl.value = ''; inwardRecalcLine(tr); return; }
            var map = window.inwardPartRates || {};
            if (map.hasOwnProperty(id)) rateEl.value = map[id];
            else rateEl.value = '';
            inwardRecalcLine(tr);
        }
        function inwardParseNum(v) {
            if (v == null || v === '') return 0;
            var n = parseFloat(String(v).replace(/,/g, ''));
            return isNaN(n) ? 0 : n;
        }
        function inwardFmtMoney(n) {
            return (Math.round(n * 100) / 100).toFixed(2);
        }
        function inwardRecalcLine(tr) {
            if (!tr) return;
            var iq = tr.querySelector('input.line-qty-inp');
            var ir = tr.querySelector('input.line-rate-inp');
            var q = inwardParseNum(iq ? iq.value : '');
            var r = inwardParseNum(ir ? ir.value : '');
            var amt = q * r;
            var cell = tr.querySelector('td.line-amt');
            if (cell) cell.textContent = inwardFmtMoney(amt);
            inwardRecalcGrand();
        }
        function inwardRecalcGrand() {
            var sum = 0;
            document.querySelectorAll('#inward_line_body tr.inward-line-row td.line-amt').forEach(function (td) {
                sum += inwardParseNum(td.textContent);
            });
            var g = document.querySelector('.line-grand-total');
            if (g) g.textContent = inwardFmtMoney(sum);
        }
        function inwardRenumberRows() {
            var body = document.getElementById('inward_line_body');
            if (!body) return;
            var rows = body.querySelectorAll('tr.inward-line-row');
            for (var i = 0; i < rows.length; i++) {
                var sr = rows[i].querySelector('td.line-sr');
                if (sr) sr.textContent = String(i + 1);
                var tBase = 10 + i * 3;
                var ddl = rows[i].querySelector('select.line-part-ddl');
                var q = rows[i].querySelector('input.line-qty-inp');
                var rt = rows[i].querySelector('input.line-rate-inp');
                if (ddl) ddl.tabIndex = tBase;
                if (q) q.tabIndex = tBase + 1;
                if (rt) rt.tabIndex = tBase + 2;
            }
            var n = rows.length;
            var lastFieldTab = n > 0 ? 10 + (n - 1) * 3 + 2 : 4;
            var addBtn = document.getElementById('btn_add_row');
            var saveBtn = document.getElementById('<%= btn_save.ClientID %>');
            if (addBtn) addBtn.tabIndex = lastFieldTab + 1;
            if (saveBtn) saveBtn.tabIndex = lastFieldTab + 2;
            body.querySelectorAll('button.line-rm-btn').forEach(function (b) { b.tabIndex = -1; });
        }
        function inwardCloneLineRow() {
            var body = document.getElementById('inward_line_body');
            if (!body) return;
            var rows = body.querySelectorAll('tr.inward-line-row');
            var src = rows.length ? rows[rows.length - 1] : null;
            if (!src) return;
            var tr = src.cloneNode(true);
            tr.querySelectorAll('[id]').forEach(function (el) { el.removeAttribute('id'); });
            tr.querySelectorAll('input, select').forEach(function (el) {
                if (el.name) el.removeAttribute('name');
            });
            var ddl = tr.querySelector('select.line-part-ddl');
            if (ddl) ddl.selectedIndex = 0;
            var q = tr.querySelector('input.line-qty-inp');
            var r = tr.querySelector('input.line-rate-inp');
            if (q) q.value = '';
            if (r) r.value = '';
            var amt = tr.querySelector('td.line-amt');
            if (amt) amt.textContent = '0.00';
            body.appendChild(tr);
            inwardRenumberRows();
            inwardRecalcGrand();
        }
        function inwardRemoveLine(btn) {
            var tr = inwardClosestTr(btn);
            if (!tr || !tr.classList.contains('inward-line-row')) return;
            var body = document.getElementById('inward_line_body');
            var cnt = body ? body.querySelectorAll('tr.inward-line-row').length : 0;
            if (cnt <= 1) { alert('At least one line is required.'); return; }
            if (!confirm('Remove this row?')) return;
            tr.parentNode.removeChild(tr);
            inwardRenumberRows();
            inwardRecalcGrand();
        }
        function inwardBindLineTable() {
            if (window.__inwardLineUiBound) return;
            window.__inwardLineUiBound = true;
            var body = document.getElementById('inward_line_body');
            if (!body) return;
            body.addEventListener('input', function (e) {
                var t = e.target;
                if (!t || !t.classList) return;
                if (t.classList.contains('line-qty-inp') || t.classList.contains('line-rate-inp')) {
                    var tr = inwardClosestTr(t);
                    inwardRecalcLine(tr);
                }
            });
            body.addEventListener('change', function (e) {
                var t = e.target;
                if (t && t.classList && t.classList.contains('line-part-ddl')) inwardOnPartChange(t);
            });
            body.addEventListener('click', function (e) {
                var el = e.target;
                while (el && el !== body) {
                    if (el.tagName === 'BUTTON' && el.classList && el.classList.contains('line-rm-btn')) {
                        inwardRemoveLine(el);
                        return;
                    }
                    el = el.parentElement;
                }
            });
            var addBtn = document.getElementById('btn_add_row');
            if (addBtn) addBtn.addEventListener('click', inwardCloneLineRow);
            body.querySelectorAll('tr.inward-line-row').forEach(function (tr) { inwardRecalcLine(tr); });
            inwardRenumberRows();
        }
        function inwardGatherLinesToHidden() {
            var rows = [];
            document.querySelectorAll('#inward_line_body tr.inward-line-row').forEach(function (tr) {
                var ddl = tr.querySelector('select.line-part-ddl');
                var q = tr.querySelector('input.line-qty-inp');
                var r = tr.querySelector('input.line-rate-inp');
                rows.push({
                    partId: ddl ? ddl.value : '0',
                    qty: q ? q.value.trim() : '',
                    rate: r ? r.value.trim() : '0'
                });
            });
            var el = document.getElementById('hd_lines_json');
            if (el) el.value = JSON.stringify(rows);
            return true;
        }
        function inwardBeforeSave() {
            inwardGatherLinesToHidden();
            return true;
        }
        if (window.jQuery) { jQuery(inwardBindLineTable); } else { document.addEventListener('DOMContentLoaded', inwardBindLineTable); }
    </script>
</asp:Content>
