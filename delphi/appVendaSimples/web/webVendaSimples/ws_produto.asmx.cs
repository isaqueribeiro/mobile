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
    /// WebService para chamada de métodos para inserir e recuprar oados de produtos
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do script, usando ASP.NET AJAX, remova os comentários da linha a seguir. 
    [System.Web.Script.Services.ScriptService]

    public class ws_produto : System.Web.Services.WebService
    {
        class Retorno
        {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            public String retorno = "";

            public void Destroy()
            {
                GC.SuppressFinalize(this);
            }
        }

        class Produto
        {
            public String id = "{00000000-0000-0000-0000-000000000000}"; // ID
            public String cd = "0";  // Código
            public String ds = "";   // Descrição
            public String br = "";   // Código de barras (EAN)
            public String vl = "0";  // Valor
            public String ft = "";   // Foto (Base 64)
            public String at = "N";  // Ativo
        }

        class RetornoProduto
        {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            public String retorno = "";
            public List<Produto> produtos = new List<Produto>();

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

        // ULOAD DE PRODUTOS (FORMATO JSON) ========================================================================
        [WebMethod]
        public void UploadProdutos(String usuario, String empresa, String token, String produtos)
        {
            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);
            produtos = HttpUtility.UrlDecode(produtos);

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
                    var lista_produto = new JavaScriptSerializer().Deserialize<List<Produto>>(produtos);

                    Conexao conn = Conexao.Instance;
                    int i;

                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    cmd.CommandText = "Delete from dbo.tb_produto_temp where (id_usuario = @id_usuario) and (id_empresa = @id_empresa)";
                    cmd.Parameters.Clear();
                    cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                    cmd.ExecuteNonQuery();

                    String sql =
                        "Insert Into dbo.tb_produto_temp (" +
                        "    id_usuario     " +
                        "  , id_empresa     " +
                        "  , id_produto     " +
                        "  , br_produto     " +
                        "  , cd_produto     " +
                        "  , ds_produto     " +
                        "  , ft_produto     " +
                        "  , vl_produto     " +
                        "  , sn_ativo       " +
                        ") values (" +
                        "    @id_usuario    " +
                        "  , @id_empresa    " +
                        "  , @id_produto    " +
                        "  , @br_produto    " +
                        "  , @cd_produto    " +
                        "  , @ds_produto    " +
                        "  , @ft_produto    " +
                        "  , @vl_produto    " +
                        "  , @sn_ativo      " +
                        ")";

                    cmd.CommandText = sql;

                    for (i = 0; i < lista_produto.Count; i++)
                    {
                        cmd.Parameters.Clear();
                        cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                        cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                        cmd.Parameters.Add(new SqlParameter("@id_produto", lista_produto[i].id));
                        cmd.Parameters.Add(new SqlParameter("@cd_produto", lista_produto[i].cd));
                        cmd.Parameters.Add(new SqlParameter("@br_produto", lista_produto[i].br.ToUpper()));
                        cmd.Parameters.Add(new SqlParameter("@ds_produto", lista_produto[i].ds.ToUpper()));
                        cmd.Parameters.Add(new SqlParameter("@sn_ativo",   lista_produto[i].at.ToUpper()));

                        if (lista_produto[i].ft.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@ft_produto", lista_produto[i].ft));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@ft_produto", DBNull.Value));
                        }

                        if (lista_produto[i].vl.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_produto", Convert.ToDecimal(lista_produto[i].vl) / 100));
                        }
                        else
                        {
                            cmd.Parameters.Add(new SqlParameter("@vl_produto", DBNull.Value));
                        }

                        cmd.ExecuteNonQuery();
                    }

                    Retorno ret = new Retorno();
                    ret.retorno = "OK";
                    arr.Add(ret);

                    GC.SuppressFinalize(lista_produto);
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

        // PROCESSAR ULOAD DE PRODUTOS      ========================================================================
        [WebMethod]
        public void ProcessarProdutos(String usuario, String empresa, String token)
        {
            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);

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
                    Conexao conn = Conexao.Instance;
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.spProcessarProdutos @usuario, @empresa, @token, @id OUT, @data OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@id", ""));
                    cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@id"].Size = 38;

                    cmd.Parameters.Add(new SqlParameter("@data", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") + ".000")); // Inserir a informação de milisegundo
                    cmd.Parameters["@data"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@data"].DbType    = DbType.DateTime; 

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    Retorno ret = new Retorno();
                    ret.data = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy HH:mm:ss}", cmd.Parameters["@data"].Value));
                    ret.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                    qry.Close();

                    if (ret.retorno == "OK")
                    {
                        cmd.CommandText = "Delete from dbo.tb_produto_temp where (id_usuario = @usuario) and (id_empresa = @empresa)";
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







    }
}
