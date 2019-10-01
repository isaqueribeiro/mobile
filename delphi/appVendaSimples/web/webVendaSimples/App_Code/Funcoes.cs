using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Text;
using System.Security.Cryptography;
using System.IO;

namespace webVendaSimples.App_Code
{
    // Classe no modelo Singleton simples
    public sealed class Funcoes
    {
        private static readonly Funcoes instance = new Funcoes();

        private Funcoes() { }

        public static Funcoes Instance
        {
            get
            {
                return instance;
            }
        }

        public static String Encriptar(String valor) {
            String retorno = "";
            byte[] hash;

            HashAlgorithm hashing = new SHA1Managed();
            byte[] encript = Encoding.Unicode.GetBytes(valor);

            hash = hashing.ComputeHash(encript);
            retorno = Encoding.Unicode.GetString(hash);

            return retorno;
        }
    }
}