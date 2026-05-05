<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="~/Home.aspx.cs" Inherits="Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        /* Clean dashboard (no fake tabs / no big background box) */
        .dash-topbar {
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap:14px;
            margin-bottom: 12px;
        }
        .dash-topbar .title {
            font-size: 1.1rem;
            font-weight: 900;
            color:#111827;
            margin:0;
        }
        .dash-topbar .subtitle {
            color:#6b7280;
            font-size: .92rem;
            margin-top: 2px;
        }

        .kpi-grid{
            display:grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 14px;
        }
        .kpi-grid.two{
            grid-template-columns: repeat(4, minmax(0, 1fr));
        }
        @media (max-width: 992px){
            .kpi-grid, .kpi-grid.two{ grid-template-columns: 1fr; }
        }
        .kpi-card{
            background:#fff;
            border:1px solid #e8edf5;
            border-radius: 14px;
            box-shadow: 0 10px 30px rgba(15,23,42,.06);
            padding: 14px 14px;
        }
        .kpi-card.highlight{
            border-color:#dbe3f5;
            box-shadow: 0 14px 34px rgba(15,23,42,.10);
            position: relative;
            overflow: hidden;
        }
        .kpi-card.highlight::before{
            content:'';
            position:absolute;
            left:0; top:0; right:0;
            height: 3px;
            background: linear-gradient(90deg, #2563eb 0%, #7c3aed 55%, #0ea5e9 100%);
        }
        .kpi-card.highlight .kpi-value{
            font-size: 2.05rem;
        }
        .kpi-card.highlight .kpi-menu{
            border-color:#dbe3f5;
            color:#2563eb;
            background:#f7f9ff;
        }
        .kpi-head{
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap: 10px;
            margin-bottom: 10px;
        }
        .kpi-name{
            font-size:.82rem;
            font-weight: 900;
            color:#64748b;
            text-transform: uppercase;
            letter-spacing: .08em;
        }
        .kpi-menu{
            width: 32px;
            height: 32px;
            border-radius: 10px;
            display:flex;
            align-items:center;
            justify-content:center;
            border: 1px solid #e8edf5;
            background:#fbfcff;
            color:#94a3b8;
        }
        .kpi-value{
            font-size: 1.8rem;
            font-weight: 900;
            color:#111827;
            font-variant-numeric: tabular-nums;
            line-height: 1.1;
        }
        .kpi-foot{
            margin-top: 6px;
            display:flex;
            justify-content:space-between;
            gap:10px;
            color:#64748b;
            font-weight: 800;
            font-size: .86rem;
        }
        .kpi-foot b{ color:#111827; font-weight: 900; }
        .kpi-foot{ display:none; } /* no sub-lines under cards */

        .dash-layout{
            display:grid;
            grid-template-columns: 1fr;
            gap: 16px;
            align-items:start;
        }

        .panel{
            background:#fff;
            border:1px solid #e8edf5;
            border-radius: 14px;
            box-shadow: 0 10px 30px rgba(15,23,42,.06);
        }
        .panel .ph{
            padding: 12px 14px;
            border-bottom: 1px solid #eef0f3;
            display:flex;
            align-items:center;
            justify-content:space-between;
            gap: 10px;
        }
        .panel .ph .t{
            font-weight: 900;
            color:#111827;
        }
        .panel .pb{ padding: 12px 14px; }

        .stat-list .row{
            margin:0;
        }
        .stat{
            border:1px solid #eef0f3;
            border-radius: 12px;
            padding: 11px 11px;
            background:#fff;
        }
        .stat .l{
            font-size: .78rem;
            font-weight: 900;
            letter-spacing: .08em;
            text-transform: uppercase;
            color:#64748b;
        }
        .stat .v{
            margin-top: 6px;
            font-size: 1.35rem;
            font-weight: 900;
            color:#111827;
            font-variant-numeric: tabular-nums;
        }

        /* calendar removed */

        .chart-shell{
            border-radius: 14px;
            border:1px solid #e8edf5;
            background:#fff;
            box-shadow: 0 10px 30px rgba(15,23,42,.06);
            padding: 10px 10px 6px;
        }

        .sec-title{
            margin: 10px 0 8px;
            font-size: .82rem;
            font-weight: 900;
            letter-spacing: .10em;
            text-transform: uppercase;
            color:#64748b;
        }

        .kpi-link{ display:block; text-decoration:none; color:inherit; }
        .kpi-link:hover{ text-decoration:none; color:inherit; }
        .kpi-link:focus-visible{ outline: 3px solid rgba(37,99,235,.25); outline-offset: 3px; border-radius: 14px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="container-fluid px-0">
        <div class="dash-topbar">
            <div>
                <div class="title">Dashboard</div>
            </div>
            <div class="sc-date">
                <i class="bi bi-calendar3"></i>
                <span><%= DateTime.Now.ToString("dd MMM, yyyy") %></span>
            </div>
        </div>
        <div class="sec-title">Summary</div>
        <div class="kpi-grid">
            <a class="kpi-link" href="Party_Master.aspx">
                <div class="kpi-card highlight">
                    <div class="kpi-head">
                        <div class="kpi-name">Total Party</div>
                        <div class="kpi-menu"><i class="bi bi-people"></i></div>
                    </div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_party" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Part_Master.aspx">
                <div class="kpi-card highlight">
                    <div class="kpi-head">
                        <div class="kpi-name">Total Part</div>
                        <div class="kpi-menu"><i class="bi bi-box-seam"></i></div>
                    </div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_part" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Inward_Challan_List.aspx">
                <div class="kpi-card highlight">
                    <div class="kpi-head"><div class="kpi-name">Active Challan</div><div class="kpi-menu"><i class="bi bi-receipt"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_active_challan" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Inward_Challan_List.aspx">
                <div class="kpi-card highlight">
                    <div class="kpi-head"><div class="kpi-name">Active Item (Qty)</div><div class="kpi-menu"><i class="bi bi-box-arrow-in-down"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_active_item" runat="server">0</asp:Literal></div>
                </div>
            </a>
        </div>

        <div class="sec-title">Inward</div>
        <div class="kpi-grid two">
            <a class="kpi-link" href="Inward_Challan_Report.aspx?mode=today">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">Today Received Challan</div><div class="kpi-menu"><i class="bi bi-calendar-check"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_today_challan" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Inward_Challan_Report.aspx?mode=today">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">Today Received Item (Qty)</div><div class="kpi-menu"><i class="bi bi-boxes"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_today_item" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Inward_Challan_Report.aspx">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">This Month Received Challan</div><div class="kpi-menu"><i class="bi bi-calendar2-month"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_month_challan" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Inward_Challan_Report.aspx">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">This Month Received Item (Qty)</div><div class="kpi-menu"><i class="bi bi-graph-up"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_count_month_item" runat="server">0</asp:Literal></div>
                </div>
            </a>
        </div>

        <div class="sec-title">Outward</div>
        <div class="kpi-grid two">
            <a class="kpi-link" href="Outward_History.aspx?mode=today">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">Today Outward Challan</div><div class="kpi-menu"><i class="bi bi-truck"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_out_today_challan" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Outward_History.aspx?mode=today">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">Today Outward Item (Qty)</div><div class="kpi-menu"><i class="bi bi-box-arrow-up-right"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_out_today_item" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Outward_History.aspx">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">This Month Outward Challan</div><div class="kpi-menu"><i class="bi bi-calendar2-month"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_out_month_challan" runat="server">0</asp:Literal></div>
                </div>
            </a>
            <a class="kpi-link" href="Outward_History.aspx">
                <div class="kpi-card">
                    <div class="kpi-head"><div class="kpi-name">This Month Outward Item (Qty)</div><div class="kpi-menu"><i class="bi bi-graph-down"></i></div></div>
                    <div class="kpi-value"><asp:Literal ID="lit_out_month_item" runat="server">0</asp:Literal></div>
                </div>
            </a>
        </div>

        <div class="sec-title">Last 30 days (Item IN vs Item OUT)</div>
        <div class="chart-shell">
            <div id="chart30"
                data-labels='[<%= lit_tr30_labels.Text %>]'
                data-in='[<%= lit_tr30_in.Text %>]'
                data-out='[<%= lit_tr30_out.Text %>]'
                style="height: 260px;"></div>
        </div>

        <asp:Literal ID="lit_tr30_labels" runat="server" Visible="false"></asp:Literal>
        <asp:Literal ID="lit_tr30_in" runat="server" Visible="false"></asp:Literal>
        <asp:Literal ID="lit_tr30_out" runat="server" Visible="false"></asp:Literal>
    </div>

    <script src="assets/plugins/apexcharts-bundle/js/apexcharts.min.js"></script>
    <script type="text/javascript">
        (function () {
            if (typeof ApexCharts === "undefined") return;
            // Use data-* attributes to keep JS valid for linters
            var host = document.getElementById("chart30");
            if (!host) return;
            var labels = JSON.parse(host.getAttribute("data-labels") || "[]");
            var inQty = JSON.parse(host.getAttribute("data-in") || "[]");
            var outQty = JSON.parse(host.getAttribute("data-out") || "[]");

            var el = host;

            var options = {
                series: [
                    { name: "Item IN (Qty)", type: "column", data: inQty },
                    { name: "Item OUT (Qty)", type: "line", data: outQty }
                ],
                chart: { height: 260, type: "line", toolbar: { show: false } },
                stroke: { width: [0, 3], curve: "smooth" },
                plotOptions: { bar: { columnWidth: "45%", borderRadius: 4 } },
                dataLabels: { enabled: false },
                colors: ["#2563eb", "#111827"],
                xaxis: { categories: labels, labels: { rotate: -45, style: { colors: "#6b7280" } } },
                yaxis: [
                    { labels: { style: { colors: "#6b7280" } } },
                    { opposite: true, labels: { style: { colors: "#6b7280" } } }
                ],
                grid: { borderColor: "#eef0f3" },
                tooltip: { theme: "light" },
                legend: { position: "top", horizontalAlign: "left" }
            };

            new ApexCharts(el, options).render();
        })();
    </script>

    <%-- calendar removed --%>
</asp:Content>
