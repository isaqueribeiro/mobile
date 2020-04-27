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
    /// WebService para chamada de métodos para inserir e recuprar oados de pedidos
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    // Para permitir que esse serviço da web seja chamado a partir do script, usando ASP.NET AJAX, remova os comentários da linha a seguir. 
    [System.Web.Script.Services.ScriptService]

    public class ws_pedido : System.Web.Services.WebService
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

        class Pedido
        {
            public String id = "{00000000-0000-0000-0000-000000000000}"; // ID
            public String cd = "0";  // Código
            public String tp = "0";  // Tipo : 0 - Orçamento, 1 - Pedido
            public String lj = "{00000000-0000-0000-0000-000000000000}"; // Loja
            public String cl = "{00000000-0000-0000-0000-000000000000}"; // Cliente
            public String ct = "";   // Contato
            public String dt = "";   // Data de Emissão
            public String vt = "0";  // Valor Total
            public String vd = "0";  // Valor Desconto
            public String vp = "0";  // Valor Pedido
            public String ob = "";   // Observações
            public String et = "N";  // Entregue
            public String at = "N";  // Ativo
        }

        class Item
        {
            public String id = "{00000000-0000-0000-0000-000000000000}"; // ID
            public String cd = "0";  // Código
            public String pe = "{00000000-0000-0000-0000-000000000000}"; // Pedido
            public String pd = "{00000000-0000-0000-0000-000000000000}"; // Produto
            public String qt = "0";  // Quantidade
            public String vu = "0";  // Valor Unitário
            public String vt = "0";  // Valor Total
            public String vd = "0";  // Valor Total Desconto
            public String vl = "0";  // Valor Total Líquido
            public String ob = "";   // Observações
        }

        class RetornoPedido
        {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            public String retorno = "";
            public List<Pedido> pedidos = new List<Pedido>();
            public List<Item> itens = new List<Item>();

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

        // ULOAD DE PEDIDOS (FORMATO JSON) ========================================================================
        [WebMethod]
        public void UploadPedidos(String usuario, String empresa, String token, String pedidos, String itens)
        {
            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            token = HttpUtility.UrlDecode(token);
            pedidos = HttpUtility.UrlDecode(pedidos);
            itens = HttpUtility.UrlDecode(itens);

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
                    int i;

                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    var lista_pedido = new JavaScriptSerializer().Deserialize<List<Pedido>>(pedidos);

                    // Limpar tabela Pedido TEMP
                    cmd.CommandText = "Delete from dbo.tb_pedido_temp where (id_usuario = @id_usuario) and (id_empresa = @id_empresa)";
                    cmd.Parameters.Clear();
                    cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                    cmd.ExecuteNonQuery();

                    // Limpar tabela Item Pedido TEMP
                    cmd.CommandText = "Delete from dbo.tb_pedido_item_temp where (id_usuario = @id_usuario) and (id_empresa = @id_empresa)";
                    cmd.Parameters.Clear();
                    cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                    cmd.ExecuteNonQuery();

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "Insert Into dbo.tb_pedido_temp (" +
                        "     id_usuario        " +
                        "   , id_empresa        " +
                        "   , id_pedido         " +
                        "   , cd_pedido         " +
                        "	, id_loja           " +
                        "	, id_cliente        " +
                        "   , tp_pedido         " +
                        "   , dt_pedido         " +
                        "	, ds_contato        " +
                        "	, ds_observacao     " +
                        "	, vl_total_bruto    " +
                        "	, vl_total_desconto " +
                        "	, vl_total_pedido   " +
                        "	, sn_entregue       " +
                        ") values (" +
                        "     @id_usuario        " +
                        "   , @id_empresa        " +
                        "   , @id_pedido         " +
                        "   , @cd_pedido         " +
                        "	, @id_loja           " +
                        "	, @id_cliente        " +
                        "   , @tp_pedido         " +
                        "   , @dt_pedido         " +
                        "	, @ds_contato        " +
                        "	, @ds_observacao     " +
                        "	, @vl_total_bruto    " +
                        "	, @vl_total_desconto " +
                        "	, @vl_total_pedido   " +
                        "	, @sn_entregue       " +
                        ")";

                    cmd.CommandText = sql;

                    for (i = 0; i < lista_pedido.Count; i++)
                    {
                        cmd.Parameters.Clear();
                        cmd.Parameters.Add(new SqlParameter("@id_usuario",  usuario));
                        cmd.Parameters.Add(new SqlParameter("@id_empresa",  empresa));
                        cmd.Parameters.Add(new SqlParameter("@id_pedido",   lista_pedido[i].id));
                        cmd.Parameters.Add(new SqlParameter("@cd_pedido",   lista_pedido[i].cd));
                        cmd.Parameters.Add(new SqlParameter("@id_loja",     lista_pedido[i].lj));
                        cmd.Parameters.Add(new SqlParameter("@id_cliente",  lista_pedido[i].cl));
                        cmd.Parameters.Add(new SqlParameter("@tp_pedido",   lista_pedido[i].tp));
                        cmd.Parameters.Add(new SqlParameter("@dt_pedido",   lista_pedido[i].dt));
                        cmd.Parameters.Add(new SqlParameter("@ds_contato",  lista_pedido[i].ct));
                        cmd.Parameters.Add(new SqlParameter("@ds_observacao", lista_pedido[i].ob));
                        cmd.Parameters.Add(new SqlParameter("@sn_entregue", lista_pedido[i].et.ToUpper()));

                        if (lista_pedido[i].vt.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_bruto", Convert.ToDecimal(lista_pedido[i].vt) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_bruto", "0"));
                        }

                        if (lista_pedido[i].vd.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_desconto", Convert.ToDecimal(lista_pedido[i].vd) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_desconto", "0"));
                        }

                        if (lista_pedido[i].vp.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_pedido", Convert.ToDecimal(lista_pedido[i].vp) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_pedido", "0"));
                        }

                        cmd.ExecuteNonQuery();
                    }

                    var lista_item = new JavaScriptSerializer().Deserialize<List<Item>>(itens);

                    sql =
                        "SET DATEFORMAT DMY " +
                        "Insert Into dbo.tb_pedido_item_temp (" +
                        "     id_usuario        " +
                        "   , id_empresa        " +
                        "   , id_item           " +
                        "   , cd_item           " +
                        "   , id_pedido         " +
                        "   , id_produto        " +
                        "   , qt_produto        " +
                        "   , vl_produto        " +
                        "   , vl_total_bruto    " +
                        "   , vl_total_desconto " +
                        "   , vl_total_produto  " +
                        ") values (" +
                        "     @id_usuario        " +
                        "   , @id_empresa        " +
                        "   , @id_item           " +
                        "   , @cd_item           " +
                        "   , @id_pedido         " +
                        "   , @id_produto        " +
                        "   , @qt_produto        " +
                        "   , @vl_produto        " +
                        "   , @vl_total_bruto    " +
                        "   , @vl_total_desconto " +
                        "   , @vl_total_produto  " +
                        ")";

                    cmd.CommandText = sql;

                    for (i = 0; i < lista_item.Count; i++) 
                    {
                        cmd.Parameters.Clear();
                        cmd.Parameters.Add(new SqlParameter("@id_usuario", usuario));
                        cmd.Parameters.Add(new SqlParameter("@id_empresa", empresa));
                        cmd.Parameters.Add(new SqlParameter("@id_item",    lista_item[i].id));
                        cmd.Parameters.Add(new SqlParameter("@cd_item",    lista_item[i].cd));
                        cmd.Parameters.Add(new SqlParameter("@id_pedido",  lista_item[i].pe));
                        cmd.Parameters.Add(new SqlParameter("@id_produto", lista_item[i].pd));

                        if (lista_item[i].qt.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@qt_produto", Convert.ToDecimal(lista_item[i].qt) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@qt_produto", "0"));
                        }

                        if (lista_item[i].vu.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_produto", Convert.ToDecimal(lista_item[i].vu) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_produto", "0"));
                        }

                        if (lista_item[i].vt.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_bruto", Convert.ToDecimal(lista_item[i].vt) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_bruto", "0"));
                        }

                        if (lista_item[i].vd.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_desconto", Convert.ToDecimal(lista_item[i].vd) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_desconto", "0"));
                        }

                        if (lista_item[i].vl.Trim() != "") {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_produto", Convert.ToDecimal(lista_item[i].vl) / 100));
                        } else {
                            cmd.Parameters.Add(new SqlParameter("@vl_total_produto", "0"));
                        }

                        cmd.ExecuteNonQuery();
                    }

                    Retorno ret = new Retorno();
                    ret.retorno = "OK";
                    arr.Add(ret);

                    GC.SuppressFinalize(lista_pedido);
                    GC.SuppressFinalize(lista_item);
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
