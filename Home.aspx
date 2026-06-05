<%@ Page Title="" Language="C#" MasterPageFile="~/MasterPage.master" AutoEventWireup="true" CodeFile="~/Home.aspx.cs" Inherits="Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="Server">
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
    <style>
        .dash-premium {
            --dash-font: "Inter", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            --dash-violet: #7c3aed;
            --dash-blue: #3b82f6;
            --dash-teal: #14b8a6;
            --dash-pink: #ec4899;
            --dash-amber: #f59e0b;
            --dash-slate: #0f172a;
            --dash-muted: #64748b;
            --dash-line: rgba(148, 163, 184, 0.22);

            font-family: var(--dash-font);
            margin: -1.5rem -1.5rem -2.5rem -1.5rem;
            min-height: calc(100vh - 60px);
            width: auto;
            background: linear-gradient(165deg, #f3f0ff 0%, #f0f4ff 38%, #f5f3f7 72%, #f8fafc 100%);
            padding: 1.5rem 1.5rem 2.25rem;
            box-sizing: border-box;
        }
        @media (min-width: 992px) {
            .dash-premium { padding: 1.75rem 2rem 2.5rem; }
        }

        .dash-premium__top { margin-bottom: 1.5rem; }
        .dash-premium__eyebrow {
            font-size: 0.68rem;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            color: #94a3b8;
            margin: 0 0 0.35rem;
        }
        .dash-premium__title {
            font-size: clamp(1.5rem, 2.8vw, 1.95rem);
            font-weight: 800;
            letter-spacing: -0.04em;
            color: var(--dash-slate);
            margin: 0 0 0.35rem;
            line-height: 1.15;
        }
        .dash-premium__meta {
            font-size: 0.875rem;
            font-weight: 500;
            color: var(--dash-muted);
            margin: 0;
        }

        .dash-premium__grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 1.25rem;
            align-items: stretch;
        }
        @media (min-width: 480px) and (max-width: 1023px) {
            .dash-premium__grid { grid-template-columns: repeat(2, 1fr); }
            .dash-masters-heading,
            .dash-span-12,
            .dash-span-6 {
                grid-column: 1 / -1;
            }
            .dash-top-card { grid-column: auto; }
        }
        @media (min-width: 1024px) {
            .dash-premium__grid {
                grid-template-columns: repeat(12, 1fr);
                gap: 1.35rem;
            }
        }

        .dash-span-6, .dash-span-12 {
            grid-column: 1 / -1;
        }
        @media (min-width: 1024px) {
            .dash-span-6 { grid-column: span 6; }
            .dash-span-12 { grid-column: span 12; }
        }

        /* —— 4 master cards, one row on desktop —— */
        .dash-masters-heading {
            grid-column: 1 / -1;
            margin-bottom: -0.35rem;
        }
        .dash-masters-heading__title {
            font-size: 1.05rem;
            font-weight: 700;
            letter-spacing: -0.02em;
            color: var(--dash-slate);
            margin: 0.15rem 0 0;
        }

        .dash-top-card {
            grid-column: 1 / -1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            gap: 0.45rem;
            padding: 1.35rem 1.45rem;
            min-height: 6rem;
            height: 100%;
            box-sizing: border-box;
            align-self: stretch;
            border-radius: 20px;
            text-decoration: none !important;
            color: inherit !important;
            position: relative;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.82);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.95);
            box-shadow:
                0 1px 2px rgba(99, 102, 241, 0.05),
                0 8px 28px rgba(99, 102, 241, 0.08),
                0 2px 8px rgba(15, 23, 42, 0.04);
            transition: transform 0.16s ease, box-shadow 0.16s ease;
        }
        .dash-top-card:hover {
            transform: translateY(-2px);
            box-shadow:
                0 12px 36px rgba(99, 102, 241, 0.12),
                0 4px 12px rgba(15, 23, 42, 0.06);
        }
        .dash-top-card::before {
            content: "";
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 4px;
            border-radius: 20px 20px 0 0;
        }
        .dash-top-card--violet::before { background: linear-gradient(90deg, #a78bfa, var(--dash-violet)); }
        .dash-top-card--pink::before { background: linear-gradient(90deg, #f472b6, var(--dash-pink)); }
        .dash-top-card--blue::before { background: linear-gradient(90deg, #60a5fa, var(--dash-blue)); }
        .dash-top-card--teal::before { background: linear-gradient(90deg, #2dd4bf, var(--dash-teal)); }
        .dash-top-card--amber::before { background: linear-gradient(90deg, #fbbf24, var(--dash-amber)); }
        .dash-top-card--rose::before { background: linear-gradient(90deg, #fb7185, #e11d48); }

        .dash-top-card__label {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--dash-muted);
        }
        .dash-top-card__value {
            font-size: clamp(1.65rem, 3.5vw, 2rem);
            font-weight: 800;
            color: var(--dash-slate);
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.04em;
            line-height: 1.05;
        }

        @media (min-width: 1024px) {
            .dash-top-card { grid-column: span 3; }
            .dash-top-card.dash-span-6 { grid-column: span 6; }
        }

        .dash-glass {
            background: rgba(255, 255, 255, 0.78);
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow:
                0 1px 2px rgba(99, 102, 241, 0.04),
                0 8px 32px rgba(99, 102, 241, 0.07),
                0 2px 8px rgba(15, 23, 42, 0.04);
            padding: 1.35rem 1.4rem 1.45rem;
            display: flex;
            flex-direction: column;
            min-height: 0;
        }
        @media (min-width: 992px) {
            .dash-glass { padding: 1.5rem 1.6rem 1.6rem; }
        }

        .dash-glass__head {
            display: flex;
            flex-wrap: wrap;
            align-items: flex-start;
            justify-content: space-between;
            gap: 0.65rem 1rem;
            margin-bottom: 1.1rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--dash-line);
        }
        .dash-glass__title {
            font-size: 1rem;
            font-weight: 700;
            letter-spacing: -0.02em;
            color: var(--dash-slate);
            margin: 0;
        }
        .dash-glass__sub {
            font-size: 0.78rem;
            font-weight: 600;
            color: var(--dash-muted);
            margin: 0.35rem 0 0;
        }
        .dash-glass__link {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--dash-violet);
            text-decoration: none;
            white-space: nowrap;
            padding: 0.35rem 0;
        }
        .dash-glass__link:hover {
            color: #5b21b6;
            text-decoration: underline;
        }

        .dash-kpi-grid {
            display: grid;
            gap: 0.75rem;
            grid-template-columns: 1fr;
        }
        .dash-kpi-grid.cols-2 {
            grid-template-columns: 1fr;
        }
        @media (min-width: 480px) {
            .dash-kpi-grid.cols-2 { grid-template-columns: repeat(2, 1fr); }
        }

        .dash-kpi {
            display: flex;
            align-items: center;
            gap: 0.9rem;
            padding: 1rem 1.05rem;
            border-radius: 14px;
            background: rgba(255, 255, 255, 0.65);
            border: 1px solid rgba(241, 245, 249, 0.95);
            text-decoration: none !important;
            color: inherit !important;
            transition: transform 0.16s ease, box-shadow 0.16s ease, border-color 0.16s ease;
            min-height: 4.5rem;
        }
        .dash-kpi:hover {
            transform: translateY(-2px);
            border-color: rgba(167, 139, 250, 0.35);
            box-shadow: 0 10px 28px rgba(99, 102, 241, 0.1);
        }

        .dash-kpi__accent {
            width: 9px;
            align-self: stretch;
            min-height: 2.75rem;
            border-radius: 6px;
            flex-shrink: 0;
        }
        .dash-kpi__accent--violet { background: linear-gradient(180deg, #a78bfa, var(--dash-violet)); }
        .dash-kpi__accent--pink { background: linear-gradient(180deg, #f472b6, var(--dash-pink)); }
        .dash-kpi__accent--teal { background: linear-gradient(180deg, #2dd4bf, var(--dash-teal)); }
        .dash-kpi__accent--blue { background: linear-gradient(180deg, #60a5fa, var(--dash-blue)); }
        .dash-kpi__accent--amber { background: linear-gradient(180deg, #fbbf24, var(--dash-amber)); }

        .dash-kpi__body {
            display: flex;
            flex-direction: column;
            gap: 0.2rem;
            min-width: 0;
        }
        .dash-kpi__value {
            font-size: clamp(1.35rem, 2.5vw, 1.65rem);
            font-weight: 800;
            color: var(--dash-slate);
            font-variant-numeric: tabular-nums;
            letter-spacing: -0.03em;
            line-height: 1.1;
        }
        .dash-kpi__label {
            font-size: 0.75rem;
            font-weight: 600;
            color: var(--dash-muted);
            line-height: 1.35;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="body" runat="Server">
    <div class="dash-premium">
        <header class="dash-premium__top">
            <p class="dash-premium__eyebrow">Overview</p>
            <h1 class="dash-premium__title">Dashboard</h1>
        </header>

        <div class="dash-premium__grid">
            <%-- Row 1: four masters, same row on desktop --%>
            <div class="dash-masters-heading">
                <p class="dash-premium__eyebrow">Master data</p>
                <h2 class="dash-masters-heading__title">Parts &amp; party</h2>
            </div>

            <a href="Party_Master.aspx" class="dash-top-card dash-top-card--violet">
                <span class="dash-top-card__label">Party</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_count_party" runat="server">0</asp:Literal></span>
            </a>
            <a href="Part_Master.aspx" class="dash-top-card dash-top-card--pink">
                <span class="dash-top-card__label">Part</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_count_part" runat="server">0</asp:Literal></span>
            </a>
            <a href="Jobwork_Party_Master.aspx" class="dash-top-card dash-top-card--blue">
                <span class="dash-top-card__label">Jobwork party</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_count_jobwork_party" runat="server">0</asp:Literal></span>
            </a>
            <a href="Jobwork_Part_Master.aspx" class="dash-top-card dash-top-card--teal">
                <span class="dash-top-card__label">Jobwork part</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_count_jobwork_part" runat="server">0</asp:Literal></span>
            </a>

            <div class="dash-masters-heading">
                <p class="dash-premium__eyebrow">Accounts</p>
                <h2 class="dash-masters-heading__title">Ledger summary</h2>
            </div>

            <a href="Account_Outstanding.aspx?account_type=PARTY" class="dash-top-card dash-top-card--amber dash-span-6">
                <span class="dash-top-card__label">Total debit money (party)</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_total_debit" runat="server">₹0.00</asp:Literal></span>
            </a>
            <a href="Account_Outstanding.aspx?account_type=JOBWORK" class="dash-top-card dash-top-card--rose dash-span-6">
                <span class="dash-top-card__label">Total credit money (jobwork)</span>
                <span class="dash-top-card__value"><asp:Literal ID="lit_total_credit" runat="server">₹0.00</asp:Literal></span>
            </a>

            <%-- Row 2: two parent cards side by side --%>
            <section class="dash-glass dash-span-6" aria-label="Active party challan">
                <div class="dash-glass__head">
                    <div>
                        <h2 class="dash-glass__title">Active party challan</h2>
                    </div>
                    <a class="dash-glass__link" href="Inward_Challan_List.aspx">View all</a>
                </div>
                <div class="dash-kpi-grid cols-2">
                    <a href="Inward_Challan_List.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--blue" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_count_active_challan" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Active challan</span>
                        </div>
                    </a>
                    <a href="Inward_Challan_List.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--violet" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_count_active_item" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Active qty</span>
                        </div>
                    </a>
                </div>
            </section>

            <section class="dash-glass dash-span-6" aria-label="Active jobwork">
                <div class="dash-glass__head">
                    <div>
                        <h2 class="dash-glass__title">Active job challan</h2>
                    </div>
                    <a class="dash-glass__link" href="Jobwork_Challan_List.aspx">View all</a>
                </div>
                <div class="dash-kpi-grid cols-2">
                    <a href="Jobwork_Challan_List.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--violet" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_jw_active_challan" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Active challan</span>
                        </div>
                    </a>
                    <a href="Jobwork_Challan_List.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--blue" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_jw_pending_qty" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Active qty</span>
                        </div>
                    </a>
                </div>
            </section>

            <%-- Row 3: same card style as row 2 — two separate parent cards --%>
            <section class="dash-glass dash-span-6" aria-label="Party outward">
                <div class="dash-glass__head">
                    <div>
                        <h2 class="dash-glass__title">Party outward</h2>
                    </div>
                    <a class="dash-glass__link" href="Outward_History.aspx">View all</a>
                </div>
                <div class="dash-kpi-grid cols-2">
                    <a href="Outward_History.aspx?mode=today" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--teal" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_out_today_item" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Today outward</span>
                        </div>
                    </a>
                    <a href="Outward_History.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--amber" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_out_month_item" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">This month outward</span>
                        </div>
                    </a>
                </div>
            </section>

            <section class="dash-glass dash-span-6" aria-label="Jobwork inward">
                <div class="dash-glass__head">
                    <div>
                        <h2 class="dash-glass__title">Jobwork inward</h2>
                    </div>
                    <a class="dash-glass__link" href="Jobwork_Receive_History.aspx">View all</a>
                </div>
                <div class="dash-kpi-grid cols-2">
                    <a href="Jobwork_Receive_History.aspx?mode=today" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--pink" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_jw_today_recv_qty" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">Today receive</span>
                        </div>
                    </a>
                    <a href="Jobwork_Receive_History.aspx" class="dash-kpi">
                        <span class="dash-kpi__accent dash-kpi__accent--violet" aria-hidden="true"></span>
                        <div class="dash-kpi__body">
                            <span class="dash-kpi__value"><asp:Literal ID="lit_jw_month_recv_qty" runat="server">0</asp:Literal></span>
                            <span class="dash-kpi__label">This month receive</span>
                        </div>
                    </a>
                </div>
            </section>
        </div>
    </div>
</asp:Content>
