using System.Data;
using System.Data.SqlClient;
using System.Globalization;

/// <summary>Read-only report queries (inward, etc.).</summary>
public class BAL_Report
{
    public static DataSet dis_inward_monthly_report(string from_date, string to_date, int party_id)
    {
        SqlCommand cmd = new SqlCommand { CommandText = "dis_inward_monthly_report_sp" };
        parameter p = new parameter();
        cmd.Parameters.Add(p.stringparam("@from_date", from_date));
        cmd.Parameters.Add(p.stringparam("@to_date", to_date));
        cmd.Parameters.Add(p.intparam("@party_id", party_id.ToString(CultureInfo.InvariantCulture)));
        return command.ExtQueryDS(cmd);
    }
}
