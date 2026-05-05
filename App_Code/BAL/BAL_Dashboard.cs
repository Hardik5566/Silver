using System.Data;
using System.Data.SqlClient;

public class BAL_Dashboard
{
    public static DataSet sel_dashboard_counts()
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_dashboard_counts_sp" };
        return command.ExtQueryDS(cmd);
    }

    public static DataTable sel_dashboard_trend_30days()
    {
        SqlCommand cmd = new SqlCommand { CommandText = "sel_dashboard_trend_30days_sp" };
        return command.ExtQueryDT(cmd);
    }
}

