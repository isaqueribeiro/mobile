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
    /// WebService para chamada de métodos para inserir e recuprar oados de usuários
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do JavaScript, usando ASP.NET AJAX. 
    [System.Web.Script.Services.ScriptService]

    class SimpleObject 
    {
        public String id = String.Concat("{", System.Guid.NewGuid().ToString().ToUpper(),  "}");
        public String texto = "";
        public String chave = "";
        public String data = DateTime.Today.ToString("dd/MM/yyyy");
        public String hash1 = "";
        public String hash2 = "";
        public String hash3 = "";
        public String md5 = "";
    }

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

    class RetornoEmpresa
    {
        public String retorno = "";
        public List<Empresa> empresas = new List<Empresa>();

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
        public String id = "{00000000-0000-0000-0000-000000000000}";
        public Int64 codigo = 0;
        public String data = "";
        public String hora = "";
        public String titulo = "";
        public String texto = "";
        public int destacar = 0;

        public void Destroy()
        {
            GC.SuppressFinalize(this);
        }
    }

    class RetornoNotificacao
    {
        public String retorno = "";
        public List<Notificacao> notificacoes = new List<Notificacao>();

        public void Destroy()
        {
            GC.SuppressFinalize(this);
        }
    }

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
                    "EXECUTE dbo.getValidarLogin @email, @senha, @token, @id  OUT, @codigo OUT, @nome OUT, @retorno OUT" +
                        ", @id_empresa OUT, @cd_empresa OUT, @nm_empresa OUT, @nm_fantasia OUT, @nr_cnpj_cpf OUT";

                cmd.Parameters.Add(new SqlParameter("@email", email));
                cmd.Parameters.Add(new SqlParameter("@senha", senha));
                cmd.Parameters.Add(new SqlParameter("@token", token));

                cmd.Parameters.Add(new SqlParameter("@id", ""));
                cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@codigo", "0"));
                cmd.Parameters["@codigo"].Direction = ParameterDirection.InputOutput;
                //cmd.Parameters["@codigo"].Size = 10;

                cmd.Parameters.Add(new SqlParameter("@nome", ""));
                cmd.Parameters["@nome"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nome"].Size = 150;

                cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@retorno"].Size = 250;

                cmd.Parameters.Add(new SqlParameter("@id_empresa", ""));
                cmd.Parameters["@id_empresa"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@id_empresa"].Size = 38;

                cmd.Parameters.Add(new SqlParameter("@cd_empresa", "0"));
                cmd.Parameters["@cd_empresa"].Direction = ParameterDirection.InputOutput;

                cmd.Parameters.Add(new SqlParameter("@nm_empresa", ""));
                cmd.Parameters["@nm_empresa"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nm_empresa"].Size = 250;

                cmd.Parameters.Add(new SqlParameter("@nm_fantasia", ""));
                cmd.Parameters["@nm_fantasia"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nm_fantasia"].Size = 150;

                cmd.Parameters.Add(new SqlParameter("@nr_cnpj_cpf", ""));
                cmd.Parameters["@nr_cnpj_cpf"].Direction = ParameterDirection.InputOutput;
                cmd.Parameters["@nr_cnpj_cpf"].Size = 25;

                cmd.CommandText = sql;
                SqlDataReader qry = cmd.ExecuteReader();

                Usuario usr = new Usuario();

                usr.id = Server.HtmlEncode(cmd.Parameters["@id"].Value.ToString());
                usr.codigo = Int64.Parse(cmd.Parameters["@codigo"].Value.ToString());
                usr.nome   = Server.HtmlEncode(cmd.Parameters["@nome"].Value.ToString());
                usr.email  = email;
                usr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                usr.empresa.id       = Server.HtmlEncode(cmd.Parameters["@id_empresa"].Value.ToString());
                usr.empresa.codigo   = Int32.Parse(cmd.Parameters["@cd_empresa"].Value.ToString());
                usr.empresa.nome     = Server.HtmlEncode(cmd.Parameters["@nm_empresa"].Value.ToString());
                usr.empresa.fantasia = Server.HtmlEncode(cmd.Parameters["@nm_fantasia"].Value.ToString());
                usr.empresa.cpf_cnpj = Server.HtmlEncode(cmd.Parameters["@nr_cnpj_cpf"].Value.ToString());

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
            //List<Notificacao> arr = new List<Notificacao>();
            RetornoNotificacao arr = new RetornoNotificacao();

            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);

            if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
            {
                Notificacao err = new Notificacao();
                arr.retorno = Server.HtmlEncode("Token de segurança inválido!");
                arr.notificacoes.Add(err);

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
                        "EXECUTE dbo.getListarNotificacoes @usuario, @empresa, @token, @retorno OUT";
                    
                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    while (qry.Read()) {
                        Notificacao notif = new Notificacao();

                        notif.id = Server.HtmlEncode(qry.GetString(0).ToString());
                        notif.codigo = Int64.Parse(qry.GetString(1).ToString());
                        notif.data = Server.HtmlEncode(qry.GetString(2).ToString());  //notif.data = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy}", qry.GetString(2)));
                        notif.hora = Server.HtmlEncode(qry.GetString(3).ToString());
                        notif.titulo = Server.HtmlEncode(qry.GetString(4).ToString());
                        notif.texto = Server.HtmlEncode(qry.GetString(5).ToString());
                        notif.destacar = int.Parse(qry.GetString(6).ToString());

                        arr.notificacoes.Add(notif);
                    }

                    if (arr.notificacoes.Count > 0)
                    {
                        arr.retorno = "OK";
                    }
                    else 
                    {
                        arr.retorno = "Nenhuma notificação encontrada!";
                    }
                    
                    GC.SuppressFinalize(cmd);
                    
                    conn.Fechar();
                }
                catch (System.IndexOutOfRangeException e)
                {
                    Notificacao err = new Notificacao();
                    arr.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                    arr.notificacoes.Add(err);
                    
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

        // LISTAR EMPRESAS DO USUÁRIO ==============================================================
        [WebMethod]
        public void ListarEmpresas(String usuario, String token) {
            Conexao conn = Conexao.Instance;
            RetornoEmpresa arr = new RetornoEmpresa();

            usuario = HttpUtility.UrlDecode(usuario);
            token = HttpUtility.UrlDecode(token);

            if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
            {
                Empresa emp = new Empresa();
                arr.retorno = Server.HtmlEncode("Token de segurança inválido!");
                arr.empresas.Add(emp);

                //err = null;
                GC.SuppressFinalize(emp);
            }
            else
            {
                try
                {
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.getListarEmpresas @usuario, @token, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;
                    
                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    arr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                    while (qry.Read())
                    {
                        Empresa emp = new Empresa();

                        emp.id = Server.HtmlEncode(qry.GetString(0).ToString());
                        emp.codigo = int.Parse( qry.GetString(1).ToString() );        
                        emp.nome = Server.HtmlEncode(qry.GetString(2).ToString());
                        emp.fantasia = Server.HtmlEncode(qry.GetString(3).ToString());
                        emp.cpf_cnpj = Server.HtmlEncode(qry.GetString(4).ToString());

                        arr.empresas.Add(emp);
                    }

                    arr.retorno = "OK";
                    GC.SuppressFinalize(cmd);
                    
                    conn.Fechar();
                }
                catch (System.IndexOutOfRangeException e)
                {
                    Empresa emp = new Empresa();
                    arr.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                    arr.empresas.Add(emp);

                    //err = null;
                    GC.SuppressFinalize(emp);
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
