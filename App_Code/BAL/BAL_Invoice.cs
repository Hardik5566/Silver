using System.Data;
using System.Data.SqlClient;

public class BAL_Invoice
{
    public static DataSet sel_inward_lines_for_invoice(string party_id, string from_date, string to_date, string inward_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_inward_lines_for_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@inward_id", string.IsNullOrWhiteSpace(inward_id) ? "0" : inward_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_inward_challan_invoice_status(string from_date, string to_date, string party_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_inward_challan_invoice_status_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@party_id", string.IsNullOrWhiteSpace(party_id) ? "0" : party_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_invoice_list(string from_date, string to_date, string party_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_invoice_list_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@party_id", string.IsNullOrWhiteSpace(party_id) ? "0" : party_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_invoice_for_edit(string invoice_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "get_invoice_for_edit_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@invoice_id", invoice_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_invoice(string party_id, string invoice_kind, string invoice_date, string remarks, string by,
        string inward_detail_ids, string qtys)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.stringparam("@invoice_kind", invoice_kind));
        cmd.Parameters.Add(p.stringparam("@invoice_date", invoice_date));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        inward_detail_ids = inward_detail_ids ?? "";
        qtys = qtys ?? "";
        cmd.Parameters.Add(p.stringparam("@inward_detail_ids", inward_detail_ids.EndsWith(",") ? inward_detail_ids : inward_detail_ids + ","));
        cmd.Parameters.Add(p.stringparam("@qtys", qtys.EndsWith(",") ? qtys : qtys + ","));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_invoice(string invoice_id, string party_id, string invoice_kind, string invoice_date, string remarks, string by,
        string inward_detail_ids, string qtys)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@invoice_id", invoice_id));
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.stringparam("@invoice_kind", invoice_kind));
        cmd.Parameters.Add(p.stringparam("@invoice_date", invoice_date));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        inward_detail_ids = inward_detail_ids ?? "";
        qtys = qtys ?? "";
        cmd.Parameters.Add(p.stringparam("@inward_detail_ids", inward_detail_ids.EndsWith(",") ? inward_detail_ids : inward_detail_ids + ","));
        cmd.Parameters.Add(p.stringparam("@qtys", qtys.EndsWith(",") ? qtys : qtys + ","));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_invoice(string invoice_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_invoice_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@invoice_id", invoice_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
