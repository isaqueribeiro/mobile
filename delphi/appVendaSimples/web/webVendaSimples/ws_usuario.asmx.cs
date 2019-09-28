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

        public void Destroy() {
            GC.SuppressFinalize(this);
        }
    }

    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do JavaScript, usando ASP.NET AJAX. 
    [System.Web.Script.Services.ScriptService]

    public class ws_usuario : System.Web.Services.WebService
    {

        [WebMethod]
        public string HelloWorld() {
            return "Olá, Mundo";
        }

        // VALIDAR LOGIN
        [WebMethod]
        public void ValidarLogin(String email, String senha) {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);

            try {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql = 
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.getValidarLogin @email, @senha, @id  OUT, @codigo OUT, @nome OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));

                cmd.Parameters.Add(new SqlParameter("@id", ""));
                cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@codigo", "0"));
                cmd.Parameters["@codigo"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@codigo"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@nome", ""));
                cmd.Parameters["@nome"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nome"].Size = 150;

                cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@retorno"].Size = 250;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Usuario usr = new Usuario();

                usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                usr.codigo = int.Parse(cmd.Parameters["@codigo"].Value.ToString());
                usr.nome = Server.HtmlEncode(cmd.Parameters["@nome"].Value.ToString());
                usr.email = email;
                usr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());
                arr.Add(usr);

                //usr = null;
                //cmd = null;
                GC.SuppressFinalize(usr);
                GC.SuppressFinalize(cmd);

                conn.Fechar();
            }
            catch (System.IndexOutOfRangeException e) {
                Usuario err = new Usuario();

                err.id      = "{00000000-0000-0000-0000-000000000000}";
                err.codigo  = 0;
                err.nome    = "";
                err.email   = email;
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

        // CRIAR NOVA CONTA
        [WebMethod]
        public void CriarLogin(String nome, String email, String senha)
        {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            nome  = HttpUtility.UrlDecode(nome);
            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);

            try
            {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql =
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.setCriarLogin @nome, @email, @senha, @id  OUT, @codigo OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@nome",  nome));
                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));

                cmd.Parameters.Add(new SqlParameter("@id", ""));
                cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@codigo", "0"));
                cmd.Parameters["@codigo"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@codigo"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@retorno"].Size = 250;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Usuario usr = new Usuario();

                usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                usr.codigo = int.Parse(cmd.Parameters["@codigo"].Value.ToString());
                usr.nome = nome;
                usr.email = email;
                usr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());
                arr.Add(usr);

                //usr = null;
                //cmd = null;
                GC.SuppressFinalize(usr);
                GC.SuppressFinalize(cmd);

                conn.Fechar();
            }
            catch (System.IndexOutOfRangeException e)
            {
                Usuario err = new Usuario();

                err.id = "{00000000-0000-0000-0000-000000000000}";
                err.codigo = 0;
                err.nome = nome;
                err.email = email;
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
