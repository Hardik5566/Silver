using System.Data;
using System.Data.SqlClient;

public class BAL_JobworkChallan
{
    public static DataSet dis_active_jobwork_challan_list()
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_active_jobwork_challan_list_sp" };
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_jobwork_challan_report(string from_date, string to_date, string jobwork_party_id, string include_deleted)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_jobwork_challan_report_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(p.intparam("@include_deleted", include_deleted));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_jobwork_receive_history(string from_date, string to_date, string jobwork_party_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_jobwork_receive_history_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_jobwork_challan_for_edit(string jobwork_challan_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "get_jobwork_challan_for_edit_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_challan_id", jobwork_challan_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_jobwork_lines_for_return(string jobwork_challan_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_jobwork_lines_for_return_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_challan_id", jobwork_challan_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_jobwork_challan(string jobwork_party_id, string challan_date, string remarks, string by,
        string part_ids, string qtys, string rates)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_jobwork_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(p.stringparam("@challan_date", challan_date));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        part_ids = part_ids ?? "";
        qtys = qtys ?? "";
        rates = rates ?? "";
        cmd.Parameters.Add(p.stringparam("@part_ids", part_ids.EndsWith(",") ? part_ids : part_ids + ","));
        cmd.Parameters.Add(p.stringparam("@qtys", qtys.EndsWith(",") ? qtys : qtys + ","));
        cmd.Parameters.Add(p.stringparam("@rates", rates.EndsWith(",") ? rates : rates + ","));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_jobwork_challan(string jobwork_challan_id, string jobwork_party_id, string challan_date, string remarks, string by,
        string part_ids, string qtys, string rates)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_jobwork_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_challan_id", jobwork_challan_id));
        cmd.Parameters.Add(p.stringparam("@jobwork_party_id", jobwork_party_id));
        cmd.Parameters.Add(p.stringparam("@challan_date", challan_date));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        part_ids = part_ids ?? "";
        qtys = qtys ?? "";
        rates = rates ?? "";
        cmd.Parameters.Add(p.stringparam("@part_ids", part_ids.EndsWith(",") ? part_ids : part_ids + ","));
        cmd.Parameters.Add(p.stringparam("@qtys", qtys.EndsWith(",") ? qtys : qtys + ","));
        cmd.Parameters.Add(p.stringparam("@rates", rates.EndsWith(",") ? rates : rates + ","));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_jobwork_challan(string jobwork_challan_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_jobwork_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_challan_id", jobwork_challan_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_jobwork_return_line(string jobwork_detail_id, string qty_perfect, string qty_reject, string slip_no, string remarks, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_jobwork_return_line_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_detail_id", jobwork_detail_id));
        cmd.Parameters.Add(p.stringparam("@qty_perfect", qty_perfect ?? "0"));
        cmd.Parameters.Add(p.stringparam("@qty_reject", qty_reject ?? "0"));
        cmd.Parameters.Add(p.stringparam("@slip_no", slip_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_jobwork_return_history_by_challan(string jobwork_challan_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_jobwork_return_history_by_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_challan_id", jobwork_challan_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_jobwork_return_history(string jobwork_return_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_jobwork_return_history_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@jobwork_return_id", jobwork_return_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }
}
