using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Part_Master : System.Web.UI.Page
{
    public enum MessageType { Success, Error, Info, Warning };
    protected void ShowMessage(string Message, MessageType type)
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), System.Guid.NewGuid().ToString(), "ShowMessage('" + Message + "','" + type + "');", true);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            bind_dropdowns();
            bind_data();
        }
    }

    public void bind_dropdowns()
    {
        // Party Dropdown
        DataSet ds_party = BAL_Party.dis_party();
        if (ds_party.Tables.Count > 0)
        {
            ddl_party.DataSource = ds_party.Tables[0];
            ddl_party.DataTextField = "party_name";
            ddl_party.DataValueField = "party_id";
            ddl_party.DataBind();
            ddl_party.Items.Insert(0, new ListItem("-- Select Party --", "0"));

            ddl_filter_party.DataSource = ds_party.Tables[0];
            ddl_filter_party.DataTextField = "party_name";
            ddl_filter_party.DataValueField = "party_id";
            ddl_filter_party.DataBind();
            ddl_filter_party.Items.Insert(0, new ListItem("All Parties", "0"));
        }

        // Unit Dropdown
        DataSet ds_unit = BAL_Part.dis_unit();
        if (ds_unit.Tables.Count > 0)
        {
            ddl_unit.DataSource = ds_unit.Tables[0];
            ddl_unit.DataTextField = "unit_name";
            ddl_unit.DataValueField = "unit_id";
            ddl_unit.DataBind();
            ddl_unit.Items.Insert(0, new ListItem("-- Select Unit --", "0"));
        }
    }

    public void bind_data()
    {
        string party_id = ddl_filter_party.SelectedValue;
        DataSet ds = BAL_Part.dis_part(party_id);
        if (ds.Tables.Count > 0)
        {
            grid_part.DataSource = ds.Tables[0];
            grid_part.DataBind();
        }
    }

    protected void ddl_filter_party_SelectedIndexChanged(object sender, EventArgs e)
    {
        bind_data();
    }

    protected void btn_save_Click(object sender, EventArgs e)
    {
        try
        {
            string by = Session["user_id"].ToString();
            DataSet ds;

            // GST ખાલી હોય તો "0" સેટ કરો
            string gstValue = string.IsNullOrEmpty(txt_tax_per.Text.Trim()) ? "0" : txt_tax_per.Text.Trim();

            if (hd_action.Value == "save")
            {
                // txt_tax_per.Text ને બદલે gstValue પાસ કરો
                ds = BAL_Part.ins_part(ddl_party.SelectedValue, txt_part_name.Text, ddl_unit.SelectedValue, txt_rate.Text, gstValue, by);
            }
            else
            {
                ds = BAL_Part.upd_part(hd_part_id.Value, ddl_party.SelectedValue, txt_part_name.Text, ddl_unit.SelectedValue, txt_rate.Text, gstValue, by);
            }

            if (ds != null && ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                if (ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
                {
                    ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Success);
                    bind_data();
                    // સેવ થયા પછી ફીલ્ડ ક્લીયર કરવા માટે (Optional)
                    txt_part_name.Text = txt_tax_per.Text = txt_rate.Text = "";
                }
                else
                {
                    ShowMessage(ds.Tables[0].Rows[0]["Message"].ToString(), MessageType.Warning);
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage(ex.Message, MessageType.Error);
        }
    }

    protected void grid_part_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        string id = e.CommandArgument.ToString();
        if (e.CommandName == "btn_edit")
        {
            DataSet ds = BAL_Part.sel_part_by_id(id);
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
            {
                DataRow dr = ds.Tables[0].Rows[0];
                ddl_party.SelectedValue = dr["party_id"].ToString();
                txt_part_name.Text = dr["part_name"].ToString();
                ddl_unit.SelectedValue = dr["unit_id"].ToString();
                txt_rate.Text = dr["rate"].ToString();
                txt_tax_per.Text = dr["tax_per"].ToString();
                hd_part_id.Value = id;
                hd_action.Value = "update";
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowModal", "showModal();", true);
            }
        }
        else if (e.CommandName == "btn_delete")
        {
            DataSet ds = BAL_Part.dlt_part(id, Session["user_id"].ToString());
            if (ds.Tables.Count > 0 && ds.Tables[0].Rows[0]["Success"].ToString().ToLower() == "true")
            {
                ShowMessage("Part Deleted Successfully", MessageType.Success);
                bind_data();
            }
        }
    }
}