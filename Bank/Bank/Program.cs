using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bank
{
    public class Program
    {
        static void Main(string[] args)
        {

            List<BankAccount> accs = new List<BankAccount> {
              new CurrentAccount("fawzy", "1", "01", 500, "cairo",500),
               new SavingAccount("sohila bendary", "12345678901234", "01234567891",100,"cairo", 0.05m)

            };
            foreach(var acc in accs)
            {
                acc.ShowAccountDetails();
                Console.WriteLine();
                Console.WriteLine("--------------------------");
            }
        }
    }
}
