<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Invoice_Print.aspx.cs" Inherits="Invoice_Print" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title></title>
    <style type="text/css">
        html, body, form { margin: 0; padding: 0; }
        *, *::before, *::after { box-sizing: border-box; }

        body {
            font-family: Calibri, "Segoe UI", Arial, Helvetica, sans-serif;
            font-size: 10.5pt;
            line-height: 1.35;
            color: #0d0d0d;
            background: #fff;
        }

        .no-print {Invoice_Print
            text-align: center;
            padding: 12px 16px;
            background: #2f3542;
            border-bottom: 2px solid #1e272e;
        }
        .no-print button {
            font-family: inherit;
            font-size: 13px;
            font-weight: 600;
            padding: 9px 24px;
            margin: 0 6px;
            cursor: pointer;
            border-radius: 2px;
            border: 1px solid #000;
        }
        .no-print .inv-btn-print { background: #1a1a1a; color: #fff; }
        .no-print .inv-btn-print:hover { background: #000; }
        .no-print .inv-btn-close { background: #fff; color: #222; }
        .no-print .inv-btn-close:hover { background: #f1f2f6; }

        .inv-page {
            max-width: 210mm;
            margin: 16px auto 40px;
            background: #fff;
            border: none;
            box-shadow: none;
        }
        .inv-inner { padding: 8mm 8mm 7mm; }

        .inv-row { display: flex; gap: 10pt; }
        .inv-col { flex: 1 1 0; min-width: 0; }

        /* ----- Top title band ----- */
        .inv-topband {
            border-bottom: 2pt solid #000;
            padding: 6pt 8pt;
            display: flex;
            align-items: center;
            gap: 8pt;
        }
        .inv-topband .t-left,
        .inv-topband .t-right { width: 26%; font-size: 8.5pt; color: #111; }
        .inv-topband .t-center {
            flex: 1 1 auto;
            text-align: center;
            font-weight: 700;
            letter-spacing: .12em;
            text-transform: uppercase;
            font-size: 10pt;
            color: #000;
        }
        .inv-topband .t-right { text-align: right; }

        /* ----- Header: one band, restrained height ----- */
        .inv-head-table {
            width: 100%;
            border-collapse: collapse;
            margin: 0;
            border-bottom: 1pt solid #000;
        }
        .inv-head-table td { vertical-align: top; padding: 6pt 8pt; }
        .inv-head-brand { width: 56%; padding-right: 8pt; }
        .inv-head-meta { text-align: right; vertical-align: middle; }

        .inv-brand-row {
            display: table;
            border-collapse: collapse;
        }
        .inv-brand-row .inv-logo-wrap,
        .inv-brand-row .inv-brand-text {
            display: table-cell;
            vertical-align: middle;
        }
        .inv-logo-wrap { padding-right: 10pt; }
        .inv-logo {
            height: 58px;
            width: auto;
            max-width: 100px;
            display: block;
            object-fit: contain;
        }
        .inv-co-name {
            font-size: 14pt;
            font-weight: 700;
            color: #000;
            line-height: 1.12;
            letter-spacing: -0.02em;
        }
        .inv-co-line {
            font-size: 8pt;
            color: #444;
            margin-top: 2pt;
            text-transform: uppercase;
            letter-spacing: .05em;
        }

        .inv-seller-meta {
            margin-top: 0;
            font-size: 8.5pt;
            color: #222;
            line-height: 1.35;
        }
        .inv-seller-meta .k { color: #000000;
    font-weight: 700; }
        .inv-seller-meta .v { font-weight: 700; color: #000; }
        .inv-seller-gst { margin-top: 2pt; }

        /* ----- Invoice meta boxed (Invoice No / Date) ----- */
        .inv-meta-box {
            margin-left: auto;
            border: 1pt solid #000;
            border-collapse: collapse;
            font-size: 9pt;
            min-width: 190pt;
        }
        .inv-meta-box td {
            padding: 4pt 6pt;
            border-bottom: 0.75pt solid #000;
        }
        .inv-meta-box tr:last-child td { border-bottom: none; }
        .inv-meta-box .k { color: #111; width: 70pt; }
        .inv-meta-box .v {
            font-weight: 700;
            text-align: right;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }

        /* ----- Party (single) ----- */
        .inv-party-wrap { border-bottom: 1pt solid #000; }
        .inv-party-box {
            border: none;
            padding: 7pt 8pt;
            font-size: 9.25pt;
            line-height: 1.35;
            min-height: 56pt;
        }
        .inv-party-h {
            font-size: 7.5pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .1em;
            color: #333;
            margin-bottom: 4pt;
        }
        .inv-party-name { font-weight: 700; color: #000; }
        .inv-party-addr { margin-top: 3pt; color: #333; font-size: 9pt; white-space: pre-wrap; }
        .inv-party-gst { margin-top: 4pt; font-size: 8.5pt; color: #333; }
        .inv-party-gst span { font-weight: 700; }

        .inv-remarks {
            margin: 0 0 8pt 0;
            padding: 6pt 8pt;
            border: 0.75pt solid #ccc;
            font-size: 9pt;
            color: #222;
            background: #fafafa;
        }
        .inv-remarks .inv-remarks-lbl {
            font-size: 7.5pt;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .08em;
            color: #666;
            margin-bottom: 3pt;
        }

        /* ----- Line items ----- */
        .inv-lines-caption {
            font-size: 7.5pt;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: #555;
            margin: 0 0 4pt 0;
        }
        .inv-table-wrap {
            margin: 0 0 11pt 0;
            border: 1pt solid #000;
            border-bottom: none;
        }

        .inv-after-lines {
            border-left: 1pt solid #000;
            border-right: 1pt solid #000;
            border-bottom: 1pt solid #000;
            padding: 5pt 8pt;
            font-size: 9.25pt;
            color: #000;
            background: #e9e9e9;
            display: block;
            margin-top: -1pt; /* visually attach to table border */
        }
        .inv-after-lines .k {
            color: #000;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .inv-after-lines .v { font-weight: 700; letter-spacing: .02em; }
        .inv-line-table {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
            font-size: 9pt;
        }
        .inv-line-table col.inv-col-sr { width: 4%; }
        .inv-line-table col.inv-col-date { width: 10%; min-width: 4.8em; }
        .inv-line-table col.inv-col-challan { width: 12%; }
        .inv-line-table col.inv-col-item { width: auto; }
        .inv-line-table col.inv-col-qty { width: 5.5%; }
        .inv-line-table col.inv-col-rate { width: 8.5%; }
        .inv-line-table col.inv-col-tax { width: 6.5%; }
        .inv-line-table col.inv-col-taxamt { width: 10.5%; }
        .inv-line-table col.inv-col-total { width: 11.5%; }

        .inv-line-table thead th {
            background: #fff !important;
            color: #000 !important;
            font-weight: 600;
            text-align: left;
            padding: 6pt 5pt;
            border: 1pt solid #000;
            font-size: 7.5pt;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .inv-line-table thead th.inv-th-num { text-align: right; }
        .inv-line-table thead th.inv-th-date {
            white-space: nowrap;
            text-align: center;
        }
        .inv-line-table tbody td {
            padding: 5pt 5pt;
            border: 0.5pt solid #777;
            vertical-align: top;
            color: #111;
        }
        .inv-line-table tbody tr.inv-tr--even td { background: #fff; }
        .inv-line-table .inv-td-num {
            text-align: right;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }
        .inv-line-table .inv-td-sno {
            text-align: center;
            font-weight: 600;
            color: #333;
            white-space: nowrap;
        }
        .inv-line-table .inv-td-date {
            font-variant-numeric: tabular-nums;
            color: #111;
            text-align: center;
            white-space: nowrap;
        }
        .inv-line-table .inv-td-challan{
            color:#111;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
        }
        .inv-line-table .inv-td-item {
            font-weight: 600;
            color: #000;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }
        .inv-line-table .inv-td-amt { font-weight: 700; }

        .inv-bottom {
            margin-top: 10pt;
            display: flex;
            gap: 10pt;
            align-items: flex-start;
        }
        .inv-bottom .inv-bottom-left { flex: 1 1 auto; min-width: 0; }
        .inv-bottom .inv-bottom-right { flex: 0 0 240pt; min-width: 200pt; }

        .inv-summary-wrap { margin-top: 0; text-align: right; }
        .inv-summary-table {
            margin-left: auto;
            border-collapse: collapse;
            width: 100%;
            max-width: 240pt;
            border: 1pt solid #000;
        }
        .inv-summary-table td {
            padding: 5pt 10pt;
            font-size: 9.5pt;
            border-bottom: 0.75pt solid #ddd;
        }
        .inv-summary-table tr:last-child td { border-bottom: none; }
        .inv-summary-table .lbl { text-align: left; color: #444; width: 55%; }
        .inv-summary-table .val {
            text-align: right;
            font-weight: 600;
            font-variant-numeric: tabular-nums;
            color: #000;
        }
        .inv-summary-table tr.inv-sum-grand td {
            background: #ececec;
            font-weight: 700;
            font-size: 10.5pt;
            border-top: 1.5pt solid #000;
        }
        .inv-summary-table tr.inv-sum-grand .val { font-size: 11pt; }

        .inv-sum-lbl {
            font-size: 7.5pt;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #555;
            margin: 8pt 0 4pt 0;
            text-align: right;
        }

        .inv-words {
            margin-top: 10pt;
            padding: 7pt 9pt;
            border: 1pt solid #000;
            font-size: 8.5pt;
            color: #333;
            line-height: 1.4;
        }
        .inv-words .inv-words-h {
            font-size: 7.5pt;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #555;
            margin-bottom: 3pt;
        }
        .inv-footer {
            margin-top: 12pt;
            padding-top: 8pt;
            border-top: 0.75pt solid #ccc;
            font-size: 7.5pt;
            color: #666;
            text-align: center;
        }

        .inv-sign {
            margin-top: 10pt;
            display: flex;
            justify-content: flex-end;
        }
        .inv-sign-box {
            width: 45%;
            min-width: 180pt;
            border: 0.75pt solid #000;
            padding: 7pt 8pt;
            text-align: right;
            font-size: 9pt;
        }
        .inv-sign-box .for { font-weight: 700; }
        .inv-sign-box .sig { margin-top: 26pt; font-size: 8.5pt; color: #333; }

        .inv-error-sheet {
            max-width: 210mm;
            margin: 40px auto;
            padding: 24px;
            background: #fff;
            border: 1px solid #c0392b;
            color: #721c24;
        }

        @media print {
            @page { size: A4 portrait; margin: 11mm 12mm; }
            html, body {
                width: 100%;
                background: #fff !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            body { font-size: 10pt; }
            form { background: #fff !important; }

            .no-print {
                display: none !important;
                height: 0 !important;
                padding: 0 !important;
                margin: 0 !important;
                overflow: hidden !important;
                border: none !important;
            }
            .inv-page {
                margin: 0 !important;
                border: none !important;
                box-shadow: none !important;
                max-width: none !important;
                width: 100% !important;
            }
            .inv-inner { padding: 0 !important; }
            .inv-line-table thead th { background: #fff !important; color: #000 !important; }
            .inv-line-table thead th.inv-th-date,
            .inv-line-table .inv-td-date,
            .inv-meta-box .v {
                white-space: nowrap !important;
            }
            .inv-line-table tbody td { border-color: #999; }
            .inv-bottom .inv-bottom-right { flex-basis: 240pt; }
            .inv-summary-table { max-width: none; }
            .inv-line-table tbody tr { page-break-inside: avoid; }
            .inv-line-table thead { display: table-header-group; }
            .inv-remarks { background: #fff !important; }
            .inv-footer { display: none !important; }
            a[href]:after { content: none !important; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="no-print">
            <button type="button" class="inv-btn-print" onclick="window.print(); return false;">Print</button>
            <button type="button" class="inv-btn-close" onclick="window.close();">Close</button>
        </div>

        <asp:Panel ID="pnl_error" runat="server" Visible="false" CssClass="inv-error-sheet">
            <strong>Unable to display invoice.</strong>
            <p style="margin:8px 0 0;">The invoice was not found or your session has expired. Sign in again and open it from the invoice list.</p>
        </asp:Panel>

        <asp:Panel ID="pnl_invoice" runat="server" CssClass="inv-page">
            <div class="inv-inner">
                <div class="inv-topband">
                    <div class="t-left"><asp:Literal ID="lit_left_badge" runat="server" Text="" /></div>
                    <div class="t-center"><asp:Literal ID="lit_doc_title" runat="server" /></div>
                    <div class="t-right">Original</div>
                </div>
                <table class="inv-head-table" role="presentation">
                    <tr>
                        <td class="inv-head-brand">
                            <div class="inv-brand-row">
                                <asp:Panel ID="pnl_logo" runat="server" CssClass="inv-logo-wrap">
                                    <asp:Image ID="img_logo" runat="server" CssClass="inv-logo" ImageUrl="~/image/thumbnail.jpg" AlternateText="" />
                                </asp:Panel>
                                <div class="inv-brand-text">
                                    <div class="inv-seller-meta">
                                        <div><asp:Literal ID="lit_seller_addr" runat="server" /></div>
                                        <asp:Panel ID="pnl_seller_gst" runat="server" Visible="false" CssClass="inv-seller-gst">
                                            <span class="k">GSTIN No.: 24ADIFS3378J1ZO</span>
                                            <span class="v"><asp:Literal ID="lit_seller_gstin" runat="server" /></span>
                                        </asp:Panel>
                                    </div>
                                </div>
                            </div>
                        </td>
                        <td class="inv-head-meta">
                            <table class="inv-meta-box" role="presentation">
                                <tr>
                                    <td class="k">PO. No.</td>
                                    <td class="v"><asp:Literal ID="lit_inv_no" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td class="k">Date</td>
                                    <td class="v"><asp:Literal ID="lit_inv_date" runat="server" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>

                <div class="inv-party-wrap">
                    <div class="inv-party-box">
                        <div class="inv-party-h">M/s.</div>
                        <div class="inv-party-name"><asp:Literal ID="lit_party_name" runat="server" /></div>
                        <div class="inv-party-addr"><asp:Literal ID="lit_party_addr" runat="server" /></div>
                        <asp:Panel ID="pnl_party_gst" runat="server" Visible="false" CssClass="inv-party-gst">
                            GSTIN / UIN <span><asp:Literal ID="lit_party_gst" runat="server" /></span>
                        </asp:Panel>
                    </div>
                </div>

                <asp:Panel ID="pnl_remarks" runat="server" Visible="false" CssClass="inv-remarks">
                    <div class="inv-remarks-lbl">Remarks</div>
                    <div style="white-space: pre-wrap;"><asp:Literal ID="lit_remarks" runat="server" /></div>
                </asp:Panel>

                <div class="inv-lines-caption">Item details</div>
                <div class="inv-table-wrap">
                    <asp:Literal ID="lit_lines_html" runat="server" Mode="PassThrough"></asp:Literal>
                </div>
                <asp:Panel ID="pnl_gstin_bottom" runat="server" Visible="false" CssClass="inv-after-lines">
                    <span class="k">GSTIN No.:</span>
                    <span class="v"><asp:Literal ID="lit_gstin_bottom" runat="server" /></span>
                </asp:Panel>

                <div class="inv-bottom">
                    <div class="inv-bottom-left">
                        <div class="inv-words">
                            <div class="inv-words-h">Amount in words</div>
                            <asp:Literal ID="lit_amount_words" runat="server" />
                        </div>
                    </div>

                    <div class="inv-bottom-right">
                        <div class="inv-sum-lbl">Summary</div>
                        <asp:Panel ID="pnl_tot_gst" runat="server" CssClass="inv-summary-wrap">
                            <table class="inv-summary-table" role="presentation">
                                <tr><td class="lbl">Taxable amount</td><td class="val"><asp:Literal ID="lit_sub_total" runat="server" /></td></tr>
                                <tr><td class="lbl">CGST</td><td class="val"><asp:Literal ID="lit_cgst" runat="server" /></td></tr>
                                <tr><td class="lbl">SGST</td><td class="val"><asp:Literal ID="lit_sgst" runat="server" /></td></tr>
                                <tr><td class="lbl">Round off</td><td class="val"><asp:Literal ID="lit_roundoff" runat="server" /></td></tr>
                                <tr class="inv-sum-grand"><td class="lbl">Grand total</td><td class="val"><asp:Literal ID="lit_grand_total" runat="server" /></td></tr>
                            </table>
                        </asp:Panel>
                        <asp:Panel ID="pnl_tot_nongst" runat="server" Visible="false" CssClass="inv-summary-wrap">
                            <table class="inv-summary-table" role="presentation">
                                <tr><td class="lbl">Taxable amount</td><td class="val"><asp:Literal ID="lit_sub_total_ng" runat="server" /></td></tr>
                                <tr><td class="lbl">Round off</td><td class="val"><asp:Literal ID="lit_roundoff_ng" runat="server" /></td></tr>
                                <tr class="inv-sum-grand"><td class="lbl">Grand total</td><td class="val"><asp:Literal ID="lit_grand_only" runat="server" /></td></tr>
                            </table>
                        </asp:Panel>
                    </div>
                </div>

                <div class="inv-sign">
                    <div class="inv-sign-box">
                        <div class="for">For, <asp:Literal ID="lit_seller_name2" runat="server" /></div>
                        <div class="sig">(Authorised Signatory)</div>
                    </div>
                </div>

                <div class="inv-footer">
                    Computer-generated Purchase Order
                </div>
            </div>
        </asp:Panel>
    </form>
    <script type="text/javascript">
        (function () {
            if ((window.location.search || '').indexOf('auto=1') >= 0)
                window.onload = function () { setTimeout(function () { window.print(); }, 200); };
        })();
    </script>
</body>
</html>
