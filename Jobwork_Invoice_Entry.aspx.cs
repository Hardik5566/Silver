using System;
using System.Data;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Invoice_Entry : Page
{
    private static readonly CultureInfo Ci = CultureInfo.GetCultureInfo("en-IN");

    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
    }

    private static void ShowJwiModal(Page page)
    {
        ScriptManager.RegisterStartupScript(page, page.GetType(), "showJwiModal",
            "var el=document.getElementById('modal_jwi'); if(el&&window.bootstrap){ bootstrap.Modal.getOrCreateInstance(el).show(); }", true);
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
            BindJobworkPartyDropdown();
            txt_invoice_date.Text = DateTime.Today.ToString("yyyy-MM-dd");
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

    private void BindJobworkPartyDropdown()
    {
        ddl_jobwork_party.Items.Clear();
        ddl_jobwork_party.Items.Add(new ListItem("-- Select jobwork party --", "0"));
        DataSet ds = BAL_JobworkParty.dis_jobwork_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_jobwork_party.Items.Add(new ListItem(r["party_name"].ToString(), r["jobwork_party_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_JobworkInvoice.dis_jobwork_invoice(txt_from.Text, txt_to.Text);
        grid_jwi.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_jwi.DataBind();
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void grid_jwi_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument != null ? e.CommandArgument.ToString() : "";

        if (e.CommandName == "edt")
        {
            DataSet ds = BAL_JobworkInvoice.sel_jobwork_invoice_by_id(id);
            if (ds == null || ds.Tables.Count == 0 || ds.Tables[0].Rows.Count == 0)
            {
                ShowMsg("Jobwork invoice not found.", Msg.Warning);
                return;
            }

            DataRow r = ds.Tables[0].Rows[0];
            hd_jobwork_invoice_id.Value = id;
            hd_action.Value = "upd";
            lbl_modal_title.Text = "Edit jobwork invoice";
            btn_save.Text = "Update";

            ddl_jobwork_party.SelectedValue = r["jobwork_party_id"].ToString();

            DateTime invDate = DateTime.Today;
            object od = r["invoice_date"];
            if (od != DBNull.Value)
            {
                if (od is DateTime)
                    invDate = (DateTime)od;
                else if (!DateTime.TryParse(od.ToString(), CultureInfo.InvariantCulture, DateTimeStyles.None, out invDate))
                    DateTime.TryParse(od.ToString(), out invDate);
            }
            txt_invoice_date.Text = invDate.ToString("yyyy-MM-dd");
            txt_invoice_no.Text = r["invoice_no"] != DBNull.Value ? r["invoice_no"].ToString() : "";

            decimal amt = 0;
            object oa = r["total_amount"];
            if (oa is decimal)
                amt = (decimal)oa;
            else
                decimal.TryParse(oa.ToString(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt);
            txt_total_amount.Text = amt.ToString(CultureInfo.InvariantCulture);

            ShowJwiModal(this);
            return;
        }

        if (e.CommandName == "dlt")
        {
            string by = Session["user_id"].ToString();
            DataSet ds = BAL_JobworkInvoice.dlt_jobwork_invoice(id, by);
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
        if (ddl_jobwork_party.SelectedValue == "0")
        {
            ShowMsg("Select jobwork party.", Msg.Warning);
            return;
        }

        decimal amt;
        if (!decimal.TryParse(txt_total_amount.Text.Trim(), NumberStyles.Number, CultureInfo.InvariantCulture, out amt) || amt <= 0)
        {
            ShowMsg("Enter a valid amount greater than zero.", Msg.Warning);
            return;
        }

        if (string.IsNullOrWhiteSpace(txt_invoice_date.Text))
        {
            ShowMsg("Select invoice date.", Msg.Warning);
            return;
        }

        string by = Session["user_id"].ToString();
        string amtStr = amt.ToString(CultureInfo.InvariantCulture);
        bool isUpd = string.Equals(hd_action.Value, "upd", StringComparison.OrdinalIgnoreCase);

        DataSet ds;
        if (isUpd)
        {
            if (string.IsNullOrWhiteSpace(hd_jobwork_invoice_id.Value))
            {
                ShowMsg("Missing invoice id.", Msg.Warning);
                return;
            }
            ds = BAL_JobworkInvoice.upd_jobwork_invoice(
                hd_jobwork_invoice_id.Value,
                ddl_jobwork_party.SelectedValue,
                txt_invoice_date.Text,
                txt_invoice_no.Text,
                amtStr,
                by);
        }
        else
        {
            ds = BAL_JobworkInvoice.ins_jobwork_invoice(
                ddl_jobwork_party.SelectedValue,
                txt_invoice_date.Text,
                txt_invoice_no.Text,
                amtStr,
                by);
        }

        if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
        {
            if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Success);
                txt_invoice_no.Text = "";
                txt_total_amount.Text = "";
                hd_jobwork_invoice_id.Value = "";
                hd_action.Value = "save";
                lbl_modal_title.Text = "Add jobwork invoice";
                btn_save.Text = "Save";
                BindGrid();
                ScriptManager.RegisterStartupScript(this, GetType(), "closeJwiModal",
                    "var el=document.getElementById('modal_jwi'); if(el&&window.bootstrap){ var m=bootstrap.Modal.getInstance(el); if(m) m.hide(); }", true);
            }
            else
                ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
        }
    }
}
