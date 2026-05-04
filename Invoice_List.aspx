<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Invoice_List.aspx.cs" Inherits="Invoice_List" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Invoices</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .inv-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .inv-grid { margin: 0; font-size: 14px; width: 100%; }
        .inv-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .inv-grid > tbody > tr > td { padding: 10px 12px; vertical-align: middle; border-bottom: 1px solid #eee; }
        .inv-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .inv-actions a, .inv-actions .btn-link { display: inline-block; padding: 4px 6px; border-radius: 4px; text-decoration: none; }
        .inv-actions a:hover { background: #e9ecef; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark">Invoices</h1>
            <a href="Invoice_Entry.aspx" class="btn btn-sm btn-primary">New invoice</a>
        </div>

        <div class="card inv-card shadow-sm mb-3 rpt-filter-card">
            <div class="card-body row g-3 align-items-end">
                <div class="col-md-2 col-sm-6">
                    <label class="form-label">From date</label>
                    <asp:TextBox ID="txt_from" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-2 col-sm-6">
                    <label class="form-label">To date</label>
                    <asp:TextBox ID="txt_to" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="col-md-5 col-sm-6">
                    <label class="form-label">Party</label>
                    <asp:DropDownList ID="ddl_party" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-3 col-sm-6 d-flex align-items-end">
                    <asp:Button ID="btn_filter" runat="server" CssClass="btn btn-primary w-100" Text="Apply filter" OnClick="btn_filter_Click" />
                </div>
            </div>
        </div>

        <div class="inv-card shadow-sm">
            <div class="table-responsive">
                <asp:GridView ID="grid_inv" runat="server" ClientIDMode="Static" CssClass="table inv-grid mb-0"
                    AutoGenerateColumns="false" DataKeyNames="invoice_id" OnRowCommand="grid_inv_RowCommand"
                    GridLines="None" ShowHeaderWhenEmpty="true">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No invoices in this range. Use <strong>New invoice</strong> to create one.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="44px" ItemStyle-CssClass="text-muted text-center" HeaderStyle-CssClass="text-center">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="invoice_no" HeaderText="Invoice no" ItemStyle-CssClass="fw-medium text-nowrap" />
                        <asp:BoundField DataField="invoice_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="party_name" HeaderText="Party" />
                        <asp:BoundField DataField="invoice_kind" HeaderText="Kind" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="grand_total" HeaderText="Total" DataFormatString="{0:N2}" HtmlEncode="false" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end inv-actions text-nowrap" ItemStyle-Width="130px">
                            <ItemTemplate>
                                <a href='<%# "Invoice_Print.aspx?id=" + Eval("invoice_id") %>' target="_blank" class="text-dark me-1" title="Print" aria-label="Print"><i class="bi bi-printer"></i></a>
                                <asp:LinkButton runat="server" CommandName="edit" CommandArgument='<%# Eval("invoice_id") %>' CssClass="text-secondary" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="del" CommandArgument='<%# Eval("invoice_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"
                                    OnClientClick="return confirm('Delete this invoice?');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>
