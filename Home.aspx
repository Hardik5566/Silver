<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="~/Home.aspx.cs" Inherits="Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <style>
        :root {
            --dash-bg: linear-gradient(160deg, #eef2ff 0%, #f8fafc 35%, #ecfdf5 100%);
            --dash-surface: #ffffff;
            --dash-master: #475569;
            --dash-in: #2563eb;
            --dash-in-soft: #eff6ff;
            --dash-out: #ea580c;
            --dash-out-soft: #fff7ed;
            --dash-jw-out: #7c3aed;
            --dash-jw-out-soft: #f5f3ff;
            --dash-jw-in: #059669;
            --dash-jw-in-soft: #ecfdf5;
            --dash-text: #0f172a;
            --dash-muted: #64748b;
            --dash-radius: 16px;
            --dash-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.07), 0 12px 24px -4px rgba(15, 23, 42, 0.08);
            --dash-shadow-hover: 0 8px 16px -4px rgba(15, 23, 42, 0.12), 0 20px 40px -8px rgba(15, 23, 42, 0.14);
        }

        /* Edge-to-edge within main content (cancel .page-content horizontal padding) */
        .dash-wrap {
            background: var(--dash-bg);
            margin-left: -1.5rem;
            margin-right: -1.5rem;
            padding: 1.5rem 1.5rem 2.25rem !important;
            min-height: calc(100vh - 72px);
            width: auto;
        }

        .dash-top {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-end;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 1.5rem;
        }
        .dash-top h1 {
            font-size: clamp(1.35rem, 2.5vw, 1.65rem);
            font-weight: 800;
            color: var(--dash-text);
            letter-spacing: -0.02em;
            margin: 0;
        }
        .dash-top .sub { color: var(--dash-muted); font-size: .9rem; margin: .25rem 0 0; }
        .dash-top .date-pill {
            background: var(--dash-surface);
            border: 1px solid rgba(148, 163, 184, 0.35);
            border-radius: 999px;
            padding: .45rem 1rem;
            font-size: .85rem;
            font-weight: 600;
            color: var(--dash-muted);
            box-shadow: var(--dash-shadow);
        }

        .dash-sec {
            margin-bottom: 1.75rem;
        }
        .dash-sec-head {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 10px;
            margin-bottom: 1rem;
        }
        .dash-sec-head .tag {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            font-size: .72rem;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .1em;
            padding: .35rem .75rem;
            border-radius: 8px;
            color: #fff;
        }
        .dash-sec-head .tag--master { background: linear-gradient(135deg, #64748b, #475569); }
        .dash-sec-head .tag--in { background: linear-gradient(135deg, #3b82f6, #2563eb); }
        .dash-sec-head .tag--out { background: linear-gradient(135deg, #fb923c, #ea580c); }
        .dash-sec-head .tag--jw { background: linear-gradient(135deg, #a78bfa, #7c3aed); }
        .dash-sec-head .tag--jw-in { background: linear-gradient(135deg, #34d399, #059669); }
        .dash-sec-head h2 {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--dash-text);
            margin: 0;
        }

        .dash-grid {
            display: grid;
            gap: 1rem;
            grid-template-columns: repeat(2, 1fr);
        }
        @media (min-width: 576px) {
            .dash-grid.cols-4 { grid-template-columns: repeat(4, 1fr); }
        }
        @media (min-width: 768px) {
            .dash-grid.cols-2 { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 575px) {
            .dash-grid.cols-4 { grid-template-columns: 1fr; }
        }

        .dash-card {
            display: block;
            background: var(--dash-surface);
            border-radius: var(--dash-radius);
            box-shadow: var(--dash-shadow);
            text-decoration: none !important;
            color: inherit !important;
            overflow: hidden;
            transition: transform .18s ease, box-shadow .18s ease;
            border: 1px solid rgba(148, 163, 184, 0.2);
            height: 100%;
        }
        .dash-card:hover {
            transform: translateY(-3px);
            box-shadow: var(--dash-shadow-hover);
        }
        .dash-card__bar { height: 4px; width: 100%; }
        .dash-card__bar--master { background: linear-gradient(90deg, #94a3b8, #475569); }
        .dash-card__bar--in { background: linear-gradient(90deg, #60a5fa, #2563eb); }
        .dash-card__bar--out { background: linear-gradient(90deg, #fb923c, #ea580c); }
        .dash-card__bar--jw-out { background: linear-gradient(90deg, #a78bfa, #7c3aed); }
        .dash-card__bar--jw-in { background: linear-gradient(90deg, #34d399, #059669); }

        .dash-card__inner {
            padding: 1rem 1.1rem 1.15rem;
        }
        .dash-card__label {
            font-size: .78rem;
            font-weight: 700;
            color: var(--dash-muted);
            line-height: 1.35;
            margin-bottom: .5rem;
        }
        .dash-card__value {
            font-size: clamp(1.65rem, 4vw, 2.15rem);
            font-weight: 800;
            color: var(--dash-text);
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.02em;
            line-height: 1.1;
        }
        .dash-card--tint-master .dash-card__inner { background: linear-gradient(180deg, #f8fafc 0%, #fff 100%); }
        .dash-card--tint-in .dash-card__inner { background: linear-gradient(180deg, var(--dash-in-soft) 0%, #fff 55%); }
        .dash-card--tint-out .dash-card__inner { background: linear-gradient(180deg, var(--dash-out-soft) 0%, #fff 55%); }
        .dash-card--tint-jw-out .dash-card__inner { background: linear-gradient(180deg, var(--dash-jw-out-soft) 0%, #fff 55%); }
        .dash-card--tint-jw-in .dash-card__inner { background: linear-gradient(180deg, var(--dash-jw-in-soft) 0%, #fff 55%); }

        .dash-subrow {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 8px;
            margin: -.25rem 0 1rem;
        }
        .dash-subrow span {
            font-size: .8rem;
            font-weight: 700;
            color: var(--dash-muted);
            text-transform: uppercase;
            letter-spacing: .06em;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="dash-wrap container-fluid">
        <div class="dash-top">
            <div>
                <h1>Dashboard</h1>
            </div>
            <div class="date-pill"><i class="bi bi-calendar3 me-2"></i><%= DateTime.Now.ToString("dddd, dd MMM yyyy") %></div>
        </div>

        <section class="dash-sec" aria-label="Party and parts">
            <div class="dash-sec-head">
                <span class="tag tag--master"><i class="bi bi-database"></i> Master</span>
                <h2>Party &amp; parts</h2>
            </div>
            <div class="dash-grid cols-2">
                <a href="Party_Master.aspx" class="dash-card dash-card--tint-master">
                    <div class="dash-card__bar dash-card__bar--master"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Total party</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_count_party" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Part_Master.aspx" class="dash-card dash-card--tint-master">
                    <div class="dash-card__bar dash-card__bar--master"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Total part</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_count_part" runat="server">0</asp:Literal></div>
                    </div>
                </a>
            </div>
        </section>

        <section class="dash-sec" aria-label="Inward">
            <div class="dash-sec-head">
                <span class="tag tag--in"><i class="bi bi-arrow-down-circle"></i> In</span>
                <h2>Inward</h2>
            </div>
            <div class="dash-grid cols-4">
                <a href="Inward_Challan_List.aspx" class="dash-card dash-card--tint-in">
                    <div class="dash-card__bar dash-card__bar--in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Active challan</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_count_active_challan" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Inward_Challan_List.aspx" class="dash-card dash-card--tint-in">
                    <div class="dash-card__bar dash-card__bar--in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Active qty</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_count_active_item" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Inward_Challan_Report.aspx?mode=today" class="dash-card dash-card--tint-in">
                    <div class="dash-card__bar dash-card__bar--in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Today receive qty</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_in_today_item" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Inward_Challan_Report.aspx" class="dash-card dash-card--tint-in">
                    <div class="dash-card__bar dash-card__bar--in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">This month receive qty</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_in_month_item" runat="server">0</asp:Literal></div>
                    </div>
                </a>
            </div>
        </section>

        <section class="dash-sec" aria-label="Outward">
            <div class="dash-sec-head">
                <span class="tag tag--out"><i class="bi bi-arrow-up-right-circle"></i> Out</span>
                <h2>Outward</h2>
            </div>
            <div class="dash-grid cols-2">
                <a href="Outward_History.aspx?mode=today" class="dash-card dash-card--tint-out">
                    <div class="dash-card__bar dash-card__bar--out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Today out</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_out_today_item" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Outward_History.aspx" class="dash-card dash-card--tint-out">
                    <div class="dash-card__bar dash-card__bar--out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">This month out</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_out_month_item" runat="server">0</asp:Literal></div>
                    </div>
                </a>
            </div>
        </section>

        <section class="dash-sec" aria-label="Jobwork">
            <div class="dash-sec-head">
                <span class="tag tag--jw"><i class="bi bi-briefcase"></i> Jobwork</span>
                <h2>Jobwork</h2>
            </div>
            <div class="dash-subrow"><span>Out — sent for jobwork</span></div>
            <div class="dash-grid cols-4">
                <a href="Jobwork_Challan_List.aspx" class="dash-card dash-card--tint-jw-out">
                    <div class="dash-card__bar dash-card__bar--jw-out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Active outward challan</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_active_challan" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Jobwork_Challan_List.aspx" class="dash-card dash-card--tint-jw-out">
                    <div class="dash-card__bar dash-card__bar--jw-out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Active outward item</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_pending_qty" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Jobwork_Challan_Report.aspx?mode=today" class="dash-card dash-card--tint-jw-out">
                    <div class="dash-card__bar dash-card__bar--jw-out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Today send challan</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_today_challan" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Jobwork_Challan_Report.aspx?mode=today" class="dash-card dash-card--tint-jw-out">
                    <div class="dash-card__bar dash-card__bar--jw-out"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Today send qty</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_today_sent_qty" runat="server">0</asp:Literal></div>
                    </div>
                </a>
            </div>
            <div class="dash-subrow mt-3"><span>In — received from jobwork</span></div>
            <div class="dash-grid cols-2">
                <a href="Jobwork_Receive_History.aspx?mode=today" class="dash-card dash-card--tint-jw-in">
                    <div class="dash-card__bar dash-card__bar--jw-in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">Today receive</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_today_recv_qty" runat="server">0</asp:Literal></div>
                    </div>
                </a>
                <a href="Jobwork_Receive_History.aspx" class="dash-card dash-card--tint-jw-in">
                    <div class="dash-card__bar dash-card__bar--jw-in"></div>
                    <div class="dash-card__inner">
                        <div class="dash-card__label">This month receive</div>
                        <div class="dash-card__value"><asp:Literal ID="lit_jw_month_recv_qty" runat="server">0</asp:Literal></div>
                    </div>
                </a>
            </div>
        </section>
    </div>
</asp:Content>
