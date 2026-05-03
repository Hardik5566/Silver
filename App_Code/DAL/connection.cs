using System;
using System.Configuration;
using System.Data.SqlClient;

/// <summary>
/// Summary description for connection
/// </summary>

public class connection
{
	public connection()
	{
		//
		// TODO: Add constructor logic here
		//
	}

    public static SqlConnection open_connection()
    {
        SqlConnection cn = new SqlConnection(ConfigurationManager.ConnectionStrings["myConnectionString"].ToString());
        cn.Open();
        return cn;
    }


    // Backward-compatible helper in case any legacy code passes an open connection.
    public static void close_connection(SqlConnection cn)
    {
        if (cn != null)
        {
            cn.Close();
            cn.Dispose();
        }
    }
}