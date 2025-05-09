import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class acciones_analisis extends StatefulWidget {
  const acciones_analisis({super.key});

  @override
  State<acciones_analisis> createState() => _AccionesTradingViewState();
}

class _AccionesTradingViewState extends State<acciones_analisis> {
  late final WebViewController _controller;
  String _currentSymbol = "AAPL";

  final List<String> destacados = [
    "AAPL",
    "MSFT",
    "GOOGL",
    "AMZN",
    "TSLA",
    "META",
    "NVDA",
    "NFLX"
  ];

  String embedHtml(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final theme = isDark ? "dark" : "light";
    final bgColor = isDark ? "#121212" : "#ffffff";
    final toolbarBg = isDark ? "#1e1e1e" : "#f1f3f6";

    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            html, body { margin: 0; padding: 0; height: 100%; background-color: $bgColor; }
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
              "symbol": "NASDAQ:${_currentSymbol}",
              "interval": "5",
              "timezone": "Etc/UTC",
              "theme": "$theme",
              "style": "1",
              "locale": "en",
              "toolbar_bg": "$toolbarBg",
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
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final brightness = Theme.of(context).brightness;
      _controller.loadHtmlString(embedHtml(brightness));
    });
  }

  void _cambiarSimbolo(String symbol) {
    setState(() {
      _currentSymbol = symbol;
      final brightness = Theme.of(context).brightness;
      _controller.loadHtmlString(embedHtml(brightness));
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Análisis Avanzado de Acciones"),
        backgroundColor: brightness == Brightness.dark ? Colors.grey[900] : Colors.indigo,
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
                    label: Text(symbol),
                    selected: isSelected,
                    onSelected: (_) => _cambiarSimbolo(symbol),
                    selectedColor: Colors.blueAccent,
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
