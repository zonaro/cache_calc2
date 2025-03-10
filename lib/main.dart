import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innerlibs/innerlibs.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await innerLibsInit();
  prefs = await SharedPreferences.getInstance();
  if (equipe.isEmpty) {
    equipe = ['Mautari', 'Kaizonaro', 'Caxa', 'Szin', 'Tucca', 'Jaqueline', 'Lalis', 'Penna'];
  }

  for (var cargo in baseCargos) {
    cargo.$3.value = prefs.getDouble('porcentagem_${cargo.$1}') ?? cargo.$6;
    if (cargo.$4 != null) cargo.$4?.value = prefs.getStringList('participantes${cargo.$1}')?.toList() ?? [];
  }

  runApp(const MyApp());
}

ValueNotifier<List<string>> arrayArtista = ValueNotifier([]);
ValueNotifier<List<string>> arrayComercial = ValueNotifier([]);
ValueNotifier<List<string>> arrayProducao = ValueNotifier([]);
ValueNotifier<List<string>> arrayProdutor = ValueNotifier([]);

var baseCargos = <(int, string, ValueNotifier<double>, ValueNotifier<List<string>>?, string, double)>[
  (1, 'Comercial', ValueNotifier(0), ValueNotifier([]), 'Quem efetivamente vendeu o show', 20),
  (2, 'Produção', ValueNotifier(0), ValueNotifier([]), 'Responsáveis pela parte técnica (Fotografia, Filmagem, Luzes, Som)', 10),
  (3, 'Produtor', ValueNotifier(0), ValueNotifier([]), 'Responsável por falar diretamente com o contratante e com a técnica', 10),
  (4, 'Artista', ValueNotifier(0), ValueNotifier([]), 'Quem se apresentou no show', 50),
  (0, 'BeatFellas', ValueNotifier(0), null, 'Porcentagem do caixa da beatfellas', 10),
];

List<string> equipe = prefs.getStringList('equipe') ?? [];

late SharedPreferences prefs;

double get somaPorcentagem => baseCargos.map((x) => x.$3.value).sum;

double get total => prefs.getDouble("total") ?? 0;
set total(double value) => prefs.setDouble("total", value);

addEquipe(String value) {
  equipe = [...equipe, value];
}

Map<String, Map<string, double>> calcularCache() {
  
  if (somaPorcentagem <= 0) {
    for (var cargo in baseCargos) {
      cargo.$3.value = cargo.$6;
    }
  }

  while (somaPorcentagem > 100) {
    for (var cargo in baseCargos) {
      if (cargo.$3.value > 0) {
        cargo.$3.value--;
        break;
      }
    }
  }

  while (somaPorcentagem < 100) {
    for (var cargo in baseCargos) {
      if (cargo.$3.value < cargo.$6) {
        cargo.$3.value++;
        break;
      }
    }
  }

  Map<String, Map<string, double>> separado = {
    for (var cargo in baseCargos.where((x) => x.$4 != null))
      if ((cargo.$4 == null || cargo.$4!.value.isNotEmpty) && cargo.$3.value > 0) cargo.$2: calcularFatia(cargo.$4!.value, cargo.$3.value, total),
    'totais': {'BeatFellas': getPercent(total, pegarCargoID(0).$3.value)}
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

string formatDouble(double value) => NumberFormat.decimalPattern('pt_BR').format(value);

string formatReal(double value) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

double getPercent(double total, double percent) => percent * total / 100.0;

double parseReal(String value) => NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').parse(value) as double;

(int, string, ValueNotifier<double>, ValueNotifier<List<string>>?, string, double) pegarCargoID(int id) => baseCargos.firstWhere((x) => x.$1 == id);
(int, string, ValueNotifier<double>, ValueNotifier<List<string>>?, string, double) pegarCargoLabel(string label) => baseCargos.firstWhere((x) => x.$2.flatEqual(label));

removeEquipe(String value) {
  equipe = equipe.where((x) => x != value).toList();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var c = NamedColor.values.randomItem!;
    return MaterialApp(
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
        title: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Nome do Evento',
          ),
        ),
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
              children: [
                ResponsiveRow.withColumns(
                  md: 2,
                  lg: 3,
                  xl: 4,
                  horizontalSpacing: 10,
                  runSpacing: 10,
                  children: [
                    ResponsiveColumn.full(
                      child: Card(
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextFormField(
                            style: const TextStyle(fontSize: 20),
                            decoration: const InputDecoration(
                              labelText: 'Cachê Bruto',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: formatReal(total),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, RealInputFormatter(moeda: true)],
                            onChanged: (value) {
                              total = parseReal(value);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                    for (var c in baseCargos) percentColumn(id: c.$1, label: c.$2, porcentagem: c.$3, participantes: c.$4, descricao: c.$5),
                  ],
                ),
                Builder(builder: (context) {
                  Map<string, Map<string, double>> cache = calcularCache();
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      const Gap(20),
                      for (string cargo in cache.keys) ...[
                        Text(cargo.toTitleCase()).fontSize(20).bold().centerText().paddingAll(10).toCenter(),
                        for (string nome in cache[cargo]?.keys ?? [])
                          ListTile(
                            leading: AvatarImage(
                              child: Text(nome.initials(2)),
                            ),
                            title: Text(nome).fontSize(25),
                            trailing: Text(formatReal(cache[cargo]?[nome] ?? 0)).fontSize(25),
                          ),
                      ]
                    ],
                  );
                }),
                const Gap(80)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget percentColumn({
    required int id,
    required string label,
    required ValueNotifier<List<string>>? participantes,
    required ValueNotifier<double> porcentagem,
    string? descricao,
  }) {
    return Card(
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 250,
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(
              children: [
                Text(label).fontSize(20),
                if (descricao.isNotBlank) Text(descricao!).fontSize(12),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Porcentagem',
                suffixIcon: Icon(FontAwesome.percent_solid),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              initialValue: formatDouble(porcentagem.value),
              onChanged: (value) {
                porcentagem.value = parseReal(value);
                prefs.setDouble('porcentagem_$id', porcentagem.value);
                setState(() {});
              },
            ),
            if (participantes != null)
              DropdownSearch.multiSelection(
                enabled: porcentagem.value > 0,
                compareFn: (item1, item2) => item1 == item2,
                items: (s, props) => FilterFunctions.search(items: equipe, searchTerms: s).toList(),
                decoratorProps: const DropDownDecoratorProps(
                  decoration: InputDecoration(
                    labelText: 'Participantes',
                  ),
                ),
                onChanged: (value) {
                  participantes.value = value;
                  prefs.setStringList('participantes_$id', value);
                  setState(() {});
                },
              )
            else
              const Gap(50),
          ]),
        ),
      ),
    );
  }
}
