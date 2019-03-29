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

    class Usuario
    {
        public String id;
        public int codigo;
        public String nome;
        public String email;
        public String token;
        public int plataforma = 0;

        public String retorno = "";
    }

    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do script, usando ASP.NET AJAX. 
    [System.Web.Script.Services.ScriptService]

    public class ws_usuario : System.Web.Services.WebService
    {

        [WebMethod]
        public string HelloWorld()
        {
            return "Olá, Mundo";
        }

        [WebMethod]
        public void ValidarLogin(String email, String senha)
        {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);

            try
            {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql = 
                    "SET FORMATDATE DMY " +
                    "EXECUTE getValidarLogin(@email, @senha, @id  OUT, @codigo OUT, @nome OUT, @retorno OUT)";

                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));

                cmd.Parameters.Add(new SqlParameter("@id", ""));
                cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@codigo", 0));
                cmd.Parameters["@codigo"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@codigo"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@nome", ""));
                cmd.Parameters["@nome"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nome"].Size = 150;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Usuario usr = new Usuario();
                usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                usr.codigo = int.Parse(cmd.Parameters["@codigo"].Value.ToString());
                usr.nome = Server.HtmlEncode(cmd.Parameters["@nome"].Value.ToString());
                usr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());
                arr.Add(usr);

                usr = null;
                cmd = null;

                conn.Fechar();
            }
            catch
            {

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
