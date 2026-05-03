using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;

/// <summary>
/// Summary description for BAL_Party
/// </summary>
public class BAL_Party
{
    public BAL_Party()
    {
        //
        // TODO: Add constructor logic here
        //
    }


    public static DataSet ins_party(string name, string contact_person, string mobile_no, string address, string gst_no, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_party_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@contact_person", contact_person));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@address", address));
        cmd.Parameters.Add(param.stringparam("@gst_no", gst_no));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }


    public static DataSet upd_party(string id, string name, string contact_person, string mobile_no, string address, string gst_no, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_party_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id)); // BIGINT માટે intparam અથવા longparam
        cmd.Parameters.Add(param.stringparam("@name", name));
        cmd.Parameters.Add(param.stringparam("@contact_person", contact_person));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@address", address));
        cmd.Parameters.Add(param.stringparam("@gst_no", gst_no));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_party_by_id(string id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_party_by_id_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id)); // BIGINT માટે ID પાસ કરો
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_party()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_party_sp";
        // આમાં કોઈ પેરામીટરની જરૂર નથી કારણ કે આપણે બધા રેકોર્ડ જોઈએ છે
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_party(string id, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_party_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.intparam("@id", id));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}