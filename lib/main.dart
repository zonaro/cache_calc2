import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innerlibs/innerlibs.dart';
import 'package:tab_container/tab_container.dart';

void main() {
  runApp(const MyApp());
}

List<String> arrayArtista = [];

List<String> arrayComercial = [];
List<String> arrayProducao = [];
List<String> arrayProdutor = [];
StringList equipe = [
  'Caxa',
  'Kaizonaro',
  'Mautari',
  'Gustavo',
  'Igor',
  'Tucca',
  'Jaqueline',
  'Sara',
  'Sara Rios',
  'Luis',
  'Lalis',
];
double porcentagemArtista = 50;
double porcentagemBeatfellas = 10;
double porcentagemComercial = 20;
double porcentagemProducao = 10;
double porcentagemProdutor = 10;
double total = 0;
double get somaPorcentagem => porcentagemArtista + porcentagemBeatfellas + porcentagemComercial + porcentagemProducao + porcentagemProdutor;

Map<String, Map<string, double>> calcularCache() {
  if (somaPorcentagem <= 0) {
    porcentagemBeatfellas = 10;
    porcentagemComercial = 20;
    porcentagemProdutor = 10;
    porcentagemProducao = 10;
    porcentagemArtista = 50;
  }

  while (somaPorcentagem > 100) {
    if (porcentagemBeatfellas > 0) {
      porcentagemBeatfellas--;
      continue;
    }
    if (porcentagemComercial > 0) {
      porcentagemComercial--;
      continue;
    }
    if (porcentagemProdutor > 0) {
      porcentagemProdutor--;
      continue;
    }
    if (porcentagemProducao > 0) {
      porcentagemProducao--;
      continue;
    }
    if (porcentagemArtista > 0) {
      porcentagemArtista--;
      continue;
    }
  }

  while (somaPorcentagem < 100) {
    if (porcentagemBeatfellas < 10) {
      porcentagemBeatfellas++;
      continue;
    } else if (porcentagemComercial < 20) {
      porcentagemComercial++;
      continue;
    } else if (porcentagemProdutor < 10) {
      porcentagemProdutor++;
      continue;
    } else if (porcentagemProducao < 10) {
      porcentagemProducao++;
      continue;
    } else {
      porcentagemArtista++;
      continue;
    }
  }

  Map<String, Map<string, double>> separado = {
    if (arrayProducao.isNotEmpty && porcentagemProducao > 0) 'producao': calcularFatia(arrayProducao, porcentagemProducao, total),
    if (arrayComercial.isNotEmpty && porcentagemComercial > 0) 'comercial': calcularFatia(arrayComercial, porcentagemComercial, total),
    if (arrayArtista.isNotEmpty && porcentagemArtista > 0) 'artista': calcularFatia(arrayArtista, porcentagemArtista, total),
    if (arrayProdutor.isNotEmpty && porcentagemProdutor > 0) 'produtor': calcularFatia(arrayProdutor, porcentagemProdutor, total),
    'totais': {'BeatFellas': getPercent(total, porcentagemBeatfellas)}
  };

  for (var cargo in separado.keys.where((x) => x != 'totais')) {
    for (var nome in separado[cargo]!.keys) {
      separado['totais']![nome] = (separado['totais']![nome] ?? 0) + (separado[cargo]![nome] ?? 0);
    }
  }
  return separado;
}

Map<String, double> calcularFatia(List<String> array, double percent, double total) {
  double totalADividir = getPercent(total, percent);
  return {for (var p in array) p: totalADividir / array.length};
}

double getPercent(double total, double percent) => percent * total / 100.0;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var c = NamedColor.values.randomItem!;
    return GetMaterialApp(
      title: 'Calculadora de Cachê - BeatFellas',
      theme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: c, brightness: Brightness.light)),
      darkTheme: ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: c, brightness: Brightness.dark)),
      home: const MyHomePage(),
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: InnerLibsLocalizations.localizationsDelegates,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Cachê'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {});
        },
        icon: const Icon(Icons.calculate),
        label: const Text('Calcular Cachê'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do Evento',
                  ),
                  initialValue: 'Cachê do Show',
                ),
                const Gap(20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Cachê Bruto',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: total.toString(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, RealInputFormatter()],
                  onChanged: (value) {
                    total = double.parse(value);
                    setState(() {});
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Porcentagem da BeatFellas',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: porcentagemBeatfellas.toString(),
                  onChanged: (value) {
                    porcentagemBeatfellas = double.parse(value);
                    setState(() {});
                  },
                ),
                DropdownSearch.multiSelection(
                  compareFn: (item1, item2) => item1 == item2,
                  items: (s, props) {
                    return equipe;
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Comercial',
                    ),
                  ),
                  onChanged: (value) {
                    arrayComercial = value;
                    setState(() {});
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Porcentagem do Comercial',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: porcentagemComercial.toStringAsFixed(2),
                  onChanged: (value) => {
                    porcentagemComercial = double.parse(value),
                    setState(() {}),
                  },
                ),
                DropdownSearch.multiSelection(
                  compareFn: (item1, item2) => item1 == item2,
                  items: (s, props) {
                    return equipe;
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Produtores',
                    ),
                  ),
                  onChanged: (value) {
                    arrayProdutor = value;
                    setState(() {});
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Porcentagem dos Produtores',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: porcentagemProdutor.toStringAsFixed(2),
                  onChanged: (value) => {
                    porcentagemProdutor = double.parse(value),
                    setState(() {}),
                  },
                ),
                DropdownSearch.multiSelection(
                  compareFn: (item1, item2) => item1 == item2,
                  items: (s, props) {
                    return equipe;
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Produção',
                    ),
                  ),
                  onChanged: (value) {
                    arrayProducao = value;
                    setState(() {});
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Porcentagem da Produção',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: porcentagemProducao.toStringAsFixed(2),
                  onChanged: (value) {
                    porcentagemProducao = double.parse(value);
                    setState(() {});
                  },
                ),
                DropdownSearch.multiSelection(
                  compareFn: (item1, item2) => item1 == item2,
                  items: (s, props) {
                    return equipe;
                  },
                  decoratorProps: const DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: 'Artistas',
                    ),
                  ),
                  onChanged: (value) {
                    arrayArtista = value;
                    setState(() {});
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Porcentagem dos Artistas',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  initialValue: porcentagemArtista.toStringAsFixed(2),
                  onChanged: (value) {
                    porcentagemArtista = double.parse(value);
                    setState(() {});
                  },
                ),
                const Gap(20),
                Builder(builder: (context) {
                  var cache = calcularCache();
                  return SizedBox(
                    width: context.width,
                    height: (cache.values.expand((x) => x.values).length * 100).clampMin(100).toDouble() + 100,
                    child: TabContainer(
                      tabEdge: TabEdge.top,
                      // tabsStart: 0.1,
                      // tabsEnd: 0.9,
                      tabMaxLength: 200,
                      tabMinLength: 100,
                      borderRadius: BorderRadius.circular(10),
                      tabBorderRadius: BorderRadius.circular(10),
                      childPadding: const EdgeInsets.all(20.0),
                      // selectedTextStyle: const TextStyle(
                      //   color: Colors.white,
                      //   fontSize: 15.0,
                      // ),
                      // unselectedTextStyle: const TextStyle(
                      //   color: Colors.black,
                      //   fontSize: 13.0,
                      // ),
                      colors: [
                        for (var cargo in cache.keys) cargo.asColor,
                      ],
                      tabs: [
                        for (var cargo in cache.keys) Tab(text: cargo),
                      ],
                      children: [
                        for (var cargo in cache.keys)
                          Column(children: [
                            for (var nome in cache[cargo]!.keys) Text('$nome: R\$ ${cache[cargo]![nome]}'),
                          ]),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
