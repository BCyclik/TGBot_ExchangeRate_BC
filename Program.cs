using System;
using System.Linq;
using System.Collections.Generic;
using System.Timers;
using Newtonsoft.Json.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Net.Http;
using Telegram.Bot;
using Telegram.Bot.Types;
using Telegram.Bot.Types.Enums;
using Telegram.Bot.Args;

namespace TGBOT_ExchangeRate_BC;

public static class Program
{
    private const string BotToken = "8533912256:AAEct-zYTPTuWpNF57uhVLaG6jAXeAC2ZfQ";
    private static TelegramBotClient BotTG = new(BotToken);
    private static decimal LastPriceBTC;
    private static System.Timers.Timer timer = new(30 * 60 * 1000);
    public static async void Main(string[] args)
    {
        Console.WriteLine("Program starting...");

        LastPriceBTC = await GetPriceBTC();
        //var cts = new CancellationToken();
        BotTG.OnMessage += HandleUpdateAsync;
        BotTG.StartReceiving();

        Console.WriteLine("TGBOT started!");

        //long id_user = 225;
        //SubscribeToExchangeRateBTC(id_user);
        timer.Elapsed += UpdatePriceBTC;
        timer.Start();

        Console.WriteLine("Timer started!");

        Console.ReadLine();

        BotTG.StopReceiving();
        timer.Stop();

        Console.WriteLine("Program stoped!");
    }
    private static async void HandleUpdateAsync(object sender, MessageEventArgs e)
    {
        var message = e.Message;
        if (string.IsNullOrEmpty(message.Text)) return;
        if (!message.Text.Contains("/start")) return;
        SubscribeToExchangeRateBTC(message.From.Id);
        await BotTG.SendTextMessageAsync(message.From.Id, "Цена сейчас: " + LastPriceBTC);
    }
    private static Task HandleErrorAsync(ITelegramBotClient botClient, Exception exception, System.Threading.CancellationToken cancellationToken)
    {
        Console.WriteLine($"Произошла ошибка: {exception.Message}");
        return Task.CompletedTask;
    }

    private static async void UpdatePriceBTC(object sender, ElapsedEventArgs e)
    {
        Console.WriteLine("Updating PriceBTC...");

        var currentPrice = await GetPriceBTC();
        var lastPrice = LastPriceBTC;

        if (currentPrice < 0) return;

        decimal changePercentage = ((currentPrice - lastPrice) / lastPrice) * 100;
        string message;

        if (changePercentage > 0)
        {
            message = $"Цена Bitcoin увеличилась на {changePercentage:F2}%! Текущая цена: ${currentPrice} (было: ${lastPrice})";
        }
        else if (changePercentage < 0)
        {
            message = $"Цена Bitcoin уменьшилась на {Math.Abs(changePercentage):F2}%! Текущая цена: ${currentPrice} (было: ${lastPrice})";
        }
        else
        {
            message = $"Цена Bitcoin осталась неизменной: ${currentPrice}.";
        }

        LastPriceBTC = currentPrice;

        Console.WriteLine(message);

        foreach (var userId in subscribesUsers)
        {
            await BotTG.SendTextMessageAsync(userId, message);
        }
    }

    private static HashSet<long> subscribesUsers = new();
    private static void SubscribeToExchangeRateBTC(long user_id)
    {
        bool result = subscribesUsers.Contains(user_id);
        if (result) return;
        subscribesUsers.Add(user_id);
        Console.WriteLine("Added new user:" + user_id);
    }
    private static async Task<decimal> GetPriceBTC()
    {
        Console.WriteLine("GetPriceBTC");
        try
        {
            using (HttpClient client = new HttpClient())
            {
                string url = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd";
                var response = await client.GetStringAsync(url);
                var json = JObject.Parse(response);
                return json["bitcoin"]["usd"].Value<decimal>();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return -1;
        }
    }
}
