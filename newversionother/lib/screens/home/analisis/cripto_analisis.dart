import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class cripto_analisis extends StatefulWidget {
  const cripto_analisis({super.key});

  @override
  State<cripto_analisis> createState() => _CriptosTradingViewState();
}

class _CriptosTradingViewState extends State<cripto_analisis> {
  late final WebViewController _controller;
  String _currentSymbol = "BTCUSDT";

  final List<String> destacados = [
    "BTCUSDT",
    "ETHUSDT",
    "BNBUSDT",
    "SOLUSDT",
    "XRPUSDT",
    "ADAUSDT",
    "AVAXUSDT",
    "DOGEUSDT"
  ];

  String get embedHtml => '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          html, body { margin: 0; padding: 0; height: 100%; }
          #tv_chart_container { height: 100%; width: 100%; }
        </style>
      </head>
      <body>
        <div id="tv_chart_container"></div>
        <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
        <script type="text/javascript">
          new TradingView.widget({
            "container_id": "tv_chart_container",
            "width": "100%",
            "height": "100%",
            "symbol": "BINANCE:${_currentSymbol}",
            "interval": "15",
            "timezone": "Etc/UTC",
            "theme": "light",
            "style": "1",
            "locale": "en",
            "toolbar_bg": "#f1f3f6",
            "enable_publishing": false,
            "allow_symbol_change": true,
            "hide_top_toolbar": false,
            "hide_side_toolbar": false,
            "studies": [],
            "support_host": "https://www.tradingview.com"
          });
        </script>
      </body>
    </html>
  ''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(embedHtml);
  }

  void _cambiarSimbolo(String symbol) {
    setState(() {
      _currentSymbol = symbol;
      _controller.loadHtmlString(embedHtml);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Análisis Cripto"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: destacados.map((symbol) {
                final isSelected = symbol == _currentSymbol;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text(symbol.replaceAll("USDT", "")),
                    selected: isSelected,
                    onSelected: (_) => _cambiarSimbolo(symbol),
                    selectedColor: Colors.deepPurpleAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
