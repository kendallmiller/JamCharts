using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using WebSandbox.Models;

namespace WebSandbox
{
    /// <summary>
    /// Summary description for Search
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class Search : System.Web.Services.WebService
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public List<SongTitleModel> SongTitlesByName(string term)
        {
            using (var db = new jamchartsEntities())
            {
                var songTitles = (from s in db.SongTitles
                                  where s.Title.Contains(term)
                                  orderby s.Title
                                  select new SongTitleModel() { Id = s.SongId, Title = s.Title });
                return songTitles.ToList();
            }
        }
    }
}
