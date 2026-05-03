<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="_Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="icon" href="image/title-logo.png" type="image/png" />
    <!-- Bootstrap CSS -->
    <link href="assets/css/bootstrap.min.css" rel="stylesheet" />
    <link href="assets/css/bootstrap-extended.css" rel="stylesheet" />
    <link href="assets/css/style.css" rel="stylesheet" />
    <link href="assets/css/icons.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" />


    <title>Silver Coating :: Login</title>
</head>
<body>
    <form id="form1" runat="server">
        <!--start wrapper-->
        <div class="wrapper">

            <!--start content-->
            <div class="authentication-content">
                <div class="container-fluid">
                    <div class="authentication-card">
                        <div class="card shadow rounded-0 overflow-hidden">
                            <div class="row g-0">
                                <div class="col-lg-6 bg-login d-flex align-items-center justify-content-center" style="margin-top: 0px !important">
                                    <img src="assets/images/error/login-img.jpg" class="img-fluid" alt="">
                                </div>
                                <div class="col-lg-6" style="margin-top: 0px !important">
                                    <div class="card-body p-4 p-sm-5">
                                        <div style="text-align: center">
                                            <img src="image/thumbnail.jpg" style="width: 62%; height: auto; margin-bottom: 30px;" />
                                        </div>
                                        <h5 class="card-title text-center">Sign In</h5>
                                        <%--<p class="card-text mb-5">See your growth and get consulting support!</p>--%>
                                        <div class="form-body">

                                            <div class="row g-3">
                                                <div class="col-12">
                                                    <label for="inputEmailAddress" class="form-label">Email or Mobile No</label>
                                                    <div class="ms-auto position-relative">
                                                        <div class="position-absolute top-50 translate-middle-y search-icon px-3"><i class="bi bi-envelope-fill"></i></div>
                                                        <asp:TextBox ID="txt_email" CssClass="form-control radius-30 ps-5" placeholder="Registered email or mobile" runat="server"></asp:TextBox>
                                                    </div>
                                                </div>
                                                <div class="col-12">
                                                    <label for="inputChoosePassword" class="form-label">Enter Password</label>
                                                    <div class="ms-auto position-relative">
                                                        <div class="position-absolute top-50 translate-middle-y search-icon px-3"><i class="bi bi-lock-fill"></i></div>
                                                        <asp:TextBox ID="txt_pass" CssClass="form-control radius-30 ps-5" placeholder="Enter Password" runat="server" TextMode="Password"></asp:TextBox>

                                                    </div>
                                                </div>
                                               <%-- <div class="col-6">
                                                    <div class="form-check form-switch">
                                                        <input class="form-check-input" type="checkbox" id="flexSwitchCheckChecked" checked="">
                                                        <label class="form-check-label" for="flexSwitchCheckChecked">Remember Me</label>
                                                    </div>
                                                </div>
                                                <div class="col-6 text-end">
                                                    <a href="authentication-forgot-password.html">Forgot Password ?</a>
                                                </div>--%>
                                                <div class="col-12">
                                                    <div class="d-grid">
                                                        <asp:Button ID="btn_login" OnClick="btn_login_Click" runat="server" CssClass="btn btn-primary radius-30" Text="Sign In" />
                                                    </div>
                                                </div>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!--end page main-->

        </div>
        <!--end wrapper-->


        <!--plugins-->
        <script src="assets/js/jquery.min.js"></script>

    </form>
</body>
</html>
