using System.Data;
using System.Data.SqlClient;

public class BAL_Expense
{
    public static DataSet dis_expense(string from_date, string to_date)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_expense_by_id(string expense_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_expense_by_id_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@expense_id", expense_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_expense(string user_id, string expense_date, string amount, string note, string payment_mode, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@expense_date", expense_date));
        cmd.Parameters.Add(p.stringparam("@amount", amount));
        cmd.Parameters.Add(p.stringparam("@note", note ?? ""));
        cmd.Parameters.Add(p.stringparam("@payment_mode", payment_mode ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_expense(string expense_id, string user_id, string expense_date, string amount, string note, string payment_mode, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@expense_id", expense_id));
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@expense_date", expense_date));
        cmd.Parameters.Add(p.stringparam("@amount", amount));
        cmd.Parameters.Add(p.stringparam("@note", note ?? ""));
        cmd.Parameters.Add(p.stringparam("@payment_mode", payment_mode ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_expense(string expense_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@expense_id", expense_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
