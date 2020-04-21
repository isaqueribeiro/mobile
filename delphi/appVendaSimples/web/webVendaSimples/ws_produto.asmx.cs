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








    }
}
