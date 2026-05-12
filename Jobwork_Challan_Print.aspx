<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Jobwork_Challan_Print.aspx.cs" Inherits="Jobwork_Challan_Print" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Jobwork challan print</title>
    <style type="text/css">
        html, body, form { margin: 0; padding: 0; }
        *, *::before, *::after { box-sizing: border-box; }

        body {
            font-family: Calibri, "Segoe UI", Arial, Helvetica, sans-serif;
            font-size: 10pt;
            line-height: 1.35;
            color: #111;
            background: #e8eaed;
        }

        .no-print {
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
        .no-print .jw-btn-print { background: #1a1a1a; color: #fff; }
        .no-print .jw-btn-print:hover { background: #000; }
        .no-print .jw-btn-close { background: #fff; color: #222; }
        .no-print .jw-btn-close:hover { background: #f1f2f6; }

        /* A4 width; screen preview uses full sheet height (11.69in ≈ 297mm). */
        .jw-a4 {
            width: 210mm;
            max-width: 100%;
            min-height: 297mm;
            margin: 14px auto 32px;
            background: #fff;
            box-shadow: 0 2px 12px rgba(0,0,0,.08);
        }
        .jw-a4-inner {
            padding: 6mm 8mm;
            min-height: 285mm;
            display: flex;
            flex-direction: column;
            box-sizing: border-box;
        }

        /* Fixed one page: top = jobwork party, bottom = company */
        .jw-print-root {
            flex: 1 1 auto;
            display: flex;
            flex-direction: column;
            min-height: 0;
            border: 1px solid #ddd;
        }

        .jw-pane {
            display: flex;
            flex-direction: column;
            min-height: 0;
            overflow: hidden;
        }

        .jw-pane-body {
            flex: 1 1 auto;
            min-height: 0;
            overflow-y: auto;
            padding-right: 2px;
        }

        /* Two or more line items: split ~50% / 50% */
        .jw-print-root--equal .jw-pane--jobwork {
            flex: 1 1 50%;
        }
        .jw-print-root--equal .jw-pane--company {
            flex: 1 1 50%;
        }

        /* Single line item: top (jobwork) uses most of the sheet; company band compact */
        .jw-print-root--single-item .jw-pane--jobwork {
            flex: 4 1 0;
        }
        .jw-print-root--single-item .jw-pane--company {
            flex: 1 1 0;
        }

        .jw-copy-tag {
            text-align: center;
            font-size: 8.5pt;
            font-weight: 700;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: #fff;
            background: #1a1a1a;
            padding: 5pt 10pt;
            margin: 0 0 6pt 0;
            border-radius: 2px;
        }

        .jw-cut-line {
            flex: 0 0 auto;
            margin: 0;
            padding: 2mm 0;
            border: none;
            border-top: 1px dashed #000;
            background: transparent;
            height: 0;
            line-height: 0;
            font-size: 0;
        }

        .jw-topband {
            display: flex;
            align-items: center;
            gap: 8pt;
            border-bottom: 2pt solid #000;
            padding: 5pt 6pt 7pt;
            margin-bottom: 6pt;
        }
        .jw-topband .jw-doc-title {
            flex: 1;
            text-align: center;
            font-weight: 700;
            font-size: 11pt;
            letter-spacing: .1em;
            text-transform: uppercase;
        }

        .jw-head-row {
            display: table;
            width: 100%;
            table-layout: fixed;
            margin-bottom: 8pt;
            border-bottom: 1pt solid #000;
            padding-bottom: 6pt;
        }
        .jw-head-row .jw-logo-cell,
        .jw-head-row .jw-co-addr,
        .jw-head-row .jw-meta-cell {
            display: table-cell;
            vertical-align: top;
        }
        .jw-logo-cell { width: 100px; padding-right: 10pt; }
        .jw-logo { height: 52px; width: auto; max-width: 92px; object-fit: contain; display: block; }
        .jw-co-addr {
            font-size: 8pt;
            color: #333;
            white-space: pre-wrap;
            line-height: 1.35;
            padding-right: 8pt;
        }
        .jw-meta-cell { text-align: right; }
        .jw-meta-box {
            margin-left: auto;
            border: 1pt solid #000;
            border-collapse: collapse;
            font-size: 9pt;
            min-width: 170pt;
        }
        .jw-meta-box td { padding: 4pt 7pt; border-bottom: 0.75pt solid #000; }
        .jw-meta-box tr:last-child td { border-bottom: none; }
        .jw-meta-box .k { width: 72pt; color: #222; }
        .jw-meta-box .v { font-weight: 700; text-align: right; font-variant-numeric: tabular-nums; }

        .jw-party-simple {
            display: table;
            width: 100%;
            margin: 0 0 6pt 0;
            font-size: 9.5pt;
        }
        .jw-party-simple .jw-party-lbl {
            display: table-cell;
            white-space: nowrap;
            padding-right: 8pt;
            font-weight: 600;
            vertical-align: bottom;
        }
        .jw-party-simple .jw-party-value {
            display: table-cell;
            width: 100%;
            border-bottom: 1pt solid #000;
            padding: 0 2pt 2pt 4pt;
            vertical-align: bottom;
            font-weight: 600;
            min-height: 1.3em;
        }

        .jw-line-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 9pt;
            border: 1pt solid #000;
            table-layout: fixed;
        }
        .jw-line-table th {
            background: #fff;
            font-weight: 600;
            text-align: left;
            padding: 4pt 6pt;
            border: 1pt solid #000;
            font-size: 7.5pt;
            text-transform: uppercase;
            letter-spacing: .04em;
        }
        .jw-line-table th.jw-th-sr { width: 9%; text-align: center; }
        .jw-line-table th.jw-th-qty { width: 18%; text-align: right; }
        .jw-line-table td {
            padding: 3pt 6pt;
            border: 0.5pt solid #666;
            vertical-align: top;
        }
        .jw-line-table td.jw-td-sr { text-align: center; font-weight: 600; }
        .jw-line-table td.jw-td-qty {
            text-align: right;
            font-variant-numeric: tabular-nums;
            white-space: nowrap;
            font-weight: 600;
        }
        .jw-line-table .jw-item { font-weight: 600; word-wrap: break-word; }

        .jw-total-qty {
            margin-top: 5pt;
            padding: 4pt 6pt;
            font-size: 9.5pt;
            text-align: right;
            border: 1pt solid #000;
            border-top: none;
            background: #f3f3f3;
        }
        .jw-total-qty strong { font-variant-numeric: tabular-nums; }

        .jw-remarks {
            margin-top: 6pt;
            padding: 5pt 8pt;
            border: 0.75pt solid #999;
            font-size: 9pt;
            background: #fafafa;
        }

        .jw-error {
            max-width: 210mm;
            margin: 40px auto;
            padding: 24px;
            background: #fff;
            border: 1px solid #c0392b;
            color: #721c24;
        }

        @media print {
            /* Explicit A4 — height 297mm (11.69in) */
            @page { size: 210mm 297mm; margin: 6mm 8mm; }
            html, body, form {
                background: #fff !important;
                height: 100% !important;
            }
            body {
                font-size: 8.5pt !important;
                line-height: 1.22 !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .no-print { display: none !important; }
            .jw-a4 {
                margin: 0 !important;
                box-shadow: none !important;
                width: 100% !important;
                max-width: none !important;
                min-height: 0 !important;
                height: auto !important;
            }
            /* Printable area inside margins: ~285mm tall */
            .jw-a4-inner {
                padding: 0 !important;
                width: 100% !important;
                min-height: 285mm !important;
                height: 285mm !important;
                max-height: 285mm !important;
                display: flex !important;
                flex-direction: column !important;
                overflow: hidden !important;
            }

            .jw-print-root {
                flex: 1 1 auto !important;
                min-height: 0 !important;
                height: 100% !important;
                max-height: 100% !important;
                border: none !important;
                page-break-inside: avoid !important;
                break-inside: avoid !important;
            }

            .jw-pane {
                page-break-inside: avoid !important;
                overflow: hidden !important;
            }

            .jw-pane-body {
                overflow: hidden !important;
            }

            .jw-copy-tag {
                padding: 3pt 8pt !important;
                margin-bottom: 4pt !important;
                font-size: 7.5pt !important;
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }
            .jw-cut-line {
                padding: 1.5mm 0 !important;
                margin: 0 !important;
                border: none !important;
                border-top: 1px dashed #000 !important;
                background: transparent !important;
                height: 0 !important;
                line-height: 0 !important;
                font-size: 0 !important;
            }

            .jw-topband { padding: 2pt 4pt 4pt !important; margin-bottom: 3pt !important; }
            .jw-topband .jw-doc-title { font-size: 9pt !important; }

            .jw-head-row { margin-bottom: 3pt !important; padding-bottom: 3pt !important; }
            .jw-logo { height: 38px !important; max-width: 70px !important; }
            .jw-co-addr { font-size: 7pt !important; line-height: 1.2 !important; }
            .jw-meta-box { font-size: 8pt !important; min-width: 130pt !important; }
            .jw-meta-box td { padding: 2pt 5pt !important; }

            .jw-party-simple { margin-bottom: 4pt !important; font-size: 8.5pt !important; }
            .jw-party-simple .jw-party-lbl { padding-right: 6pt !important; }

            .jw-line-table { font-size: 7.5pt !important; }
            .jw-line-table th { padding: 2pt 4pt !important; font-size: 7pt !important; }
            .jw-line-table td { padding: 2pt 4pt !important; }

            .jw-total-qty {
                margin-top: 0 !important;
                padding: 3pt 6pt !important;
                font-size: 8.5pt !important;
            }

            .jw-remarks {
                margin-top: 4pt !important;
                padding: 3pt 6pt !important;
                font-size: 7.5pt !important;
            }

            .jw-line-table thead { display: table-header-group; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="no-print">
            <button type="button" class="jw-btn-print" onclick="window.print(); return false;">Print</button>
            <button type="button" class="jw-btn-close" onclick="window.close();">Close</button>
        </div>

        <asp:Panel ID="pnl_error" runat="server" Visible="false" CssClass="jw-error">
            <strong>Unable to print challan.</strong>
            <p style="margin:8px 0 0;">The jobwork challan was not found or your session has expired.</p>
        </asp:Panel>

        <asp:Panel ID="pnl_print" runat="server" CssClass="jw-a4">
            <div class="jw-a4-inner">
                <asp:Literal ID="lit_duplex_body" runat="server" Mode="PassThrough"></asp:Literal>
            </div>
        </asp:Panel>
    </form>
</body>
</html>
