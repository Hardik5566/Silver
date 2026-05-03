using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Part
/// </summary>
public class BAL_Part
{
    public BAL_Part()
    {
        //
        // TODO: Add constructor logic here
        //
    }

    // ૧. નવો પાર્ટ ઉમેરવા માટે (Insert)
    public static DataSet ins_part(string party_id, string part_name, string unit_id, string rate, string tax_per, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@party_id", party_id));
        cmd.Parameters.Add(param.stringparam("@part_name", part_name));
        cmd.Parameters.Add(param.stringparam("@unit_id", unit_id));
        cmd.Parameters.Add(param.stringparam("@rate", rate));
        cmd.Parameters.Add(param.stringparam("@tax_per", tax_per));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    // ૨. પાર્ટની વિગત અપડેટ કરવા માટે (Update)
    public static DataSet upd_part(string part_id, string party_id, string part_name, string unit_id, string rate, string tax_per, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@part_id", part_id));
        cmd.Parameters.Add(param.stringparam("@party_id", party_id));
        cmd.Parameters.Add(param.stringparam("@part_name", part_name));
        cmd.Parameters.Add(param.stringparam("@unit_id", unit_id));
        cmd.Parameters.Add(param.stringparam("@rate", rate));
        cmd.Parameters.Add(param.stringparam("@tax_per", tax_per));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    // ૩. ગ્રીડ વ્યુ માટે - પાર્ટી વાઈઝ લિસ્ટ મેળવવા (Display)
    public static DataSet sel_part_by_id(string id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_part_by_id_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@id", id));
        return command.ExtQueryDS(cmd);
    }

    // ૪. એડિટ કરતી વખતે ચોક્કસ આઈડીનો ડેટા મેળવવા (Select by ID)
    public static DataSet dis_part(string party_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@party_id", party_id));
        return command.ExtQueryDS(cmd);
    }

    // ૫. પાર્ટ ડિલીટ કરવા માટે (Delete)
    public static DataSet dlt_part(string id, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@id", id));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_unit()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_unit";
        return command.ExtQueryDS(cmd);
    }
}