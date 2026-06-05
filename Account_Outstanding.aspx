<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Account_Outstanding.aspx.cs" Inherits="Account_Outstanding" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Account outstanding</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .aout-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .aout-grid { margin: 0; font-size: 14px; width: 100%; }
        .aout-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .aout-grid > tbody > tr > td { padding: 12px; vertical-align: middle; border-bottom: 1px solid #eee; }
        .aout-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .mono { font-variant-numeric: tabular-nums; }
        .aout-panel-title {
            font-size: 0.8rem;
            font-weight: 600;
            color: #495057;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            padding: 12px 14px;
            border-bottom: 1px solid #dee2e6;
            background: #f8f9fa;
        }
        .badge-type { font-size: 11px; font-weight: 600; padding: 4px 8px; border-radius: 4px; }
        .badge-party { background: #e7f1ff; color: #0d6efd; }
        .badge-jobwork { background: #fff3cd; color: #856404; }
        .badge-staff { background: #e8f5e9; color: #2e7d32; }
        .bal-recv { color: #198754; }
        .bal-pay { color: #dc3545; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark"><i class="bi bi-journal-bookmark me-1"></i>Account outstanding</h1>
        </div>

        <div class="card aout-card shadow-sm mb-3 rpt-filter-card">
            <div class="card-body row g-3 align-items-end">
                <div class="col-md-3 col-sm-6">
                    <label class="form-label">Account type</label>
                    <asp:DropDownList ID="ddl_account_type" runat="server" CssClass="form-select">
                        <asp:ListItem Value="ALL" Text="All types" Selected="True" />
                        <asp:ListItem Value="PARTY" Text="Party (receivable)" />
                        <asp:ListItem Value="JOBWORK" Text="Jobwork (payable)" />
                        <asp:ListItem Value="STAFF" Text="Staff (payable)" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-4 col-sm-6">
                    <label class="form-label">Search name</label>
                    <asp:TextBox ID="txt_search" runat="server" CssClass="form-control" placeholder="Party / jobwork / staff name"></asp:TextBox>
                </div>
                <div class="col-md-2 col-sm-6 d-flex align-items-end">
                    <asp:Button ID="btn_show" runat="server" CssClass="btn btn-primary w-100" Text="Show" OnClick="btn_show_Click" />
                </div>
            </div>
        </div>

        <div class="aout-card shadow-sm">
            <div class="aout-panel-title">Outstanding balances</div>
            <div class="table-responsive">
                <asp:GridView ID="grid_out" runat="server" CssClass="table aout-grid mb-0" AutoGenerateColumns="false"
                    GridLines="None" ShowHeaderWhenEmpty="true" ShowFooter="false">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No outstanding balance found.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:BoundField DataField="sr" HeaderText="Sr" ItemStyle-Width="52px" ItemStyle-CssClass="text-muted text-center mono" HeaderStyle-CssClass="text-center" />
                        <asp:TemplateField HeaderText="Type" ItemStyle-Width="110px">
                            <ItemTemplate>
                                <span class='badge-type <%# GetTypeBadgeClass(Eval("account_type")) %>'><%# Eval("account_type_label") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Account name">
                            <ItemTemplate>
                                <a href='<%# "Account_Ledger.aspx?account_type=" + Eval("account_type") + "&account_id=" + Eval("account_id") %>' class="fw-medium text-decoration-none"><%# Eval("account_name") %></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Debit" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">
                            <ItemTemplate>₹<%# FormatAmt(Eval("debit_total")) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Credit" ItemStyle-CssClass="mono text-end" HeaderStyle-CssClass="text-end">
                            <ItemTemplate>₹<%# FormatAmt(Eval("credit_total")) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Balance" ItemStyle-CssClass="mono text-end fw-semibold" HeaderStyle-CssClass="text-end">
                            <ItemTemplate>
                                <span class='<%# GetBalanceClass(Eval("balance_label")) %>'>₹<%# FormatBalance(Eval("balance"), Eval("balance_label")) %></span>
                                <div class="text-muted small fw-normal"><%# Eval("balance_label") %></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
