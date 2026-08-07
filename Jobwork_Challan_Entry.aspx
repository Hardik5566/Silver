<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Jobwork_Challan_Entry.aspx.cs" Inherits="Jobwork_Challan_Entry" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Jobwork challan entry</asp:Content>
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
        .jobwork-tfoot td { background: #e7f1ff; font-weight: 600; border-top: 2px solid #0d6efd; }
        .line-part-wrap { display: flex; gap: 4px; align-items: center; }
        .line-part-wrap .line-part-ddl { flex: 1 1 auto; min-width: 0; }
        .line-new-part-btn { flex: 0 0 auto; padding: 2px 7px; line-height: 1.2; }
        .quick-part-modal .modal-content { border: none; border-radius: 12px; overflow: hidden; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <h1 class="h5 mb-0 fw-semibold text-dark"><asp:Literal ID="lit_page_title" runat="server" Text="New jobwork challan" /></h1>
        <div class="d-flex flex-wrap gap-2">
            <asp:HyperLink ID="lnk_print" runat="server" CssClass="btn btn-sm btn-outline-dark" Target="_blank" Visible="false"><i class="bi bi-printer me-1"></i>Print</asp:HyperLink>
            <a href="Jobwork_Challan_List.aspx" class="btn btn-sm btn-outline-secondary">← Active jobwork challans</a>
        </div>
    </div>

    <div class="card mb-3 shadow-sm">
        <div class="card-body row g-3">
            <div class="col-lg-4 col-md-6">
                <label class="form-label">Jobwork party</label>
                <asp:DropDownList ID="ddl_jobwork_party" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddl_jobwork_party_SelectedIndexChanged" AccessKey="p"></asp:DropDownList>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">Challan no</label>
                <asp:TextBox ID="txt_challan_no" runat="server" CssClass="form-control" ClientIDMode="Static" ReadOnly="true" placeholder="Auto on save"></asp:TextBox>
            </div>
            <div class="col-lg-2 col-md-3">
                <label class="form-label">Date</label>
                <asp:TextBox ID="txt_challan_date" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static"></asp:TextBox>
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
                <tbody id="jobwork_line_body">
                    <asp:Repeater ID="rep_lines" runat="server" OnItemDataBound="rep_lines_ItemDataBound">
                        <ItemTemplate>
                            <tr class="jobwork-line-row">
                                <td class="w-sr text-muted line-sr"><%# Container.ItemIndex + 1 %></td>
                                <td>
                                    <div class="line-part-wrap">
                                        <asp:DropDownList ID="ddl_line_part" runat="server" CssClass="form-select form-select-sm line-part-ddl"></asp:DropDownList>
                                        <button type="button" class="btn btn-sm btn-outline-secondary line-new-part-btn" title="Add new item" aria-label="Add new item">+</button>
                                    </div>
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
                <tfoot class="jobwork-tfoot">
                    <tr>
                        <td colspan="4" class="text-end">Total</td>
                        <td class="w-amt text-end line-grand-total">0.00</td>
                        <td></td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="px-3 py-2 border-top bg-light d-flex flex-wrap gap-2">
            <button type="button" class="btn btn-sm btn-outline-primary" id="btn_add_row" accesskey="a">+ Add row</button>
            <button type="button" class="btn btn-sm btn-outline-success" id="btn_quick_part" title="Add new item to this jobwork party">+ New item</button>
        </div>
    </div>

    <asp:HiddenField ID="hd_jobwork_challan_id" runat="server" />
    <asp:HiddenField ID="hd_lines_json" runat="server" ClientIDMode="Static" Value="" />
    <asp:HiddenField ID="hd_quick_target_row" runat="server" ClientIDMode="Static" Value="0" />

    <div class="modal fade quick-part-modal" id="modal_quick_part" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow">
                <div class="modal-header bg-success text-white">
                    <h2 class="modal-title fs-5 mb-0">New item</h2>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p class="small text-muted mb-3">Jobwork party: <strong id="sp_quick_party_name"></strong></p>
                    <div class="mb-3">
                        <label class="form-label">Part name <span class="text-danger">*</span></label>
                        <asp:TextBox ID="txt_quick_part_name" runat="server" CssClass="form-control" placeholder="Item name"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Unit <span class="text-danger">*</span></label>
                        <asp:DropDownList ID="ddl_quick_unit" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label">Rate (₹)</label>
                            <asp:TextBox ID="txt_quick_rate" runat="server" CssClass="form-control" placeholder="0"></asp:TextBox>
                        </div>
                        <div class="col-6">
                            <label class="form-label">Tax (%)</label>
                            <asp:TextBox ID="txt_quick_tax" runat="server" CssClass="form-control" Text="0"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btn_quick_part_save" runat="server" CssClass="btn btn-success" Text="Save &amp; use item"
                        OnClick="btn_quick_part_save_Click" OnClientClick="return jobworkBeforeQuickPartSave();" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex flex-wrap gap-2 align-items-center">
        <asp:Button ID="btn_save" runat="server" CssClass="btn btn-primary px-4" Text="Save challan" OnClick="btn_save_Click" OnClientClick="return jobworkBeforeSave();" AccessKey="s" />
        <a href="Jobwork_Challan_List.aspx" class="btn btn-outline-secondary" tabindex="9999">Cancel</a>
    </div>

    <script type="text/javascript">
        function jobworkClosestTr(el) {
            while (el && el.tagName !== 'TR') el = el.parentElement;
            return el;
        }
        function jobworkOnPartChange(ddl) {
            var tr = jobworkClosestTr(ddl);
            if (!tr) return;
            var rateEl = tr.querySelector('input.line-rate-inp');
            if (!rateEl) return;
            var id = ddl.value;
            if (!id || id === '0') { rateEl.value = ''; jobworkRecalcLine(tr); return; }
            var map = window.jobworkPartRates || {};
            if (map.hasOwnProperty(id)) rateEl.value = map[id];
            else rateEl.value = '';
            jobworkRecalcLine(tr);
        }
        function jobworkParseNum(v) {
            if (v == null || v === '') return 0;
            var n = parseFloat(String(v).replace(/,/g, ''));
            return isNaN(n) ? 0 : n;
        }
        function jobworkFmtMoney(n) {
            return (Math.round(n * 100) / 100).toFixed(2);
        }
        function jobworkRecalcLine(tr) {
            if (!tr) return;
            var iq = tr.querySelector('input.line-qty-inp');
            var ir = tr.querySelector('input.line-rate-inp');
            var q = jobworkParseNum(iq ? iq.value : '');
            var r = jobworkParseNum(ir ? ir.value : '');
            var amt = q * r;
            var cell = tr.querySelector('td.line-amt');
            if (cell) cell.textContent = jobworkFmtMoney(amt);
            jobworkRecalcGrand();
        }
        function jobworkRecalcGrand() {
            var sum = 0;
            document.querySelectorAll('#jobwork_line_body tr.jobwork-line-row td.line-amt').forEach(function (td) {
                sum += jobworkParseNum(td.textContent);
            });
            var g = document.querySelector('.line-grand-total');
            if (g) g.textContent = jobworkFmtMoney(sum);
        }
        function jobworkRenumberRows() {
            var body = document.getElementById('jobwork_line_body');
            if (!body) return;
            var rows = body.querySelectorAll('tr.jobwork-line-row');
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
            var lastFieldTab = n > 0 ? 10 + (n - 1) * 3 + 2 : 5;
            var addBtn = document.getElementById('btn_add_row');
            var saveBtn = document.getElementById('<%= btn_save.ClientID %>');
            if (addBtn) addBtn.tabIndex = lastFieldTab + 1;
            if (saveBtn) saveBtn.tabIndex = lastFieldTab + 2;
            body.querySelectorAll('button.line-rm-btn').forEach(function (b) { b.tabIndex = -1; });
        }
        function jobworkCloneLineRow() {
            var body = document.getElementById('jobwork_line_body');
            if (!body) return;
            var rows = body.querySelectorAll('tr.jobwork-line-row');
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
            jobworkRenumberRows();
            jobworkRecalcGrand();
        }
        function jobworkRemoveLine(btn) {
            var tr = jobworkClosestTr(btn);
            if (!tr || !tr.classList.contains('jobwork-line-row')) return;
            var body = document.getElementById('jobwork_line_body');
            var cnt = body ? body.querySelectorAll('tr.jobwork-line-row').length : 0;
            if (cnt <= 1) { alert('At least one line is required.'); return; }
            if (!confirm('Remove this row?')) return;
            tr.parentNode.removeChild(tr);
            jobworkRenumberRows();
            jobworkRecalcGrand();
        }
        function jobworkBindLineTable() {
            if (window.__jobworkLineUiBound) return;
            window.__jobworkLineUiBound = true;
            var body = document.getElementById('jobwork_line_body');
            if (!body) return;
            body.addEventListener('input', function (e) {
                var t = e.target;
                if (!t || !t.classList) return;
                if (t.classList.contains('line-qty-inp') || t.classList.contains('line-rate-inp')) {
                    var tr = jobworkClosestTr(t);
                    jobworkRecalcLine(tr);
                }
            });
            body.addEventListener('change', function (e) {
                var t = e.target;
                if (t && t.classList && t.classList.contains('line-part-ddl')) jobworkOnPartChange(t);
            });
            body.addEventListener('click', function (e) {
                var el = e.target;
                while (el && el !== body) {
                    if (el.tagName === 'BUTTON' && el.classList && el.classList.contains('line-rm-btn')) {
                        jobworkRemoveLine(el);
                        return;
                    }
                    if (el.tagName === 'BUTTON' && el.classList && el.classList.contains('line-new-part-btn')) {
                        jobworkOpenQuickPartModal(el);
                        return;
                    }
                    el = el.parentElement;
                }
            });
            var addBtn = document.getElementById('btn_add_row');
            if (addBtn) addBtn.addEventListener('click', jobworkCloneLineRow);
            var quickBtn = document.getElementById('btn_quick_part');
            if (quickBtn) quickBtn.addEventListener('click', function () { jobworkOpenQuickPartModal(null); });
            body.querySelectorAll('tr.jobwork-line-row').forEach(function (tr) { jobworkRecalcLine(tr); });
            jobworkRenumberRows();
        }
        function jobworkGatherLinesToHidden() {
            var rows = [];
            document.querySelectorAll('#jobwork_line_body tr.jobwork-line-row').forEach(function (tr) {
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
        function jobworkBeforeSave() {
            jobworkGatherLinesToHidden();
            return true;
        }
        function jobworkGetPartyDdl() {
            return document.getElementById('<%= ddl_jobwork_party.ClientID %>');
        }
        function jobworkLineRowIndex(tr) {
            var body = document.getElementById('jobwork_line_body');
            if (!body || !tr) return 0;
            var rows = body.querySelectorAll('tr.jobwork-line-row');
            for (var i = 0; i < rows.length; i++) if (rows[i] === tr) return i;
            return 0;
        }
        function jobworkOpenQuickPartModal(fromBtn) {
            var partyDdl = jobworkGetPartyDdl();
            if (!partyDdl || partyDdl.value === '0') {
                alert('Select jobwork party first.');
                if (partyDdl) partyDdl.focus();
                return;
            }
            var tr = fromBtn ? jobworkClosestTr(fromBtn) : null;
            var body = document.getElementById('jobwork_line_body');
            if (!tr && body) {
                var rows = body.querySelectorAll('tr.jobwork-line-row');
                tr = rows.length ? rows[rows.length - 1] : null;
            }
            var idx = jobworkLineRowIndex(tr);
            var hd = document.getElementById('hd_quick_target_row');
            if (hd) hd.value = String(idx);
            var sp = document.getElementById('sp_quick_party_name');
            if (sp) sp.textContent = partyDdl.options[partyDdl.selectedIndex].text;
            var el = document.getElementById('modal_quick_part');
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
            var nm = document.getElementById('<%= txt_quick_part_name.ClientID %>');
            if (nm) { nm.value = ''; nm.focus(); }
        }
        function jobworkBeforeQuickPartSave() {
            jobworkGatherLinesToHidden();
            var partyDdl = jobworkGetPartyDdl();
            if (!partyDdl || partyDdl.value === '0') {
                alert('Select jobwork party first.');
                return false;
            }
            var nm = document.getElementById('<%= txt_quick_part_name.ClientID %>');
            if (!nm || !nm.value.trim()) {
                alert('Enter part name.');
                if (nm) nm.focus();
                return false;
            }
            var unit = document.getElementById('<%= ddl_quick_unit.ClientID %>');
            if (!unit || unit.value === '0') {
                alert('Select unit.');
                if (unit) unit.focus();
                return false;
            }
            return true;
        }
        if (window.jQuery) { jQuery(jobworkBindLineTable); } else { document.addEventListener('DOMContentLoaded', jobworkBindLineTable); }
    </script>
</asp:Content>
