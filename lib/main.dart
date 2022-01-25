import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amberAccent.shade700,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.amberAccent.shade700,
          )),
          hintStyle: TextStyle(
            color: Colors.amberAccent.shade700,
          ),
        )),
  ));
}

Future<Map> getData() async {
  const request = "https://api.hgbrasil.com/finance?format=json-cors";
  var response = await Dio().get(request);
  return response.data;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();

  double? dollar;
  double? euro;

  void _realChanged(String text) {
    if (text.isEmpty) {
      dollarController.text = "";
      euroController.text = "";
    } else {
      double real = double.parse(text);
      dollarController.text = (real / dollar!).toStringAsFixed(2);
      euroController.text = (real / euro!).toStringAsFixed(2);
    }
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      realController.text = "";
      euroController.text = "";
    } else {
      double dollar = double.parse(text);
      realController.text = (dollar * this.dollar!).toStringAsFixed(2);
      euroController.text = (dollar * this.dollar! / euro!).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      realController.text = "";
      dollarController.text = "";
    } else {
      double euro = double.parse(text);
      realController.text = (euro * this.euro!).toStringAsFixed(2);
      dollarController.text = (euro * this.euro! / dollar!).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        title: Text("Conversor"),
        backgroundColor: Colors.amberAccent.shade700,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando",
                    style: TextStyle(
                      color: Colors.amberAccent.shade700,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao Carregar Dados",
                      style: TextStyle(
                        color: Colors.amberAccent.shade700,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar =
                      snapshot.data?["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(padding: EdgeInsets.only(top: 10)),
                        Image(
                          image: AssetImage("assets/images/coin.png"),
                          height: 120,
                          width: 120,
                        ),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 20, left: 10, right: 10),
                            child: buildTextFiled(
                                "Reais", "R\$", realController, _realChanged)),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 20, left: 10, right: 10),
                            child: buildTextFiled("Dólares", "U\$",
                                dollarController, _dollarChanged)),
                        Padding(
                            padding:
                                EdgeInsets.only(top: 20, left: 10, right: 10),
                            child: buildTextFiled(
                                "Euros", "€", euroController, _euroChanged)),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextFiled(String label, String prefix, TextEditingController c, f) {
  return TextField(
    controller: c,
    onChanged: f,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.amberAccent.shade700,
        ),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amberAccent.shade700, fontSize: 25.0),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}
