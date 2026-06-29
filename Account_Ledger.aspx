<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Account_Ledger.aspx.cs" Inherits="Account_Ledger" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Account ledger</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .aled-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .aled-grid { margin: 0; font-size: 14px; width: 100%; }
        .aled-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .aled-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .aled-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .mono { font-variant-numeric: tabular-nums; }
        .aled-panel-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: #495057;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 12px 14px;
            border-bottom: 1px solid #dee2e6;
            background: #f8f9fa;
        }
        .aled-account-title {
            font-size: 1rem;
            font-weight: 600;
            color: #212529;
            text-transform: none;
            letter-spacing: normal;
        }
        .aled-summary {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            padding: 14px;
            background: #fafbfc;
        }
        .aled-sum-box {
            flex: 1 1 160px;
            min-width: 140px;
            padding: 12px 14px;
            border: 1px solid #e9ecef;
            border-radius: 8px;
            background: #fff;
        }
        .aled-sum-box .lbl {
            font-size: 11px;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            font-weight: 600;
        }
        .aled-sum-box .val {
            font-size: 1.15rem;
            font-weight: 700;
            margin-top: 6px;
            font-variant-numeric: tabular-nums;
        }
        .aled-sum-box .hint { font-size: 11px; color: #6c757d; margin-top: 4px; }
        .bal-recv { color: #198754; }
        .bal-pay { color: #dc3545; }
        .bal-dr { color: #198754; }
        .bal-cr { color: #dc3545; }
        .bal-zero { color: #6c757d; }
        .amt-dr { color: #198754; font-weight: 500; }
        .amt-cr { color: #dc3545; font-weight: 500; }
        .amt-empty { color: #adb5bd; }
        .sum-debit .val { color: #212529; }
        .sum-credit .val { color: #495057; }
        .aled-summary-head { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; padding: 12px 14px; border-bottom: 1px solid #dee2e6; background: #f8f9fa; }
        .modal_form_footer { padding: 15px; border-top: 1px solid #dee2e6; display: flex; justify-content: space-between; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark"><i class="bi bi-journal-text me-1"></i>Account ledger</h1>
        </div>

        <div class="card aled-card shadow-sm mb-3 rpt-filter-card">
            <div class="card-body row g-3 align-items-end">
                <div class="col-md-3 col-sm-6">
                    <label class="form-label">Account type</label>
                    <asp:DropDownList ID="ddl_account_type" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddl_account_type_Changed">
                        <asp:ListItem Value="PARTY" Text="Party" Selected="True" />
                        <asp:ListItem Value="JOBWORK" Text="Jobwork" />
                        <asp:ListItem Value="STAFF" Text="Staff" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-4 col-sm-6">
                    <label class="form-label">Account</label>
                    <asp:DropDownList ID="ddl_account" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddl_account_Changed"></asp:DropDownList>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnl_summary" runat="server" Visible="false" CssClass="aled-card shadow-sm mb-3">
            <div class="aled-summary-head">
                <asp:Label ID="lbl_account_title" runat="server" CssClass="aled-account-title mb-0" />
                <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#modal_payment" onclick="resetPaymentModal();">
                    + <asp:Label ID="lbl_add_payment_btn" runat="server" Text="Add payment" />
                </button>
            </div>
            <div class="aled-summary">
                <div class="aled-sum-box sum-debit">
                    <div class="lbl">Total debit</div>
                    <div class="val mono"><asp:Label ID="lbl_total_debit" runat="server" /></div>
                </div>
                <div class="aled-sum-box sum-credit">
                    <div class="lbl">Total credit</div>
                    <div class="val mono"><asp:Label ID="lbl_total_credit" runat="server" /></div>
                </div>
                <div class="aled-sum-box">
                    <div class="lbl">Balance</div>
                    <div class="val mono"><asp:Label ID="lbl_balance" runat="server" /></div>
                    <div class="hint"><asp:Label ID="lbl_balance_hint" runat="server" /></div>
                </div>
            </div>
        </asp:Panel>

        <div class="aled-card shadow-sm">
            <div class="aled-panel-title">Ledger entries</div>
            <div class="table-responsive">
                <asp:GridView ID="grid_ledger" runat="server" CssClass="table aled-grid mb-0" AutoGenerateColumns="false"
                    GridLines="None" ShowHeaderWhenEmpty="true" ShowFooter="true">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No entries for this account.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:BoundField DataField="sr" HeaderText="Sr" ItemStyle-Width="52px" ItemStyle-CssClass="text-muted text-center mono" HeaderStyle-CssClass="text-center" />
                        <asp:BoundField DataField="txn_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="txn_type_label" HeaderText="Type" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="ref_no" HeaderText="Ref no" ItemStyle-CssClass="text-muted" NullDisplayText="—" />
                        <asp:BoundField DataField="note" HeaderText="Note" ItemStyle-CssClass="text-break" NullDisplayText="—" />
                        <asp:TemplateField HeaderText="Debit" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">
                            <ItemTemplate><span class='<%# GetDebitCss(Eval("debit_amt")) %>'><%# FormatDebitCredit(Eval("debit_amt")) %></span></ItemTemplate>
                            <FooterTemplate>
                                <span class="fw-semibold">₹<asp:Label ID="lbl_foot_debit" runat="server" /></span>
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Credit" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">
                            <ItemTemplate><span class='<%# GetCreditCss(Eval("credit_amt")) %>'><%# FormatDebitCredit(Eval("credit_amt")) %></span></ItemTemplate>
                            <FooterTemplate>
                                <span class="fw-semibold">₹<asp:Label ID="lbl_foot_credit" runat="server" /></span>
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Balance" ItemStyle-CssClass="mono text-end fw-semibold" HeaderStyle-CssClass="text-end">
                            <ItemTemplate>
                                <span class='<%# GetLineBalanceCss(Eval("debit_amt"), Eval("credit_amt"), Eval("running_balance")) %>'>₹<%# FormatBalance(Eval("running_balance")) %></span>
                            </ItemTemplate>
                            <FooterTemplate>
                                <span class="fw-semibold"><asp:Label ID="lbl_foot_balance" runat="server" CssClass="" /></span>
                            </FooterTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade right" id="modal_payment" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title mb-0"><asp:Label ID="lbl_payment_modal_title" runat="server" Text="Add payment" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Payment date</label>
                            <asp:TextBox ID="txt_pay_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Ref no <span class="text-muted fw-normal">(optional)</span></label>
                            <asp:TextBox ID="txt_pay_ref" runat="server" CssClass="form-control" MaxLength="50" placeholder="REC-201"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Amount (₹)</label>
                            <asp:TextBox ID="txt_pay_amount" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label d-block">Payment mode</label>
                            <div class="d-flex flex-wrap gap-4 mt-1">
                                <div class="form-check m-0 d-flex align-items-center">
                                    <asp:RadioButton ID="rb_pay_cash" runat="server" GroupName="led_pay_mode" CssClass="form-check-input" />
                                    <asp:Label runat="server" AssociatedControlID="rb_pay_cash" CssClass="form-check-label ms-1 mb-0">Cash</asp:Label>
                                </div>
                                <div class="form-check m-0 d-flex align-items-center">
                                    <asp:RadioButton ID="rb_pay_online" runat="server" GroupName="led_pay_mode" CssClass="form-check-input" />
                                    <asp:Label runat="server" AssociatedControlID="rb_pay_online" CssClass="form-check-label ms-1 mb-0">Online</asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Note</label>
                            <asp:TextBox ID="txt_pay_note" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal_form_footer">
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" style="width: 49%">Cancel</button>
                    <asp:Button ID="btn_save_payment" runat="server" CssClass="btn btn-primary" Style="width: 49%" Text="Save" OnClick="btn_save_payment_Click" />
                </div>
            </div>
        </div>
    </div>
    <script type="text/javascript">
        function resetPaymentModal() {
            var d = new Date();
            var y = d.getFullYear(), m = ('0' + (d.getMonth() + 1)).slice(-2), day = ('0' + d.getDate()).slice(-2);
            var dt = document.getElementById('<%= txt_pay_date.ClientID %>');
            if (dt) dt.value = y + '-' + m + '-' + day;
            var ref = document.getElementById('<%= txt_pay_ref.ClientID %>');
            if (ref) ref.value = '';
            var amt = document.getElementById('<%= txt_pay_amount.ClientID %>');
            if (amt) amt.value = '';
            var nt = document.getElementById('<%= txt_pay_note.ClientID %>');
            if (nt) nt.value = '';
            var rc = document.getElementById('<%= rb_pay_cash.ClientID %>');
            var ro = document.getElementById('<%= rb_pay_online.ClientID %>');
            if (rc) rc.checked = false;
            if (ro) ro.checked = false;
        }
    </script>
</asp:Content>
