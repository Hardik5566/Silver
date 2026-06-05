using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Account_Ledger : Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");
    private bool _isPayableBalance;

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            BindAccountDropdown();
            ApplyQueryString();
            if (ddl_account.SelectedValue != "0")
                BindLedger();
        }
    }

    protected string FormatAmt(object value)
    {
        return ParseDecimal(value).ToString("N2", Ci);
    }

    protected string FormatBalance(object value)
    {
        return FormatBalanceAmount(ParseDecimal(value), _isPayableBalance);
    }

    protected string GetBalanceCss()
    {
        return _isPayableBalance ? "bal-pay" : "bal-recv";
    }

    private static string FormatBalanceAmount(decimal balance, bool isPayable)
    {
        return Math.Abs(balance).ToString("N2", Ci);
    }

    private static string FormatBalanceMoney(decimal balance, bool isPayable)
    {
        return "₹" + FormatBalanceAmount(balance, isPayable);
    }

    private void ApplyQueryString()
    {
        string type = Request.QueryString["account_type"];
        string id = Request.QueryString["account_id"];
        if (!string.IsNullOrWhiteSpace(type))
        {
            ListItem li = ddl_account_type.Items.FindByValue(type.ToUpperInvariant());
            if (li != null)
                ddl_account_type.SelectedValue = li.Value;
        }
        BindAccountDropdown();
        if (!string.IsNullOrWhiteSpace(id))
        {
            ListItem acc = ddl_account.Items.FindByValue(id);
            if (acc != null)
                ddl_account.SelectedValue = id;
        }
    }

    private void BindAccountDropdown()
    {
        ddl_account.Items.Clear();
        ddl_account.Items.Add(new ListItem("-- Select account --", "0"));

        string type = ddl_account_type.SelectedValue;
        DataSet ds = null;

        if (type == "PARTY")
            ds = BAL_Party.dis_party();
        else if (type == "JOBWORK")
            ds = BAL_JobworkParty.dis_jobwork_party();
        else if (type == "STAFF")
            ds = BAL_User.dis_user();

        if (ds == null || ds.Tables.Count == 0)
            return;

        string idCol = type == "PARTY" ? "party_id" : (type == "JOBWORK" ? "jobwork_party_id" : "user_id");
        string nameCol = type == "STAFF" ? "full_name" : "party_name";

        foreach (DataRow r in ds.Tables[0].Rows)
            ddl_account.Items.Add(new ListItem(r[nameCol].ToString(), r[idCol].ToString()));
    }

    protected void ddl_account_type_Changed(object sender, EventArgs e)
    {
        BindAccountDropdown();
        pnl_summary.Visible = false;
        grid_ledger.DataSource = null;
        grid_ledger.DataBind();
    }

    protected void ddl_account_Changed(object sender, EventArgs e)
    {
        BindLedger();
    }

    private void BindLedger()
    {
        if (ddl_account.SelectedValue == "0")
        {
            pnl_summary.Visible = false;
            grid_ledger.DataSource = null;
            grid_ledger.DataBind();
            return;
        }

        DataSet ds = BAL_Account.dis_account_ledger(
            ddl_account_type.SelectedValue,
            ddl_account.SelectedValue);

        if (ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
        {
            ShowMsg("Could not load ledger.", Msg.Warning);
            return;
        }

        DataRow header = ds.Tables[0].Rows[0];
        if (header.Table.Columns.Contains("Success") && header["Success"].ToString() == "False")
        {
            ShowMsg(header["Message"].ToString(), Msg.Warning);
            pnl_summary.Visible = false;
            grid_ledger.DataSource = null;
            grid_ledger.DataBind();
            return;
        }

        string typeLabel = header["account_type_label"].ToString();
        string accName = header["account_name"].ToString();
        string balLabel = header["balance_label"].ToString();
        _isPayableBalance = balLabel == "Payable";
        decimal totalDebit = ParseDecimal(header["period_debit"]);
        decimal totalCredit = ParseDecimal(header["period_credit"]);
        decimal balance = ParseDecimal(header["closing_balance"]);

        lbl_account_title.Text = typeLabel + " — " + accName;
        lbl_total_debit.Text = "₹" + totalDebit.ToString("N2", Ci);
        lbl_total_credit.Text = "₹" + totalCredit.ToString("N2", Ci);
        lbl_balance.Text = FormatBalanceMoney(balance, _isPayableBalance);
        lbl_balance.CssClass = _isPayableBalance ? "bal-pay" : "bal-recv";
        lbl_balance_hint.Text = balLabel;
        pnl_summary.Visible = true;
        SetPaymentLabels(ddl_account_type.SelectedValue);
        if (string.IsNullOrWhiteSpace(txt_pay_date.Text))
            txt_pay_date.Text = DateTime.Today.ToString("yyyy-MM-dd");

        DataTable lines = ds.Tables.Count > 1 ? ds.Tables[1] : null;
        grid_ledger.DataSource = lines;
        grid_ledger.DataBind();

        if (grid_ledger.FooterRow != null && lines != null && lines.Rows.Count > 0)
        {
            grid_ledger.FooterRow.TableSection = TableRowSection.TableFooter;
            Label lblD = grid_ledger.FooterRow.FindControl("lbl_foot_debit") as Label;
            Label lblC = grid_ledger.FooterRow.FindControl("lbl_foot_credit") as Label;
            Label lblB = grid_ledger.FooterRow.FindControl("lbl_foot_balance") as Label;
            if (lblD != null) lblD.Text = totalDebit.ToString("N2", Ci);
            if (lblC != null) lblC.Text = totalCredit.ToString("N2", Ci);
            if (lblB != null)
            {
                lblB.Text = FormatBalanceMoney(balance, _isPayableBalance);
                lblB.CssClass = _isPayableBalance ? "bal-pay" : "bal-recv";
            }
        }
        else if (grid_ledger.FooterRow != null)
            grid_ledger.FooterRow.Visible = false;
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

    private void SetPaymentLabels(string accountType)
    {
        if (accountType == "PARTY")
        {
            lbl_add_payment_btn.Text = "Receive payment";
            lbl_payment_modal_title.Text = "Party payment received";
        }
        else if (accountType == "JOBWORK")
        {
            lbl_add_payment_btn.Text = "Pay jobwork";
            lbl_payment_modal_title.Text = "Jobwork payment";
        }
        else
        {
            lbl_add_payment_btn.Text = "Pay staff";
            lbl_payment_modal_title.Text = "Staff payment";
        }
    }

    private string GetSelectedPaymentMode()
    {
        if (rb_pay_cash.Checked) return "Cash";
        if (rb_pay_online.Checked) return "Online";
        return "";
    }

    protected void btn_save_payment_Click(object sender, EventArgs e)
    {
        if (ddl_account.SelectedValue == "0")
        {
            ShowMsg("Select account first.", Msg.Warning);
            return;
        }

        if (string.IsNullOrWhiteSpace(GetSelectedPaymentMode()))
        {
            ShowMsg("Select payment mode (Cash or Online).", Msg.Warning);
            return;
        }

        decimal amt;
        if (!decimal.TryParse(txt_pay_amount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt) || amt <= 0)
        {
            ShowMsg("Enter a valid amount greater than zero.", Msg.Warning);
            return;
        }

        if (string.IsNullOrWhiteSpace(txt_pay_date.Text))
        {
            ShowMsg("Select payment date.", Msg.Warning);
            return;
        }

        string by = Session["user_id"].ToString();
        DataSet ds = BAL_Account.ins_ledger_payment(
            ddl_account_type.SelectedValue,
            ddl_account.SelectedValue,
            txt_pay_date.Text,
            txt_pay_ref.Text,
            txt_pay_note.Text,
            amt.ToString(CultureInfo.InvariantCulture),
            GetSelectedPaymentMode(),
            by);

        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Success);
                txt_pay_ref.Text = "";
                txt_pay_amount.Text = "";
                txt_pay_note.Text = "";
                rb_pay_cash.Checked = false;
                rb_pay_online.Checked = false;
                BindLedger();
                ScriptManager.RegisterStartupScript(this, GetType(), "closePayModal",
                    "var el=document.getElementById('modal_payment'); if(el&&window.bootstrap){ var m=bootstrap.Modal.getInstance(el); if(m) m.hide(); }", true);
            }
            else
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
        }
    }

    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }
}
