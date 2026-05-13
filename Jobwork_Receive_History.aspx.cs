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
            BindJobworkParty();
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

    private void BindJobworkParty()
    {
        ddl_jobwork_party.Items.Clear();
        ddl_jobwork_party.Items.Add(new ListItem("All jobwork parties", "0"));
        DataSet ds = BAL_JobworkParty.dis_jobwork_party();
        if (ds.Tables.Count > 0)
        {
            foreach (DataRow r in ds.Tables[0].Rows)
                ddl_jobwork_party.Items.Add(new ListItem(r["party_name"].ToString(), r["jobwork_party_id"].ToString()));
        }
    }

    private void BindGrid()
    {
        DataSet ds = BAL_JobworkChallan.dis_jobwork_receive_history(txt_from.Text, txt_to.Text, ddl_jobwork_party.SelectedValue);
        grid_recv.DataSource = ds.Tables.Count > 0 ? ds.Tables[0] : null;
        grid_recv.DataBind();
    }

    protected void btn_filter_Click(object sender, EventArgs e)
    {
        BindGrid();
    }
}
