using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;

namespace WebSandbox.Models
{
    [Serializable]
    public class SongTitleModel
    {
        public int Id { get; set; }
        public string Title { get; set; }
    }
}