using System;
using System.Data;
using System.Web.UI;

public partial class Home : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCounts();
        }
    }

    private void LoadCounts()
    {
        DataSet dsParty = BAL_Party.dis_party();
        lit_count_party.Text = (dsParty.Tables.Count > 0 ? dsParty.Tables[0].Rows.Count : 0).ToString();

        DataSet dsPart = BAL_Part.dis_part("0");
        lit_count_part.Text = (dsPart.Tables.Count > 0 ? dsPart.Tables[0].Rows.Count : 0).ToString();

        DataSet dsUnit = BAL_Unit.sel_unit_grid();
        lit_count_unit.Text = (dsUnit.Tables.Count > 0 ? dsUnit.Tables[0].Rows.Count : 0).ToString();

        DataSet dsUser = BAL_User.dis_user();
        lit_count_user.Text = (dsUser.Tables.Count > 0 ? dsUser.Tables[0].Rows.Count : 0).ToString();
    }
}
