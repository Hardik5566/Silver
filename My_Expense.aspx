<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="My_Expense.aspx.cs" Inherits="My_Expense" %>



<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">My expense</asp:Content>

<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">

    <style>

        .mexp-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }

        .mexp-grid { margin: 0; font-size: 14px; width: 100%; }

        .mexp-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }

        .mexp-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }

        .mexp-grid > tbody > tr:hover > td { background: #fcfcfd; }

        .mexp-grid > tbody > tr.mexp-opening > td { background: #f8f9fa; font-style: italic; color: #495057; }

        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }

        .mono { font-variant-numeric: tabular-nums; }

        .mexp-panel-title {

            font-size: 0.8rem;

            font-weight: 600;

            color: #495057;

            text-transform: uppercase;

            letter-spacing: 0.04em;

            padding: 12px 14px;

            border-bottom: 1px solid #dee2e6;

            background: #f8f9fa;

        }

        .mexp-summary {

            display: flex;

            flex-wrap: wrap;

            gap: 12px;

            padding: 14px;

            background: #fafbfc;

        }

        .mexp-sum-box {

            flex: 1 1 150px;

            min-width: 130px;

            padding: 12px 14px;

            border: 1px solid #e9ecef;

            border-radius: 8px;

            background: #fff;

        }

        .mexp-sum-box .lbl {

            font-size: 11px;

            color: #6c757d;

            text-transform: uppercase;

            letter-spacing: 0.03em;

            font-weight: 600;

        }

        .mexp-sum-box .val {

            font-size: 1.1rem;

            font-weight: 700;

            margin-top: 6px;

            font-variant-numeric: tabular-nums;

        }

        .mexp-sum-box .hint { font-size: 11px; color: #6c757d; margin-top: 4px; }

        .bal-recv { color: #198754; }
        .bal-pay { color: #dc3545; }

        .modal_form_footer { padding: 15px; border-top: 1px solid #dee2e6; display: flex; justify-content: space-between; }

    </style>

</asp:Content>

<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">

    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>

    <div class="messagealert" id="alert_container"></div>



    <div class="w-100">

        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">

            <div>

                <h1 class="h5 mb-0 fw-semibold text-dark"><i class="bi bi-wallet2 me-1"></i>My expense</h1>

                <div class="text-muted small mt-1">Logged in as: <asp:Label ID="lbl_user_name" runat="server" /></div>

            </div>

            <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#modal_mexp" onclick="resetMexpModalAdd();">+ Add expense</button>

            <asp:HiddenField ID="hd_staff_expense_id" runat="server" />

            <asp:HiddenField ID="hd_action" runat="server" Value="save" />

        </div>



        <div class="card mexp-card shadow-sm mb-3 rpt-filter-card">

            <div class="card-body row g-3 align-items-end">

                <div class="col-md-2 col-sm-6">

                    <label class="form-label">From date</label>

                    <asp:TextBox ID="txt_from" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>

                </div>

                <div class="col-md-2 col-sm-6">

                    <label class="form-label">To date</label>

                    <asp:TextBox ID="txt_to" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>

                </div>

                <div class="col-md-3 col-sm-6 d-flex align-items-end">

                    <asp:Button ID="btn_filter" runat="server" CssClass="btn btn-primary w-100" Text="Show statement" OnClick="btn_filter_Click" />

                </div>

            </div>

        </div>



        <asp:Panel ID="pnl_summary" runat="server" Visible="false" CssClass="mexp-card shadow-sm mb-3">

            <div class="mexp-summary">

                <div class="mexp-sum-box">

                    <div class="lbl">Opening balance</div>

                    <div class="val mono"><asp:Label ID="lbl_opening" runat="server" /></div>

                    <div class="hint">Before from date</div>

                </div>

                <div class="mexp-sum-box">

                    <div class="lbl">Total expense</div>

                    <div class="val mono"><asp:Label ID="lbl_total_expense" runat="server" /></div>

                    <div class="hint">In this period</div>

                </div>

                <div class="mexp-sum-box">

                    <div class="lbl">Payment received</div>

                    <div class="val mono"><asp:Label ID="lbl_total_payment" runat="server" /></div>

                    <div class="hint">In this period</div>

                </div>

                <div class="mexp-sum-box">

                    <div class="lbl">Balance</div>

                    <div class="val mono"><asp:Label ID="lbl_balance" runat="server" /></div>

                    <div class="hint"><asp:Label ID="lbl_balance_hint" runat="server" /></div>

                </div>

            </div>

        </asp:Panel>



        <div class="mexp-card shadow-sm">

            <div class="mexp-panel-title">Expense &amp; payment statement</div>

            <div class="table-responsive">

                <asp:GridView ID="grid_mexp" runat="server" CssClass="table mexp-grid mb-0" AutoGenerateColumns="false"

                    GridLines="None" ShowHeaderWhenEmpty="true" OnRowCommand="grid_mexp_RowCommand"

                    OnRowDataBound="grid_mexp_RowDataBound" ShowFooter="true">

                    <EmptyDataTemplate>

                        <div class="p-4 text-center text-muted">No entries in this date range.</div>

                    </EmptyDataTemplate>

                    <Columns>

                        <asp:TemplateField HeaderText="Sr" ItemStyle-Width="52px" ItemStyle-CssClass="text-muted text-center mono" HeaderStyle-CssClass="text-center">

                            <ItemTemplate>

                                <%# IsOpeningRow(Eval("is_opening")) ? "—" : Eval("sr") %>

                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Date" ItemStyle-CssClass="text-nowrap">

                            <ItemTemplate>

                                <%# FormatDate(Eval("is_opening"), Eval("txn_date")) %>

                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:BoundField DataField="txn_type_label" HeaderText="Type" ItemStyle-CssClass="text-nowrap" />

                        <asp:BoundField DataField="ref_no" HeaderText="Ref no" ItemStyle-CssClass="text-muted" NullDisplayText="—" />

                        <asp:TemplateField HeaderText="Note" ItemStyle-CssClass="text-break">

                            <ItemTemplate>

                                <%# FormatNote(Eval("is_opening"), Eval("note"), Eval("payment_mode")) %>

                            </ItemTemplate>

                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Expense" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">

                            <ItemTemplate>

                                <%# FormatDebitCredit(Eval("is_opening"), Eval("credit_amt")) %>

                            </ItemTemplate>

                            <FooterTemplate>

                                <span class="fw-semibold">₹<asp:Label ID="lbl_foot_expense" runat="server" /></span>

                            </FooterTemplate>

                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Payment" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">

                            <ItemTemplate>

                                <%# FormatDebitCredit(Eval("is_opening"), Eval("debit_amt")) %>

                            </ItemTemplate>

                            <FooterTemplate>

                                <span class="fw-semibold">₹<asp:Label ID="lbl_foot_payment" runat="server" /></span>

                            </FooterTemplate>

                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Balance" ItemStyle-CssClass="mono text-end fw-semibold" HeaderStyle-CssClass="text-end">

                            <ItemTemplate>

                                <span class='<%# GetBalanceCss(Eval("running_balance")) %>'>₹<%# FormatBalance(Eval("running_balance")) %></span>

                            </ItemTemplate>

                            <FooterTemplate>

                                <span class="fw-semibold"><asp:Label ID="lbl_foot_balance" runat="server" /></span>

                            </FooterTemplate>

                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end text-nowrap" ItemStyle-Width="90px">

                            <ItemTemplate>

                                <asp:Panel runat="server" Visible='<%# CanEditRow(Eval("can_edit")) %>'>

                                    <asp:LinkButton runat="server" CommandName="edt" CommandArgument='<%# Eval("staff_expense_id") %>' CssClass="text-secondary me-2" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>

                                    <asp:LinkButton runat="server" CommandName="dlt" CommandArgument='<%# Eval("staff_expense_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"

                                        OnClientClick="return confirm('Delete this expense?');"><i class="bi bi-trash"></i></asp:LinkButton>

                                </asp:Panel>

                            </ItemTemplate>

                            <FooterTemplate>

                                <span class="text-muted small">Closing</span>

                            </FooterTemplate>

                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

            </div>

        </div>

    </div>



    <div class="modal fade right" id="modal_mexp" tabindex="-1" aria-hidden="true">

        <div class="modal-dialog">

            <div class="modal-content">

                <div class="modal-header">

                    <h5 class="modal-title mb-0"><asp:Label ID="lbl_modal_title" runat="server" Text="Add expense" /></h5>

                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>

                </div>

                <div class="modal-body">

                    <div class="row g-3">

                        <div class="col-12">

                            <label class="form-label">Expense date</label>

                            <asp:TextBox ID="txt_expense_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>

                        </div>

                        <div class="col-12">

                            <label class="form-label">Ref no <span class="text-muted fw-normal">(optional)</span></label>

                            <asp:TextBox ID="txt_ref_no" runat="server" CssClass="form-control" MaxLength="50" placeholder="EXP-801"></asp:TextBox>

                        </div>

                        <div class="col-12">

                            <label class="form-label">Note</label>

                            <asp:TextBox ID="txt_note" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="What did you buy?"></asp:TextBox>

                        </div>

                        <div class="col-12">

                            <label class="form-label">Amount (₹)</label>

                            <asp:TextBox ID="txt_amount" runat="server" CssClass="form-control"></asp:TextBox>

                        </div>

                    </div>

                </div>

                <div class="modal_form_footer">

                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" style="width: 49%">Cancel</button>

                    <asp:Button ID="btn_save" runat="server" CssClass="btn btn-primary" Style="width: 49%" Text="Save" OnClick="btn_save_Click" />

                </div>

            </div>

        </div>

    </div>

    <script type="text/javascript">

        function resetMexpModalAdd() {

            var hId = document.getElementById('<%= hd_staff_expense_id.ClientID %>');

            var hAct = document.getElementById('<%= hd_action.ClientID %>');

            var lbl = document.getElementById('<%= lbl_modal_title.ClientID %>');

            var btn = document.getElementById('<%= btn_save.ClientID %>');

            if (hId) hId.value = '';

            if (hAct) hAct.value = 'save';

            if (lbl) lbl.innerText = 'Add expense';

            if (btn) btn.value = 'Save';

            var d = new Date();

            var y = d.getFullYear(), m = ('0' + (d.getMonth() + 1)).slice(-2), day = ('0' + d.getDate()).slice(-2);

            var dt = document.getElementById('<%= txt_expense_date.ClientID %>');

            if (dt) dt.value = y + '-' + m + '-' + day;

            var ref = document.getElementById('<%= txt_ref_no.ClientID %>');

            if (ref) ref.value = '';

            var nt = document.getElementById('<%= txt_note.ClientID %>');

            if (nt) nt.value = '';

            var amt = document.getElementById('<%= txt_amount.ClientID %>');

            if (amt) amt.value = '';

        }

    </script>

</asp:Content>

