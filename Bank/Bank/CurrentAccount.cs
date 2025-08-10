using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bank
{
    public class CurrentAccount :BankAccount
    {

        private decimal _OverdraftLimit;
         
        public decimal OverdraftLimit {
            set
            {

                if (value > 0&&value<10000)
                {
                    _OverdraftLimit = value;
                }
                else
                {
                    Console.WriteLine("not valid ");
                }

            }
            get
            {
                return _OverdraftLimit;
            }
        }

        public CurrentAccount(string fullName, string nationalID, string phoneNumber, decimal balance, string address, decimal overdraftLimit) : base(fullName, nationalID, phoneNumber, balance, address)
        {
            OverdraftLimit=overdraftLimit;
        }

        public override decimal CalculateInterest()
        { return 0; }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine("OverdraftLimit :" + _OverdraftLimit);
        }

    }
}
