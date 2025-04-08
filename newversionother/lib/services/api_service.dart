// 📁 lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String alphaVantageApiKey = 'TU_API_KEY_ALPHA_VANTAGE';
  static const String coingeckoBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String forexApiUrl = 'https://api.exchangerate-api.com/v4/latest/USD'; // API de ejemplo

  // Fetch Stock Data from Alpha Vantage
  static Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final url = 'https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=$symbol&apikey=$alphaVantageApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos de acciones.');
    }
  }

  // Fetch Cryptocurrency Data from CoinGecko
  static Future<Map<String, dynamic>> fetchCryptoData(String cryptoId) async {
    final url = '$coingeckoBaseUrl/coins/$cryptoId/market_chart?vs_currency=usd&days=7';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos de criptomonedas.');
    }
  }

  // Fetch Forex Data (Ejemplo: EUR/USD)
  static Future<Map<String, dynamic>> fetchForexData(String baseCurrency) async {
    final url = '$forexApiUrl'; // Usamos USD como base para el ejemplo
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos de Forex.');
    }
  }

  // Fetch Commodities Data (Ejemplo: Oro)
  static Future<Map<String, dynamic>> fetchCommoditiesData(String commodity) async {
    final url = 'https://metals-api.com/api/latest?access_key=YOUR_ACCESS_KEY&base=USD&symbols=$commodity';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos de Commodities.');
    }
  }
}
