using Microsoft.AspNetCore.Mvc;

namespace solarcalc;

[ApiController]
[Route("[controller]")]
public class SolarCalcController : ControllerBase
{
    private readonly ILogger<SolarCalcController> _logger;

    public SolarCalcController(ILogger<SolarCalcController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    [Route("GetMegaWattPeak")]
    public SolarCalcDto GetMegaWattPeak(string streetAddress)
    {
        return new SolarCalcDto {
            MegaWattPeak = streetAddress[0]
        };
    }
}
