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

    class Empresa
    {
        public String id;
        public int codigo;
        public String nome;
        public String fantasia;
        public String cpf_cnpj;

        public void Destroy()
        {
            GC.SuppressFinalize(this);
        }
    }

    class Usuario
    {
        public String id;
        public Int64 codigo;
        public String nome;
        public String email;
        public String token = "";
        public int plataforma = 0;
        public Empresa empresa = new Empresa();

        public String retorno = "";

        public void Destroy() {
            GC.SuppressFinalize(this);
        }
    }

    class Notificacao {
        public String id;
        public Int64 codigo;
        public String data;
        public String titulo;
        public String texto;
        public int destacar = 0;

        public String retorno = "";
        public void Destroy()
        {
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

        // VALIDAR LOGIN ===========================================================================
        [WebMethod]
        public void ValidarLogin(String email, String senha, String token) {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);
            token = HttpUtility.UrlDecode(token);

            try {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql = 
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.getValidarLogin @email, @senha, @token, @id  OUT, @codigo OUT, @nome OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));
                cmd.Parameters.Add(new SqlParameter("@token", token));

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
                usr.codigo = Int64.Parse(cmd.Parameters["@codigo"].Value.ToString());
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

        // CRIAR NOVA CONTA ========================================================================
        [WebMethod]
        public void CriarLogin(String nome, String email, String senha, String token)
        {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            nome  = HttpUtility.UrlDecode(nome);
            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);
            token = HttpUtility.UrlDecode(token);

            try
            {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql =
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.setCriarLogin @nome, @email, @senha, @token, @id  OUT, @codigo OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@nome",  nome));
                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));
                cmd.Parameters.Add(new SqlParameter("@token", token));

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
                usr.codigo = Int64.Parse(cmd.Parameters["@codigo"].Value.ToString());
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

        // EDITAR PERFIL CONTA =====================================================================
        [WebMethod]
        public void EditarPerfilLogin(String id, String nome, String email, String senha, String cpf_cnpj, String empresa, String fantasia, String token)
        {
            Conexao conn = Conexao.Instance;
            List<Usuario> arr = new List<Usuario>();

            id = HttpUtility.UrlDecode(id);
            nome = HttpUtility.UrlDecode(nome);
            email = HttpUtility.UrlDecode(email);
            senha = HttpUtility.UrlDecode(senha);
            cpf_cnpj = HttpUtility.UrlDecode(cpf_cnpj);
            empresa = HttpUtility.UrlDecode(empresa);
            fantasia = HttpUtility.UrlDecode(fantasia);
            token = HttpUtility.UrlDecode(token);

            try
            {
                conn.Conectar();
                SqlCommand cmd = new SqlCommand("", conn.Conn());

                String sql =
                    "SET DATEFORMAT DMY " +
                    "EXECUTE dbo.setEditarPerfilLogin @id, @nome, @email, @senha, @cpf_cnpj, @empresa, @fantasia, @token, @id_empresa OUT, @cd_empresa OUT, @retorno OUT";

                cmd.Parameters.Add(new SqlParameter("@id", id));
                cmd.Parameters.Add(new SqlParameter("@nome", nome));
                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));
                cmd.Parameters.Add(new SqlParameter("@cpf_cnpj", cpf_cnpj));
                cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                cmd.Parameters.Add(new SqlParameter("@fantasia", fantasia));
                cmd.Parameters.Add(new SqlParameter("@token", token));

                cmd.Parameters.Add(new SqlParameter("@id_empresa", ""));
                cmd.Parameters["@id_empresa"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id_empresa"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@cd_empresa", "0"));
                cmd.Parameters["@cd_empresa"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@cd_empresa"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@retorno"].Size = 250;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Usuario usr = new Usuario();

                usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                usr.nome = nome;
                usr.email = email;
                usr.empresa.id = Server.HtmlEncode(cmd.Parameters["@id_empresa"].Value.ToString());
                usr.empresa.codigo = int.Parse(cmd.Parameters["@cd_empresa"].Value.ToString());
                usr.empresa.nome = empresa;
                usr.empresa.fantasia = fantasia;
                usr.empresa.cpf_cnpj = cpf_cnpj;
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
                err.empresa.id = "{00000000-0000-0000-0000-000000000000}";
                err.empresa.codigo = 0;
                err.empresa.nome = "";
                err.empresa.fantasia = "";
                err.empresa.cpf_cnpj = "";
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

        // LISTAR NOTIFICAÇÕES DO USUÁRIO ==========================================================
        [WebMethod]
        public void ListarNotificacoes(String usuario, String empresa, String token)
        {
            Conexao conn = Conexao.Instance;
            List<Notificacao> arr = new List<Notificacao>();

            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);

            if (token != Funcoes.Encriptar("TheLordIsGod")) {
                Notificacao err = new Notificacao();

                err.id = "{00000000-0000-0000-0000-000000000000}";
                err.codigo = 0;
                err.titulo = "";
                err.texto = "";
                err.retorno = Server.HtmlEncode("Token de segurança inválido!");
                arr.Add(err);

                //err = null;
                GC.SuppressFinalize(err);
            }
            else {
                try
                {
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.getValidarLogin @email, @senha, @token, @id  OUT, @codigo OUT, @nome OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@email", email));
                    cmd.Parameters.Add(new SqlParameter("@senha", senha));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

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

                    Notificacao notif = new Notificacao();

                    usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                    usr.codigo = Int64.Parse(cmd.Parameters["@codigo"].Value.ToString());
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
                catch (System.IndexOutOfRangeException e)
                {
                    Notificacao err = new Notificacao();

                    err.id = "{00000000-0000-0000-0000-000000000000}";
                    err.codigo = 0;
                    err.nome = "";
                    err.email = email;
                    err.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                    arr.Add(err);

                    //err = null;
                    GC.SuppressFinalize(err);
                }
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
