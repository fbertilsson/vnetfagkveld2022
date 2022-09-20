using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace greenapi;

public class GetReport
{
    private readonly ISolarCalcClient _client;
    private readonly ILogger _logger;

    public GetReport(
        ILoggerFactory loggerFactory,
        ISolarCalcClient client)
    {
        _logger = loggerFactory.CreateLogger<GetReport>();
        _client = client;
    }

    [Function("GetReport")]
    public async Task<HttpResponseData> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req,
        string streetAddress)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        var megaWattPeak = await _client.Calculate(streetAddress);

        var response = req.CreateResponse(HttpStatusCode.OK);


        await response.WriteAsJsonAsync<ReportDto>(new ReportDto
        {
            MegaWattPeak = megaWattPeak.MegaWattPeak,
            PriceArea = "NO3"
        });

        return response;
    }
}
