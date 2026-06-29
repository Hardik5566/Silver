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
        .out-actions a { display: inline-block; padding: 4px 6px; border-radius: 4px; }
        .out-actions a:hover { background: #e9ecef; }
        .out-edit-modal .modal-content { border: none; border-radius: 14px; overflow: hidden; box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15); }
        .out-edit-modal-head {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 50%, #084298 100%);
            padding: 1.1rem 1.35rem;
        }
        .out-edit-meta { font-size: 0.875rem; opacity: 0.92; margin-top: 0.35rem; }
        .out-edit-hint { font-size: 0.8rem; color: #6c757d; }
    </style>
</asp:Content>

<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

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
            <div class="px-3 pt-3 pb-0">
                <div class="row mb-3">
                    <div class="col-md-4 col-sm-6">
                        <label class="form-label">Search</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" id="txt_outward_search" class="form-control" placeholder="Date, slip, challan, party, part..." autocomplete="off" />
                        </div>
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="grid_out" runat="server" ClientIDMode="Static" CssClass="table out-grid mb-0" AutoGenerateColumns="false"
                    DataKeyNames="outward_history_id" OnRowCommand="grid_out_RowCommand"
                    UseAccessibleHeader="true" GridLines="None" ShowHeaderWhenEmpty="true">
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
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end out-actions text-nowrap" ItemStyle-Width="72px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="editout" CommandArgument='<%# Eval("outward_history_id") %>' CssClass="text-secondary" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="delout" CommandArgument='<%# Eval("outward_history_id") %>' CssClass="text-danger" ToolTip="Reverse" aria-label="Reverse"
                                    OnClientClick="return confirm('Reverse this outward entry? Pending qty on the challan will be restored.');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade out-edit-modal" id="modal_edit" tabindex="-1" aria-labelledby="modal_edit_title" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header out-edit-modal-head text-white border-0">
                    <div>
                        <div class="small text-uppercase opacity-75" id="modal_edit_title">Edit outward</div>
                        <h2 class="modal-title text-white fs-5 mb-0">Update dispatch</h2>
                        <div class="out-edit-meta"><asp:Literal ID="lit_edit_meta" runat="server" /></div>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body px-3 px-md-4 pt-3 pb-2">
                    <asp:HiddenField ID="hd_edit_id" runat="server" />
                    <p class="out-edit-hint mb-3"><asp:Literal ID="lit_edit_hint" runat="server" /></p>
                    <div class="mb-3">
                        <label class="form-label">Qty out</label>
                        <asp:TextBox ID="txt_edit_qty" runat="server" CssClass="form-control mono" placeholder="0"></asp:TextBox>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Slip no</label>
                        <asp:TextBox ID="txt_edit_slip" runat="server" CssClass="form-control" placeholder="Optional"></asp:TextBox>
                    </div>
                    <div class="mb-2">
                        <label class="form-label">Remarks</label>
                        <asp:TextBox ID="txt_edit_remarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Optional"></asp:TextBox>
                    </div>
                </div>
                <div class="modal-footer border-0 bg-light">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                    <asp:Button ID="btn_save_edit" runat="server" CssClass="btn btn-primary px-4" Text="Save changes" OnClick="btn_save_edit_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function filterOutwardGrid() {
            var value = $("#txt_outward_search").val().toLowerCase().trim();
            $("#grid_out tr:has(td)").each(function () {
                var text = $(this).text().toLowerCase();
                $(this).toggle(value === "" || text.indexOf(value) > -1);
            });
        }

        $(document).ready(function () {
            $("#txt_outward_search").on("keyup input", filterOutwardGrid);
            filterOutwardGrid();
        });

        function showEditModal() {
            var el = document.getElementById('modal_edit');
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
        }
    </script>
</asp:Content>
