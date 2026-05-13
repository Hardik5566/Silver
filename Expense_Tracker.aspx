<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Expense_Tracker.aspx.cs" Inherits="Expense_Tracker" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Expense</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .exp-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .exp-grid { margin: 0; font-size: 14px; width: 100%; }
        .exp-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .exp-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .exp-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .mono { font-variant-numeric: tabular-nums; }
        .modal_form_footer { padding: 15px; border-top: 1px solid #dee2e6; display: flex; justify-content: space-between; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark"><i class="bi bi-wallet me-1"></i>Expense</h1>
            <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#modal_expense" onclick="resetExpenseModalAdd();">+ Add expense</button>
            <asp:HiddenField ID="hd_expense_id" runat="server" />
            <asp:HiddenField ID="hd_action" runat="server" Value="save" />
        </div>

        <div class="card exp-card shadow-sm mb-3 rpt-filter-card">
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
                    <asp:Button ID="btn_filter" runat="server" CssClass="btn btn-primary w-100" Text="Show list" OnClick="btn_filter_Click" />
                </div>
            </div>
        </div>

        <div class="exp-card shadow-sm">
            <div class="table-responsive">
                <asp:GridView ID="grid_exp" runat="server" CssClass="table exp-grid mb-0" AutoGenerateColumns="false"
                    GridLines="None" ShowHeaderWhenEmpty="true" DataKeyNames="expense_id" OnRowCommand="grid_exp_RowCommand">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No expenses in this date range.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:BoundField DataField="sr" HeaderText="Sr" ItemStyle-Width="52px" ItemStyle-CssClass="text-muted text-center mono" HeaderStyle-CssClass="text-center" />
                        <asp:BoundField DataField="user_name" HeaderText="User name" />
                        <asp:BoundField DataField="expense_date" HeaderText="Expense date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:TemplateField HeaderText="Amount (payment mode)" ItemStyle-CssClass="mono">
                            <ItemTemplate>
                                <span class="fw-semibold">₹<%# string.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-IN"), "{0:N2}", Eval("amount")) %></span>
                                <span class="text-muted"> (<%# Eval("payment_mode") %>)</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="note" HeaderText="Note" ItemStyle-CssClass="text-break" />
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end text-nowrap exp-actions" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="edt" CommandArgument='<%# Eval("expense_id") %>' CssClass="text-secondary me-2" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="dlt" CommandArgument='<%# Eval("expense_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"
                                    OnClientClick="return confirm('Delete this expense?');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade right" id="modal_expense" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title mb-0"><asp:Label ID="lbl_modal_title" runat="server" Text="Add expense" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">User</label>
                            <asp:DropDownList ID="ddl_user" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Expense date</label>
                            <asp:TextBox ID="txt_exp_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Amount (₹)</label>
                            <asp:TextBox ID="txt_amount" runat="server" CssClass="form-control" TextMode="SingleLine"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label d-block">Payment mode</label>
                            <div class="d-flex flex-wrap gap-4 mt-1">
                                <div class="form-check m-0 d-flex align-items-center">
                                    <asp:RadioButton ID="rb_pay_cash" runat="server" GroupName="exp_pay_mode" CssClass="form-check-input" />
                                    <asp:Label runat="server" AssociatedControlID="rb_pay_cash" CssClass="form-check-label ms-1 mb-0">Cash</asp:Label>
                                </div>
                                <div class="form-check m-0 d-flex align-items-center">
                                    <asp:RadioButton ID="rb_pay_online" runat="server" GroupName="exp_pay_mode" CssClass="form-check-input" />
                                    <asp:Label runat="server" AssociatedControlID="rb_pay_online" CssClass="form-check-label ms-1 mb-0">Online</asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Note</label>
                            <asp:TextBox ID="txt_note" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
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
        function resetExpenseModalAdd() {
            var hId = document.getElementById('<%= hd_expense_id.ClientID %>');
            var hAct = document.getElementById('<%= hd_action.ClientID %>');
            var lbl = document.getElementById('<%= lbl_modal_title.ClientID %>');
            var btn = document.getElementById('<%= btn_save.ClientID %>');
            if (hId) hId.value = '';
            if (hAct) hAct.value = 'save';
            if (lbl) lbl.innerText = 'Add expense';
            if (btn) btn.value = 'Save';
            var ddlU = document.getElementById('<%= ddl_user.ClientID %>');
            if (ddlU) ddlU.selectedIndex = 0;
            var d = new Date();
            var y = d.getFullYear(), m = ('0' + (d.getMonth() + 1)).slice(-2), day = ('0' + d.getDate()).slice(-2);
            var dt = document.getElementById('<%= txt_exp_date.ClientID %>');
            if (dt) dt.value = y + '-' + m + '-' + day;
            var amt = document.getElementById('<%= txt_amount.ClientID %>');
            if (amt) amt.value = '';
            var rc = document.getElementById('<%= rb_pay_cash.ClientID %>');
            var ro = document.getElementById('<%= rb_pay_online.ClientID %>');
            if (rc) rc.checked = false;
            if (ro) ro.checked = false;
            var nt = document.getElementById('<%= txt_note.ClientID %>');
            if (nt) nt.value = '';
        }
    </script>
</asp:Content>
