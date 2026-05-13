<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Jobwork_Challan_List.aspx.cs" Inherits="Jobwork_Challan_List" %>

<asp:Content ID="c1" ContentPlaceHolderID="title" runat="server">Active jobwork challans</asp:Content>
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
        .inward-actions a { display: inline-block; padding: 4px 6px; border-radius: 4px; }
        .inward-actions a:hover { background: #e9ecef; }

        /* Receive modal (jobwork return) */
        .jw-ret-modal .modal-content { border: none; border-radius: 14px; overflow: hidden; box-shadow: 0 12px 40px rgba(0, 0, 0, 0.15); }
        .jw-ret-modal .modal-dialog { max-width: 980px; }
        .jw-ret-modal-head {
            background: linear-gradient(135deg, #198754 0%, #146c43 50%, #0f5132 100%);
            padding: 1.1rem 1.35rem;
        }
        .jw-ret-modal-head .modal-title { font-weight: 700; letter-spacing: -0.02em; }
        .jw-ret-modal-head .jw-ret-kicker { font-size: 0.7rem; text-transform: uppercase; letter-spacing: 0.12em; opacity: 0.85; }
        .jw-ret-meta { font-size: 0.875rem; opacity: 0.92; margin-top: 0.25rem; }
        .jw-ret-meta strong { font-weight: 600; opacity: 1; }
        .jw-ret-section { margin-top: 1.25rem; }
        .jw-ret-section-title {
            font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.08em; color: #6c757d; margin-bottom: 0.5rem;
            display: flex; align-items: center; gap: 0.4rem;
        }
        .jw-ret-section-title .bi { color: #198754; }
        .jw-ret-card {
            border: 1px solid #e9ecef; border-radius: 10px; overflow: hidden; background: #fff;
        }
        .jw-ret-card .table { margin-bottom: 0; }
        .jw-ret-card .table thead th {
            background: #f8f9fa; font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.04em; color: #495057; font-weight: 600; border-bottom-width: 1px;
        }
        .jw-ret-card .table tbody td { vertical-align: middle; padding: 0.65rem 0.75rem; }
        .jw-ret-qty-inp { max-width: 72px; margin-left: auto; text-align: right; font-weight: 600; }
        .jw-ret-foot { background: linear-gradient(180deg, #f8f9fa 0%, #fff 100%); border-top: 1px solid #e9ecef; padding: 1rem 1.35rem; }
        .jw-ret-hint { font-size: 0.8rem; color: #6c757d; margin: 0 0 0.75rem; }
    </style>
</asp:Content>
<asp:Content ID="c3" ContentPlaceHolderID="body" runat="server">
    <asp:ScriptManager ID="sm1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="w-100">
        <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
            <h1 class="h5 mb-0 fw-semibold text-dark">Active jobwork challans</h1>
            <div class="d-flex gap-2">
                <a href="Jobwork_Challan_Report.aspx" class="btn btn-sm btn-outline-secondary">Jobwork challan history</a>
                <a href="Jobwork_Challan_Entry.aspx" class="btn btn-sm btn-primary">New jobwork challan</a>
            </div>
        </div>

        <div class="inward-card shadow-sm">
            <div class="table-responsive">
                <asp:GridView ID="grid_jobwork" runat="server" ClientIDMode="Static" CssClass="table inward-grid mb-0"
                    AutoGenerateColumns="false" DataKeyNames="jobwork_challan_id" OnRowCommand="grid_jobwork_RowCommand" OnRowDataBound="grid_jobwork_RowDataBound"
                    EnableViewState="true" GridLines="None" ShowHeaderWhenEmpty="true">
                    <EmptyDataTemplate>
                        <div class="p-4 text-center text-muted">No jobwork challans with <strong>pending</strong> return quantity. Click <strong>New jobwork challan</strong> to add one.</div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="#" ItemStyle-Width="40px" ItemStyle-CssClass="text-muted text-center" HeaderStyle-CssClass="text-center">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="challan_date" HeaderText="Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="true" ItemStyle-CssClass="text-nowrap" />
                        <asp:BoundField DataField="challan_no" HeaderText="Challan no" ItemStyle-CssClass="fw-medium text-nowrap" />
                        <asp:BoundField DataField="jobwork_party_name" HeaderText="Jobwork party" />
                        <asp:TemplateField HeaderText="Parts">
                            <ItemTemplate>
                                <asp:Literal ID="lit_lines" runat="server" Mode="PassThrough"></asp:Literal>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="" ItemStyle-CssClass="text-end inward-actions text-nowrap" ItemStyle-Width="148px">
                            <ItemTemplate>
                                <a href='<%# string.Format("Jobwork_Challan_Print.aspx?id={0}", Eval("jobwork_challan_id")) %>' target="_blank" class="text-dark me-1" title="Print"><i class="bi bi-printer"></i></a>
                                <asp:LinkButton runat="server" CommandName="recv" CommandArgument='<%# Eval("jobwork_challan_id") %>' CssClass="text-success" ToolTip="Receive" aria-label="Receive"><i class="bi bi-box-arrow-in-down-left"></i></asp:LinkButton>
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

    <div class="modal fade jw-ret-modal" id="modal_recv" tabindex="-1" aria-labelledby="modal_recv_title" aria-hidden="true">
        <div class="modal-dialog modal-dialog-scrollable modal-lg">
            <div class="modal-content">
                <div class="modal-header jw-ret-modal-head text-white border-0">
                    <div>
                        <div class="jw-ret-kicker" id="modal_recv_title">Receive from jobwork</div>
                        <h2 class="modal-title text-white fs-5 mb-0">Record return (perfect / reject)</h2>
                        <div class="jw-ret-meta"><asp:Literal ID="lit_recv_meta" runat="server" /></div>
                    </div>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body px-3 px-md-4 pt-3 pb-2">
                    <asp:HiddenField ID="hd_recv_jobwork_challan_id" runat="server" />
                    <p class="jw-ret-hint"><i class="bi bi-info-circle me-1"></i> Enter <strong>perfect</strong> and/or <strong>reject</strong> qty on one or more lines (total per line cannot exceed pending), then click <strong>Save receive</strong> once.</p>

                    <div class="row g-2 mb-3">
                        <div class="col-md-4">
                            <label class="form-label small text-muted mb-1">Ref. / slip (optional)</label>
                            <asp:TextBox ID="txt_recv_slip" runat="server" CssClass="form-control form-control-sm" placeholder="Reference" />
                        </div>
                        <div class="col-md-8">
                            <label class="form-label small text-muted mb-1">Note (optional)</label>
                            <asp:TextBox ID="txt_recv_remarks" runat="server" CssClass="form-control form-control-sm" placeholder="Remarks for this save" />
                        </div>
                    </div>

                    <div class="jw-ret-section">
                        <div class="jw-ret-section-title"><i class="bi bi-list-ul"></i> Lines with pending qty</div>
                        <div class="jw-ret-card shadow-sm">
                            <div class="table-responsive">
                                <asp:GridView ID="gv_recv_lines" runat="server" CssClass="table table-sm align-middle" AutoGenerateColumns="false" DataKeyNames="jobwork_detail_id" GridLines="None">
                                    <Columns>
                                        <asp:BoundField DataField="part_name" HeaderText="Item" ItemStyle-CssClass="fw-semibold" />
                                        <asp:BoundField DataField="qty_sent" HeaderText="Sent" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_perfect_done" HeaderText="Ok done" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_reject_done" HeaderText="Rej. done" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_pending" HeaderText="Pending" ItemStyle-CssClass="text-end text-nowrap fw-semibold text-danger" HeaderStyle-CssClass="text-end" />
                                        <asp:TemplateField HeaderText="Perfect" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txt_perfect" runat="server" CssClass="form-control form-control-sm jw-ret-qty-inp" placeholder="0" Text=""></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Reject" HeaderStyle-CssClass="text-end" ItemStyle-CssClass="text-end">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txt_reject" runat="server" CssClass="form-control form-control-sm jw-ret-qty-inp" placeholder="0" Text=""></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>

                    <div class="jw-ret-section">
                        <div class="jw-ret-section-title"><i class="bi bi-clock-history"></i> Return history</div>
                        <div class="jw-ret-card shadow-sm">
                            <div class="table-responsive">
                                <asp:GridView ID="gv_recv_hist" runat="server" CssClass="table table-sm align-middle" AutoGenerateColumns="false" DataKeyNames="jobwork_return_id"
                                    GridLines="None" OnRowCommand="gv_recv_hist_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="return_date" HeaderText="When" DataFormatString="{0:dd-MMM-yyyy HH:mm}" ItemStyle-CssClass="text-nowrap" />
                                        <asp:BoundField DataField="part_name" HeaderText="Item" />
                                        <asp:BoundField DataField="qty_perfect" HeaderText="Ok" ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="qty_reject" HeaderText="Rej." ItemStyle-CssClass="text-end text-nowrap" HeaderStyle-CssClass="text-end" />
                                        <asp:BoundField DataField="slip_no" HeaderText="Ref." ItemStyle-CssClass="text-muted small" />
                                        <asp:BoundField DataField="remarks" HeaderText="Note" ItemStyle-CssClass="small text-muted" />
                                        <asp:TemplateField HeaderText="" ItemStyle-Width="88px">
                                            <ItemTemplate>
                                                <asp:LinkButton runat="server" CommandName="delrethist" CssClass="btn btn-sm btn-outline-danger py-0" CommandArgument='<%# Eval("jobwork_return_id") %>'
                                                    OnClientClick="return confirm('Reverse this return?');" Text="Reverse"></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer jw-ret-foot d-flex flex-wrap align-items-center justify-content-between gap-2 border-0">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btn_save_all_receive" runat="server" CssClass="btn btn-success px-4" Text="Save receive" OnClick="btn_save_all_receive_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showRecvModal() {
            var el = document.getElementById('modal_recv');
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
        }
    </script>
</asp:Content>
