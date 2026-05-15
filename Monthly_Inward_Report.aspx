<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Monthly_Inward_Report.aspx.cs" Inherits="Monthly_Inward_Report" %>



<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Monthly inward report</asp:Content>

<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">

    <style>

        .mir-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }

        .mir-grid { margin: 0; font-size: 14px; width: 100%; }

        .mir-grid > thead > tr > th {

            background: #f8f9fa;

            color: #495057;

            font-weight: 600;

            font-size: 12px;

            padding: 10px 12px;

            border-bottom: 2px solid #dee2e6;

        }

        .mir-grid > tbody > tr > td { padding: 10px 12px; vertical-align: middle; border-bottom: 1px solid #eee; }

        .mir-grid > tbody > tr:hover > td { background: #fcfcfd; }

        .mir-grid .mir-num { font-variant-numeric: tabular-nums; text-align: right; white-space: nowrap; }

        .mir-grid tfoot td { padding: 10px 12px; border-top: 2px solid #dee2e6; background: #f8f9fa; font-weight: 600; }

        .mir-grid tfoot .mir-ft-label { text-align: right; color: #495057; }

        .mir-grid tfoot .mir-ft-val { text-align: right; font-variant-numeric: tabular-nums; color: #212529; }

        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }

        .mir-panel-title {

            font-size: 0.8rem;

            font-weight: 600;

            color: #495057;

            text-transform: uppercase;

            letter-spacing: 0.04em;

            padding: 12px 14px;

            border-bottom: 1px solid #dee2e6;

            background: #f8f9fa;

        }

        #mirChart { min-height: 420px; }

        @media (max-width: 991.98px) {

            #mirChart { min-height: 320px; }

        }

    </style>

</asp:Content>

<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">

    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>



    <div class="w-100">

        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">

            <h1 class="h5 mb-0 fw-semibold text-dark">Monthly inward report</h1>

        </div>



        <div class="card mir-card shadow-sm mb-3 rpt-filter-card">

            <div class="card-body row g-3 align-items-end">

                <div class="col-md-4 col-sm-6">

                    <label class="form-label">Month</label>

                    <asp:DropDownList ID="ddl_month" runat="server" CssClass="form-select"></asp:DropDownList>

                </div>

                <div class="col-md-5 col-sm-6">

                    <label class="form-label">Party</label>

                    <asp:DropDownList ID="ddl_party" runat="server" CssClass="form-select"></asp:DropDownList>

                </div>

                <div class="col-md-3 col-sm-6 d-flex align-items-end">

                    <asp:Button ID="btn_apply" runat="server" CssClass="btn btn-primary w-100" Text="Show report" OnClick="btn_apply_Click" />

                </div>

            </div>

        </div>



        <div class="row g-3 align-items-stretch">

            <div class="col-lg-5">

                <div class="mir-card shadow-sm h-100 d-flex flex-column">

                    <div class="mir-panel-title">Daily counts</div>

                    <div class="table-responsive flex-grow-1">

                        <asp:GridView ID="grid_rpt" runat="server" CssClass="table mir-grid mb-0" AutoGenerateColumns="false"

                            GridLines="None" ShowHeaderWhenEmpty="true" ShowFooter="true">

                            <EmptyDataTemplate>

                                <div class="p-4 text-center text-muted">No rows to display.</div>

                            </EmptyDataTemplate>

                            <Columns>

                                <asp:BoundField DataField="report_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="false" ItemStyle-CssClass="fw-medium text-nowrap" />

                                <asp:BoundField DataField="total_party_inward" HeaderText="Total Party" ItemStyle-CssClass="mir-num" HeaderStyle-CssClass="text-end" />

                                <asp:BoundField DataField="total_uniq_item_inward" HeaderText="Total uniq Item" ItemStyle-CssClass="mir-num" HeaderStyle-CssClass="text-end" />

                                <asp:BoundField DataField="total_qty_inward" HeaderText="Total qty" DataFormatString="{0:N0}" HtmlEncode="false" ItemStyle-CssClass="mir-num" HeaderStyle-CssClass="text-end" />

                                <asp:BoundField DataField="total_amount" HeaderText="Total amount" DataFormatString="{0:N2}" HtmlEncode="false" ItemStyle-CssClass="mir-num" HeaderStyle-CssClass="text-end" />

                            </Columns>

                        </asp:GridView>

                    </div>

                </div>

            </div>

            <div class="col-lg-7">

                <div class="mir-card shadow-sm h-100 d-flex flex-column">

                    <div class="mir-panel-title">Daily amount chart</div>

                    <div class="p-2 flex-grow-1">

                        <div id="mirChart"></div>

                    </div>

                </div>

            </div>

        </div>



        <p class="small text-muted mt-2 mb-0">Each row is one calendar day in the selected month. Days without inward show 0. Amount uses <code>rate_at_time</code>; missing rate counts as zero.</p>

    </div>



    <script src="assets/plugins/apexcharts-bundle/js/apexcharts.js"></script>

    <asp:Literal ID="lit_chart_boot" runat="server" Mode="PassThrough" />

</asp:Content>

