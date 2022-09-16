using Microsoft.AspNetCore.Mvc;

namespace greenapi;

[ApiController]
[Route("[controller]")]
public class GreenApiController : ControllerBase
{
    private readonly ILogger<GreenApiController> _logger;
    private readonly ISolarCalcClient _client;

    public GreenApiController(ILogger<GreenApiController> logger,
        ISolarCalcClient client)
    {
        _logger = logger;
        _client = client;
    }

    [HttpGet(Name = "GetSolarCalc")]
    public async Task<ActionResult> GetSolarCalc(string streetAddress)
    {
        try {
            var megaWattPeak = await _client.Calculate(streetAddress);
            return Ok(megaWattPeak.ToString());
        }
        catch (Exception ex) {
            _logger.LogError(ex, "Could not calculate right now for street address {streetAddress}", streetAddress);
            return StatusCode(500); 
        }
    }
}
