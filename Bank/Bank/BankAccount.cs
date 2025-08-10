using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Bank
{
     public class BankAccount
    {
        const string BankCode = "BNK001";
        readonly DateTime CreatedDate;
        private int _accountNumber;
        private string _fullName;
        private string _nationalID;
        private string _phoneNumber;
        private string _address;
        private decimal _balance;

        public string full_name
        {
            set
            {
                if (!string.IsNullOrEmpty(value))
                {
                    _fullName = value;
                }
                else
                {
                    Console.WriteLine("please enter your full name");
                }
            }
            get
            {
                return _fullName;
            }
        }
        public string national_id
        {
            set
            {
                if (value.Length == 14)
                {
                    _nationalID = value;
                }
                else
                {
                    Console.WriteLine("not valid");
                }
            }
            get { return _nationalID; }
        }

        public string phone_Number
        {
            set
            {
                if (value.Length == 11 && value[0] == '0' && value[1] == '1')
                {
                    _phoneNumber = value;
                }
                else
                {
                    Console.WriteLine("not valid ");
                }
            }
            get { return _phoneNumber; }
        }

        public decimal balance
        {
            set
            {
                if (value > 0)
                {
                    _balance = value;
                }
                else
                {
                    Console.WriteLine("not valid ");
                }

            }
            get
            {
                return _balance;
            }
        }
        public string address { set; get; }


        public BankAccount()
        {

            Console.WriteLine("default constructor");
        }
        public BankAccount(string fullName, string nationalID, string phoneNumber, decimal balance, string address)
        {
            this.full_name = fullName;
            this.national_id = nationalID;
            this.phone_Number = phoneNumber;
            this.balance = balance;
            _address = address;
            Console.WriteLine("paramterize");
        }

        public BankAccount(string fullName, string nationalID, string phoneNumber, string address)
        {
            this.full_name = fullName;
            this.national_id = nationalID;
            this.phone_Number = phoneNumber;
            _balance = 0;
            _address = address;
            Console.WriteLine("overload");
        }

        public virtual void ShowAccountDetails()
        {
            Console.WriteLine("Full Name: " + full_name);
            Console.WriteLine("Phone Number: " + phone_Number);
            Console.WriteLine("Balance: " + balance);
            Console.WriteLine("Address: " + _address);
            Console.WriteLine("National ID: " + national_id);
        }
        public bool IsValidNationalID()
        {
            return _nationalID.Length == 14;
        }
        public bool IsValidPhoneNumber()
        {
            string phone = _phoneNumber;
            return phone.Length == 11 && phone[0] == 0 && phone[1] == 1;
        }


        public virtual decimal CalculateInterest() { return 0;  }
    }
}
