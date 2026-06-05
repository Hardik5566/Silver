using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Account_Outstanding : Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Session["user_id"] == null)
        {
            Response.Redirect("Default.aspx");
            return;
        }

        if (!IsPostBack)
        {
            ApplyQueryString();
            BindGrid();
        }
    }

    private void ApplyQueryString()
    {
        string type = Request.QueryString["account_type"];
        if (!string.IsNullOrWhiteSpace(type))
        {
            ListItem li = ddl_account_type.Items.FindByValue(type.ToUpperInvariant());
            if (li != null)
                ddl_account_type.SelectedValue = li.Value;
        }
    }

    protected string FormatAmt(object value)
    {
        return ParseDecimal(value).ToString("N2", Ci);
    }

    protected string FormatBalance(object balance, object balanceLabel)
    {
        return Math.Abs(ParseDecimal(balance)).ToString("N2", Ci);
    }

    protected string GetTypeBadgeClass(object accountType)
    {
        string t = accountType != null ? accountType.ToString().ToUpperInvariant() : "";
        if (t == "PARTY") return "badge-party";
        if (t == "JOBWORK") return "badge-jobwork";
        if (t == "STAFF") return "badge-staff";
        return "";
    }

    protected string GetBalanceClass(object balanceLabel)
    {
        string lbl = balanceLabel != null ? balanceLabel.ToString() : "";
        return lbl == "Receivable" ? "bal-recv" : "bal-pay";
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

    private void BindGrid()
    {
        string type = ddl_account_type.SelectedValue ?? "ALL";
        string search = txt_search.Text.Trim();

        DataSet ds = BAL_Account.dis_account_outstanding(type, search);
        DataTable table = ds.Tables.Count > 0 ? ds.Tables[0] : null;

        grid_out.DataSource = table;
        grid_out.DataBind();
    }

    protected void btn_show_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
