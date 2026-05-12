using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Jobwork_Receive_History : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            ApplyPresetFromQuery();
            BindParty();
            BindGrid();
        }
    }

    private void ApplyPresetFromQuery()
    {
        string mode = (Request.QueryString["mode"] ?? "").Trim().ToLowerInvariant();
        if (mode == "today")
        {
            txt_from.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
            return;
        }

        txt_from.Text = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).ToString("yyyy-MM-dd");
        txt_to.Text = DateTime.Today.ToString("yyyy-MM-dd");
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
        DataSet ds = BAL_JobworkChallan.dis_jobwork_receive_history(txt_from.Text, txt_to.Text, ddl_party.SelectedValue);
        grid_recv.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_recv.DataBind();
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
