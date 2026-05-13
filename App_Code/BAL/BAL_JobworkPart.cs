using System.Data;
using System.Data.SqlClient;

public class BAL_JobworkPart
{
    public static DataSet ins_jobwork_part(string jobwork_party_id, string part_name, string unit_id, string rate, string tax_per, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_jobwork_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(param.stringparam("@part_name", part_name));
        cmd.Parameters.Add(param.stringparam("@unit_id", unit_id));
        cmd.Parameters.Add(param.stringparam("@rate", rate));
        cmd.Parameters.Add(param.stringparam("@tax_per", tax_per));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_jobwork_part(string jobwork_part_id, string jobwork_party_id, string part_name, string unit_id, string rate, string tax_per, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_jobwork_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@jobwork_part_id", jobwork_part_id));
        cmd.Parameters.Add(param.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(param.stringparam("@part_name", part_name));
        cmd.Parameters.Add(param.stringparam("@unit_id", unit_id));
        cmd.Parameters.Add(param.stringparam("@rate", rate));
        cmd.Parameters.Add(param.stringparam("@tax_per", tax_per));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_jobwork_part_by_id(string id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_jobwork_part_by_id_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@id", id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_jobwork_part(string jobwork_party_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_jobwork_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@jobwork_party_id", jobwork_party_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_jobwork_part(string id, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_jobwork_part_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@id", id));
        cmd.Parameters.Add(param.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_unit()
    {
        return BAL_Part.dis_unit();
    }
}
