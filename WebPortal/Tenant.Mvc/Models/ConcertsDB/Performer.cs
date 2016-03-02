﻿using System;

namespace Tenant.Mvc.Models.ConcertsDB
{
    /// <summary>
    /// Maps to 'Performer' table in application database schema
    /// </summary>
    public class Performer
    {
        #region - Properties -

        public int PerformerId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Skills { get; set; }
        public Decimal ContactNbr { get; set; }
        public String ShortName { get; set; }

        #endregion
    }
}