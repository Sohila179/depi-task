using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanckAccount
{
    internal class Bank
    {
        const string BankCode = "BNK001";
        readonly DateTime  CreatedDate;
        private int _accountNumber;
        private string _fullName;
        private string _nationalID;
        private string _phoneNumber;
        private string _address;
        private decimal  _balance;
        
        public string full_name
        {
            set {
                if (!string.IsNullOrEmpty(value))
                {
                    _fullName = value;
                }
                else {
                    Console.WriteLine("please enter your full name");
                }
            }
            get {
                return _fullName;
            }
        }
        public string national_id
        {
            set {
                if (value.Length==14) {
                    _nationalID = value;
                }
            }
            get { return _nationalID; }
        }

        public string phone_Number
        {
            set
            {
                if (value.Length == 11 && value[0] == 0 && value[1]==1)
                {
                    _phoneNumber = value;
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
                else {
                    Console.WriteLine("not valid ");
                }
               
            }
            get { 
                return _balance; 
            }
        }
        public string address { set; get; }


        public Bank()
        {
            
            Console.WriteLine("default constructor");
        }
        public Bank(string fullName, string nationalID, string phoneNumber, int balance, string address)
        {
            _fullName = fullName;
            _nationalID = nationalID;
            _phoneNumber = phoneNumber;
            _balance = balance;
            _address = address;
            Console.WriteLine("paramterize");
        }

        public Bank(string fullName, string nationalID, string phoneNumber, string address)
        : this(fullName, nationalID, phoneNumber, 0, address)
        {
            Console.WriteLine("overload");
        }

        public void ShowAccountDetails()
        {
            Console.WriteLine("Full Name: " + _fullName);
            Console.WriteLine("Phone Number: " + _phoneNumber);
            Console.WriteLine("Balance: " + _balance);
            Console.WriteLine("Address: " + _address);
            Console.WriteLine("National ID: " + _nationalID);
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


    }
}
