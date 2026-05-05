<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Outward_History.aspx.cs" Inherits="Outward_History" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Outward history</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .out-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .out-grid { margin: 0; font-size: 14px; width: 100%; }
        .out-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .out-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .out-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .mono { font-variant-numeric: tabular-nums; }
    </style>
</asp:Content>

<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark">Outward history</h1>
        </div>

        <div class="card out-card shadow-sm mb-3 rpt-filter-card">
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

        <div class="out-card shadow-sm">
            <div class="table-responsive">
                <asp:GridView ID="grid_out" runat="server" CssClass="table out-grid mb-0" AutoGenerateColumns="false"
                    GridLines="None" ShowHeaderWhenEmpty="true">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No outward entries in this date range.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="40px" ItemStyle-CssClass="text-muted text-center" HeaderStyle-CssClass="text-center">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="outward_date" HeaderText="Out date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="slip_no" HeaderText="Slip no" ItemStyle-CssClass="text-nowrap mono" />
                        <asp:BoundField DataField="challan_no" HeaderText="Inward challan" ItemStyle-CssClass="text-nowrap fw-semibold" />
                        <asp:BoundField DataField="party_name" HeaderText="Party" />
                        <asp:BoundField DataField="part_name" HeaderText="Part" />
                        <asp:BoundField DataField="qty_out" HeaderText="Qty out" ItemStyle-CssClass="text-end mono" HeaderStyle-CssClass="text-end" />
                        <asp:BoundField DataField="remarks" HeaderText="Remarks" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>
</asp:Content>

