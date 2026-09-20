using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace _24_1639DelMundoPersonalPortfolio.Data
{
    /// <summary>
    /// DatabaseHelper provides centralized connection management and ADO.NET utility methods
    /// for interacting with Microsoft SQL Server (MSSQL).
    /// </summary>
    public static class DatabaseHelper
    {
        /// <summary>
        /// Gets the active connection string. Automatically detects whether the application is running
        /// locally (localhost / 127.0.0.1 / ::1 / Debug) to use PortfolioDB_Local, or remotely to use PortfolioDB_Remote.
        /// </summary>
        public static string ConnectionString
        {
            get
            {
                try
                {
                    var context = HttpContext.Current;
                    if (context != null && context.Request != null)
                    {
                        bool isLocal = context.Request.IsLocal ||
                                       context.Request.Url.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
                                       context.Request.Url.Host.Equals("127.0.0.1") ||
                                       context.Request.Url.Host.Equals("::1");

                        if (isLocal)
                        {
                            var localConn = ConfigurationManager.ConnectionStrings["PortfolioDB_Local"]?.ConnectionString;
                            if (!string.IsNullOrEmpty(localConn)) return localConn;
                        }
                        else
                        {
                            var remoteConn = ConfigurationManager.ConnectionStrings["PortfolioDB_Remote"]?.ConnectionString;
                            if (!string.IsNullOrEmpty(remoteConn)) return remoteConn;
                        }
                    }
                    else
                    {
#if DEBUG
                        var localDebug = ConfigurationManager.ConnectionStrings["PortfolioDB_Local"]?.ConnectionString;
                        if (!string.IsNullOrEmpty(localDebug)) return localDebug;
#endif
                    }
                }
                catch
                {
                    // Fall back gracefully if context is unavailable
                }

                return ConfigurationManager.ConnectionStrings["PortfolioDB"]?.ConnectionString ??
                       ConfigurationManager.ConnectionStrings["PortfolioDb"]?.ConnectionString;
            }
        }

        /// <summary>
        /// Retrieves an open SqlConnection.
        /// </summary>
        public static SqlConnection GetOpenConnection()
        {
            if (string.IsNullOrEmpty(ConnectionString))
            {
                throw new InvalidOperationException("Connection string 'PortfolioDB' is missing or not configured in Web.config.");
            }

            var connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }

        /// <summary>
        /// Executes a non-query command (INSERT, UPDATE, DELETE) and returns rows affected.
        /// </summary>
        public static int ExecuteNonQuery(string query, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(query, conn))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Executes a query and returns a single scalar value.
        /// </summary>
        public static object ExecuteScalar(string query, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(query, conn))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                return cmd.ExecuteScalar();
            }
        }

        /// <summary>
        /// Executes a query and fills a DataTable with the results.
        /// </summary>
        public static DataTable ExecuteDataTable(string query, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(query, conn))
            {
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var table = new DataTable();
                    adapter.Fill(table);
                    return table;
                }
            }
        }

        /// <summary>
        /// Alias for ExecuteDataTable for compatibility.
        /// </summary>
        public static DataTable ExecuteQuery(string query, params SqlParameter[] parameters)
        {
            return ExecuteDataTable(query, parameters);
        }

        /// <summary>
        /// Executes a Stored Procedure and returns a DataTable.
        /// </summary>
        public static DataTable ExecuteStoredProcedureDataTable(string procedureName, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(procedureName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var table = new DataTable();
                    adapter.Fill(table);
                    return table;
                }
            }
        }

        /// <summary>
        /// Executes a Stored Procedure and returns rows affected.
        /// </summary>
        public static int ExecuteStoredProcedureNonQuery(string procedureName, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(procedureName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                return cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Executes a Stored Procedure and returns a single scalar value.
        /// </summary>
        public static object ExecuteStoredProcedureScalar(string procedureName, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(procedureName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }
                return cmd.ExecuteScalar();
            }
        }

        /// <summary>
        /// Executes a Stored Procedure and returns a DataSet with multiple result sets.
        /// </summary>
        public static DataSet ExecuteStoredProcedureDataSet(string procedureName, params SqlParameter[] parameters)
        {
            using (var conn = GetOpenConnection())
            using (var cmd = new SqlCommand(procedureName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null && parameters.Length > 0)
                {
                    cmd.Parameters.AddRange(parameters);
                }

                using (var adapter = new SqlDataAdapter(cmd))
                {
                    var ds = new DataSet();
                    adapter.Fill(ds);
                    return ds;
                }
            }
        }
    }
}

