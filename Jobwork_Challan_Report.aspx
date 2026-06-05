<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Jobwork_Challan_Report.aspx.cs" Inherits="Jobwork_Challan_Report" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Jobwork challan history</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .inward-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .inward-grid { margin: 0; font-size: 14px; width: 100%; }
        .inward-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .inward-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .inward-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .inward-line-box { min-width: 200px; width: 100%; }
        .inward-sheet { border: 1px solid #e9ecef; border-radius: 8px; overflow: hidden; background: #fff; }
        .inward-sheet__row {
            display: grid;
            grid-template-columns: minmax(120px, 1fr) 88px 88px 96px;
            column-gap: 10px;
            align-items: center;
            padding: 8px 10px;
            font-size: 13px;
            border-top: 1px solid #edf0f3;
            background: #fff;
        }
        .inward-sheet__body .inward-sheet__row:first-child { border-top: none; }
        .inward-sheet__item { font-weight: 500; color: #212529; word-break: break-word; }
        .inward-sheet__num {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 5px;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
            font-weight: 600;
            padding: 5px 7px;
            border-radius: 6px;
        }
        .inward-sheet__ico { font-size: 1rem; line-height: 1; flex-shrink: 0; }
        .inward-sheet__num--qty { color: #198754; background: rgba(25, 135, 84, 0.1); }
        .inward-sheet__num--qty .inward-sheet__ico { color: #198754; }
        .inward-sheet__num--out { color: #d35400; background: rgba(234, 88, 12, 0.12); }
        .inward-sheet__num--out .inward-sheet__ico { color: #d35400; }
        .inward-sheet__num--pend { color: #dc3545; background: rgba(220, 53, 69, 0.1); }
        .inward-sheet__num--pend .inward-sheet__ico { color: #dc3545; }
        .inward-sheet__num--empty { font-weight: 500; color: #ced4da !important; background: #f8f9fa !important; }
        .inward-sheet__num--empty .inward-sheet__ico { color: #dee2e6; }
        .rpt-filter-card .form-label { font-size: 0.8rem; font-weight: 600; color: #495057; }
        .inward-actions a, .inward-actions button { display: inline-block; padding: 4px 6px; border-radius: 4px; border: none; background: transparent; }
        .inward-actions a:hover, .inward-actions button:hover { background: #e9ecef; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark">Jobwork challan history</h1>
            <a href="Jobwork_Challan_List.aspx" class="btn btn-sm btn-outline-primary">Active jobwork challans</a>
        </div>

        <div class="card inward-card shadow-sm mb-3 rpt-filter-card">
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
                    <label class="form-label">Jobwork party</label>
                    <asp:DropDownList ID="ddl_jobwork_party" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>
                <div class="col-md-3 col-sm-6 d-flex align-items-end">
                    <asp:Button ID="btn_filter" runat="server" CssClass="btn btn-primary w-100" Text="Apply filter" OnClick="btn_filter_Click" />
                </div>
            </div>
        </div>

        <div class="inward-card shadow-sm">
            <div class="px-3 pt-3 pb-0">
                <div class="row mb-3">
                    <div class="col-md-4 col-sm-6">
                        <label class="form-label">Search</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" id="txt_jw_challan_rpt_search" class="form-control" placeholder="Status, date, challan no, party, part..." autocomplete="off" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="grid_rpt" runat="server" ClientIDMode="Static" CssClass="table inward-grid mb-0" AutoGenerateColumns="false" DataKeyNames="jobwork_challan_id"
                    UseAccessibleHeader="true" GridLines="None" ShowHeaderWhenEmpty="true" OnRowDataBound="grid_rpt_RowDataBound" OnRowCommand="grid_rpt_RowCommand">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No jobwork challans in this date range.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="40px" ItemStyle-CssClass="text-muted text-center" HeaderStyle-CssClass="text-center">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="text-nowrap">
                            <ItemTemplate>
                                <span class="badge rounded-pill <%# Eval("challan_status").ToString() == "Active" ? "bg-success" : "bg-secondary" %>"><%# Eval("challan_status") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="challan_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="challan_no" HeaderText="Challan no" ItemStyle-CssClass="fw-semibold text-nowrap" />
                        <asp:BoundField DataField="jobwork_party_name" HeaderText="Jobwork party" />
                        <asp:TemplateField HeaderText="Parts">
                            <ItemTemplate>
                                <asp:Literal ID="lit_rpt_parts" runat="server" Mode="PassThrough"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end inward-actions text-nowrap" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="edit" CommandArgument='<%# Eval("jobwork_challan_id") %>' CssClass="text-secondary" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="del" CommandArgument='<%# Eval("jobwork_challan_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"
                                    OnClientClick="return confirm('Delete this challan?');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function filterJwChallanRptGrid() {
            var value = $("#txt_jw_challan_rpt_search").val().toLowerCase().trim();
            $("#grid_rpt tr:has(td)").each(function () {
                var text = $(this).text().toLowerCase();
                $(this).toggle(value === "" || text.indexOf(value) > -1);
            });
        }

        $(document).ready(function () {
            $("#txt_jw_challan_rpt_search").on("keyup input", filterJwChallanRptGrid);
            filterJwChallanRptGrid();
        });
    </script>
</asp:Content>
