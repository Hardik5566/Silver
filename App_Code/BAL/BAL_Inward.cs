using System.Data;
using System.Data.SqlClient;

public class BAL_Inward
{
    public static DataSet dis_active_inward_list()
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_active_inward_list_sp" };
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_inward_report(string from_date, string to_date, string party_id, string include_deleted)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_inward_report_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.intparam("@include_deleted", include_deleted));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet get_inward_for_edit(string inward_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "get_inward_for_edit_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_id", inward_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet sel_inward_lines_for_out(string inward_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_inward_lines_for_out_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_id", inward_id));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_inward_challan(string party_id, string challan_no, string inward_date, string remarks, string by,
        string part_ids, string qtys, string rates)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_inward_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.stringparam("@challan_no", challan_no));
        cmd.Parameters.Add(p.stringparam("@inward_date", inward_date));
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

    public static DataSet upd_inward_challan(string inward_id, string party_id, string challan_no, string inward_date, string remarks, string by,
        string part_ids, string qtys, string rates)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_inward_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_id", inward_id));
        cmd.Parameters.Add(p.stringparam("@party_id", party_id));
        cmd.Parameters.Add(p.stringparam("@challan_no", challan_no));
        cmd.Parameters.Add(p.stringparam("@inward_date", inward_date));
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

    public static DataSet dlt_inward_challan(string inward_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_inward_challan_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_id", inward_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet ins_outward_line(string inward_detail_id, string qty_out, string slip_no, string remarks, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "ins_outward_line_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_detail_id", inward_detail_id));
        cmd.Parameters.Add(p.stringparam("@qty_out", qty_out));
        cmd.Parameters.Add(p.stringparam("@slip_no", slip_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet upd_outward_history(string outward_history_id, string qty_out, string slip_no, string remarks, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "upd_outward_history_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@outward_history_id", outward_history_id));
        cmd.Parameters.Add(p.stringparam("@qty_out", qty_out));
        cmd.Parameters.Add(p.stringparam("@slip_no", slip_no ?? ""));
        cmd.Parameters.Add(p.stringparam("@remarks", remarks ?? ""));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dlt_outward_history(string outward_history_id, string by)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dlt_outward_history_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@outward_history_id", outward_history_id));
        cmd.Parameters.Add(p.stringparam("@by", by));
        return command.ExtQueryDS(cmd);
    }

    public static DataSet dis_outward_history_by_inward(string inward_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_outward_history_by_inward_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@inward_id", inward_id));
        return command.ExtQueryDS(cmd);
    }
}
