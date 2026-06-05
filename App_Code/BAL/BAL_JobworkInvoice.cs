using System.Data;
using System.Data.SqlClient;

public class BAL_JobworkInvoice
{
    public static DataSet dis_jobwork_invoice(string from_date, string to_date)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_jobwork_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_jobwork_invoice_by_id(string jobwork_invoice_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_jobwork_invoice_by_id_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_invoice_id", jobwork_invoice_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_jobwork_invoice(string jobwork_party_id, string invoice_date, string invoice_no, string total_amount, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_jobwork_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(p.stringparam("@invoice_date", invoice_date));
        cmd.Parameters.Add(p.stringparam("@invoice_no", invoice_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@total_amount", total_amount));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_jobwork_invoice(string jobwork_invoice_id, string jobwork_party_id, string invoice_date, string invoice_no, string total_amount, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_jobwork_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_invoice_id", jobwork_invoice_id));
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(p.stringparam("@invoice_date", invoice_date));
        cmd.Parameters.Add(p.stringparam("@invoice_no", invoice_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@total_amount", total_amount));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_jobwork_invoice(string jobwork_invoice_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_jobwork_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_invoice_id", jobwork_invoice_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
