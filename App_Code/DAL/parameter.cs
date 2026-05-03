using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

using System.Web;

/// <summary>
/// Summary description for parameter
/// </summary>
public class parameter
{
	public parameter()
	{
		//
		// TODO: Add constructor logic here
		//
	}
    public SqlParameter intparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.DbType = DbType.Int32;
        param.ParameterName = name;
        param.Value = value;
        return param;
    }

    public SqlParameter bigintparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.BigInt;
        param.ParameterName = name;
        long v = 0;
        long.TryParse(value, out v);
        param.Value = v;
        return param;
    }

    public SqlParameter floatparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.DbType = DbType.Double;
        param.ParameterName = name;
        param.Value = value;
        return param;
    }

    public SqlParameter decimalparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.SqlDbType = SqlDbType.Decimal;
        param.ParameterName = name;

        decimal val = 0;
        decimal.TryParse(value, out val);

        param.Value = val;
        return param;
    }


    public SqlParameter stringparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.DbType = DbType.String;
        param.ParameterName = name;
        param.Value = value;
        return param;
    }

    public SqlParameter datetimeparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.DbType = DbType.DateTime;
        param.ParameterName = name;
        param.Value = value;
        return param;
    }

    public SqlParameter boolparam(string name, string value)
    {
        SqlParameter param = new SqlParameter();
        param.DbType = DbType.Boolean;
        param.ParameterName = name;
        param.Value = value;
        return param;
    }

    public SqlParameter tableparam(string name, DataTable table, string typeName)
    {
        SqlParameter param = new SqlParameter();
        param.ParameterName = name;
        param.Value = table ?? (object)DBNull.Value;
        param.SqlDbType = SqlDbType.Structured;
        param.TypeName = typeName;  // e.g., "dbo.InvoiceItemType"
        return param;
    }

}