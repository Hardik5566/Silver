using System;

using System.Data;

using System.Globalization;

using System.Web.UI;

using System.Web.UI.WebControls;



public partial class My_Expense : Page

{

    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    public enum Msg { Success, Error, Warning }



    private decimal _periodExpense;

    private decimal _periodPayment;

    private decimal _closingBalance;



    private string MyUserId

    {

        get { return Session["user_id"] != null ? Session["user_id"].ToString() : ""; }

    }



    protected void ShowMsg(string msg, Msg t)

    {

        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),

            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);

    }



    private static void ShowMexpModal(Page page, bool showPaymentMode)

    {

        string showPm = showPaymentMode ? "''" : "'none'";

        ScriptManager.RegisterStartupScript(page, page.GetType(), "showMexpModal",

            "var el=document.getElementById('modal_mexp');" +

            "var pnl=document.getElementById('pnl_payment_mode');" +

            "if(pnl) pnl.style.display=" + showPm + ";" +

            "if(el&&window.bootstrap){ bootstrap.Modal.getOrCreateInstance(el).show(); }", true);

    }



    protected void Page_Load(object sender, EventArgs e)

    {

        if (Session["user_id"] == null)

        {

            Response.Redirect("Default.aspx");

            return;

        }



        if (!IsPostBack)

        {

            lbl_user_name.Text = Session["name"] != null ? Session["name"].ToString() : "—";

            SetDefaultMonthRange();

            txt_expense_date.Text = DateTime.Today.ToString("yyyy-MM-dd");

            hd_action.Value = "save";

            hd_entry_kind.Value = "expense";

            BindGrid();

        }

    }



    private static void SetMonthRangeOnControls(TextBox fromBox, TextBox toBox)

    {

        DateTime today = DateTime.Today;

        var start = new DateTime(today.Year, today.Month, 1);

        int dim = DateTime.DaysInMonth(today.Year, today.Month);

        var end = new DateTime(today.Year, today.Month, dim);

        fromBox.Text = start.ToString("yyyy-MM-dd");

        toBox.Text = end.ToString("yyyy-MM-dd");

    }



    private void SetDefaultMonthRange()

    {

        SetMonthRangeOnControls(txt_from, txt_to);

    }



    protected string FormatBalance(object value)

    {

        return FormatBalanceAmount(ParseDecimal(value));

    }



    protected string GetBalanceCss(object value)

    {

        return GetBalanceCssClass(ParseDecimal(value));

    }



    protected bool IsOpeningRow(object value)

    {

        return ParseInt(value) == 1;

    }



    protected bool CanEditRow(object value)

    {

        return ParseInt(value) == 1;

    }



    protected string FormatDate(object isOpening, object txnDate)

    {

        if (ParseInt(isOpening) == 1)

            return "—";

        if (txnDate == null || txnDate == DBNull.Value)

            return "—";

        DateTime d;

        if (txnDate is DateTime)

            d = (DateTime)txnDate;

        else if (!DateTime.TryParse(txnDate.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out d))

            DateTime.TryParse(txnDate.ToString(), out d);

        return d.ToString("dd-MMM-yyyy", Ci);

    }



    protected string FormatNote(object isOpening, object note, object paymentMode)

    {

        if (ParseInt(isOpening) == 1)

            return "Balance brought forward";

        string n = note != null && note != DBNull.Value ? note.ToString().Trim() : "";

        string pm = paymentMode != null && paymentMode != DBNull.Value ? paymentMode.ToString().Trim() : "";

        if (!string.IsNullOrEmpty(n) && !string.IsNullOrEmpty(pm))

            return n + " (" + pm + ")";

        if (!string.IsNullOrEmpty(n))

            return n;

        if (!string.IsNullOrEmpty(pm))

            return pm;

        return "—";

    }



    protected string FormatDebitCredit(object isOpening, object amount)

    {

        if (ParseInt(isOpening) == 1)

            return "—";

        decimal amt = ParseDecimal(amount);

        if (amt <= 0)

            return "—";

        return "₹" + amt.ToString("N2", Ci);

    }



    protected void grid_mexp_RowDataBound(object sender, GridViewRowEventArgs e)

    {

        if (e.Row.RowType != DataControlRowType.DataRow)

            return;

        DataRowView row = e.Row.DataItem as DataRowView;

        if (row == null)

            return;

        if (ParseInt(row["is_opening"]) == 1)

            e.Row.CssClass = "mexp-opening";

    }



    private void BindGrid()

    {

        DataSet ds = BAL_StaffExpense.dis_my_staff_account(MyUserId, txt_from.Text, txt_to.Text);



        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)

        {

            pnl_summary.Visible = false;

            grid_mexp.DataSource = null;

            grid_mexp.DataBind();

            return;

        }



        DataRow header = ds.Tables[0].Rows[0];

        if (header.Table.Columns.Contains("Success") && header["Success"].ToString() == "False")

        {

            ShowMsg(header["Message"].ToString(), Msg.Warning);

            pnl_summary.Visible = false;

            grid_mexp.DataSource = null;

            grid_mexp.DataBind();

            return;

        }



        decimal opening = ParseDecimal(header["opening_balance"]);

        _periodExpense = ParseDecimal(header["period_credit"]);

        _periodPayment = ParseDecimal(header["period_debit"]);

        _closingBalance = ParseDecimal(header["closing_balance"]);



        SetBalanceLabel(lbl_opening, opening);

        lbl_total_expense.Text = "₹" + _periodExpense.ToString("N2", Ci);

        lbl_total_payment.Text = "₹" + _periodPayment.ToString("N2", Ci);

        SetBalanceLabel(lbl_balance, _closingBalance);

        lbl_balance_hint.Text = GetBalanceHint(_closingBalance);

        pnl_summary.Visible = true;



        DataTable lines = ds.Tables.Count > 1 ? ds.Tables[1] : null;

        grid_mexp.DataSource = lines;

        grid_mexp.DataBind();



        bool hasData = lines != null && lines.Rows.Count > 0;

        if (grid_mexp.FooterRow != null && hasData)

        {

            grid_mexp.FooterRow.TableSection = TableRowSection.TableFooter;

            Label lblE = grid_mexp.FooterRow.FindControl("lbl_foot_expense") as Label;

            Label lblP = grid_mexp.FooterRow.FindControl("lbl_foot_payment") as Label;

            Label lblB = grid_mexp.FooterRow.FindControl("lbl_foot_balance") as Label;

            if (lblE != null) lblE.Text = _periodExpense.ToString("N2", Ci);

            if (lblP != null) lblP.Text = _periodPayment.ToString("N2", Ci);

            if (lblB != null)

            {

                lblB.Text = "₹" + FormatBalanceAmount(_closingBalance);

                lblB.CssClass = GetBalanceCssClass(_closingBalance);

            }

        }

        else if (grid_mexp.FooterRow != null)

            grid_mexp.FooterRow.Visible = false;

    }



    protected void btn_filter_Click(object sender, EventArgs e)

    {

        BindGrid();

    }



    protected void grid_mexp_RowCommand(object sender, GridViewCommandEventArgs e)

    {

        string id = e.CommandArgument != null ? e.CommandArgument.ToString() : "";



        if (e.CommandName == "edt")

        {

            DataSet ds = BAL_StaffExpense.sel_staff_expense_by_id(id, MyUserId);

            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)

            {

                ShowMsg("Expense not found.", Msg.Warning);

                return;

            }



            DataRow r = ds.Tables[0].Rows[0];

            hd_staff_expense_id.Value = id;

            hd_entry_kind.Value = "expense";

            hd_action.Value = "upd";

            lbl_modal_title.Text = "Edit expense";

            lbl_date_caption.Text = "Expense date";

            btn_save.Text = "Update";



            txt_expense_date.Text = FormatDateForInput(r["expense_date"]);

            txt_ref_no.Text = r["ref_no"] != DBNull.Value ? r["ref_no"].ToString() : "";

            txt_note.Text = r["note"] != DBNull.Value ? r["note"].ToString() : "";

            txt_amount.Text = ParseRowAmount(r["amount"]);



            rb_pay_cash.Checked = false;

            rb_pay_online.Checked = false;



            ShowMexpModal(this, false);

            return;

        }



        if (e.CommandName == "dlt")

        {

            DataSet ds = BAL_StaffExpense.dlt_staff_expense(id, MyUserId, MyUserId);

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)

            {

                if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")

                {

                    ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Success);

                    BindGrid();

                }

                else

                    ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);

            }

        }

    }



    protected void btn_save_Click(object sender, EventArgs e)

    {

        decimal amt;

        if (!decimal.TryParse(txt_amount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt) || amt <= 0)

        {

            ShowMsg("Enter a valid amount greater than zero.", Msg.Warning);

            return;

        }



        if (string.IsNullOrWhiteSpace(txt_expense_date.Text))

        {

            ShowMsg(hd_entry_kind.Value == "income" ? "Select income date." : "Select expense date.", Msg.Warning);

            return;

        }



        bool isIncome = string.Equals(hd_entry_kind.Value, "income", StringComparison.OrdinalIgnoreCase);

        string paymentMode = "";

        if (isIncome)

        {

            paymentMode = GetSelectedPaymentMode();

            if (string.IsNullOrEmpty(paymentMode))

            {

                ShowMsg("Select payment mode (Cash or Online).", Msg.Warning);

                return;

            }

        }



        string amtStr = amt.ToString(CultureInfo.InvariantCulture);

        bool isUpd = string.Equals(hd_action.Value, "upd", StringComparison.OrdinalIgnoreCase);



        DataSet ds;

        if (isIncome)

        {

            ds = BAL_Account.ins_ledger_payment(

                "STAFF",

                MyUserId,

                txt_expense_date.Text,

                txt_ref_no.Text,

                txt_note.Text,

                amtStr,

                paymentMode,

                "D",

                MyUserId);

        }

        else if (isUpd)

        {

            if (string.IsNullOrWhiteSpace(hd_staff_expense_id.Value))

            {

                ShowMsg("Missing expense id.", Msg.Warning);

                return;

            }

            ds = BAL_StaffExpense.upd_staff_expense(

                hd_staff_expense_id.Value,

                MyUserId,

                txt_expense_date.Text,

                txt_ref_no.Text,

                txt_note.Text,

                amtStr,

                MyUserId);

        }

        else

        {

            ds = BAL_StaffExpense.ins_staff_expense(

                MyUserId,

                txt_expense_date.Text,

                txt_ref_no.Text,

                txt_note.Text,

                amtStr,

                MyUserId);

        }



        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)

        {

            if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")

            {

                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Success);

                ResetModalAfterSave();

                BindGrid();

                ScriptManager.RegisterStartupScript(this, GetType(), "closeMexpModal",

                    "var el=document.getElementById('modal_mexp'); if(el&&window.bootstrap){ var m=bootstrap.Modal.getInstance(el); if(m) m.hide(); }", true);

            }

            else

                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);

        }

    }



    private void ResetModalAfterSave()

    {

        txt_ref_no.Text = "";

        txt_note.Text = "";

        txt_amount.Text = "";

        hd_staff_expense_id.Value = "";

        hd_action.Value = "save";

        hd_entry_kind.Value = "expense";

        lbl_modal_title.Text = "Add expense";

        lbl_date_caption.Text = "Expense date";

        btn_save.Text = "Save";

        rb_pay_cash.Checked = false;

        rb_pay_online.Checked = false;

    }



    private string GetSelectedPaymentMode()

    {

        if (rb_pay_cash.Checked) return "Cash";

        if (rb_pay_online.Checked) return "Online";

        return "";

    }



    private static string FormatDateForInput(object value)

    {

        if (value == null || value == DBNull.Value)

            return DateTime.Today.ToString("yyyy-MM-dd");

        DateTime d;

        if (value is DateTime)

            d = (DateTime)value;

        else if (!DateTime.TryParse(value.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out d))

            DateTime.TryParse(value.ToString(), out d);

        return d.ToString("yyyy-MM-dd");

    }



    private static string ParseRowAmount(object value)

    {

        decimal amt = ParseDecimal(value);

        return amt.ToString(CultureInfo.InvariantCulture);

    }



    private static void SetBalanceLabel(Label lbl, decimal balance)

    {

        if (lbl == null) return;

        lbl.Text = "₹" + FormatBalanceAmount(balance);

        lbl.CssClass = GetBalanceCssClass(balance);

    }



    private static string GetBalanceCssClass(decimal balance)

    {

        if (balance < 0) return "bal-recv";

        if (balance > 0) return "bal-pay";

        return "";

    }



    private static string GetBalanceHint(decimal balance)

    {

        if (balance < 0) return "Receivable";

        if (balance > 0) return "Payable";

        return "Settled";

    }



    private static string FormatBalanceAmount(decimal balance)

    {

        return Math.Abs(balance).ToString("N2", Ci);

    }



    private static decimal ParseDecimal(object value)

    {

        if (value == null || value == DBNull.Value)

            return 0m;

        if (value is decimal)

            return (decimal)value;

        decimal amt;

        decimal.TryParse(value.ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt);

        return amt;

    }



    private static int ParseInt(object value)

    {

        if (value == null || value == DBNull.Value)

            return 0;

        if (value is int)

            return (int)value;

        if (value is bool)

            return (bool)value ? 1 : 0;

        int n;

        int.TryParse(value.ToString(), out n);

        return n;

    }

}


