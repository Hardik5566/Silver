using System.Data;
using System.Data.SqlClient;

public class BAL_Account
{
    public static DataSet dis_account_outstanding(string account_type, string search)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_account_outstanding_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@account_type", account_type ?? ""));
        cmd.Parameters.Add(p.stringparam("@search", search ?? ""));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_account_ledger(string account_type, string account_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_account_ledger_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@account_type", account_type ?? ""));
        cmd.Parameters.Add(p.stringparam("@account_id", account_id ?? ""));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_ledger_payment(string account_type, string account_id, string payment_date,
        string ref_no, string note, string amount, string payment_mode, string dr_cr, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_ledger_payment_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@account_type", account_type ?? ""));
        cmd.Parameters.Add(p.stringparam("@account_id", account_id ?? ""));
        cmd.Parameters.Add(p.stringparam("@payment_date", payment_date));
        cmd.Parameters.Add(p.stringparam("@ref_no", ref_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@note", note ?? ""));
        cmd.Parameters.Add(p.stringparam("@amount", amount));
        cmd.Parameters.Add(p.stringparam("@payment_mode", payment_mode ?? ""));
        cmd.Parameters.Add(p.stringparam("@dr_cr", dr_cr ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
