using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;

using System.Data;
using System.Data.SqlClient;
using System.Web.Script.Serialization;

using webVendaSimples.App_Code;

namespace webVendaSimples
{
    /// <summary>
    /// WebService para chamada de funções da base de dados SQL Server
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do script, usando ASP.NET AJAX, remova os comentários da linha a seguir. 
    [System.Web.Script.Services.ScriptService]

    public class ws_funcoes : System.Web.Services.WebService
    {

        class Retorno
        {
            public DateTime dh_server = DateTime.Today;
            public String data = "";
            public String hora = "";
            public String data_hora = "";
            public String retorno = "";

            public void Destroy()
            {
                GC.SuppressFinalize(this);
            }
        }

        [WebMethod]
        public string HelloWorld()
        {
            return "Olá, Mundo";
        }

        // LER DATA/HORA ===========================================================================
        [WebMethod]
        public void DataHora()
        {
            Conexao conn = Conexao.Instance;
            List<Retorno> arr = new List<Retorno>();

            try
            {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql =
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.getDataHora @dh_server OUT, @data OUT, @hora OUT, @data_hora OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@dh_server", ""));
                cmd.Parameters["@dh_server"].Direction = ParameterDirection.InputOutput;
                //cmd.Parameters["@dh_server"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@data", ""));
                cmd.Parameters["@data"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@data"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@hora", ""));
                cmd.Parameters["@hora"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@hora"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@data_hora", ""));
                cmd.Parameters["@data_hora"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@data_hora"].Size = 20;

                cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@retorno"].Size = 250;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Retorno obj = new Retorno();

                //obj.dh_server = DateTime.Parse(cmd.Parameters["@dh_server"].Value.ToString());
                obj.data = Server.HtmlEncode(cmd.Parameters["@data"].Value.ToString());
                obj.hora = Server.HtmlEncode(cmd.Parameters["@hora"].Value.ToString());
                obj.data_hora = Server.HtmlEncode(cmd.Parameters["@data_hora"].Value.ToString());
                obj.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());
                arr.Add(obj);

                //usr = null;
                //cmd = null;
                GC.SuppressFinalize(obj);
                GC.SuppressFinalize(cmd);

                conn.Fechar();
            }
            catch (System.IndexOutOfRangeException e)
            {
                Retorno err = new Retorno();

                err.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                arr.Add(err);

                //err = null;
                GC.SuppressFinalize(err);
            }

            // Serializar JSON
            JavaScriptSerializer js = new JavaScriptSerializer();

            Context.Response.Clear();
            Context.Response.Write(js.Serialize(arr));
            Context.Response.Flush();
            Context.Response.End();
        }
    }
}