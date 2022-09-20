using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace solarcalc;

public class MegaWattPeak
{
    private readonly ILogger _logger;

    public MegaWattPeak(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger<MegaWattPeak>();
    }

    [Function("GetMegaWattPeak")]
    public async Task<HttpResponseData> GetMegaWattPeak(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req,
        string streetAddress)
    {
        _logger.LogInformation("C# HTTP trigger function processing: streetAddress: {streetAddress}", streetAddress);

        var response = req.CreateResponse(HttpStatusCode.OK);

        var dto = new SolarCalcDto {
            MegaWattPeak = streetAddress[0]
        };
    
        await response.WriteAsJsonAsync<SolarCalcDto>(dto);

        return response;
    }
}
