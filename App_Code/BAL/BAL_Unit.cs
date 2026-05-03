using System.Data;
using System.Data.SqlClient;

public class BAL_Unit
{
    public static DataSet ins_unit(string unit_name, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_unit_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@unit_name", unit_name));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_unit(string unit_id, string unit_name, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_unit_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@unit_id", unit_id));
        cmd.Parameters.Add(param.stringparam("@unit_name", unit_name));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_unit_by_id(string id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_unit_by_id_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@id", id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_unit_grid()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_unit_sp";
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_unit(string id, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_unit_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@id", id));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
