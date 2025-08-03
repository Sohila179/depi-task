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

            Bank account2 = new Bank("sohila bendary", "123456789", "01234567891", 100, "cairo");
            account2.ShowAccountDetails();


            Bank account3 = new Bank("Sara", "12345678912345", "01234567891", "cairo");
            account2.ShowAccountDetails();
        }

    }
      
}
