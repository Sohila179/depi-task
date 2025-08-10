using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bank
{
     public class SavingAccount :BankAccount
     {
        private decimal _InterestRate;

        public SavingAccount(string fullName,string nationalID,string phoneNumber,  decimal balance,  string address, decimal interestRate):base( fullName,  nationalID,  phoneNumber,  balance,  address)
        {
            
            InterestRate = interestRate;
        }

        public decimal InterestRate { 
            set {

                if (value > 0)
                {
                    _InterestRate = value;
                }
                else
                {
                    Console.WriteLine("not valid ");
                }

            }
            get { 
               return _InterestRate;
            } 
        }
        public override decimal CalculateInterest(){
            return balance*InterestRate / 100; 
        }

        public override void ShowAccountDetails()
        { 
           base.ShowAccountDetails();
            Console.WriteLine("InterestRate :" + _InterestRate);
        }
        }
    }
