<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="~/Home.aspx.cs" Inherits="Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        .dashboard-card {
            border: none;
            border-radius: 12px;
            background: #ffffff;
            transition: all 0.3s ease;
            border-bottom: 3px solid #dee2e6;
        }
        .dashboard-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.1) !important;
        }
        .text-label {
            font-size: 0.8rem;
            font-weight: 700;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 0.8px;
        }
        .text-value {
            font-size: 2rem;
            font-weight: 800;
            color: #2d3436;
            line-height: 1.2;
        }
        .icon-shape {
            width: 50px;
            height: 50px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
        }
        .border-party { border-bottom-color: #4e73df; } .icon-party { background: rgba(78, 115, 223, 0.1); color: #4e73df; }
        .border-part-ms { border-bottom-color: #1cc88a; } .icon-part-ms { background: rgba(28, 200, 138, 0.12); color: #1cc88a; }
        .border-unit { border-bottom-color: #f6c23e; } .icon-unit { background: rgba(246, 194, 62, 0.1); color: #f6c23e; }
        .border-user { border-bottom-color: #36b9cc; } .icon-user { background: rgba(54, 185, 204, 0.1); color: #36b9cc; }
        a.dashboard-card-link {
            display: block;
            text-decoration: none;
            color: inherit;
            height: 100%;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="row mb-4 align-items-center">
        <div class="col">
            <h4 class="fw-bold text-dark mb-0">Dashboard</h4>
            <p class="text-muted small mb-0">Party, Part, Unit, User — masters only</p>
        </div>
        <div class="col-auto">
            <div class="px-3 py-2 bg-white border rounded-3 shadow-sm">
                <small class="text-muted fw-bold d-block" style="font-size: 10px; text-transform: uppercase;">Today</small>
                <span class="fw-bold text-primary"><i class="bi bi-calendar3 me-2"></i><%= DateTime.Now.ToString("dd MMM, yyyy") %></span>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-xl-3 col-md-6">
            <a href="Party_Master.aspx" class="dashboard-card-link" title="Party master">
            <div class="card dashboard-card border-party shadow-sm h-100">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-label mb-2">Parties</div>
                            <div class="text-value"><asp:Literal ID="lit_count_party" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="icon-shape icon-party"><i class="bi bi-person-badge"></i></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <div class="col-xl-3 col-md-6">
            <a href="Part_Master.aspx" class="dashboard-card-link" title="Part master">
            <div class="card dashboard-card border-part-ms shadow-sm h-100">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-label mb-2">Parts</div>
                            <div class="text-value"><asp:Literal ID="lit_count_part" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="icon-shape icon-part-ms"><i class="bi bi-box-seam"></i></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <div class="col-xl-3 col-md-6">
            <a href="Unit_Master.aspx" class="dashboard-card-link" title="Unit master">
            <div class="card dashboard-card border-unit shadow-sm h-100">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-label mb-2">Units</div>
                            <div class="text-value"><asp:Literal ID="lit_count_unit" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="icon-shape icon-unit"><i class="bi bi-box"></i></div>
                    </div>
                </div>
            </div>
            </a>
        </div>

        <div class="col-xl-3 col-md-6">
            <a href="User_Master.aspx" class="dashboard-card-link" title="User master">
            <div class="card dashboard-card border-user shadow-sm h-100">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="text-label mb-2">Users</div>
                            <div class="text-value"><asp:Literal ID="lit_count_user" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="icon-shape icon-user"><i class="bi bi-people"></i></div>
                    </div>
                </div>
            </div>
            </a>
        </div>
    </div>
</asp:Content>
