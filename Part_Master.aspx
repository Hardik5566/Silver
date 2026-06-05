<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Part_Master.aspx.cs" Inherits="Part_Master" %>


<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    PART / ITEM MASTER
</asp:Content>

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
        <div class="breadcrumb-title pe-3"><i class="bx bx-box">&nbsp;</i>Part Master</div>
        <div class="ms-auto">
            <button type="button" class="btn btn-sm btn-primary btn_add" data-bs-toggle="modal" data-bs-target="#modal_part">+ Add New Part</button>
        </div>
    </div>

    <div class="row mb-3">
        <div class="col-md-4">
            <label class="form-label">Filter by Party</label>
            <asp:DropDownList ID="ddl_filter_party" CssClass="form-select" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddl_filter_party_SelectedIndexChanged"></asp:DropDownList>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="row mb-3">
                <div class="col-md-4 col-sm-6">
                    <label class="form-label">Search</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" id="txt_part_search" class="form-control" placeholder="Party, part name, unit, rate, tax..." autocomplete="off" />
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <asp:GridView ID="grid_part" ClientIDMode="Static" CssClass="table tbl_bottem_boder align-middle mb-0" runat="server" AutoGenerateColumns="false" UseAccessibleHeader="true" OnRowCommand="grid_part_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr" ItemStyle-Width="50px">
                            <ItemTemplate><%# Container.DataItemIndex+1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="party_name" HeaderText="Party" />
                        <asp:BoundField DataField="part_name" HeaderText="Part Name" />
                        <asp:BoundField DataField="unit_name" HeaderText="Unit" />
                        <asp:BoundField DataField="rate" HeaderText="Rate (₹)" />
                        <asp:BoundField DataField="tax_per" HeaderText="Tax (%)" />
                        
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-3 fs-6">
                                    <asp:LinkButton CommandName="btn_edit" CommandArgument='<%# Eval("part_id") %>' runat="server" CssClass="text-info" title="Edit">
                                        <i class="bi bi-pencil-fill"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton CommandName="btn_delete" CommandArgument='<%# Eval("part_id") %>' runat="server" CssClass="text-danger" title="Delete" OnClientClick="return confirm('Are you sure delete this part?');">
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

    <div class="modal fade right" id="modal_part" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Part Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Select Party</label>
                            <asp:DropDownList ID="ddl_party" CssClass="form-select" runat="server"></asp:DropDownList>
                            <span id="party_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Part Name</label>
                            <asp:TextBox ID="txt_part_name" CssClass="form-control" runat="server"></asp:TextBox>
                            <span id="name_Error" class="text-danger"></span>
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
                    <asp:Button ID="btn_save" runat="server" OnClick="btn_save_Click" OnClientClick="return validatePart();" CssClass="btn btn-primary" Style="width: 49%" Text="Submit" />
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hd_part_id" runat="server" />
    <asp:HiddenField ID="hd_action" Value="save" runat="server" />

    <script>
        function validatePart() {
            var party = $("#<%= ddl_party.ClientID%>").val();
            var name = $("#<%= txt_part_name.ClientID%>").val();
            var isValid = true;

            $("#party_Error, #name_Error").text("");

            if (party === "0") { $("#party_Error").text("Please select party !"); isValid = false; }
            if (name.trim() === "") { $("#name_Error").text("Part Name Required !"); isValid = false; }

            return isValid;
        }

        function filterPartGrid() {
            var value = $("#txt_part_search").val().toLowerCase().trim();
            $("#grid_part tr:has(td)").each(function () {
                var text = $(this).text().toLowerCase();
                $(this).toggle(value === "" || text.indexOf(value) > -1);
            });
        }

        $(document).ready(function () {
            $("#txt_part_search").on("keyup input", filterPartGrid);
            filterPartGrid();

            $(".btn_add").click(function () {
                $("#<%=hd_action.ClientID%>").val("save");
                $("#<%=txt_part_name.ClientID%>, #<%=txt_rate.ClientID%>, #<%=txt_tax_per.ClientID%>").val("");
                $("#<%=ddl_party.ClientID%>, #<%=ddl_unit.ClientID%>").val("0");
            });
        });

        function showModal() {
            var myModal = new bootstrap.Modal(document.getElementById('modal_part'));
            myModal.show();
        }
    </script>
</asp:Content>

