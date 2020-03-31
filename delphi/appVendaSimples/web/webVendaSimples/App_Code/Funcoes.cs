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

        public static String Encriptar(String valor)
        {
            String retorno = "";
            byte[] hash;

            HashAlgorithm hashing = new SHA1Managed();
            byte[] encript = Encoding.Unicode.GetBytes(valor);

            hash = hashing.ComputeHash(encript);
            retorno = Encoding.Unicode.GetString(hash);

            return retorno;
        }

        public static String Encriptar_v2(String input)
        {
            SHA1Managed sha1 = new SHA1Managed();
            var hash = sha1.ComputeHash(Encoding.Unicode.GetBytes(input));
            var sb = new StringBuilder(hash.Length * 2);

            foreach (byte b in hash)
            {
                // can be "x2" if you want lowercase
                sb.Append(b.ToString("X2"));
            }

            return sb.ToString();
        }

        public static String EncriptarHashBytes(String valueToHash)
        {
            HashAlgorithm hasher = new SHA1CryptoServiceProvider();
            Byte[] valueToHashAsByte = Encoding.UTF8.GetBytes(valueToHash);
            Byte[] returnBytes = hasher.ComputeHash(valueToHashAsByte);
            StringBuilder hex = new StringBuilder(returnBytes.Length * 2);

            foreach (byte b in returnBytes)
            {
                hex.AppendFormat("{0:x2}", b);
            };

            return "0x" + hex.ToString().ToUpper();
        }

        public static String HashBytes(byte[] clearBytes)
        {
            SHA1 hasher = SHA1.Create();
            byte[] hashBytes = hasher.ComputeHash(clearBytes);
            string hash = System.Convert.ToBase64String(hashBytes);
            hasher.Clear();

            return hash;
        }

        public static String HashString(String cleartext)
        {
            byte[] clearBytes = Encoding.UTF8.GetBytes(cleartext);
            return HashBytes(clearBytes);
        }

        public static String GetMd5Hash(MD5 md5Hash, string input)
        {
            byte[] data = md5Hash.ComputeHash(Encoding.UTF8.GetBytes(input));
            StringBuilder sBuilder = new StringBuilder();
            for (int i = 0; i < data.Length; i++)
            {
                sBuilder.Append(data[i].ToString("x2"));
            }
            return sBuilder.ToString();
        }

        public static String Md5String(String text)
        {
            MD5 md5Hash = MD5.Create();
            string hash = GetMd5Hash(md5Hash, text);
            return hash;
        }
    }
}