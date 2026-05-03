<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="Party_Master.aspx.cs" Inherits="Party_Master" %>


<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    PARTY MASTER
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
        <div class="breadcrumb-title pe-3"><i class="bx bx-group">&nbsp;</i>Party</div>
        <div class="ms-auto">
            <button type="button" class="btn btn-sm btn-primary btn_add" data-bs-toggle="modal" data-bs-target="#modal_party">+ Add New Party</button>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="grid_party" ClientIDMode="Static" CssClass="table tbl_bottem_boder align-middle mb-0" runat="server" AutoGenerateColumns="false" OnRowCommand="grid_party_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr" ItemStyle-Width="50px">
                            <ItemTemplate><%# Container.DataItemIndex+1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="party_name" HeaderText="Party Name" />
                        <asp:BoundField DataField="contact_person" HeaderText="Contact Person" />
                        <asp:BoundField DataField="mobile_no" HeaderText="Mobile" />
                        <asp:BoundField DataField="gst_no" HeaderText="GST No" />
                        
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-3 fs-6">
                                    <asp:LinkButton CommandName="btn_edit" CommandArgument='<%# Eval("party_id") %>' runat="server" CssClass="text-info" title="Edit">
                                        <i class="bi bi-pencil-fill"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton CommandName="btn_delete" CommandArgument='<%# Eval("party_id") %>' runat="server" CssClass="text-danger" title="Delete" OnClientClick="return confirm('Are you sure delete this party?');">
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

    <div class="modal fade right" id="modal_party" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Party Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Party Name</label>
                            <asp:TextBox ID="txt_party_name" CssClass="form-control" runat="server"></asp:TextBox>
                            <span id="name_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Contact Person</label>
                            <asp:TextBox ID="txt_contact" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Mobile</label>
                            <asp:TextBox ID="txt_mobile" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">GST No</label>
                            <asp:TextBox ID="txt_gst" CssClass="form-control" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Address</label>
                            <asp:TextBox ID="txt_address" CssClass="form-control" TextMode="MultiLine" Rows="2" runat="server"></asp:TextBox>
                        </div>
                    </div>
                </div>
                <div class="modal_form_footer">
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" style="width: 49%">Cancel</button>
                    <asp:Button ID="btn_save" runat="server" OnClick="btn_save_Click" OnClientClick="return validateForm();" CssClass="btn btn-primary" Style="width: 49%" Text="Submit" />
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hd_party_id" runat="server" />
    <asp:HiddenField ID="hd_action" Value="save" runat="server" />

    <script>
        function validateForm() {
            var name = $("#<%= txt_party_name.ClientID%>").val();
            if (name.trim() === "") {
                $("#name_Error").text("Required this !");
                return false;
            }
            return true;
        }

        $(document).ready(function () {
            $(".btn_add").click(function () {
                $("#<%=hd_action.ClientID%>").val("save");
                $("#<%=txt_party_name.ClientID%>, #<%=txt_contact.ClientID%>, #<%=txt_mobile.ClientID%>, #<%=txt_gst.ClientID%>, #<%=txt_address.ClientID%>").val("");
            });
        });

        function showModal() {
            var myModal = new bootstrap.Modal(document.getElementById('modal_party'));
            myModal.show();
        }
    </script>
</asp:Content>