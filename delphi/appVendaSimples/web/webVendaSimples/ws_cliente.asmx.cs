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
    /// WebService para chamada de métodos para inserir e recuprar oados de clientes
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do script, usando ASP.NET AJAX, remova os comentários da linha a seguir. 
    [System.Web.Script.Services.ScriptService]

    public class ws_cliente : System.Web.Services.WebService
    {

        class Cliente {
            public String id = "{00000000-0000-0000-0000-000000000000}"; // ID
            public String cd = "0"; // Código
            public String nm = "";  // Nome
            public String cp = "";  // CPF/CNPJ
            public String ct = "";  // Contato
            public String fn = "";  // Telefone
            public String ce = "";  // Celular
            public String em = "";  // E-mail
            public String ed = "";  // Endereço
            public String ob = "";  // Observações
            public String at = "N"; // Ativo
        }

        class Retorno {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            public String retorno = "";

            public void Destroy() {
                GC.SuppressFinalize(this);
            }
        }

        class RetornoCliente
        {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Today.ToString("dd/MM/yyyy") + " " + DateTime.Now.ToString("HH:mm:ss");
            public String retorno = "";
            public List<Cliente> clientes = new List<Cliente>();

            public void Destroy()
            {
                GC.SuppressFinalize(this);
            }
        }

        [WebMethod]
        public string HelloWorld() {
            return "Olá, Mundo";
        }

        // ULOAD DE CLIENTES (FORMATO JSON) ========================================================================
        [WebMethod]
        public void UploadClientes(String usuario, String empresa, String token, String clientes) {
            usuario  = HttpUtility.UrlDecode(usuario);
            empresa  = HttpUtility.UrlDecode(empresa);
            token    = HttpUtility.UrlDecode(token);
            clientes = HttpUtility.UrlDecode(clientes);
            
            List<Retorno> arr = new List<Retorno>();

            try
            {
                if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
                {
                    Retorno err = new Retorno();
                    err.retorno = Server.HtmlEncode("Token de segurança inválido!");
                    arr.Add(err);
                }
                else
                {
                    var lista_cliente = new JavaScriptSerializer().Deserialize<List<Cliente>>(clientes);

                    Conexao conn = Conexao.Instance;
                    int i;

                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    cmd.CommandText = "Delete from dbo.tb_cliente_temp where (id_usuario = @id_usuario) and (id_empresa = @id_empresa)";
                    cmd.Parameters.Clear();
                    cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                    cmd.ExecuteNonQuery();

                    String sql =
                        "Insert Into dbo.tb_cliente_temp (" +
                        "    id_usuario     " +
                        "  , id_empresa     " +
                        "  , id_cliente     " +
                        "  , cd_cliente     " +
                        "  , nm_cliente     " +
                        "  , nr_cnpj_cpf    " +
                        "  , nm_contato     " +
                        "  , nr_telefone    " +
                        "  , nr_celular     " +
                        "  , ds_email       " +
                        "  , ds_endereco    " +
                        "  , ds_observacao  " +
                        "  , sn_ativo       " +
                        ") values (" +
                        "    @id_usuario     " +
                        "  , @id_empresa     " +
                        "  , @id_cliente     " +
                        "  , @cd_cliente     " +
                        "  , @nm_cliente     " +
                        "  , @nr_cnpj_cpf    " +
                        "  , @nm_contato     " +
                        "  , @nr_telefone    " +
                        "  , @nr_celular     " +
                        "  , @ds_email       " +
                        "  , @ds_endereco    " +
                        "  , @ds_observacao  " +
                        "  , @sn_ativo       " +
                        ")";

                    cmd.CommandText = sql;

                    for (i = 0; i < lista_cliente.Count; i++)
                    {
                        cmd.Parameters.Clear();
                        cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                        cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                        cmd.Parameters.Add(new SqlParameter("@id_cliente", lista_cliente[i].id));
                        cmd.Parameters.Add(new SqlParameter("@cd_cliente", lista_cliente[i].cd));
                        cmd.Parameters.Add(new SqlParameter("@nm_cliente", lista_cliente[i].nm.ToUpper()));
                        cmd.Parameters.Add(new SqlParameter("@nr_cnpj_cpf", lista_cliente[i].cp));
                        cmd.Parameters.Add(new SqlParameter("@nm_contato", lista_cliente[i].ct));
                        cmd.Parameters.Add(new SqlParameter("@nr_telefone", lista_cliente[i].fn));
                        cmd.Parameters.Add(new SqlParameter("@nr_celular", lista_cliente[i].ce));
                        cmd.Parameters.Add(new SqlParameter("@ds_email", lista_cliente[i].em.ToLower()));
                        cmd.Parameters.Add(new SqlParameter("@ds_endereco", lista_cliente[i].ed));
                        cmd.Parameters.Add(new SqlParameter("@ds_observacao", lista_cliente[i].ob));
                        cmd.Parameters.Add(new SqlParameter("@sn_ativo", lista_cliente[i].at.ToUpper()));
                        cmd.ExecuteNonQuery();
                    }

                    Retorno ret = new Retorno();
                    ret.retorno = "OK";
                    arr.Add(ret);

                    GC.SuppressFinalize(lista_cliente);
                    GC.SuppressFinalize(cmd);

                    conn.Fechar();
                }
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

        // PROCESSAR ULOAD DE CLIENTES      ========================================================================
        [WebMethod]
        public void ProcessarClientes(String usuario, String empresa, String token) {
            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);

            List<Retorno> arr = new List<Retorno>();

            try {
                if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
                {
                    Retorno err = new Retorno();
                    err.retorno = Server.HtmlEncode("Token de segurança inválido!");
                    arr.Add(err);
                }
                else
                {
                    Conexao conn = Conexao.Instance;
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.spProcessarClientes @usuario, @empresa, @token, @id OUT, @data OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@id", ""));
                    cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@id"].Size = 38;

                    cmd.Parameters.Add(new SqlParameter("@data", ""));
                    cmd.Parameters["@data"].Direction = ParameterDirection.InputOutput;
                    //cmd.Parameters["@data"].DbType    = DbType.DateTime; 
                    cmd.Parameters["@data"].Size = 10;

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    Retorno ret = new Retorno();
                    //ret.data = Server.HtmlEncode(String.Format("{0:dd/mm/yyyy}", cmd.Parameters["@data"].Value));
                    ret.data    = Server.HtmlEncode(cmd.Parameters["@data"].Value.ToString());
                    ret.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                    qry.Close();

                    if (ret.retorno == "OK")
                    {
                        cmd.CommandText = "Delete from dbo.tb_cliente_temp where (id_usuario = @usuario) and (id_empresa = @empresa)";
                        cmd.Parameters.Clear();
                        cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                        cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                        cmd.ExecuteNonQuery();
                    }
                    
                    arr.Add(ret);

                    GC.SuppressFinalize(cmd);

                    conn.Fechar();
                }
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

        // DOWNLOAD CLIENTES (FORMATO JSON) ========================================================================
        [WebMethod]
        public void DownloadClientes(String usuario, String empresa, String data, String token)
        {
            Conexao conn = Conexao.Instance;
            RetornoCliente arr = new RetornoCliente();

            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            data  = HttpUtility.UrlDecode(data);
            token = HttpUtility.UrlDecode(token);

            if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
            {
                Cliente err = new Cliente();
                arr.retorno = Server.HtmlEncode("Token de segurança inválido!");
                arr.clientes.Add(err);

                //err = null;
                GC.SuppressFinalize(err);
            }
            else
            {
                try
                {
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.getListarClientes @usuario, @empresa, @data, @token, @atualizacao OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));

                    if (data.Trim() != "") {
                        cmd.Parameters.Add(new SqlParameter("@data", data));
                    } else {
                        cmd.Parameters.Add(new SqlParameter("@data", DBNull.Value));
                    }

                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@atualizacao", arr.data + ".000")); // Inserir a informação de milisegundo
                    cmd.Parameters["@atualizacao"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@atualizacao"].DbType    = DbType.DateTime;
                    cmd.Parameters["@atualizacao"].Size = 25;

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    arr.data = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy HH:mm:ss}", cmd.Parameters["@atualizacao"].Value));
                    arr.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                    while (qry.Read())
                    {
                        Cliente cli = new Cliente();

                        cli.id = Server.HtmlEncode(qry.GetString(0).ToString());  // ID
                        cli.cd = Server.HtmlEncode(qry.GetString(1).ToString());  // Código
                        cli.nm = Server.HtmlEncode(qry.GetString(2).ToString());  // Nome
                        cli.cp = Server.HtmlEncode(qry.GetString(3).ToString());  // CPF/CNPJ
                        cli.ct = Server.HtmlEncode(qry.GetString(4).ToString());  // Contato
                        cli.fn = Server.HtmlEncode(qry.GetString(5).ToString());  // Telefone
                        cli.ce = Server.HtmlEncode(qry.GetString(6).ToString());  // Celular
                        cli.em = Server.HtmlEncode(qry.GetString(7).ToString());  // E-mail
                        cli.ed = Server.HtmlEncode(qry.GetString(8).ToString());  // Endereço
                        cli.ob = Server.HtmlEncode(qry.GetString(9).ToString());  // Observações
                        cli.at = "S"; // Ativo

                        arr.clientes.Add(cli);
                    }

                    arr.retorno = "OK";
                    GC.SuppressFinalize(cmd);

                    conn.Fechar();
                }
                catch (System.IndexOutOfRangeException e)
                {
                    Cliente err = new Cliente();
                    arr.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                    arr.clientes.Add(err);

                    //err = null;
                    GC.SuppressFinalize(err);
                }
            }

            // Serializar JSON
            JavaScriptSerializer js = new JavaScriptSerializer();
            js.MaxJsonLength = Int32.MaxValue;

            Context.Response.Clear();
            Context.Response.Write(js.Serialize(arr));
            Context.Response.Flush();
            Context.Response.End();
        }
    }
}
