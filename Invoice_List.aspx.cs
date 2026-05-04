using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Invoice_List : Page
{
    public enum Msg { Success, Error, Warning }

    protected void ShowMsg(string msg, Msg t)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
            "ShowMessage('" + msg.Replace("'", "\\'") + "','" + t + "');", true);
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
            txt_from.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
            txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            BindParty();
            BindGrid();
        }
    }

    private void BindParty()
    {
        ddl_party.Items.Clear();
        ddl_party.Items.Add(new ListItem("All parties", "0"));
        DataSet ds = BAL_Party.dis_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_party.Items.Add(new ListItem(r["party_name"].ToString(), r["party_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_Invoice.dis_invoice_list(txt_from.Text, txt_to.Text, ddl_party.SelectedValue);
        grid_inv.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_inv.DataBind();
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }

    protected void grid_inv_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "edit")
        {
            Response.Redirect("Invoice_Entry.aspx?id=" + id);
            return;
        }
        if (e.CommandName == "del")
        {
            DataSet ds = BAL_Invoice.dlt_invoice(id, Session["user_id"].ToString());
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (string.Equals(ds.Tables[0].Rows[0]["Success"].ToString(), "true", StringComparison.OrdinalIgnoreCase))
                {
                    ShowMsg("Invoice deleted.", Msg.Success);
                    BindGrid();
                }
                else
                    ShowMsg(ds.Tables[0].Rows[0]["Message"].ToString(), Msg.Warning);
            }
        }
    }
}
