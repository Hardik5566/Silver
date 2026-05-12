using System.Data;
using System.Data.SqlClient;

public class BAL_JobworkParty
{
    public static DataSet ins_jobwork_party(string name, string contact_person, string mobile_no, string address, string gst_no, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_jobwork_party_sp" };
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@contact_person", contact_person ?? ""));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no ?? ""));
        cmd.Parameters.Add(param.stringparam("@address", address ?? ""));
        cmd.Parameters.Add(param.stringparam("@gst_no", gst_no ?? ""));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_jobwork_party(string id, string name, string contact_person, string mobile_no, string address, string gst_no, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_jobwork_party_sp" };
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id));
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@contact_person", contact_person ?? ""));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no ?? ""));
        cmd.Parameters.Add(param.stringparam("@address", address ?? ""));
        cmd.Parameters.Add(param.stringparam("@gst_no", gst_no ?? ""));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_jobwork_party_by_id(string id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_jobwork_party_by_id_sp" };
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_jobwork_party()
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_jobwork_party_sp" };
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_jobwork_party(string id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_jobwork_party_sp" };
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
