using System;
using System.Data;
using System.Data.SqlClient;

public class BAL_User
{
    public static DataSet user_login(string login_key, string password)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "user_login_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@login_key", login_key ?? ""));
        cmd.Parameters.Add(param.stringparam("@password", password ?? ""));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_user(string full_name, string mobile_no, string email, string password, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "ins_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.stringparam("@full_name", full_name));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@email", email ?? ""));
        cmd.Parameters.Add(param.stringparam("@password", password));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_user(string user_id, string full_name, string mobile_no, string email, string password, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "upd_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@user_id", user_id));
        cmd.Parameters.Add(param.stringparam("@full_name", full_name));
        cmd.Parameters.Add(param.stringparam("@mobile_no", mobile_no));
        cmd.Parameters.Add(param.stringparam("@email", email ?? ""));
        cmd.Parameters.Add(param.stringparam("@password", password ?? ""));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_user_by_id(string user_id)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "sel_user_by_id_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_user()
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dis_user_sp";
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_user(string user_id, string by)
    {
        SqlCommand cmd = new SqlCommand();
        cmd.CommandText = "dlt_user_sp";
        parameter param = new parameter();
        cmd.Parameters.Add(param.bigintparam("@user_id", user_id));
        cmd.Parameters.Add(param.intparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
