<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="~/Home.aspx.cs" Inherits="Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        /* Completely new dashboard UI (matches the professional sample layout) */
        .sc-dash {
            --bg: #f5f7fb;
            --card: #ffffff;
            --text: #0f172a;
            --muted: #64748b;
            --border: #e8edf5;
            --shadow: 0 10px 30px rgba(15, 23, 42, 0.06);
            --shadow2: 0 8px 18px rgba(15, 23, 42, 0.07);
        }

        .sc-dash {
            background: var(--bg);
            border-radius: 16px;
            padding: 18px;
        }

        .sc-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 14px;
        }
        .sc-title {
            font-weight: 900;
            color: var(--text);
            font-size: 1.1rem;
            margin: 0;
        }
        .sc-sub {
            margin: 2px 0 0;
            color: var(--muted);
            font-size: .92rem;
        }
        .sc-date {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 10px 12px;
            box-shadow: var(--shadow2);
            color: var(--text);
            font-weight: 800;
            white-space: nowrap;
        }

        .sc-tabs {
            display: flex;
            gap: 18px;
            align-items: center;
            margin: 10px 0 14px;
            color: var(--muted);
            font-weight: 800;
            font-size: .85rem;
        }
        .sc-tab {
            padding: 6px 0;
            border-bottom: 2px solid transparent;
        }
        .sc-tab.active {
            color: var(--text);
            border-bottom-color: #111827;
        }

        .sc-grid {
            display: grid;
            grid-template-columns: 1fr 340px;
            gap: 16px;
        }
        @media (max-width: 1200px) {
            .sc-grid { grid-template-columns: 1fr; }
        }

        .sc-kpis {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 16px;
        }
        @media (max-width: 992px) {
            .sc-kpis { grid-template-columns: 1fr; }
        }

        .sc-card {
            background: var(--card);
            border: 1px solid var(--border);
            border-radius: 14px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .sc-kpi {
            padding: 14px 14px 12px;
        }
        .sc-kpi-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            margin-bottom: 10px;
        }
        .sc-kpi-name {
            font-size: .82rem;
            font-weight: 900;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: .08em;
        }
        .sc-kpi-menu {
            width: 32px;
            height: 32px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border);
            background: #fbfcff;
            color: #94a3b8;
        }
        .sc-kpi-main {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 14px;
        }
        .sc-kpi-value {
            font-size: 1.75rem;
            font-weight: 900;
            color: var(--text);
            line-height: 1.1;
            font-variant-numeric: tabular-nums;
        }
        .sc-kpi-meta {
            display: flex;
            gap: 12px;
            align-items: baseline;
            color: var(--muted);
            font-weight: 800;
        }
        .sc-kpi-meta span { white-space: nowrap; }
        .sc-kpi-meta b { color: var(--text); font-weight: 900; font-variant-numeric: tabular-nums; }

        .sc-overview {
            padding: 14px;
        }
        .sc-overview-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 12px;
        }
        .sc-overview-title {
            font-weight: 900;
            color: var(--text);
        }
        .sc-pill {
            font-size: .78rem;
            font-weight: 900;
            color: var(--muted);
            border: 1px solid var(--border);
            background: #fbfcff;
            padding: 7px 10px;
            border-radius: 999px;
            white-space: nowrap;
        }

        .sc-mini {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        @media (max-width: 768px) {
            .sc-mini { grid-template-columns: 1fr; }
        }
        .sc-mini-item {
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 12px 12px;
            background: #fff;
        }
        .sc-mini-label {
            font-size: .78rem;
            font-weight: 900;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: .08em;
        }
        .sc-mini-value {
            margin-top: 6px;
            font-weight: 900;
            color: var(--text);
            font-size: 1.25rem;
            font-variant-numeric: tabular-nums;
        }

        .sc-right {
            display: grid;
            gap: 14px;
            align-content: start;
        }
        .sc-right-card {
            padding: 14px;
        }
        .sc-right-title {
            font-weight: 900;
            color: var(--text);
            margin-bottom: 12px;
        }
        .sc-statline {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 10px 10px;
            border: 1px solid var(--border);
            border-radius: 12px;
            margin-bottom: 10px;
            background: #fff;
        }
        .sc-statline:last-child { margin-bottom: 0; }
        .sc-statline .l {
            font-size: .78rem;
            font-weight: 900;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: .08em;
        }
        .sc-statline .v {
            font-weight: 900;
            color: var(--text);
            font-variant-numeric: tabular-nums;
        }

        a.sc-link { text-decoration: none; color: inherit; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="sc-dash">
        <div class="sc-top">
            <div>
                <div class="sc-title">Dashboard</div>
                <div class="sc-sub">Counts summary (masters and inward)</div>
            </div>
            <div class="sc-date">
                <i class="bi bi-calendar3"></i>
                <span><%= DateTime.Now.ToString("dd MMM, yyyy") %></span>
            </div>
        </div>

        <div class="sc-tabs">
            <div class="sc-tab">Last 24 hours</div>
            <div class="sc-tab active">Last weeks</div>
            <div class="sc-tab">Last months</div>
            <div class="sc-tab">Last years</div>
        </div>

        <div class="sc-grid">
            <div>
                <div class="sc-kpis">
                    <a class="sc-link" href="Party_Master.aspx" title="Total Party">
                        <div class="sc-card">
                            <div class="sc-kpi">
                                <div class="sc-kpi-head">
                                    <div class="sc-kpi-name">Total Party</div>
                                    <div class="sc-kpi-menu"><i class="bi bi-three-dots"></i></div>
                                </div>
                                <div class="sc-kpi-main">
                                    <div class="sc-kpi-value"><asp:Literal ID="lit_count_party" runat="server">0</asp:Literal></div>
                                    <div class="sc-kpi-meta"><span>Masters</span></div>
                                </div>
                            </div>
                        </div>
                    </a>

                    <a class="sc-link" href="Part_Master.aspx" title="Total Part">
                        <div class="sc-card">
                            <div class="sc-kpi">
                                <div class="sc-kpi-head">
                                    <div class="sc-kpi-name">Total Part</div>
                                    <div class="sc-kpi-menu"><i class="bi bi-three-dots"></i></div>
                                </div>
                                <div class="sc-kpi-main">
                                    <div class="sc-kpi-value"><asp:Literal ID="lit_count_part" runat="server">0</asp:Literal></div>
                                    <div class="sc-kpi-meta"><span>Masters</span></div>
                                </div>
                            </div>
                        </div>
                    </a>

                    <a class="sc-link" href="Inward_Challan_List.aspx" title="Active inward">
                        <div class="sc-card">
                            <div class="sc-kpi">
                                <div class="sc-kpi-head">
                                    <div class="sc-kpi-name">Active inward</div>
                                    <div class="sc-kpi-menu"><i class="bi bi-three-dots"></i></div>
                                </div>
                                <div class="sc-kpi-main">
                                    <div class="sc-kpi-value"><asp:Literal ID="lit_count_active_challan" runat="server">0</asp:Literal></div>
                                    <div class="sc-kpi-meta"><span>Qty <b><asp:Literal ID="lit_count_active_item" runat="server">0</asp:Literal></b></span></div>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>

                <div class="sc-card">
                    <div class="sc-overview">
                        <div class="sc-overview-head">
                            <div class="sc-overview-title">Overview</div>
                            <div class="sc-pill">Counts only</div>
                        </div>
                        <div class="sc-mini">
                            <div class="sc-mini-item">
                                <div class="sc-mini-label">Today challan</div>
                                <div class="sc-mini-value"><asp:Literal ID="lit_count_today_challan" runat="server">0</asp:Literal></div>
                            </div>
                            <div class="sc-mini-item">
                                <div class="sc-mini-label">Today qty received</div>
                                <div class="sc-mini-value"><asp:Literal ID="lit_count_today_item" runat="server">0</asp:Literal></div>
                            </div>
                            <div class="sc-mini-item">
                                <div class="sc-mini-label">This month challan</div>
                                <div class="sc-mini-value"><asp:Literal ID="lit_count_month_challan" runat="server">0</asp:Literal></div>
                            </div>
                            <div class="sc-mini-item">
                                <div class="sc-mini-label">This month qty received</div>
                                <div class="sc-mini-value"><asp:Literal ID="lit_count_month_item" runat="server">0</asp:Literal></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="sc-right">
                <div class="sc-card">
                    <div class="sc-right-card">
                        <div class="sc-right-title">Today</div>
                        <div class="sc-statline">
                            <div class="l">Day</div>
                            <div class="v"><%= DateTime.Now.ToString("dddd") %></div>
                        </div>
                        <div class="sc-statline">
                            <div class="l">Date</div>
                            <div class="v"><%= DateTime.Now.ToString("dd MMM yyyy") %></div>
                        </div>
                    </div>
                </div>

                <div class="sc-card">
                    <div class="sc-right-card">
                        <div class="sc-right-title">Quick stats</div>
                        <div class="sc-statline">
                            <div class="l">Month challan</div>
                            <div class="v"><asp:Literal ID="lit_count_month_challan2" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="sc-statline">
                            <div class="l">Month qty</div>
                            <div class="v"><asp:Literal ID="lit_count_month_item2" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="sc-statline">
                            <div class="l">Today challan</div>
                            <div class="v"><asp:Literal ID="lit_count_today_challan2" runat="server">0</asp:Literal></div>
                        </div>
                        <div class="sc-statline">
                            <div class="l">Today qty</div>
                            <div class="v"><asp:Literal ID="lit_count_today_item2" runat="server">0</asp:Literal></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
