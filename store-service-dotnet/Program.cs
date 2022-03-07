using Newtonsoft.Json;
using Dapr.Client;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/", () =>
{
    var myData = new
        {
            storeService = "running",
            status = "ok",
            version = "0.10"
        };
    string jsonData = JsonConvert.SerializeObject(myData);
    return jsonData;
});

app.MapGet("/status", () =>
{
    var myData = new
        {
            storeService = "running",
            status = "ok",
            version = "0.10"
        };
    string jsonData = JsonConvert.SerializeObject(myData);
    return jsonData;
});

app.MapGet("/allinventory", async () =>
{
    using var client = new DaprClientBuilder().Build();
    var request = client.CreateInvokeMethodRequest("inventory-service", "allinventory");
    var response = await client.InvokeMethodWithResponseAsync(request);

    return response;

    // CancellationTokenSource source = new CancellationTokenSource();
    // CancellationToken cancellationToken = source.Token;
    // using var client = new DaprClientBuilder().Build();
    // var result = client.CreateInvokeMethodRequest(HttpMethod.Get, "inventory-service", "allinventory");
    // await client.InvokeMethodAsync(result);
    // return result;
});

app.Run();
