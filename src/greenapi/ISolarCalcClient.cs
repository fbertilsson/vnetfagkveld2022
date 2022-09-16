namespace greenapi;

public interface ISolarCalcClient
{
    /// <summary>
    /// Returns mega watt peak effect
    /// </summary>
    /// <param name="streetAddress"></param>
    /// <returns></returns>
    Task<int> Calculate(string streetAddress);
}
