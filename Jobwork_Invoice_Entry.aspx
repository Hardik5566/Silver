<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Jobwork_Invoice_Entry.aspx.cs" Inherits="Jobwork_Invoice_Entry" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Jobwork invoice</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .jwi-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .jwi-grid { margin: 0; font-size: 14px; width: 100%; }
        .jwi-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .jwi-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .jwi-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .mono { font-variant-numeric: tabular-nums; }
        .jwi-panel-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: #495057;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 12px 14px;
            border-bottom: 1px solid #dee2e6;
            background: #f8f9fa;
        }
        .modal_form_footer { padding: 15px; border-top: 1px solid #dee2e6; display: flex; justify-content: space-between; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark"><i class="bi bi-file-earmark-text me-1"></i>Jobwork invoice</h1>
            <button type="button" class="btn btn-sm btn-primary" data-bs-toggle="modal" data-bs-target="#modal_jwi" onclick="resetJwiModalAdd();">+ Add invoice</button>
            <asp:HiddenField ID="hd_jobwork_invoice_id" runat="server" />
            <asp:HiddenField ID="hd_action" runat="server" Value="save" />
        </div>

        <div class="card jwi-card shadow-sm mb-3 rpt-filter-card">
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

        <div class="jwi-card shadow-sm">
            <div class="jwi-panel-title">Invoice list</div>
            <div class="table-responsive">
                <asp:GridView ID="grid_jwi" runat="server" CssClass="table jwi-grid mb-0" AutoGenerateColumns="false"
                    GridLines="None" ShowHeaderWhenEmpty="true" DataKeyNames="jobwork_invoice_id" OnRowCommand="grid_jwi_RowCommand">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No jobwork invoices in this date range.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:BoundField DataField="sr" HeaderText="Sr" ItemStyle-Width="52px" ItemStyle-CssClass="text-muted text-center mono" HeaderStyle-CssClass="text-center" />
                        <asp:BoundField DataField="party_name" HeaderText="Jobwork party" />
                        <asp:BoundField DataField="invoice_date" HeaderText="Invoice date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="invoice_no" HeaderText="Invoice / Challan no" ItemStyle-CssClass="text-muted" NullDisplayText="—" />
                        <asp:TemplateField HeaderText="Total amount" ItemStyle-CssClass="mono">
                            <ItemTemplate>
                                <span class="fw-semibold">₹<%# string.Format(System.Globalization.CultureInfo.CreateSpecificCulture("en-IN"), "{0:N2}", Eval("total_amount")) %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end text-nowrap" ItemStyle-Width="90px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="edt" CommandArgument='<%# Eval("jobwork_invoice_id") %>' CssClass="text-secondary me-2" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="dlt" CommandArgument='<%# Eval("jobwork_invoice_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"
                                    OnClientClick="return confirm('Delete this jobwork invoice?');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade right" id="modal_jwi" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title mb-0"><asp:Label ID="lbl_modal_title" runat="server" Text="Add jobwork invoice" /></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Jobwork party</label>
                            <asp:DropDownList ID="ddl_jobwork_party" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Invoice date</label>
                            <asp:TextBox ID="txt_invoice_date" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Invoice / Challan no <span class="text-muted fw-normal">(optional)</span></label>
                            <asp:TextBox ID="txt_invoice_no" runat="server" CssClass="form-control" MaxLength="50"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Total amount (₹)</label>
                            <asp:TextBox ID="txt_total_amount" runat="server" CssClass="form-control"></asp:TextBox>
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
        function resetJwiModalAdd() {
            var hId = document.getElementById('<%= hd_jobwork_invoice_id.ClientID %>');
            var hAct = document.getElementById('<%= hd_action.ClientID %>');
            var lbl = document.getElementById('<%= lbl_modal_title.ClientID %>');
            var btn = document.getElementById('<%= btn_save.ClientID %>');
            if (hId) hId.value = '';
            if (hAct) hAct.value = 'save';
            if (lbl) lbl.innerText = 'Add jobwork invoice';
            if (btn) btn.value = 'Save';
            var ddl = document.getElementById('<%= ddl_jobwork_party.ClientID %>');
            if (ddl) ddl.selectedIndex = 0;
            var d = new Date();
            var y = d.getFullYear(), m = ('0' + (d.getMonth() + 1)).slice(-2), day = ('0' + d.getDate()).slice(-2);
            var dt = document.getElementById('<%= txt_invoice_date.ClientID %>');
            if (dt) dt.value = y + '-' + m + '-' + day;
            var no = document.getElementById('<%= txt_invoice_no.ClientID %>');
            if (no) no.value = '';
            var amt = document.getElementById('<%= txt_total_amount.ClientID %>');
            if (amt) amt.value = '';
        }
    </script>
</asp:Content>
