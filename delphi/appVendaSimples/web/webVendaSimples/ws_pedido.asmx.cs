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
            public String ft = "N";  // Faturado
            public String et = "N";  // Entregue
            public String at = "N";  // Ativo
            public String nr = "";   // Número
            public String lc = "";   // CPF/CNPJ da Loja
            public List<Item> itens = new List<Item>();
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

        class DownloadPedido
        {
            public String id = "{00000000-0000-0000-0000-000000000000}";
            public String data = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");
            public String retorno = "";
            public List<Pedido> pedidos = new List<Pedido>();

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

        // PROCESSAR ULOAD DE PEDIDOS      ========================================================================
        [WebMethod]
        public void ProcessarPedidos(String usuario, String empresa, String token)
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
                        "EXECUTE dbo.spProcessarPedidos @usuario, @empresa, @token, @id OUT, @data OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@id", ""));
                    cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@id"].Size = 38;

                    cmd.Parameters.Add(new SqlParameter("@data", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") + ".000")); // Inserir a informação de milisegundo
                    cmd.Parameters["@data"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@data"].DbType = DbType.DateTime;

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

        // DOWNLOAD PEDIDOS (FORMATO JSON) ========================================================================
        [WebMethod]
        public void DownloadPedidos(String usuario, String empresa, String data, String token)
        {
            Conexao conn = Conexao.Instance;
            DownloadPedido arr = new DownloadPedido();

            usuario = HttpUtility.UrlDecode(usuario);
            empresa = HttpUtility.UrlDecode(empresa);
            data = HttpUtility.UrlDecode(data);
            token = HttpUtility.UrlDecode(token);

            if (token != Funcoes.EncriptarHashBytes(String.Concat("TheLordIsGod", DateTime.Today.ToString("dd/MM/yyyy"))).ToUpper())
            {
                Pedido err = new Pedido();
                arr.retorno = Server.HtmlEncode("Token de segurança inválido!");
                arr.pedidos.Add(err);

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
                        "Select " +
                        "    p.id_pedido  " +
                        "  , Convert(varchar(20), coalesce(nullif(p.cd_pedido_app, 0), p.cd_pedido)) as cd_pedido " +
                        "  , p.id_empresa " +
                        "  , p.id_cliente " +
                        "  , Convert(varchar(1), p.tp_pedido) as tp_pedido " +
                        "  , convert(varchar(10), p.dt_pedido, 103) as dt_pedido " +
                        "  , p.ds_contato " +
                        "  , p.ds_observacao      " +
                        //"  , p.vl_total_bruto     " +
                        //"  , p.vl_total_desconto  " +
                        //"  , p.vl_total_pedido    " +
                        "  , convert(varchar(20), convert(BIGINT, coalesce(p.vl_total_bruto,    0) * 100)) as vl_total_bruto " +
                        "  , convert(varchar(20), convert(BIGINT, coalesce(p.vl_total_desconto, 0) * 100)) as vl_total_desconto " +
                        "  , convert(varchar(20), convert(BIGINT, coalesce(p.vl_total_pedido,   0) * 100)) as vl_total_pedido " +
                        "  , Case when p.sn_faturado = 1 then 'S' else 'N' end as sn_faturado " +
                        "  , Case when p.sn_entregue = 1 then 'S' else 'N' end as sn_entregue " +
                        //"  , Convert(varchar(20), p.nr_pedido) as nr_pedido " +
                        "  , Case when isnull(trim(a.nr_cnpj_cpf), '') = '' " +
                        "      then format(p.nr_pedido, '###00000')         " +
                        "      else concat(format(p.nr_pedido, '###00000'), right(trim(a.nr_cnpj_cpf), 3)) " +
                        "    end as nr_pedido " +
                        "  , concat(convert(varchar(10), getdate(), 103), ' ', convert(varchar(10), getdate(), 108)) as dt_hoje " +
                        "  , isnull(a.nr_cnpj_cpf, '') as nr_cnpj_cpf " +
                        "from dbo.tb_pedido p " +
                        "  left join dbo.sys_empresa a on (a.id_empresa = p.id_empresa) " +
                        "where  (p.id_usuario = @usuario) " +
                        "  and ((p.dt_ult_edicao > @data) or (@data is null)) " +
                        "  and ((p.id_empresa in ( " +
                        "    Select         " +
                        "      e.id_empresa " +
                        "    from dbo.sys_usuario_empresa e " +
                        "    where e.id_usuario = @usuario  " +
                        "      and e.sn_ativo = 1           " +
                        "  )) or (p.id_empresa = @empresa)) ";

                    cmd.Parameters.Add(new SqlParameter("@usuario", usuario));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));

                    if (data.Trim() != "") {
                        cmd.Parameters.Add(new SqlParameter("@data", data));
                        cmd.Parameters["@data"].Direction = ParameterDirection.Input;
                        cmd.Parameters["@data"].DbType = DbType.DateTime;
                        cmd.Parameters["@data"].Size = 25;
                    } else {
                        cmd.Parameters.Add(new SqlParameter("@data", DBNull.Value));
                        cmd.Parameters["@data"].Direction = ParameterDirection.Input;
                        cmd.Parameters["@data"].DbType = DbType.DateTime;
                        cmd.Parameters["@data"].Size = 25;
                    }

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    while (qry.Read())
                    {
                        Pedido ped = new Pedido();

                        ped.id = Server.HtmlEncode(qry.GetString(0).ToString());  // ID
                        ped.cd = Server.HtmlEncode(qry.GetString(1).ToString());  // Código
                        ped.lj = Server.HtmlEncode(qry.GetString(2).ToString());  // Empresa
                        ped.cl = Server.HtmlEncode(qry.GetString(3).ToString());  // Cliente
                        ped.tp = Server.HtmlEncode(qry.GetString(4).ToString());  // Tipo
                        //ped.dt = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy HH:mm:ss}", qry.GetString(5) ));  // Data de Emissão
                        ped.dt = Server.HtmlEncode(qry.GetString(5).ToString());  // Data de Emissão
                        ped.ct = Server.HtmlEncode(qry.GetString(6).ToString());  // Contato
                        ped.ob = Server.HtmlEncode(qry.GetString(7).ToString());  // Observação
                        //ped.vt = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry.GetString(8).ToString()) * 100));   // Valor Total
                        //ped.vd = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry.GetString(9).ToString()) * 100));   // Valor Desconto
                        //ped.vp = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry.GetString(10).ToString()) * 100));  // Valor Pedido
                        ped.vt = Server.HtmlEncode(qry.GetString(8).ToString());   // Valor Total
                        ped.vd = Server.HtmlEncode(qry.GetString(9).ToString());   // Valor Desconto
                        ped.vp = Server.HtmlEncode(qry.GetString(10).ToString());  // Valor Pedido
                        ped.ft = Server.HtmlEncode(qry.GetString(11).ToString());  // Faturado? (S/N)
                        ped.et = Server.HtmlEncode(qry.GetString(12).ToString());  // Entregue? (S/N)
                        ped.nr = Server.HtmlEncode(qry.GetString(13).ToString());  // Número
                        ped.at = "S";
                        ped.lc = Server.HtmlEncode(qry.GetString(15).ToString());  // CPF/CNPJ da Loja

                        ped.itens = new List<Item>();
                        arr.data  = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy HH:mm:ss}", qry.GetString(14) ));  // Data atual do servidor SQL Server

                        // Carregar itens do Pedido
                        SqlCommand cmd_item = new SqlCommand("", conn.Conn());

                        sql =
                            "SET DATEFORMAT DMY " +
                            "Select             " +
                            "    i.id_item      " +
                            "  , Convert(varchar(20), i.cd_item) as cd_item " +
                            "  , i.id_pedido    " +
                            "  , i.id_produto   " +
                            //"  , i.qt_produto   " +
                            //"  , i.vl_produto   " +
                            //"  , i.vl_total_bruto       " +
                            //"  , i.vl_total_desconto    " +
                            //"  , i.vl_total_produto     " +
                            "  , convert(varchar(20), convert(BIGINT, coalesce(i.qt_produto, 0) * 100)) as qt_produto " +
                            "  , convert(varchar(20), convert(BIGINT, coalesce(i.vl_produto, 0) * 100)) as vl_produto " +
                            "  , convert(varchar(20), convert(BIGINT, coalesce(i.vl_total_bruto,    0) * 100)) as vl_total_bruto " +
                            "  , convert(varchar(20), convert(BIGINT, coalesce(i.vl_total_desconto, 0) * 100)) as vl_total_desconto " +
                            "  , convert(varchar(20), convert(BIGINT, coalesce(i.vl_total_produto,  0) * 100)) as vl_total_produto " +
                            "from dbo.tb_pedido_item i  " +
                            "where (i.id_pedido = @pedido) ";

                        cmd_item.Parameters.Add(new SqlParameter("@pedido", ped.id));
                        cmd_item.CommandText   = sql;
                        SqlDataReader qry_item = cmd_item.ExecuteReader();

                        while (qry_item.Read()) {
                            Item itm = new Item();

                            itm.id = Server.HtmlEncode(qry_item.GetString(0).ToString());  // ID
                            itm.cd = Server.HtmlEncode(qry_item.GetString(1).ToString());  // Código
                            itm.pe = Server.HtmlEncode(qry_item.GetString(2).ToString());  // Pedido
                            itm.pd = Server.HtmlEncode(qry_item.GetString(3).ToString());  // Produto
                            //itm.qt = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry_item.GetString(4).ToString()) * 100));  // Quantidade
                            //itm.vu = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry_item.GetString(5).ToString()) * 100));  // Valor Unitário
                            //itm.vt = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry_item.GetString(6).ToString()) * 100));  // Valor Total
                            //itm.vd = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry_item.GetString(7).ToString()) * 100));  // Valor Total Desconto
                            //itm.vl = Server.HtmlEncode(String.Format("{0:0}", Decimal.Parse(qry_item.GetString(8).ToString()) * 100));  // Valor Total Líquido
                            itm.qt = Server.HtmlEncode(qry_item.GetString(4).ToString());  // Quantidade
                            itm.vu = Server.HtmlEncode(qry_item.GetString(5).ToString());  // Valor Unitário
                            itm.vt = Server.HtmlEncode(qry_item.GetString(6).ToString());  // Valor Total
                            itm.vd = Server.HtmlEncode(qry_item.GetString(7).ToString());  // Valor Total Desconto
                            itm.vl = Server.HtmlEncode(qry_item.GetString(8).ToString());  // Valor Total Líquido
                            itm.ob = "";   // Observações

                            ped.itens.Add(itm);
                        }

                        GC.SuppressFinalize(cmd_item);

                        arr.pedidos.Add(ped);
                    }

                    arr.retorno = "OK";
                    GC.SuppressFinalize(cmd);

                    conn.Fechar();
                }
                catch (System.IndexOutOfRangeException e)
                {
                    Pedido err = new Pedido();
                    arr.retorno = Server.HtmlEncode("ERRO - " + e.Message);
                    arr.pedidos.Add(err);

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

        // PEDIDO ENTREGUE (FORMATO JSON) =========================================================================
        [WebMethod]
        public void PedidoEntregue(String pedido, String empresa, String token)
        {
            pedido = HttpUtility.UrlDecode(pedido);
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

                    //err = null;
                    GC.SuppressFinalize(err);
                } 
                else
                {
                    Conexao conn = Conexao.Instance;
                    conn.Conectar();
                    SqlCommand cmd = new SqlCommand("", conn.Conn());

                    String sql =
                        "SET DATEFORMAT DMY " +
                        "EXECUTE dbo.setPedidoEntregue @usuario, @empresa, @token, @id OUT, @data OUT, @retorno OUT";

                    cmd.Parameters.Add(new SqlParameter("@pedido", pedido));
                    cmd.Parameters.Add(new SqlParameter("@empresa", empresa));
                    cmd.Parameters.Add(new SqlParameter("@token", token));

                    cmd.Parameters.Add(new SqlParameter("@id", ""));
                    cmd.Parameters["@id"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@id"].Size = 38;

                    cmd.Parameters.Add(new SqlParameter("@data", DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss") + ".000")); // Inserir a informação de milisegundo
                    cmd.Parameters["@data"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@data"].DbType = DbType.DateTime;

                    cmd.Parameters.Add(new SqlParameter("@retorno", ""));
                    cmd.Parameters["@retorno"].Direction = ParameterDirection.InputOutput;
                    cmd.Parameters["@retorno"].Size = 250;

                    cmd.CommandText = sql;
                    SqlDataReader qry = cmd.ExecuteReader();

                    Retorno ret = new Retorno();

                    ret.data    = Server.HtmlEncode(String.Format("{0:dd/MM/yyyy HH:mm:ss}", cmd.Parameters["@data"].Value));
                    ret.retorno = Server.HtmlEncode(cmd.Parameters["@retorno"].Value.ToString());

                    qry.Close();

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
