using greenapi;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults(ConfigureServices)
    .Build();

void ConfigureServices(IFunctionsWorkerApplicationBuilder builder)
{
    var services = builder.Services;
    //services.AddHttpClient();
    //services.AddSingleton<ISolarCalcClient, SolarCalcClient>();
    services.AddHttpClient<ISolarCalcClient, SolarCalcClient>();
}

host.Run();
