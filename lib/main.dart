import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
const request = "https://api.hgbrasil.com/finance?key=bdab7778";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
        hintStyle: TextStyle(color: Colors.amber),
      ),
    ),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final pesoargentinoController = TextEditingController();


  late double dolar;
  late double euro;
  late double pesoargentino;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text.replaceAll(',', '.'));
    dolarController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(real / dolar);
    euroController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(real / euro);
    pesoargentinoController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(real / pesoargentino);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolarValue = double.parse(text.replaceAll(',', '.'));
    realController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(dolarValue * dolar);
    euroController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(dolarValue * dolar / euro);
    pesoargentinoController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(dolar / pesoargentino);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euroValue = double.parse(text.replaceAll(',', '.'));
    realController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(euroValue * euro);
    dolarController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(euroValue * euro / dolar);
    pesoargentinoController.text =
        NumberFormat.currency(locale: 'pt_BR', symbol: '').format(euro / pesoargentino);
  }
  void _pesoargentinoChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double pesoargentinoValue = double.parse(text.replaceAll(',', '.'));
    pesoargentinoController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '') as String;
    realController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(pesoargentinoValue * pesoargentino);
    dolarController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(pesoargentinoValue * pesoargentino / dolar);
    euroController.text = NumberFormat.currency(locale: 'pt_BR', symbol: '')
        .format(pesoargentinoValue * pesoargentino / euro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("\$ Quanto custa \$",
            style: TextStyle(fontSize: 30),
        ),
        toolbarHeight: 150,
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyanAccent, Colors.lightGreen, Colors.amberAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(
                  child: Text(
                    "Carregando Dados",
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Erro ao carregar Dados :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.0),
                        Image.asset(''),
                      ],
                    ),
                  );
                } else {
                  dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];
                  pesoargentino = snapshot.data?["results"]["currencies"]["ARS"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/raining-money-38.gif',
                            width: 330.0,
                            height: 330.0,
                            //color: Colors.amberAccent,
                          ),
                          buildTextField(
                              "Reais", "R\$", realController, _realChanged),

                          //const Icon(Icons.monetization_on,
                             // size: 220.0, color: Colors.amberAccent),

                          const Divider(),
                          buildTextField(
                              "Dólares", "US", dolarController, _dolarChanged),
                          const Divider(),
                          buildTextField(
                              "Euros", "€", euroController, _euroChanged),
                          const Divider(),
                          buildTextField(
                              "Peso Argentino", "ARS", pesoargentinoController, _pesoargentinoChanged),
                          const Divider(),
                        ],
                      ),
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController controller, void Function(String) onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.amber, fontSize: 25.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        prefixText: prefix,
      ),
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 28.0,
      ),
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
    pesoargentinoController.text = "";
  }
}
