using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanckAccount
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Bank account1 = new Bank("sohila bendary", "12345678901234", "01234567891",100,"cairo");
            account1.ShowAccountDetails();
            Console.WriteLine("");
            Console.WriteLine("");
            Console.WriteLine("");


            Bank account2 = new Bank("fawzy", "1", "01", 500, "cairo");
            account2.ShowAccountDetails();
            Console.WriteLine("");
            Console.WriteLine("");
            Console.WriteLine("");
            Bank account3 = new Bank("Sara", "12345678912345", "01234567891", "cairo");
            account3.ShowAccountDetails();
        }

    }
      
}
