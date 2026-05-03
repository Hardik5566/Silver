<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="User_Master.aspx.cs" Inherits="User_Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="title" runat="Server">
    USER MASTER
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
        <div class="breadcrumb-title pe-3"><i class="bx bx-user">&nbsp;</i>User</div>
        <div class="ms-auto">
            <button type="button" class="btn btn-sm btn-primary btn_add" data-bs-toggle="modal" data-bs-target="#modal_user">+ Add User</button>
        </div>
    </div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <asp:GridView ID="grid_user" ClientIDMode="Static" CssClass="table tbl_bottem_boder align-middle mb-0" runat="server" AutoGenerateColumns="false" OnRowCommand="grid_user_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="Sr" ItemStyle-Width="50px">
                            <ItemTemplate><%# Container.DataItemIndex+1 %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="full_name" HeaderText="Name" />
                        <asp:BoundField DataField="mobile_no" HeaderText="Mobile" />
                        <asp:BoundField DataField="email" HeaderText="Email" NullDisplayText="-" />
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="100px">
                            <ItemTemplate>
                                <div class="d-flex align-items-center gap-3 fs-6">
                                    <asp:LinkButton CommandName="btn_edit" CommandArgument='<%# Eval("user_id") %>' runat="server" CssClass="text-info" title="Edit">
                                        <i class="bi bi-pencil-fill"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton CommandName="btn_delete" CommandArgument='<%# Eval("user_id") %>' runat="server" CssClass="text-danger" title="Delete" OnClientClick="return confirm('Delete this user?');">
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

    <div class="modal fade right" id="modal_user" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">User Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Full Name</label>
                            <asp:TextBox ID="txt_full_name" CssClass="form-control" runat="server"></asp:TextBox>
                            <span id="name_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Mobile No</label>
                            <asp:TextBox ID="txt_mobile" CssClass="form-control" runat="server"></asp:TextBox>
                            <span id="mobile_Error" class="text-danger"></span>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Email <small class="text-muted">(optional)</small></label>
                            <asp:TextBox ID="txt_email" CssClass="form-control" runat="server" TextMode="Email"></asp:TextBox>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Password</label>
                            <asp:TextBox ID="txt_password" CssClass="form-control" runat="server" TextMode="Password" placeholder="Required for new user; leave blank on edit to keep"></asp:TextBox>
                            <span id="pass_Error" class="text-danger"></span>
                        </div>
                    </div>
                </div>
                <div class="modal_form_footer">
                    <button type="button" class="btn btn-danger" data-bs-dismiss="modal" style="width: 49%">Cancel</button>
                    <asp:Button ID="btn_save" runat="server" OnClick="btn_save_Click" OnClientClick="return validateUserForm();" CssClass="btn btn-primary" Style="width: 49%" Text="Submit" />
                </div>
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hd_user_id" runat="server" />
    <asp:HiddenField ID="hd_action" Value="save" runat="server" />

    <script>
        function validateUserForm() {
            $("#name_Error,#mobile_Error,#pass_Error").text("");
            var name = $("#<%= txt_full_name.ClientID%>").val();
            var mob = $("#<%= txt_mobile.ClientID%>").val();
            var pwd = $("#<%= txt_password.ClientID%>").val();
            var action = $("#<%= hd_action.ClientID%>").val();
            var ok = true;
            if (!name || name.trim() === "") {
                $("#name_Error").text("Name required");
                ok = false;
            }
            if (!mob || mob.trim() === "") {
                $("#mobile_Error").text("Mobile required");
                ok = false;
            }
            if (action === "save" && (!pwd || pwd.trim() === "")) {
                $("#pass_Error").text("Password required for new user");
                ok = false;
            }
            return ok;
        }

        $(document).ready(function () {
            $(".btn_add").click(function () {
                $("#<%=hd_action.ClientID%>").val("save");
                $("#<%=hd_user_id.ClientID%>").val("");
                $("#<%=txt_full_name.ClientID%>, #<%=txt_mobile.ClientID%>, #<%=txt_email.ClientID%>, #<%=txt_password.ClientID%>").val("");
            });
        });

        function showUserModal() {
            var myModal = new bootstrap.Modal(document.getElementById('modal_user'));
            myModal.show();
        }
    </script>
</asp:Content>
