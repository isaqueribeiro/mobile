using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;

namespace webVendaSimples.App_Code
{
    // Classe no modelo Singleton simples
    public sealed class Conexao
    {
        private static readonly Conexao instance = new Conexao();

        private SqlConnection conn;
        private String servidor = "localhost";
        private String banco = "venda_simples_server";
        private String usuario = "sa";
        private String senha = "TheLordIsGod";
        private String strConexao = "";

        private Conexao() {}

        public static Conexao Instance
        {
            get
            {
                return instance;
            }
        }

        public void Conectar()
        {
            strConexao = "Data Source=" + servidor + ";Initial Catalog=" + banco + ";User Id=" + usuario + ";Password=" + senha;
            conn = new SqlConnection(strConexao);
            conn.Open();
        }

        public void Fechar()
        {
            conn.Close();
        }

        public System.Data.SqlClient.SqlConnection Conn()
        {
            return conn;
        }
    }
}