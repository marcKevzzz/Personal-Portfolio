using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1639DelMundoPersonalPortfolio.Data
{
    /// <summary>
    /// DatabaseHelper provides centralized connection management and ADO.NET utility methods
    /// for interacting with Microsoft SQL Server (MSSQL).
    /// </summary>
    public static class DatabaseHelper
    {
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["PortfolioDB"]?.ConnectionString ??
            ConfigurationManager.ConnectionStrings["PortfolioDb"]?.ConnectionString;

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
    }
}
