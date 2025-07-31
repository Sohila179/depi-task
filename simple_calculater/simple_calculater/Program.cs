using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace simple_calculater
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine("Hello!");
            Console.Write("Input the first number:");
            double num1=double.Parse(Console.ReadLine());
            Console.Write("Input the second number:");
            double num2 = double.Parse(Console.ReadLine());
            Console.WriteLine("");
            Console.WriteLine("What do you want to do with those numbers?\r\n[A]dd\r\n[S]ubtract\r\n[M]ultiply");
            char c = char.Parse(Console.ReadLine());
            switch (c) {
                case 'a':
                case 'A': Console.WriteLine(num1 + num2); break;
                case 'S':
                case 's': Console.WriteLine(num1 - num2); break;
                case 'M':
                case 'm': Console.WriteLine(num1 * num2); break;
                default : Console.WriteLine("Invalid option");break;
            }

        }
    }
}
