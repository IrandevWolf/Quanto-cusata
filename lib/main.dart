import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

const request = "https://api.hgbrasil.com/finance?key=bdab7778";

void main() async {
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

  late double dolar;
  late double euro;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("\$ Quanto custa \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent, Colors.lightGreen, Colors.amberAccent], // Cores do gradiente
                begin: Alignment.bottomLeft, // Ponto de início do gradiente
                end: Alignment.bottomRight, // Ponto de término do gradiente
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
                      return const Center(
                        child: Text(
                          "Erro ao carregar Dados :(",
                          style: TextStyle(color: Colors.amber, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                      euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Icon(Icons.monetization_on,
                                size: 220.0, color: Colors.amberAccent),
                            buildTextField(
                                "Reais", "R\$", realController, _realChanged),
                            Divider(),
                            buildTextField(
                                "Dólares", "US", dolarController, _dolarChanged),
                            Divider(),
                            buildTextField(
                                "Euros", "€", euroController, _euroChanged),
                            Divider(),
                          ],
                        ),
                      ),
                      );
                    }
                }
              },
            ),
          ),
        ],
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
        border: OutlineInputBorder(),
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
  }
}
