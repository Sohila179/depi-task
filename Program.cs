using CompanyEFCore.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections;
using System.Collections.Immutable;
using System.Numerics;
using static System.Reflection.Metadata.BlobBuilder;

namespace CompanyEFCore
{
    internal class Program
    {
        static void Main(string[] args)
        {

            CompanyT1Context c = new CompanyT1Context();
            var res = c.Departments.ToList();
            foreach(var item in res)
            {
                Console.WriteLine(item.Dname);
            }
        }
    }
}
