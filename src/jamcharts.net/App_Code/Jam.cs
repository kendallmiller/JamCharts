namespace WebSandbox
{
    using System.Threading.Tasks;
    using Microsoft.AspNet.SignalR.Hubs;


    public class Jam : Hub
    {
        public Task JoinGroup(string group)
        {
            return Groups.Add(Context.ConnectionId, group);
        }

        public Task LeaveGroup(string group)
        {
            return Groups.Remove(Context.ConnectionId, group);
        }

        public void LetsJam(string group, int id)
        {
            Clients.OthersInGroup(group).together(Context.ConnectionId, id);
        }
    }
}