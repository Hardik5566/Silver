<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Inward_Challan_List.aspx.cs" Inherits="Inward_Challan_List" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Active challans</asp:Content>
<asp:Content ID="c2" ContentPlaceHolderID="head" runat="server">
    <style>
        .inward-card { border: 1px solid #dee2e6; border-radius: 8px; overflow: hidden; background: #fff; width: 100%; }
        .inward-grid { margin: 0; font-size: 14px; width: 100%; }
        .inward-grid > thead > tr > th { background: #f8f9fa; color: #495057; font-weight: 600; font-size: 12px; padding: 10px 12px; border-bottom: 2px solid #dee2e6; }
        .inward-grid > tbody > tr > td { padding: 12px; vertical-align: top; border-bottom: 1px solid #eee; }
        .inward-grid > tbody > tr:hover > td { background: #fcfcfd; }
        .inward-line-box { min-width: 200px; width: 100%; }
        /* Line block: grid only (no nested HTML table) */
        .inward-sheet { border: 1px solid #e9ecef; border-radius: 8px; overflow: hidden; background: #fff; }
        /* No inner header row — icons + color on each value show Qty / Out / Pending */
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
        .inward-actions a { display: inline-block; padding: 4px 6px; border-radius: 4px; }
        .inward-actions a:hover { background: #e9ecef; }

        /* Outward modal */
        .outw-modal .modal-content { border: none; border-radius: 14px; overflow: hidden; box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15); }
        .outw-modal .modal-dialog { max-width: 920px; }
        .outw-modal-head {
            background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 50%, #084298 100%);
            padding: 1.1rem 1.35rem;
        }
        .outw-modal-head .modal-title { font-weight: 700; letter-spacing: -0.02em; }
        .outw-modal-head .outw-kicker { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85; }
        .outw-meta { font-size: 0.875rem; opacity: 0.92; margin-top: 0.25rem; }
        .outw-meta strong { font-weight: 600; opacity: 1; }
        .outw-section { margin-top: 1.25rem; }
        .outw-section-title {
            font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #6c757d; margin-bottom: 0.5rem;
            display: flex; align-items: center; gap: 0.4rem;
        }
        .outw-section-title .bi { color: #0d6efd; }
        .outw-card {
            border: 1px solid #e9ecef; border-radius: 10px; overflow: hidden; background: #fff;
        }
        .outw-card .table { margin-bottom: 0; }
        .outw-card .table thead th {
            background: #f8f9fa; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.04em; color: #495057; font-weight: 600; border-bottom-width: 1px;
        }
        .outw-card .table tbody td { vertical-align: middle; padding: 0.65rem 0.75rem; }
        .outw-qty-inp { max-width: 88px; margin-left: auto; text-align: right; font-weight: 600; }
        .outw-foot { background: linear-gradient(180deg, #f8f9fa 0%, #fff 100%); border-top: 1px solid #e9ecef; padding: 1rem 1.35rem; }
        .outw-hint { font-size: 0.8rem; color: #6c757d; margin: 0 0 0.75rem; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark">Active challans</h1>
            <div class="d-flex gap-2">
                <a href="Inward_Challan_Report.aspx" class="btn btn-sm btn-outline-secondary">Challan history</a>
                <a href="Inward_Challan_Entry.aspx" class="btn btn-sm btn-primary">New challan</a>
            </div>
        </div>

        <div class="inward-card shadow-sm">
            <div class="table-responsive">
                <asp:GridView ID="grid_inward" runat="server" ClientIDMode="Static" CssClass="table inward-grid mb-0"
                    AutoGenerateColumns="false" DataKeyNames="inward_id" OnRowCommand="grid_inward_RowCommand" OnRowDataBound="grid_inward_RowDataBound"
                    EnableViewState="true" GridLines="None" ShowHeaderWhenEmpty="true">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No challans with <strong>pending</strong> quantity. Fully dispatched challans are under <strong>Challan history</strong>. Click <strong>New challan</strong> to add one.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="40px" ItemStyle-CssClass="text-muted text-center" HeaderStyle-CssClass="text-center">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="inward_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="challan_no" HeaderText="Challan no" ItemStyle-CssClass="fw-medium text-nowrap" />
                        <asp:BoundField DataField="party_name" HeaderText="Party" />
                        <asp:TemplateField HeaderText="Parts">
                            <ItemTemplate>
                                <asp:Literal ID="lit_lines" runat="server" Mode="PassThrough"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end inward-actions text-nowrap" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <asp:LinkButton runat="server" CommandName="edit" CommandArgument='<%# Eval("inward_id") %>' CssClass="text-secondary" ToolTip="Edit" aria-label="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="out" CommandArgument='<%# Eval("inward_id") %>' CssClass="text-primary" ToolTip="Outward" aria-label="Outward"><i class="bi bi-box-arrow-up-right"></i></asp:LinkButton>
                                <asp:LinkButton runat="server" CommandName="del" CommandArgument='<%# Eval("inward_id") %>' CssClass="text-danger" ToolTip="Delete" aria-label="Delete"
                                    OnClientClick="return confirm('Delete this challan?');"><i class="bi bi-trash"></i></asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade outw-modal" id="modal_out" tabindex="-1" aria-labelledby="modal_out_title" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable modal-lg">
            <div class="modal-content">
                <div class="modal-header outw-modal-head text-white border-0">
                    <div>
                        <div class="outw-kicker" id="modal_out_title">Record outward</div>
                        <h2 class="modal-title text-white fs-5 mb-0">Send stock out</h2>
                        <div class="outw-meta"><asp:Literal ID="lit_out_meta" runat="server" /></div>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body px-3 px-md-4 pt-3 pb-2">
                    <asp:HiddenField ID="hd_out_inward_id" runat="server" />
                    <p class="outw-hint"><i class="bi bi-info-circle me-1"></i> Enter <strong>out qty</strong> on one or more lines, then click <strong>Save outward</strong> once. Qty cannot exceed pending.</p>

                    <div class="outw-section">
                        <div class="outw-section-title"><i class="bi bi-list-ul"></i> Lines to dispatch</div>
                        <div class="outw-card shadow-sm">
                            <div class="table-responsive">
                                <asp:GridView ID="gv_out_lines" runat="server" CssClass="table table-sm align-middle" AutoGenerateColumns="false" DataKeyNames="inward_detail_id" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="part_name" HeaderText="Item" ItemStyle-CssClass="fw-semibold" />
                                        <asp:BoundField DataField="qty_inward" HeaderText="Received" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_out_done" HeaderText="Already out" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_pending" HeaderText="Pending" ItemStyle-CssClass="text-end text-nowrap fw-semibold text-danger" HeaderStyle-CssClass="text-end" />
                                        <asp:TemplateField HeaderText="Out now" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txt_out_qty" runat="server" CssClass="form-control form-control-sm outw-qty-inp" placeholder="0"></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>

                    <div class="outw-section">
                        <div class="outw-section-title"><i class="bi bi-clock-history"></i> Recent movements</div>
                        <div class="outw-card shadow-sm">
                            <div class="table-responsive">
                                <asp:GridView ID="gv_history" runat="server" CssClass="table table-sm align-middle" AutoGenerateColumns="false" DataKeyNames="outward_history_id"
                                    GridLines="None" OnRowCommand="gv_history_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="outward_date" HeaderText="When" DataFormatString="{0:dd-MMM-yyyy HH:mm}" ItemStyle-CssClass="text-nowrap" />
                                        <asp:BoundField DataField="part_name" HeaderText="Item" />
                                        <asp:BoundField DataField="qty_out" HeaderText="Qty" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="slip_no" HeaderText="Ref." ItemStyle-CssClass="text-muted small" />
                                        <asp:BoundField DataField="remarks" HeaderText="Note" ItemStyle-CssClass="small text-muted" />
                                        <asp:TemplateField HeaderText="" ItemStyle-Width="88px">
                                            <ItemTemplate>
                                                <asp:LinkButton runat="server" CommandName="delhist" CssClass="btn btn-sm btn-outline-danger py-0" CommandArgument='<%# Eval("outward_history_id") %>'
                                                    OnClientClick="return confirm('Reverse this movement?');" Text="Reverse"></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer outw-foot d-flex flex-wrap align-items-center justify-content-between gap-2 border-0">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btn_save_all_outward" runat="server" CssClass="btn btn-primary px-4" Text="Save outward" OnClick="btn_save_all_outward_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showOutModal() {
            var el = document.getElementById('modal_out');
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
        }
    </script>
</asp:Content>
