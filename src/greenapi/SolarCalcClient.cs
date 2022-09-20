using Microsoft.Extensions.Configuration;
using System.Net.Http.Json;

namespace greenapi;

public class SolarCalcClient : ISolarCalcClient
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _config;

    public SolarCalcClient(HttpClient httpClient, IConfiguration config)
    {
        _httpClient = httpClient;
        _config = config;
    }

    public async Task<SolarCalcDto> Calculate(string streetAddress)
    {
        var baseUri = _config["SolarCalcUri"];
        var uriBuilder = new UriBuilder(baseUri);
        uriBuilder.Query = $"streetAddress={streetAddress}";
        try
        {                    
            var dto = await _httpClient.GetFromJsonAsync<SolarCalcDto>(uriBuilder.ToString());
            if (dto == null) throw new Exception("Could not deserialize dto");

            return dto;
        }
        catch (Exception e) 
        {
            throw new Exception($"Error getting data from address '{baseUri}'", e);
        }
    }
}
