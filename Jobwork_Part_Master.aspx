<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Jobwork_Part_Master.aspx.cs" Inherits="Jobwork_Part_Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">Jobwork part master</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="head" runat="Server">
    <style>
        .tbl_bottem_boder thead { background-color: #f8f9fa; color: #333; font-weight: 600; }
        .modal_form_footer { padding: 15px; border-top: 1px solid #dee2e6; display: flex; justify-content: space-between; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="body" runat="Server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="messagealert" id="alert_container"></div>

    <div class="page-breadcrumb d-sm-flex align-items-center mb-3">
        <div class="breadcrumb-title pe-3"><i class="bi bi-box-seam">&nbsp;</i>Jobwork part master</div>
        <div class="ms-auto">
            <button type="button" class="btn btn-sm btn-primary btn_add_jw" data-bs-toggle="modal" data-bs-target="#modal_jw_part">+ Add jobwork part</button>
        </div>
    </div>

    <div class="row mb-3">
        <div class="col-md-4">
            <label class="form-label">Jobwork party</label>
            <asp:DropDownList ID="ddl_filter_jobwork_party" CssClass="form-select" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddl_filter_jobwork_party_SelectedIndexChanged"></asp:DropDownList>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-4 col-sm-6">
                    <label class="form-label">Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" id="txt_jw_part_search" class="form-control" placeholder="Jobwork party, part name, unit, rate, tax..." autocomplete="off" />
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="grid_jw_part" ClientIDMode="Static" CssClass="table tbl_bottem_boder align-middle mb-0" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" OnRowCommand="grid_jw_part_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr" ItemStyle-Width="50px">
                            <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="jobwork_party_name" HeaderText="Jobwork party" />
                        <asp:BoundField DataField="part_name" HeaderText="Part name" />
                        <asp:BoundField DataField="unit_name" HeaderText="Unit" />
                        <asp:BoundField DataField="rate" HeaderText="Rate (₹)" />
                        <asp:BoundField DataField="tax_per" HeaderText="Tax (%)" />
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-3 fs-6">
                                    <asp:LinkButton CommandName="btn_edit" CommandArgument='<%# Eval("jobwork_part_id") %>' runat="server" CssClass="text-info" title="Edit">
                                        <i class="bi bi-pencil-fill"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton CommandName="btn_delete" CommandArgument='<%# Eval("jobwork_part_id") %>' runat="server" CssClass="text-danger" title="Delete" OnClientClick="return confirm('Delete this jobwork part?');">
                                        <i class="bi bi-trash-fill"></i>
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>
    </div>

    <div class="modal fade right" id="modal_jw_part" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Jobwork part</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Jobwork party</label>
                            <div class="d-flex gap-1">
                                <asp:DropDownList ID="ddl_jobwork_party" CssClass="form-select" runat="server"></asp:DropDownList>
                                <button type="button" class="btn btn-sm btn-outline-success flex-shrink-0" id="btn_quick_jw_party" title="Add new jobwork party" aria-label="Add new jobwork party">+</button>
                            </div>
                            <span id="jw_party_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Part name</label>
                            <asp:TextBox ID="txt_part_name" CssClass="form-control" runat="server"></asp:TextBox>
                            <span id="jw_name_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Unit</label>
                            <asp:DropDownList ID="ddl_unit" CssClass="form-select" runat="server"></asp:DropDownList>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Rate (₹)</label>
                            <asp:TextBox ID="txt_rate" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Tax (%)</label>
                            <asp:TextBox ID="txt_tax_per" CssClass="form-control" runat="server" Text="0"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal_form_footer">
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" style="width: 49%">Cancel</button>
                    <asp:Button ID="btn_save" runat="server" OnClick="btn_save_Click" OnClientClick="return validateJwPart();" CssClass="btn btn-primary" Style="width: 49%" Text="Submit" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="modal_quick_jw_party" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow">
                <div class="modal-header bg-success text-white">
                    <h2 class="modal-title fs-5 mb-0">New jobwork party</h2>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label">Party name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txt_quick_jw_party_name" runat="server" CssClass="form-control" placeholder="Party name"></asp:TextBox>
                            <span id="jw_quick_name_Error" class="text-danger"></span>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Contact person</label>
                            <asp:TextBox ID="txt_quick_jw_contact" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Mobile</label>
                            <asp:TextBox ID="txt_quick_jw_mobile" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">GST no</label>
                            <asp:TextBox ID="txt_quick_jw_gst" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Address</label>
                            <asp:TextBox ID="txt_quick_jw_address" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal_form_footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" style="width: 49%">Cancel</button>
                    <asp:Button ID="btn_quick_jw_party_save" runat="server" CssClass="btn btn-success" Style="width: 49%" Text="Save &amp; use party"
                        OnClick="btn_quick_jw_party_save_Click" OnClientClick="return validateQuickJwParty();" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hd_jobwork_part_id" runat="server" />
    <asp:HiddenField ID="hd_action" Value="save" runat="server" />

    <script>
        function validateJwPart() {
            var party = $("#<%= ddl_jobwork_party.ClientID%>").val();
            var name = $("#<%= txt_part_name.ClientID%>").val();
            var isValid = true;
            $("#jw_party_Error, #jw_name_Error").text("");
            if (party === "0") { $("#jw_party_Error").text("Please select jobwork party."); isValid = false; }
            if (!name || name.trim() === "") { $("#jw_name_Error").text("Part name required."); isValid = false; }
            return isValid;
        }
        function filterJwPartGrid() {
            var value = $("#txt_jw_part_search").val().toLowerCase().trim();
            $("#grid_jw_part tr:has(td)").each(function () {
                var text = $(this).text().toLowerCase();
                $(this).toggle(value === "" || text.indexOf(value) > -1);
            });
        }

        $(document).ready(function () {
            $("#txt_jw_part_search").on("keyup input", filterJwPartGrid);
            filterJwPartGrid();

            $(".btn_add_jw").click(function () {
                $("#<%= hd_action.ClientID%>").val("save");
                $("#<%= txt_part_name.ClientID%>, #<%= txt_rate.ClientID%>, #<%= txt_tax_per.ClientID%>").val("");
                $("#<%= txt_tax_per.ClientID%>").val("0");
                $("#<%= ddl_jobwork_party.ClientID%>, #<%= ddl_unit.ClientID%>").val("0");
            });

            $("#btn_quick_jw_party").click(function () { openQuickJwPartyModal(); });
            $("#modal_quick_jw_party").on("hidden.bs.modal", function () { showJwModal(); });
        });
        function showJwModal() {
            var el = document.getElementById("modal_jw_part");
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
        }
        function openQuickJwPartyModal() {
            $("#jw_quick_name_Error").text("");
            $("#<%= txt_quick_jw_party_name.ClientID %>, #<%= txt_quick_jw_contact.ClientID %>, #<%= txt_quick_jw_mobile.ClientID %>, #<%= txt_quick_jw_gst.ClientID %>, #<%= txt_quick_jw_address.ClientID %>").val("");
            var jwEl = document.getElementById("modal_jw_part");
            var jwModal = jwEl && window.bootstrap ? bootstrap.Modal.getInstance(jwEl) : null;
            if (jwModal) jwModal.hide();
            var el = document.getElementById("modal_quick_jw_party");
            if (el && window.bootstrap) new bootstrap.Modal(el).show();
            setTimeout(function () { $("#<%= txt_quick_jw_party_name.ClientID %>").trigger("focus"); }, 300);
        }
        function validateQuickJwParty() {
            var name = $("#<%= txt_quick_jw_party_name.ClientID %>").val();
            $("#jw_quick_name_Error").text("");
            if (!name || name.trim() === "") {
                $("#jw_quick_name_Error").text("Party name is required.");
                return false;
            }
            return true;
        }
    </script>
</asp:Content>
