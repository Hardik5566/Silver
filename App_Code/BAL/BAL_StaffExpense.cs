using System.Data;
using System.Data.SqlClient;

public class BAL_StaffExpense
{
    public static DataSet dis_staff_expense(string user_id, string from_date, string to_date)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_staff_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_my_staff_account(string user_id, string from_date, string to_date)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_my_staff_account_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_staff_expense_by_id(string staff_expense_id, string user_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_staff_expense_by_id_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@staff_expense_id", staff_expense_id));
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_staff_expense(string user_id, string expense_date, string ref_no, string note, string amount, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_staff_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@expense_date", expense_date));
        cmd.Parameters.Add(p.stringparam("@ref_no", ref_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@note", note ?? ""));
        cmd.Parameters.Add(p.stringparam("@amount", amount));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_staff_expense(string staff_expense_id, string user_id, string expense_date, string ref_no, string note, string amount, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_staff_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@staff_expense_id", staff_expense_id));
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@expense_date", expense_date));
        cmd.Parameters.Add(p.stringparam("@ref_no", ref_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@note", note ?? ""));
        cmd.Parameters.Add(p.stringparam("@amount", amount));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_staff_expense(string staff_expense_id, string user_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_staff_expense_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@staff_expense_id", staff_expense_id));
        cmd.Parameters.Add(p.stringparam("@user_id", user_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
