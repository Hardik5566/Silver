using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Expense_Tracker : Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    public enum Msg { Success, Error, Warning }

    private string GetSelectedPaymentMode()
    {
        if (rb_pay_cash.Checked)
            return "Cash";
        if (rb_pay_online.Checked)
            return "Online";
        return "";
    }

    private void ClearPaymentMode()
    {
        rb_pay_cash.Checked = false;
        rb_pay_online.Checked = false;
    }

    private void SetPaymentMode(string pm)
    {
        rb_pay_cash.Checked = false;
        rb_pay_online.Checked = false;
        if (string.Equals(pm, "Cash", StringComparison.OrdinalIgnoreCase))
            rb_pay_cash.Checked = true;
        else if (string.Equals(pm, "Online", StringComparison.OrdinalIgnoreCase))
            rb_pay_online.Checked = true;
    }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

    private static void ShowExpenseModal(Page page)
    {
        ScriptManager.RegisterStartupScript(page, page.GetType(), "showExpModal",
            "var el=document.getElementById('modal_expense'); if(el&&window.bootstrap){ bootstrap.Modal.getOrCreateInstance(el).show(); }", true);
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
            SetDefaultMonthRange();
            BindUserDropdown();
            txt_exp_date.Text = DateTime.Today.ToString("yyyy-MM-dd");
            hd_action.Value = "save";
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

    private void BindUserDropdown()
    {
        ddl_user.Items.Clear();
        ddl_user.Items.Add(new ListItem("-- Select user --", "0"));
        DataSet ds = BAL_User.dis_user();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_user.Items.Add(new ListItem(r["full_name"].ToString(), r["user_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_Expense.dis_expense(txt_from.Text, txt_to.Text);
        DataTable expenses = ds.Tables.Count > 0 ? ds.Tables[0] : null;

        grid_exp.DataSource = expenses;
        grid_exp.DataBind();

        BindUserSummary(expenses);
    }

    private void BindUserSummary(DataTable expenses)
    {
        DataTable table = BuildSummaryFromExpenses(expenses);

        grid_user_sum.DataSource = table;
        grid_user_sum.DataBind();

        decimal sumAmt = 0m;
        long sumEntries = 0;
        if (table != null)
        {
            foreach (DataRow r in table.Rows)
            {
                if (r["entry_count"] != DBNull.Value)
                    sumEntries += Convert.ToInt64(r["entry_count"], CultureInfo.InvariantCulture);
                if (r["total_amount"] != DBNull.Value)
                    sumAmt += Convert.ToDecimal(r["total_amount"], CultureInfo.InvariantCulture);
            }
        }

        if (grid_user_sum.FooterRow != null)
        {
            bool hasRows = table != null && table.Rows.Count > 0;
            grid_user_sum.FooterRow.Visible = hasRows;
            if (hasRows)
            {
                grid_user_sum.FooterRow.TableSection = TableRowSection.TableFooter;
                grid_user_sum.FooterRow.Cells[0].ColumnSpan = 2;
                grid_user_sum.FooterRow.Cells[0].Text = "Grand total";
                grid_user_sum.FooterRow.Cells[0].HorizontalAlign = HorizontalAlign.Right;
                grid_user_sum.FooterRow.Cells.RemoveAt(1);

                grid_user_sum.FooterRow.Cells[1].Text = sumEntries.ToString("N0", Ci);
                grid_user_sum.FooterRow.Cells[1].HorizontalAlign = HorizontalAlign.Right;

                grid_user_sum.FooterRow.Cells[2].Text = sumAmt.ToString("C2", Ci);
                grid_user_sum.FooterRow.Cells[2].HorizontalAlign = HorizontalAlign.Right;
            }
        }
    }

    private sealed class ExpenseMonthUserSum
    {
        public DateTime MonthStart;
        public string UserName;
        public long EntryCount;
        public decimal TotalAmount;
    }

    private static DataTable BuildSummaryFromExpenses(DataTable expenses)
    {
        var table = new DataTable();
        table.Columns.Add("month_label", typeof(string));
        table.Columns.Add("user_name", typeof(string));
        table.Columns.Add("entry_count", typeof(long));
        table.Columns.Add("total_amount", typeof(decimal));

        if (expenses == null || expenses.Rows.Count == 0)
            return table;

        var map = new Dictionary<string, ExpenseMonthUserSum>(StringComparer.Ordinal);

        foreach (DataRow r in expenses.Rows)
        {
            DateTime ed = ParseExpenseDate(r["expense_date"]);
            var monthStart = new DateTime(ed.Year, ed.Month, 1);
            string userId = r["user_id"] != DBNull.Value ? r["user_id"].ToString() : "0";
            string key = monthStart.ToString("yyyy-MM", CultureInfo.InvariantCulture) + "|" + userId;

            ExpenseMonthUserSum row;
            if (!map.TryGetValue(key, out row))
            {
                row = new ExpenseMonthUserSum
                {
                    MonthStart = monthStart,
                    UserName = r["user_name"] != DBNull.Value ? r["user_name"].ToString() : "—",
                    EntryCount = 0,
                    TotalAmount = 0m
                };
                map[key] = row;
            }

            row.EntryCount++;
            row.TotalAmount += ParseAmount(r["amount"]);
        }

        var list = new List<ExpenseMonthUserSum>(map.Values);
        list.Sort((a, b) =>
        {
            int c = b.MonthStart.CompareTo(a.MonthStart);
            return c != 0 ? c : string.Compare(a.UserName, b.UserName, StringComparison.CurrentCultureIgnoreCase);
        });

        foreach (ExpenseMonthUserSum s in list)
            table.Rows.Add(s.MonthStart.ToString("MMMM yyyy", Ci), s.UserName, s.EntryCount, s.TotalAmount);

        return table;
    }

    private static DateTime ParseExpenseDate(object value)
    {
        if (value == null || value == DBNull.Value)
            return DateTime.Today;
        if (value is DateTime)
            return (DateTime)value;
        DateTime d;
        if (DateTime.TryParse(value.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out d))
            return d;
        DateTime.TryParse(value.ToString(), out d);
        return d;
    }

    private static decimal ParseAmount(object value)
    {
        if (value == null || value == DBNull.Value)
            return 0m;
        if (value is decimal)
            return (decimal)value;
        decimal amt;
        decimal.TryParse(value.ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt);
        return amt;
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void grid_exp_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument != null ? e.CommandArgument.ToString() : "";

        if (e.CommandName == "edt")
        {
            DataSet ds = BAL_Expense.sel_expense_by_id(id);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                ShowMsg("Expense not found.", Msg.Warning);
                return;
            }

            DataRow r = ds.Tables[0].Rows[0];
            hd_expense_id.Value = id;
            hd_action.Value = "upd";
            lbl_modal_title.Text = "Edit expense";
            btn_save.Text = "Update";

            ddl_user.SelectedValue = r["user_id"].ToString();

            DateTime ed = DateTime.Today;
            object od = r["expense_date"];
            if (od != DBNull.Value)
            {
                if (od is DateTime)
                    ed = (DateTime)od;
                else if (!DateTime.TryParse(od.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out ed))
                    DateTime.TryParse(od.ToString(), out ed);
            }
            txt_exp_date.Text = ed.ToString("yyyy-MM-dd");

            decimal amt = 0;
            object oa = r["amount"];
            if (oa is decimal)
                amt = (decimal)oa;
            else
                decimal.TryParse(oa.ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt);
            txt_amount.Text = amt.ToString(CultureInfo.InvariantCulture);

            string pm = (r["payment_mode"] ?? "").ToString();
            SetPaymentMode(pm);

            txt_note.Text = r["note"] != DBNull.Value ? r["note"].ToString() : "";

            ShowExpenseModal(this);
            return;
        }

        if (e.CommandName == "dlt")
        {
            string by = Session["user_id"].ToString();
            DataSet ds = BAL_Expense.dlt_expense(id, by);
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
        if (ddl_user.SelectedValue == "0")
        {
            ShowMsg("Select user.", Msg.Warning);
            return;
        }
        if (string.IsNullOrWhiteSpace(GetSelectedPaymentMode()))
        {
            ShowMsg("Select payment mode (Cash or Online).", Msg.Warning);
            return;
        }
        decimal amt;
        if (!decimal.TryParse(txt_amount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt) || amt <= 0)
        {
            ShowMsg("Enter a valid amount greater than zero.", Msg.Warning);
            return;
        }

        string by = Session["user_id"].ToString();
        string amtStr = amt.ToString(CultureInfo.InvariantCulture);
        string payMode = GetSelectedPaymentMode();
        bool isUpd = string.Equals(hd_action.Value, "upd", StringComparison.OrdinalIgnoreCase);

        DataSet ds;
        if (isUpd)
        {
            if (string.IsNullOrWhiteSpace(hd_expense_id.Value))
            {
                ShowMsg("Missing expense id.", Msg.Warning);
                return;
            }
            ds = BAL_Expense.upd_expense(
                hd_expense_id.Value,
                ddl_user.SelectedValue,
                txt_exp_date.Text,
                amtStr,
                txt_note.Text,
                payMode,
                by);
        }
        else
        {
            ds = BAL_Expense.ins_expense(
                ddl_user.SelectedValue,
                txt_exp_date.Text,
                amtStr,
                txt_note.Text,
                payMode,
                by);
        }

        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Success);
                txt_amount.Text = "";
                txt_note.Text = "";
                ClearPaymentMode();
                hd_expense_id.Value = "";
                hd_action.Value = "save";
                lbl_modal_title.Text = "Add expense";
                btn_save.Text = "Save";
                BindGrid();
                ScriptManager.RegisterStartupScript(this, GetType(), "closeExpModal",
                    "var el=document.getElementById('modal_expense'); if(el&&window.bootstrap){ var m=bootstrap.Modal.getInstance(el); if(m) m.hide(); }", true);
            }
            else
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
        }
    }
}
