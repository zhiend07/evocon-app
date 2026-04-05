// Correction des warnings :
// - Suppression de la variable inutilisée 'totalDowntimeAllStations'
// - Placement du paramètre `child` en dernier dans tous les widgets

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:intl/intl.dart';

// Variables Supabase
const String supabaseUrl = 'https://jteqwfyhvedyhswwwgpn.supabase.co';
const String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imp0ZXF3ZnlodmVkeWhzd3d3Z3BuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2NTc3NjUsImV4cCI6MjA2MTIzMzc2NX0.e_EWOHjLQjiqnuRLCVAP3bLFR2Xs4gwIgT6XNHUF62A';
const String tableLogin = 'login';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evocon App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showErrorDialog(
        "Erreur",
        "Veuillez entrer un nom d'utilisateur et un mot de passe.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl =
          '$supabaseUrl/rest/v1/$tableLogin?select=username,password&username=eq.$username&password=eq.$password';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'apikey': supabaseKey,
          'Authorization': 'Bearer $supabaseKey',
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*', // Ajoutez cette ligne
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          _showErrorDialog(
            "Erreur",
            "Nom d'utilisateur ou mot de passe incorrect.",
          );
        }
      } else {
        _showErrorDialog("Erreur", "Erreur serveur : ${response.statusCode}");
        developer.log("Erreur serveur : ${response.body}", name: "HTTP Error");
      }
    } catch (error) {
      _showErrorDialog("Erreur", "Une erreur inattendue est survenue : $error");
      developer.log("Exception: $error", name: "HTTP Exception");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/evocon.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Nom d'utilisateur",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _login,
                    child: const Text('Se Connecter'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color.fromARGB(255, 241, 226, 177);
    final Color buttonColor = Colors.blue;
    final Color buttonTextColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page d\'accueil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 112, 242, 222),
      ),
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/supercerame.png',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 220,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: buttonTextColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Synthèse', style: TextStyle(fontSize: 18)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SynthesisPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Berrechid'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BerrechidPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Casa'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CasaPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Kenitra'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KenitraPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 120,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: buttonTextColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Tetouan'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TetouanPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- CASA PAGE ---------------------------
class CasaPage extends StatefulWidget {
  const CasaPage({super.key});

  @override
  CasaPageState createState() => CasaPageState();
}

class CasaPageState extends State<CasaPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _data = [];
  bool _loading = false;

  bool _showProductionTable = false;
  bool _showDowntimeTable = false;
  bool _showConsoEnergies = false;
  bool _showRatiosEnergies = false;

  List<Map<String, dynamic>> _consoEnergiesData = [];
  bool _loadingConsoEnergies = false;

  // Liste des stations Casablanca pour la production
  List<String> get casablancaStations {
    return [
      "Triage Phase 10 Casablanca",
      "Triage Phase 4 Casablanca",
      "Triage Phase 6 Casablanca",
      "Triage Phase 8 Casablanca",
    ];
  }

  // Liste des ids pour Vide Four
  static const List<int> downtimeStationIds = [77, 65, 75, 70, 67, 72];

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> fetchData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _data = [];
    });

    final String apiUrl =
        'https://api.evocon.com/api/reports/oee_json?stationId=41&stationId=31&stationId=67&stationId=72&stationId=42&stationId=33&stationId=77&stationId=65&stationId=75&stationId=70&startTime=${_startDate!.toIso8601String()}&endTime=${_endDate!.toIso8601String()}';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          setState(() {
            _data = jsonData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données chargées avec succès !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON: ${e.toString()}',
            name: 'fetchData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données du serveur.',
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        developer.log(
          'Erreur 401 : Non autorisé - Vérifiez vos identifiants.',
          name: 'fetchData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec de l\'authentification. Vérifiez vos identifiants.',
            ),
          ),
        );
      } else {
        developer.log('Erreur : ${response.statusCode}', name: 'fetchData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchConsoEnergiesData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loadingConsoEnergies = true;
      _consoEnergiesData = [];
      _showProductionTable = false;
      _showDowntimeTable = false;
      _showConsoEnergies = true;
      _showRatiosEnergies = false;
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final List<String> desiredFields = [
            "Stock citerne Butane  (Kg)²",
            "Stock citerne Propane  (Kg)²",
            "Stock Fuel (Kg)²",
            "Arrivage Afriquia butane (Kg)²",
            "Arrivage Afriquia propane (Kg)²",
            "Arrivage Total butane (Kg)²",
            "Arrivage Total Propane (Kg)²",
            "Arrivage Fuel (Kg)²",
          ];
          final filtered =
              jsonData
                  .where(
                    (item) =>
                        item['station'] ==
                        "Machine d'injection / Entrée four PH 8 casa",
                  )
                  .toList();

          Map<String, Map<String, String>> dateToFieldResults = {};
          for (var item in filtered) {
            final date = (item['date'] ?? item['Date'] ?? '')
                .toString()
                .substring(0, 10);
            final field = item['itemname'] ?? '';
            final result = item['itemresult']?.toString() ?? '';
            if (desiredFields.contains(field)) {
              dateToFieldResults.putIfAbsent(date, () => {});
              dateToFieldResults[date]![field] = result;
            }
          }

          final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
          final endDateStr = DateFormat(
            'yyyy-MM-dd',
          ).format(_endDate!.add(const Duration(days: 1)));

          List<Map<String, dynamic>> result = [];
          for (var field in desiredFields) {
            Map<String, dynamic> row = {};
            row['champ'] = field;
            row['startValue'] = dateToFieldResults[startDateStr]?[field] ?? '';
            row['endValue'] = dateToFieldResults[endDateStr]?[field] ?? '';
            result.add(row);
          }

          setState(() {
            _consoEnergiesData = result;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données Conso Energies chargées !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON Conso Energies: ${e.toString()}',
            name: 'fetchConsoEnergiesData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données Conso Energies.',
              ),
            ),
          );
        }
      } else {
        developer.log(
          'Erreur Conso Energies : ${response.statusCode}',
          name: 'fetchConsoEnergiesData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données Conso Energies : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Conso Energies : ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergies = false;
        });
      }
    }
  }

  double getQuantiteTotaleCasablancaFromSummary(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    double total = 0.0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        total += mainTableSummary[station]!['totalQty'] as double;
      }
    }
    return total;
  }

  List<Map<String, String>> getRatiosEnergies(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesData.isEmpty) return [];

    Map<String, dynamic> getRow(String champ) => _consoEnergiesData.firstWhere(
      (r) => r['champ'] == champ,
      orElse: () => {},
    );

    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane  (Kg)²")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane  (Kg)²")['endValue'],
    );

    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane  (Kg)²")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane  (Kg)²")['endValue'],
    );

    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)²")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)²")['endValue']);

    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia butane (Kg)²")['endValue'],
    );
    double arrivageAfriquiaButaneEnd = parseVal(
      getRow("Arrivage Afriquia propane (Kg)²")['endValue'],
    );
    double arrivageTotalButaneEnd = parseVal(
      getRow("Arrivage Total butane (Kg)²")['endValue'],
    );
    double arrivageTotalPropaneEnd = parseVal(
      getRow("Arrivage Total Propane (Kg)²")['endValue'],
    );
    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)²")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalButaneEnd) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaButaneEnd +
                arrivageTotalPropaneEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double quantiteTotaleCasa = getQuantiteTotaleCasablancaFromSummary(
      mainTableSummary,
    );
    String quantiteTotaleCasaStr =
        quantiteTotaleCasa > 0 ? quantiteTotaleCasa.toStringAsFixed(2) : "0.00";

    double gazDiv = quantiteTotaleCasa > 0 ? gaz / quantiteTotaleCasa : 0.0;
    double fuelDiv = quantiteTotaleCasa > 0 ? fuel / quantiteTotaleCasa : 0.0;
    double sommeDiv = quantiteTotaleCasa > 0 ? somme / quantiteTotaleCasa : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Casa': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Casa': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Casa': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Casablanca',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Casa': quantiteTotaleCasaStr,
      },
    ];
  }

  Map<String, Map<String, dynamic>> calculateMainTableSummary() {
    final Map<String, Map<String, dynamic>> summary = {};

    for (final item in _data) {
      final String station = item['station'];
      final double operatingTimeSec =
          (item['operatingTimeSec'] as num).toDouble();
      final double plannedTime = (item['plannedTime'] as num).toDouble();
      final double totalQty = (item['totalQty'] as num).toDouble();
      final double idealQty = (item['idealQty'] as num).toDouble();
      final double goodQty = (item['goodQty'] as num).toDouble();

      summary.putIfAbsent(
        station,
        () => {
          'operatingTimeSec': 0.0,
          'plannedTime': 0.0,
          'totalQty': 0.0,
          'idealQty': 0.0,
          'goodQty': 0.0,
        },
      );

      summary[station]!['operatingTimeSec'] += operatingTimeSec;
      summary[station]!['plannedTime'] += plannedTime;
      summary[station]!['totalQty'] += totalQty;
      summary[station]!['idealQty'] += idealQty;
      summary[station]!['goodQty'] += goodQty;
    }

    summary.forEach((station, data) {
      final double operatingTimeSum = data['operatingTimeSec'];
      final double plannedTimeSum = data['plannedTime'];
      final double totalQtySum = data['totalQty'];
      final double idealQtySum = data['idealQty'];
      final double goodQtySum = data['goodQty'];

      final double trs =
          (plannedTimeSum > 0 && idealQtySum > 0 && totalQtySum > 0)
              ? (operatingTimeSum / plannedTimeSum) *
                  (totalQtySum / idealQtySum) *
                  (goodQtySum / totalQtySum)
              : 0.0;

      data['trs'] = trs;
    });

    return summary;
  }

  Map<String, double> calculateDowntimeSummary() {
    final Map<String, double> downtimeSummary = {};
    for (final item in _data) {
      final String station = item['station'];
      final int stationId = item['stationId'];
      final double downtime = (item['downtime'] as num).toDouble();
      final double plannedStops = (item['plannedstops'] as num).toDouble();
      if (downtimeStationIds.contains(stationId)) {
        downtimeSummary.update(
          station,
          (existing) => existing + downtime + plannedStops,
          ifAbsent: () => downtime + plannedStops,
        );
      }
    }
    return downtimeSummary;
  }

  List<String> getVideFourStationsFromData() {
    final stations = <String>{};
    for (final item in _data) {
      final int stationId = item['stationId'];
      final String station = item['station'];
      if (downtimeStationIds.contains(stationId)) {
        stations.add(station);
      }
    }
    return stations.toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> mainTableSummary =
        calculateMainTableSummary();
    final Map<String, double> downtimeTableSummary = calculateDowntimeSummary();

    double totalQtyAllStations = 0.0;
    double totalGoodQtyAllStations = 0.0;
    double totalTRSAllStations = 0.0;
    int trsCount = 0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        totalQtyAllStations += mainTableSummary[station]!['totalQty'];
        totalGoodQtyAllStations += mainTableSummary[station]!['goodQty'];
        totalTRSAllStations += mainTableSummary[station]!['trs'];
        trsCount++;
      }
    }
    final double overallQualityPercentage =
        totalQtyAllStations > 0
            ? (totalGoodQtyAllStations / totalQtyAllStations) * 100
            : 0.0;
    final double totalTrsGlobal =
        trsCount > 0 ? (totalTRSAllStations / trsCount) : 0.0;

    final videFourStations = getVideFourStationsFromData();

    final ratiosEnergies = getRatiosEnergies(mainTableSummary);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(child: Text('Evocon Data Casa')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F1F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text(
                                  'Sélectionner une plage de dates',
                                ),
                                onPressed: () => _selectDateRange(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'End date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchData,
                                child: const Text('Actualiser'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Production par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = true;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Vide Four par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = true;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchConsoEnergiesData,
                                child: const Text('Conso Energies'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Ratios Energies'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_showProductionTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Quantité totale')),
                                  DataColumn(label: Text('% Qualité')),
                                  DataColumn(label: Text('TRS')),
                                ],
                                rows: [
                                  ...casablancaStations.map((station) {
                                    final data = mainTableSummary[station];
                                    final double totalQty =
                                        data?['totalQty'] ?? 0.0;
                                    final double goodQty =
                                        data?['goodQty'] ?? 0.0;
                                    final double trs = data?['trs'] ?? 0.0;
                                    final double qualityPercentage =
                                        totalQty > 0
                                            ? (goodQty / totalQty) * 100
                                            : 0.0;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              NumberFormat(
                                                "###,###",
                                                "fr_FR",
                                              ).format(totalQty),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${qualityPercentage.toStringAsFixed(2)}%',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(trs * 100).toStringAsFixed(2)}%',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            NumberFormat(
                                              "###,###",
                                              "fr_FR",
                                            ).format(totalQtyAllStations),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${overallQualityPercentage.toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${(totalTrsGlobal * 100).toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showDowntimeTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Vide Four (heures)')),
                                ],
                                rows: [
                                  ...videFourStations.map((station) {
                                    final double downtimeInSeconds =
                                        downtimeTableSummary[station] ?? 0.0;
                                    final double downtimeInHours =
                                        downtimeInSeconds / 3600;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Text(
                                            downtimeInHours.toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (videFourStations
                                                      .map(
                                                        (station) =>
                                                            downtimeTableSummary[station] ??
                                                            0.0,
                                                      )
                                                      .fold(
                                                        0.0,
                                                        (a, b) => a + b,
                                                      ) /
                                                  3600)
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showConsoEnergies)
                        Expanded(
                          child:
                              _loadingConsoEnergies
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _consoEnergiesData.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée trouvée pour Conso Energies Machine d\'injection / Entrée four PH 8 casa.',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: [
                                          const DataColumn(
                                            label: Text('Champ'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _startDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(_startDate!)
                                                  : '',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _endDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(
                                                    _endDate!.add(
                                                      const Duration(days: 1),
                                                    ),
                                                  )
                                                  : '',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            _consoEnergiesData.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['champ'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['startValue'] ?? ''}',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['endValue'] ?? ''}',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                      if (_showRatiosEnergies)
                        Expanded(
                          child:
                              ratiosEnergies.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée pour Ratios Energies',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Nom')),
                                          DataColumn(
                                            label: Text('Ratios (KWH)'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Ratios/Qté Totale Casa',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            ratiosEnergies.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['Nom'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios (KWH)'] ?? '',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios/Qté Totale Casa'] ??
                                                          '',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- Berrechid PAGE ---------------------------
class BerrechidPage extends StatefulWidget {
  const BerrechidPage({super.key});

  @override
  BerrechidPageState createState() => BerrechidPageState();
}

class BerrechidPageState extends State<BerrechidPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _data = [];
  bool _loading = false;

  bool _showProductionTable = false;
  bool _showDowntimeTable = false;
  bool _showConsoEnergies = false;
  bool _showRatiosEnergies = false;

  List<Map<String, dynamic>> _consoEnergiesData = [];
  bool _loadingConsoEnergies = false;

  // Liste des stations Casablanca pour la production
  List<String> get casablancaStations {
    return [
      "Triage 1 Berrechid",
      "Triage 2 Berrechid",
      "Triage 3 Berrechid",
      "Triage 4 Berrechid",
      "Triage 5 Berrechid",
      "Triage 6 Berrechid",
    ];
  }

  // Liste des ids pour Vide Four
  static const List<int> downtimeStationIds = [6, 7, 134, 57, 58];

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> fetchData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _data = [];
    });

    final String apiUrl =
        'https://api.evocon.com/api/reports/oee_json?stationId=2&stationId=3&stationId=57&stationId=58&stationId=6&stationId=7&stationId=134&stationId=12&stationId=13&stationId=135&stationId=106&startTime=${_startDate!.toIso8601String()}&endTime=${_endDate!.toIso8601String()}';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          setState(() {
            _data = jsonData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données chargées avec succès !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON: ${e.toString()}',
            name: 'fetchData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données du serveur.',
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        developer.log(
          'Erreur 401 : Non autorisé - Vérifiez vos identifiants.',
          name: 'fetchData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec de l\'authentification. Vérifiez vos identifiants.',
            ),
          ),
        );
      } else {
        developer.log('Erreur : ${response.statusCode}', name: 'fetchData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchConsoEnergiesData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loadingConsoEnergies = true;
      _consoEnergiesData = [];
      _showProductionTable = false;
      _showDowntimeTable = false;
      _showConsoEnergies = true;
      _showRatiosEnergies = false;
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final List<String> desiredFields = [
            "Stock citerne Butane (Kg)¹",
            "Stock citerne Propane (Kg)¹",
            "Stock Fuel (Kg)¹",
            "Arrivage Afriquia Butane (Kg)¹",
            "Arrivage Afriquia propane (Kg)¹",
            "Arrivage Total Butane (Kg)¹",
            "Arrivage Total Propane (Kg)¹",
            "Arrivage Fuel (Kg)¹",
          ];
          final filtered =
              jsonData
                  .where((item) => item['station'] == "Four 1 Berrechid")
                  .toList();

          Map<String, Map<String, String>> dateToFieldResults = {};
          for (var item in filtered) {
            final date = (item['date'] ?? item['Date'] ?? '')
                .toString()
                .substring(0, 10);
            final field = item['itemname'] ?? '';
            final result = item['itemresult']?.toString() ?? '';
            if (desiredFields.contains(field)) {
              dateToFieldResults.putIfAbsent(date, () => {});
              dateToFieldResults[date]![field] = result;
            }
          }

          final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
          final endDateStr = DateFormat(
            'yyyy-MM-dd',
          ).format(_endDate!.add(const Duration(days: 1)));

          List<Map<String, dynamic>> result = [];
          for (var field in desiredFields) {
            Map<String, dynamic> row = {};
            row['champ'] = field;
            row['startValue'] = dateToFieldResults[startDateStr]?[field] ?? '';
            row['endValue'] = dateToFieldResults[endDateStr]?[field] ?? '';
            result.add(row);
          }

          setState(() {
            _consoEnergiesData = result;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données Conso Energies  SCB chargées !'),
            ),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON Conso Energies  SCB: ${e.toString()}',
            name: 'fetchConsoEnergiesData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données Conso Energies  SCB.',
              ),
            ),
          );
        }
      } else {
        developer.log(
          'Erreur Conso Energies  SCB : ${response.statusCode}',
          name: 'fetchConsoEnergiesData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données Conso Energies  SCB : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Conso Energies  SCB : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergies = false;
        });
      }
    }
  }

  double getQuantiteTotaleCasablancaFromSummary(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    double total = 0.0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        total += mainTableSummary[station]!['totalQty'] as double;
      }
    }
    return total;
  }

  List<Map<String, String>> getRatiosEnergies(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesData.isEmpty) return [];

    Map<String, dynamic> getRow(String champ) => _consoEnergiesData.firstWhere(
      (r) => r['champ'] == champ,
      orElse: () => {},
    );

    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane (Kg)¹")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane (Kg)¹")['endValue'],
    );

    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane (Kg)¹")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane (Kg)¹")['endValue'],
    );

    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)¹")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)¹")['endValue']);

    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia Butane (Kg)¹")['endValue'],
    );
    double arrivageAfriquiaButaneEnd = parseVal(
      getRow("Arrivage Afriquia propane (Kg)¹")['endValue'],
    );
    double arrivageTotalButaneEnd = parseVal(
      getRow("Arrivage Total Butane (Kg)¹")['endValue'],
    );
    double arrivageTotalPropaneEnd = parseVal(
      getRow("Arrivage Total Propane (Kg)¹")['endValue'],
    );
    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)¹")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalButaneEnd) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaButaneEnd +
                arrivageTotalPropaneEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double quantiteTotaleCasa = getQuantiteTotaleCasablancaFromSummary(
      mainTableSummary,
    );
    String quantiteTotaleCasaStr =
        quantiteTotaleCasa > 0 ? quantiteTotaleCasa.toStringAsFixed(2) : "0.00";

    double gazDiv = quantiteTotaleCasa > 0 ? gaz / quantiteTotaleCasa : 0.0;
    double fuelDiv = quantiteTotaleCasa > 0 ? fuel / quantiteTotaleCasa : 0.0;
    double sommeDiv = quantiteTotaleCasa > 0 ? somme / quantiteTotaleCasa : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Berrechid',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Berrechid': quantiteTotaleCasaStr,
      },
    ];
  }

  Map<String, Map<String, dynamic>> calculateMainTableSummary() {
    final Map<String, Map<String, dynamic>> summary = {};

    for (final item in _data) {
      final String station = item['station'];
      final double operatingTimeSec =
          (item['operatingTimeSec'] as num).toDouble();
      final double plannedTime = (item['plannedTime'] as num).toDouble();
      final double totalQty = (item['totalQty'] as num).toDouble();
      final double idealQty = (item['idealQty'] as num).toDouble();
      final double goodQty = (item['goodQty'] as num).toDouble();

      summary.putIfAbsent(
        station,
        () => {
          'operatingTimeSec': 0.0,
          'plannedTime': 0.0,
          'totalQty': 0.0,
          'idealQty': 0.0,
          'goodQty': 0.0,
        },
      );

      summary[station]!['operatingTimeSec'] += operatingTimeSec;
      summary[station]!['plannedTime'] += plannedTime;
      summary[station]!['totalQty'] += totalQty;
      summary[station]!['idealQty'] += idealQty;
      summary[station]!['goodQty'] += goodQty;
    }

    summary.forEach((station, data) {
      final double operatingTimeSum = data['operatingTimeSec'];
      final double plannedTimeSum = data['plannedTime'];
      final double totalQtySum = data['totalQty'];
      final double idealQtySum = data['idealQty'];
      final double goodQtySum = data['goodQty'];

      final double trs =
          (plannedTimeSum > 0 && idealQtySum > 0 && totalQtySum > 0)
              ? (operatingTimeSum / plannedTimeSum) *
                  (totalQtySum / idealQtySum) *
                  (goodQtySum / totalQtySum)
              : 0.0;

      data['trs'] = trs;
    });

    return summary;
  }

  Map<String, double> calculateDowntimeSummary() {
    final Map<String, double> downtimeSummary = {};
    for (final item in _data) {
      final String station = item['station'];
      final int stationId = item['stationId'];
      final double downtime = (item['downtime'] as num).toDouble();
      final double plannedStops = (item['plannedstops'] as num).toDouble();
      if (downtimeStationIds.contains(stationId)) {
        downtimeSummary.update(
          station,
          (existing) => existing + downtime + plannedStops,
          ifAbsent: () => downtime + plannedStops,
        );
      }
    }
    return downtimeSummary;
  }

  List<String> getVideFourStationsFromData() {
    final stations = <String>{};
    for (final item in _data) {
      final int stationId = item['stationId'];
      final String station = item['station'];
      if (downtimeStationIds.contains(stationId)) {
        stations.add(station);
      }
    }
    return stations.toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> mainTableSummary =
        calculateMainTableSummary();
    final Map<String, double> downtimeTableSummary = calculateDowntimeSummary();

    double totalQtyAllStations = 0.0;
    double totalGoodQtyAllStations = 0.0;
    double totalTRSAllStations = 0.0;
    int trsCount = 0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        totalQtyAllStations += mainTableSummary[station]!['totalQty'];
        totalGoodQtyAllStations += mainTableSummary[station]!['goodQty'];
        totalTRSAllStations += mainTableSummary[station]!['trs'];
        trsCount++;
      }
    }
    final double overallQualityPercentage =
        totalQtyAllStations > 0
            ? (totalGoodQtyAllStations / totalQtyAllStations) * 100
            : 0.0;
    final double totalTrsGlobal =
        trsCount > 0 ? (totalTRSAllStations / trsCount) : 0.0;

    final videFourStations = getVideFourStationsFromData();

    final ratiosEnergies = getRatiosEnergies(mainTableSummary);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(child: Text('Evocon Data Berrechid')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F1F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text(
                                  'Sélectionner une plage de dates',
                                ),
                                onPressed: () => _selectDateRange(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'End date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchData,
                                child: const Text('Actualiser'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Production par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = true;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Vide Four par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = true;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchConsoEnergiesData,
                                child: const Text('Conso Energies  SCB'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Ratios Energies'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_showProductionTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Quantité totale')),
                                  DataColumn(label: Text('% Qualité')),
                                  DataColumn(label: Text('TRS')),
                                ],
                                rows: [
                                  ...casablancaStations.map((station) {
                                    final data = mainTableSummary[station];
                                    final double totalQty =
                                        data?['totalQty'] ?? 0.0;
                                    final double goodQty =
                                        data?['goodQty'] ?? 0.0;
                                    final double trs = data?['trs'] ?? 0.0;
                                    final double qualityPercentage =
                                        totalQty > 0
                                            ? (goodQty / totalQty) * 100
                                            : 0.0;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              NumberFormat(
                                                "###,###",
                                                "fr_FR",
                                              ).format(totalQty),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${qualityPercentage.toStringAsFixed(2)}%',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(trs * 100).toStringAsFixed(2)}%',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            NumberFormat(
                                              "###,###",
                                              "fr_FR",
                                            ).format(totalQtyAllStations),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${overallQualityPercentage.toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${(totalTrsGlobal * 100).toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showDowntimeTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Vide Four (heures)')),
                                ],
                                rows: [
                                  ...videFourStations.map((station) {
                                    final double downtimeInSeconds =
                                        downtimeTableSummary[station] ?? 0.0;
                                    final double downtimeInHours =
                                        downtimeInSeconds / 3600;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Text(
                                            downtimeInHours.toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (videFourStations
                                                      .map(
                                                        (station) =>
                                                            downtimeTableSummary[station] ??
                                                            0.0,
                                                      )
                                                      .fold(
                                                        0.0,
                                                        (a, b) => a + b,
                                                      ) /
                                                  3600)
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showConsoEnergies)
                        Expanded(
                          child:
                              _loadingConsoEnergies
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _consoEnergiesData.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée trouvée pour Conso Energies  SCB Four 1 Berrechid.',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: [
                                          const DataColumn(
                                            label: Text('Champ'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _startDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(_startDate!)
                                                  : '',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _endDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(
                                                    _endDate!.add(
                                                      const Duration(days: 1),
                                                    ),
                                                  )
                                                  : '',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            _consoEnergiesData.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['champ'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['startValue'] ?? ''}',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['endValue'] ?? ''}',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                      if (_showRatiosEnergies)
                        Expanded(
                          child:
                              ratiosEnergies.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée pour Ratios Energies',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Nom')),
                                          DataColumn(
                                            label: Text('Ratios (KWH)'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Ratios/Qté Totale Berrechid',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            ratiosEnergies.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['Nom'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios (KWH)'] ?? '',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios/Qté Totale Berrechid'] ??
                                                          '',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- kenitra PAGE ---------------------------
class KenitraPage extends StatefulWidget {
  const KenitraPage({super.key});

  @override
  KenitraPageState createState() => KenitraPageState();
}

class KenitraPageState extends State<KenitraPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _data = [];
  bool _loading = false;

  bool _showProductionTable = false;
  bool _showDowntimeTable = false;
  bool _showConsoEnergies = false;
  bool _showRatiosEnergies = false;

  List<Map<String, dynamic>> _consoEnergiesData = [];
  bool _loadingConsoEnergies = false;

  // Liste des stations Casablanca pour la production
  List<String> get casablancaStations {
    return [
      "Triage A8 Kenitra",
      "Triage A9 Kenitra",
      "Triage B1 Kenitra",
      "Triage B2 Kenitra",
      "Triage B3 Kenitra",
    ];
  }

  // Liste des ids pour Vide Four
  static const List<int> downtimeStationIds = [
    79,
    21,
    22,
    23,
    24,
    129,
    130,
    131,
  ];

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> fetchData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _data = [];
    });

    final String apiUrl =
        'https://api.evocon.com/api/reports/oee_json?stationId=79&stationId=21&stationId=22&stationId=23&stationId=24&stationId=80&stationId=20&stationId=17&stationId=18&stationId=102&stationId=129&stationId=130&stationId=131&startTime=${_startDate!.toIso8601String()}&endTime=${_endDate!.toIso8601String()}';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          setState(() {
            _data = jsonData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données chargées avec succès !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON: ${e.toString()}',
            name: 'fetchData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données du serveur.',
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        developer.log(
          'Erreur 401 : Non autorisé - Vérifiez vos identifiants.',
          name: 'fetchData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec de l\'authentification. Vérifiez vos identifiants.',
            ),
          ),
        );
      } else {
        developer.log('Erreur : ${response.statusCode}', name: 'fetchData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchConsoEnergiesData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loadingConsoEnergies = true;
      _consoEnergiesData = [];
      _showProductionTable = false;
      _showDowntimeTable = false;
      _showConsoEnergies = true;
      _showRatiosEnergies = false;
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final List<String> desiredFields = [
            "Stock citerne Butane (Kg)³",
            "Stock citerne Propane (Kg)³",
            "Stock Fuel (Kg)³",
            "Arrivage Afriquia (Kg)³",
            "Arrivage Total (Kg)³",
            "Arrivage Vitogaz (Kg)³",
            "Arrivage Fuel (Kg)³",
          ];
          final filtered =
              jsonData
                  .where(
                    (item) =>
                        item['station'] == "Machine d'injection A8-16 Kenitra",
                  )
                  .toList();

          Map<String, Map<String, String>> dateToFieldResults = {};
          for (var item in filtered) {
            final date = (item['date'] ?? item['Date'] ?? '')
                .toString()
                .substring(0, 10);
            final field = item['itemname'] ?? '';
            final result = item['itemresult']?.toString() ?? '';
            if (desiredFields.contains(field)) {
              dateToFieldResults.putIfAbsent(date, () => {});
              dateToFieldResults[date]![field] = result;
            }
          }

          final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
          final endDateStr = DateFormat(
            'yyyy-MM-dd',
          ).format(_endDate!.add(const Duration(days: 1)));

          List<Map<String, dynamic>> result = [];
          for (var field in desiredFields) {
            Map<String, dynamic> row = {};
            row['champ'] = field;
            row['startValue'] = dateToFieldResults[startDateStr]?[field] ?? '';
            row['endValue'] = dateToFieldResults[endDateStr]?[field] ?? '';
            result.add(row);
          }

          setState(() {
            _consoEnergiesData = result;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données Conso Energies chargées !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON Conso Energies: ${e.toString()}',
            name: 'fetchConsoEnergiesData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données Conso Energies.',
              ),
            ),
          );
        }
      } else {
        developer.log(
          'Erreur Conso Energies : ${response.statusCode}',
          name: 'fetchConsoEnergiesData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données Conso Energies : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Conso Energies : ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergies = false;
        });
      }
    }
  }

  double getQuantiteTotaleCasablancaFromSummary(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    double total = 0.0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        total += mainTableSummary[station]!['totalQty'] as double;
      }
    }
    return total;
  }

  List<Map<String, String>> getRatiosEnergies(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesData.isEmpty) return [];

    Map<String, dynamic> getRow(String champ) => _consoEnergiesData.firstWhere(
      (r) => r['champ'] == champ,
      orElse: () => {},
    );

    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane (Kg)³")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane (Kg)³")['endValue'],
    );

    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane (Kg)³")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane (Kg)³")['endValue'],
    );

    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)³")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)³")['endValue']);

    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia (Kg)³")['endValue'],
    );
    double arrivageTotalEnd = parseVal(
      getRow("Arrivage Total (Kg)³")['endValue'],
    );
    double arrivageTotalvitogazEnd = parseVal(
      getRow("Arrivage Vitogaz (Kg)³")['endValue'],
    );

    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)³")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalEnd * 0.8) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalEnd * 0.2 +
                arrivageTotalvitogazEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double quantiteTotaleCasa = getQuantiteTotaleCasablancaFromSummary(
      mainTableSummary,
    );
    String quantiteTotaleCasaStr =
        quantiteTotaleCasa > 0 ? quantiteTotaleCasa.toStringAsFixed(2) : "0.00";

    double gazDiv = quantiteTotaleCasa > 0 ? gaz / quantiteTotaleCasa : 0.0;
    double fuelDiv = quantiteTotaleCasa > 0 ? fuel / quantiteTotaleCasa : 0.0;
    double sommeDiv = quantiteTotaleCasa > 0 ? somme / quantiteTotaleCasa : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Kenitra',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Kenitra': quantiteTotaleCasaStr,
      },
    ];
  }

  Map<String, Map<String, dynamic>> calculateMainTableSummary() {
    final Map<String, Map<String, dynamic>> summary = {};

    for (final item in _data) {
      final String station = item['station'];
      final double operatingTimeSec =
          (item['operatingTimeSec'] as num).toDouble();
      final double plannedTime = (item['plannedTime'] as num).toDouble();
      final double totalQty = (item['totalQty'] as num).toDouble();
      final double idealQty = (item['idealQty'] as num).toDouble();
      final double goodQty = (item['goodQty'] as num).toDouble();

      summary.putIfAbsent(
        station,
        () => {
          'operatingTimeSec': 0.0,
          'plannedTime': 0.0,
          'totalQty': 0.0,
          'idealQty': 0.0,
          'goodQty': 0.0,
        },
      );

      summary[station]!['operatingTimeSec'] += operatingTimeSec;
      summary[station]!['plannedTime'] += plannedTime;
      summary[station]!['totalQty'] += totalQty;
      summary[station]!['idealQty'] += idealQty;
      summary[station]!['goodQty'] += goodQty;
    }

    summary.forEach((station, data) {
      final double operatingTimeSum = data['operatingTimeSec'];
      final double plannedTimeSum = data['plannedTime'];
      final double totalQtySum = data['totalQty'];
      final double idealQtySum = data['idealQty'];
      final double goodQtySum = data['goodQty'];

      final double trs =
          (plannedTimeSum > 0 && idealQtySum > 0 && totalQtySum > 0)
              ? (operatingTimeSum / plannedTimeSum) *
                  (totalQtySum / idealQtySum) *
                  (goodQtySum / totalQtySum)
              : 0.0;

      data['trs'] = trs;
    });

    return summary;
  }

  Map<String, double> calculateDowntimeSummary() {
    final Map<String, double> downtimeSummary = {};
    for (final item in _data) {
      final String station = item['station'];
      final int stationId = item['stationId'];
      final double downtime = (item['downtime'] as num).toDouble();
      final double plannedStops = (item['plannedstops'] as num).toDouble();
      if (downtimeStationIds.contains(stationId)) {
        downtimeSummary.update(
          station,
          (existing) => existing + downtime + plannedStops,
          ifAbsent: () => downtime + plannedStops,
        );
      }
    }
    return downtimeSummary;
  }

  List<String> getVideFourStationsFromData() {
    final stations = <String>{};
    for (final item in _data) {
      final int stationId = item['stationId'];
      final String station = item['station'];
      if (downtimeStationIds.contains(stationId)) {
        stations.add(station);
      }
    }
    return stations.toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> mainTableSummary =
        calculateMainTableSummary();
    final Map<String, double> downtimeTableSummary = calculateDowntimeSummary();

    double totalQtyAllStations = 0.0;
    double totalGoodQtyAllStations = 0.0;
    double totalTRSAllStations = 0.0;
    int trsCount = 0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        totalQtyAllStations += mainTableSummary[station]!['totalQty'];
        totalGoodQtyAllStations += mainTableSummary[station]!['goodQty'];
        totalTRSAllStations += mainTableSummary[station]!['trs'];
        trsCount++;
      }
    }
    final double overallQualityPercentage =
        totalQtyAllStations > 0
            ? (totalGoodQtyAllStations / totalQtyAllStations) * 100
            : 0.0;
    final double totalTrsGlobal =
        trsCount > 0 ? (totalTRSAllStations / trsCount) : 0.0;

    final videFourStations = getVideFourStationsFromData();

    final ratiosEnergies = getRatiosEnergies(mainTableSummary);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(child: Text('Evocon Data Kenitra')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F1F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text(
                                  'Sélectionner une plage de dates',
                                ),
                                onPressed: () => _selectDateRange(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'End date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchData,
                                child: const Text('Actualiser'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Production par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = true;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Vide Four par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = true;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchConsoEnergiesData,
                                child: const Text('Conso Energies'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Ratios Energies'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_showProductionTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Quantité totale')),
                                  DataColumn(label: Text('% Qualité')),
                                  DataColumn(label: Text('TRS')),
                                ],
                                rows: [
                                  ...casablancaStations.map((station) {
                                    final data = mainTableSummary[station];
                                    final double totalQty =
                                        data?['totalQty'] ?? 0.0;
                                    final double goodQty =
                                        data?['goodQty'] ?? 0.0;
                                    final double trs = data?['trs'] ?? 0.0;
                                    final double qualityPercentage =
                                        totalQty > 0
                                            ? (goodQty / totalQty) * 100
                                            : 0.0;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              NumberFormat(
                                                "###,###",
                                                "fr_FR",
                                              ).format(totalQty),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${qualityPercentage.toStringAsFixed(2)}%',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(trs * 100).toStringAsFixed(2)}%',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            NumberFormat(
                                              "###,###",
                                              "fr_FR",
                                            ).format(totalQtyAllStations),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${overallQualityPercentage.toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${(totalTrsGlobal * 100).toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showDowntimeTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Vide Four (heures)')),
                                ],
                                rows: [
                                  ...videFourStations.map((station) {
                                    final double downtimeInSeconds =
                                        downtimeTableSummary[station] ?? 0.0;
                                    final double downtimeInHours =
                                        downtimeInSeconds / 3600;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Text(
                                            downtimeInHours.toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (videFourStations
                                                      .map(
                                                        (station) =>
                                                            downtimeTableSummary[station] ??
                                                            0.0,
                                                      )
                                                      .fold(
                                                        0.0,
                                                        (a, b) => a + b,
                                                      ) /
                                                  3600)
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showConsoEnergies)
                        Expanded(
                          child:
                              _loadingConsoEnergies
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _consoEnergiesData.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée trouvée pour Conso Energies Kenitra.',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: [
                                          const DataColumn(
                                            label: Text('Champ'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _startDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(_startDate!)
                                                  : '',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _endDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(
                                                    _endDate!.add(
                                                      const Duration(days: 1),
                                                    ),
                                                  )
                                                  : '',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            _consoEnergiesData.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['champ'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['startValue'] ?? ''}',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['endValue'] ?? ''}',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                      if (_showRatiosEnergies)
                        Expanded(
                          child:
                              ratiosEnergies.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée pour Ratios Energies',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Nom')),
                                          DataColumn(
                                            label: Text('Ratios (KWH)'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Ratios/Qté Totale Kenitra',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            ratiosEnergies.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['Nom'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios (KWH)'] ?? '',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios/Qté Totale Kenitra'] ??
                                                          '',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- Tetouan PAGE ---------------------------
class TetouanPage extends StatefulWidget {
  const TetouanPage({super.key});

  @override
  TetouanPageState createState() => TetouanPageState();
}

class TetouanPageState extends State<TetouanPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _data = [];
  bool _loading = false;

  bool _showProductionTable = false;
  bool _showDowntimeTable = false;
  bool _showConsoEnergies = false;
  bool _showRatiosEnergies = false;

  List<Map<String, dynamic>> _consoEnergiesData = [];
  bool _loadingConsoEnergies = false;

  // Liste des stations Casablanca pour la production
  List<String> get casablancaStations {
    return ["Triage 1 Tétouan", "Triage 2 Tétouan"];
  }

  // Liste des ids pour Vide Four
  static const List<int> downtimeStationIds = [94, 95, 49, 50];

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> fetchData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _data = [];
    });

    final String apiUrl =
        'https://api.evocon.com/api/reports/oee_json?stationId=49&stationId=50&stationId=94&stationId=95&stationId=47&stationId=48&startTime=${_startDate!.toIso8601String()}&endTime=${_endDate!.toIso8601String()}';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          setState(() {
            _data = jsonData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données chargées avec succès !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON: ${e.toString()}',
            name: 'fetchData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données du serveur.',
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        developer.log(
          'Erreur 401 : Non autorisé - Vérifiez vos identifiants.',
          name: 'fetchData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec de l\'authentification. Vérifiez vos identifiants.',
            ),
          ),
        );
      } else {
        developer.log('Erreur : ${response.statusCode}', name: 'fetchData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> fetchConsoEnergiesData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loadingConsoEnergies = true;
      _consoEnergiesData = [];
      _showProductionTable = false;
      _showDowntimeTable = false;
      _showConsoEnergies = true;
      _showRatiosEnergies = false;
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          final List<String> desiredFields = [
            "Stock citerne Butane (Kg)",
            "Stock citerne Propane (Kg)",
            "Stock Fuel (Kg)",
            "Arrivage Afriquia (Kg)",
            "Arrivage VITOGAZ (Kg)",
            "Arrivage Fuel (Kg)",
          ];
          final filtered =
              jsonData
                  .where((item) => item['station'] == "Four 1 TN240 Tétouan")
                  .toList();

          Map<String, Map<String, String>> dateToFieldResults = {};
          for (var item in filtered) {
            final date = (item['date'] ?? item['Date'] ?? '')
                .toString()
                .substring(0, 10);
            final field = item['itemname'] ?? '';
            final result = item['itemresult']?.toString() ?? '';
            if (desiredFields.contains(field)) {
              dateToFieldResults.putIfAbsent(date, () => {});
              dateToFieldResults[date]![field] = result;
            }
          }

          final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
          final endDateStr = DateFormat(
            'yyyy-MM-dd',
          ).format(_endDate!.add(const Duration(days: 1)));

          List<Map<String, dynamic>> result = [];
          for (var field in desiredFields) {
            Map<String, dynamic> row = {};
            row['champ'] = field;
            row['startValue'] = dateToFieldResults[startDateStr]?[field] ?? '';
            row['endValue'] = dateToFieldResults[endDateStr]?[field] ?? '';
            result.add(row);
          }

          setState(() {
            _consoEnergiesData = result;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données Conso Energies chargées !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON Conso Energies: ${e.toString()}',
            name: 'fetchConsoEnergiesData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données Conso Energies.',
              ),
            ),
          );
        }
      } else {
        developer.log(
          'Erreur Conso Energies : ${response.statusCode}',
          name: 'fetchConsoEnergiesData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données Conso Energies : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur Conso Energies : ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergies = false;
        });
      }
    }
  }

  double getQuantiteTotaleCasablancaFromSummary(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    double total = 0.0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        total += mainTableSummary[station]!['totalQty'] as double;
      }
    }
    return total;
  }

  List<Map<String, String>> getRatiosEnergies(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesData.isEmpty) return [];

    Map<String, dynamic> getRow(String champ) => _consoEnergiesData.firstWhere(
      (r) => r['champ'] == champ,
      orElse: () => {},
    );

    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane (Kg)")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane (Kg)")['endValue'],
    );

    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane (Kg)")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane (Kg)")['endValue'],
    );

    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)")['endValue']);

    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia (Kg)")['endValue'],
    );
    double arrivagevitogazEnd = parseVal(
      getRow("Arrivage VITOGAZ (Kg)")['endValue'],
    );
    double arrivageFuelEnd = parseVal(getRow("Arrivage Fuel (Kg)")['endValue']);

    double gaz =
        ((stockButaneStart - stockButaneEnd) * 12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaEnd +
                arrivagevitogazEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double quantiteTotaleCasa = getQuantiteTotaleCasablancaFromSummary(
      mainTableSummary,
    );
    String quantiteTotaleCasaStr =
        quantiteTotaleCasa > 0 ? quantiteTotaleCasa.toStringAsFixed(2) : "0.00";

    double gazDiv = quantiteTotaleCasa > 0 ? gaz / quantiteTotaleCasa : 0.0;
    double fuelDiv = quantiteTotaleCasa > 0 ? fuel / quantiteTotaleCasa : 0.0;
    double sommeDiv = quantiteTotaleCasa > 0 ? somme / quantiteTotaleCasa : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Tétouan',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Tétouan': quantiteTotaleCasaStr,
      },
    ];
  }

  Map<String, Map<String, dynamic>> calculateMainTableSummary() {
    final Map<String, Map<String, dynamic>> summary = {};

    for (final item in _data) {
      final String station = item['station'];
      final double operatingTimeSec =
          (item['operatingTimeSec'] as num).toDouble();
      final double plannedTime = (item['plannedTime'] as num).toDouble();
      final double totalQty = (item['totalQty'] as num).toDouble();
      final double idealQty = (item['idealQty'] as num).toDouble();
      final double goodQty = (item['goodQty'] as num).toDouble();

      summary.putIfAbsent(
        station,
        () => {
          'operatingTimeSec': 0.0,
          'plannedTime': 0.0,
          'totalQty': 0.0,
          'idealQty': 0.0,
          'goodQty': 0.0,
        },
      );

      summary[station]!['operatingTimeSec'] += operatingTimeSec;
      summary[station]!['plannedTime'] += plannedTime;
      summary[station]!['totalQty'] += totalQty;
      summary[station]!['idealQty'] += idealQty;
      summary[station]!['goodQty'] += goodQty;
    }

    summary.forEach((station, data) {
      final double operatingTimeSum = data['operatingTimeSec'];
      final double plannedTimeSum = data['plannedTime'];
      final double totalQtySum = data['totalQty'];
      final double idealQtySum = data['idealQty'];
      final double goodQtySum = data['goodQty'];

      final double trs =
          (plannedTimeSum > 0 && idealQtySum > 0 && totalQtySum > 0)
              ? (operatingTimeSum / plannedTimeSum) *
                  (totalQtySum / idealQtySum) *
                  (goodQtySum / totalQtySum)
              : 0.0;

      data['trs'] = trs;
    });

    return summary;
  }

  Map<String, double> calculateDowntimeSummary() {
    final Map<String, double> downtimeSummary = {};
    for (final item in _data) {
      final String station = item['station'];
      final int stationId = item['stationId'];
      final double downtime = (item['downtime'] as num).toDouble();
      final double plannedStops = (item['plannedstops'] as num).toDouble();
      if (downtimeStationIds.contains(stationId)) {
        downtimeSummary.update(
          station,
          (existing) => existing + downtime + plannedStops,
          ifAbsent: () => downtime + plannedStops,
        );
      }
    }
    return downtimeSummary;
  }

  List<String> getVideFourStationsFromData() {
    final stations = <String>{};
    for (final item in _data) {
      final int stationId = item['stationId'];
      final String station = item['station'];
      if (downtimeStationIds.contains(stationId)) {
        stations.add(station);
      }
    }
    return stations.toList();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> mainTableSummary =
        calculateMainTableSummary();
    final Map<String, double> downtimeTableSummary = calculateDowntimeSummary();

    double totalQtyAllStations = 0.0;
    double totalGoodQtyAllStations = 0.0;
    double totalTRSAllStations = 0.0;
    int trsCount = 0;
    for (final station in casablancaStations) {
      if (mainTableSummary.containsKey(station)) {
        totalQtyAllStations += mainTableSummary[station]!['totalQty'];
        totalGoodQtyAllStations += mainTableSummary[station]!['goodQty'];
        totalTRSAllStations += mainTableSummary[station]!['trs'];
        trsCount++;
      }
    }
    final double overallQualityPercentage =
        totalQtyAllStations > 0
            ? (totalGoodQtyAllStations / totalQtyAllStations) * 100
            : 0.0;
    final double totalTrsGlobal =
        trsCount > 0 ? (totalTRSAllStations / trsCount) : 0.0;

    final videFourStations = getVideFourStationsFromData();

    final ratiosEnergies = getRatiosEnergies(mainTableSummary);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Center(child: Text('Evocon Data Tétouan')),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF6F1F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text(
                                  'Sélectionner une plage de dates',
                                ),
                                onPressed: () => _selectDateRange(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'End date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  elevation: 1,
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchData,
                                child: const Text('Actualiser'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Production par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = true;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Vide Four par ligne'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = true;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = false;
                                  });
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                onPressed: fetchConsoEnergiesData,
                                child: const Text('Conso Energies'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.deepPurpleAccent,
                                    width: 0.5,
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Ratios Energies'),
                                onPressed: () {
                                  setState(() {
                                    _showProductionTable = false;
                                    _showDowntimeTable = false;
                                    _showConsoEnergies = false;
                                    _showRatiosEnergies = true;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      if (_showProductionTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Quantité totale')),
                                  DataColumn(label: Text('% Qualité')),
                                  DataColumn(label: Text('TRS')),
                                ],
                                rows: [
                                  ...casablancaStations.map((station) {
                                    final data = mainTableSummary[station];
                                    final double totalQty =
                                        data?['totalQty'] ?? 0.0;
                                    final double goodQty =
                                        data?['goodQty'] ?? 0.0;
                                    final double trs = data?['trs'] ?? 0.0;
                                    final double qualityPercentage =
                                        totalQty > 0
                                            ? (goodQty / totalQty) * 100
                                            : 0.0;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Center(
                                            child: Text(
                                              NumberFormat(
                                                "###,###",
                                                "fr_FR",
                                              ).format(totalQty),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${qualityPercentage.toStringAsFixed(2)}%',
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            '${(trs * 100).toStringAsFixed(2)}%',
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Text(
                                            NumberFormat(
                                              "###,###",
                                              "fr_FR",
                                            ).format(totalQtyAllStations),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${overallQualityPercentage.toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${(totalTrsGlobal * 100).toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showDowntimeTable)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Station')),
                                  DataColumn(label: Text('Vide Four (heures)')),
                                ],
                                rows: [
                                  ...videFourStations.map((station) {
                                    final double downtimeInSeconds =
                                        downtimeTableSummary[station] ?? 0.0;
                                    final double downtimeInHours =
                                        downtimeInSeconds / 3600;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(station)),
                                        DataCell(
                                          Text(
                                            downtimeInHours.toStringAsFixed(2),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                  DataRow(
                                    cells: [
                                      const DataCell(
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          (videFourStations
                                                      .map(
                                                        (station) =>
                                                            downtimeTableSummary[station] ??
                                                            0.0,
                                                      )
                                                      .fold(
                                                        0.0,
                                                        (a, b) => a + b,
                                                      ) /
                                                  3600)
                                              .toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_showConsoEnergies)
                        Expanded(
                          child:
                              _loadingConsoEnergies
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : _consoEnergiesData.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée trouvée pour Conso Energies Tétouan.',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: [
                                          const DataColumn(
                                            label: Text('Champ'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _startDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(_startDate!)
                                                  : '',
                                            ),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              _endDate != null
                                                  ? DateFormat(
                                                    'yyyy-MM-dd',
                                                  ).format(
                                                    _endDate!.add(
                                                      const Duration(days: 1),
                                                    ),
                                                  )
                                                  : '',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            _consoEnergiesData.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['champ'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['startValue'] ?? ''}',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      '${row['endValue'] ?? ''}',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                      if (_showRatiosEnergies)
                        Expanded(
                          child:
                              ratiosEnergies.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Aucune donnée pour Ratios Energies',
                                    ),
                                  )
                                  : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: DataTable(
                                        columns: const [
                                          DataColumn(label: Text('Nom')),
                                          DataColumn(
                                            label: Text('Ratios (KWH)'),
                                          ),
                                          DataColumn(
                                            label: Text(
                                              'Ratios/Qté Totale Tétouan',
                                            ),
                                          ),
                                        ],
                                        rows:
                                            ratiosEnergies.map((row) {
                                              return DataRow(
                                                cells: [
                                                  DataCell(
                                                    Text(row['Nom'] ?? ''),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios (KWH)'] ?? '',
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      row['Ratios/Qté Totale Tétouan'] ??
                                                          '',
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// -------------------- synthèses PAGE ---------------------------
// -------------------- SynthesisPage ---------------------------

class SynthesisPage extends StatefulWidget {
  const SynthesisPage({super.key});

  @override
  SynthesisPageState createState() => SynthesisPageState();
}

class SynthesisPageState extends State<SynthesisPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<dynamic> _data = [];
  bool _loading = false;
  late bool silent;

  bool _showProductionTable = false;
  bool _showDowntimeTable = false;
  bool _showConsoEnergiesSCC = false;
  bool _showRatiosEnergiesSCC = false;
  bool _showConsoEnergiesBerrechid = false;
  bool _showRatiosEnergiesBerrechid = false;
  bool _showConsoEnergiesKenitra = false;
  bool _showRatiosEnergiesKenitra = false;

  // Contrôle du défilement horizontal des boutons
  final ScrollController _buttonsScrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  // Pour SCT (Tétouan) - nommé SCK dans ton code
  bool _showConsoEnergiesSCK = false;
  bool _showRatiosEnergiesSCK = false;

  // Nouveau: vue Synthèse
  bool _showSynthesis = false;

  List<Map<String, dynamic>> _consoEnergiesSCCData = [];
  bool _loadingConsoEnergiesSCC = false;

  List<Map<String, dynamic>> _consoEnergiesBerrechidData = [];
  bool _loadingConsoEnergiesBerrechid = false;

  List<Map<String, dynamic>> _consoEnergiesKenitraData = [];
  bool _loadingConsoEnergiesKenitra = false;

  // Pour SCT
  List<Map<String, dynamic>> _consoEnergiesSCKData = [];
  bool _loadingConsoEnergiesSCK = false;

  double _quantiteTotaleCasa = 0.0;
  double _quantiteTotaleBerrechid = 0.0;
  double _quantiteTotaleKenitra = 0.0;

  List<String> berrechidStations = [
    "Triage 1 Berrechid",
    "Triage 2 Berrechid",
    "Triage 3 Berrechid",
    "Triage 4 Berrechid",
    "Triage 5 Berrechid",
    "Triage 6 Berrechid",
  ];

  List<String> kenitraStations = [
    "Triage A8 Kenitra",
    "Triage A9 Kenitra",
    "Triage B1 Kenitra",
    "Triage B2 Kenitra",
    "Triage B3 Kenitra",
  ];

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> fetchData() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loading = true;
      _data = [];
    });

    final String apiUrl =
        'https://api.evocon.com/api/reports/oee_json?stationId=41&stationId=31&stationId=42&stationId=33&stationId=77&stationId=65&stationId=75&stationId=70&stationId=2&stationId=3&stationId=12&stationId=13&stationId=135&stationId=106&stationId=6&stationId=7&stationId=134&stationId=47&stationId=48&stationId=49&stationId=50&stationId=80&stationId=20&stationId=17&stationId=18&stationId=102&stationId=79&stationId=21&stationId=22&stationId=22&stationId=23&stationId=24&startTime=${_startDate!.toIso8601String()}&endTime=${_endDate!.toIso8601String()}';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final jsonData = json.decode(response.body);
          setState(() {
            _data = jsonData;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Données chargées avec succès !')),
          );
        } catch (e) {
          developer.log(
            'Erreur de parsing JSON: ${e.toString()}',
            name: 'fetchData',
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Erreur lors du traitement des données du serveur.',
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        developer.log(
          'Erreur 401 : Non autorisé - Vérifiez vos identifiants.',
          name: 'fetchData',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec de l\'authentification. Vérifiez vos identifiants.',
            ),
          ),
        );
      } else {
        developer.log('Erreur : ${response.statusCode}', name: 'fetchData');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Échec du chargement des données : ${response.statusCode}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Map<String, Map<String, dynamic>> calculateMainTableSummary() {
    final Map<String, Map<String, dynamic>> summary = {};
    const List<int> mainStationIds = [
      41,
      31,
      42,
      33,
      2,
      3,
      12,
      13,
      135,
      106,
      47,
      48,
      80,
      20,
      17,
      18,
      102,
    ];
    for (final item in _data) {
      final int stationId = item['stationId'];
      if (mainStationIds.contains(stationId)) {
        final String factory = item['factory'];
        final double operatingTimeSec =
            (item['operatingTimeSec'] as num).toDouble();
        final double plannedTime = (item['plannedTime'] as num).toDouble();
        final double totalQty = (item['totalQty'] as num).toDouble();
        final double idealQty = (item['idealQty'] as num).toDouble();
        final double goodQty = (item['goodQty'] as num).toDouble();

        summary.putIfAbsent(
          factory,
          () => {
            'operatingTimeSec': 0.0,
            'plannedTime': 0.0,
            'totalQty': 0.0,
            'idealQty': 0.0,
            'goodQty': 0.0,
          },
        );
        summary[factory]!['operatingTimeSec'] += operatingTimeSec;
        summary[factory]!['plannedTime'] += plannedTime;
        summary[factory]!['totalQty'] += totalQty;
        summary[factory]!['idealQty'] += idealQty;
        summary[factory]!['goodQty'] += goodQty;
      }
    }
    summary.forEach((factory, data) {
      final double operatingTimeSum = data['operatingTimeSec'];
      final double plannedTimeSum = data['plannedTime'];
      final double totalQtySum = data['totalQty'];
      final double idealQtySum = data['idealQty'];
      final double goodQtySum = data['goodQty'];
      final double trs =
          (plannedTimeSum > 0 && idealQtySum > 0 && totalQtySum > 0)
              ? (operatingTimeSum / plannedTimeSum) *
                  (totalQtySum / idealQtySum) *
                  (goodQtySum / totalQtySum)
              : 0.0;
      data['trs'] = trs;
    });
    _quantiteTotaleCasa = getQuantiteTotaleCasa(summary);
    _quantiteTotaleBerrechid = getQuantiteTotaleBerrechid(summary);
    _quantiteTotaleKenitra = getQuantiteTotaleKenitra(summary);
    return summary;
  }

  double getQuantiteTotaleCasa(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (mainTableSummary.containsKey('Casablanca')) {
      return mainTableSummary['Casablanca']?['totalQty'] ?? 0.0;
    }
    return 0.0;
  }

  double getQuantiteTotaleBerrechid(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (mainTableSummary.containsKey('Berrechid')) {
      return mainTableSummary['Berrechid']?['totalQty'] ?? 0.0;
    }
    return 0.0;
  }

  double getQuantiteTotaleKenitra(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (mainTableSummary.containsKey('Kenitra')) {
      return mainTableSummary['Kenitra']?['totalQty'] ?? 0.0;
    }
    return 0.0;
  }

  Map<String, double> calculateDowntimeSummary() {
    final Map<String, double> downtimeSummary = {};
    const List<int> downtimeStationIds = [
      77,
      65,
      75,
      70,
      6,
      7,
      134,
      49,
      50,
      79,
      21,
      22,
      23,
      24,
      129,
      130,
      131,
    ];
    for (final item in _data) {
      final int stationId = item['stationId'];
      if (downtimeStationIds.contains(stationId)) {
        final String factory = item['factory'];
        final double downtime = (item['downtime'] as num).toDouble();
        final double plannedStops = (item['plannedstops'] as num).toDouble();
        downtimeSummary.update(
          factory,
          (existing) => existing + downtime + plannedStops,
          ifAbsent: () => downtime + plannedStops,
        );
      }
    }
    return downtimeSummary;
  }

  // ------- Conso Energies SCC (Casa) -------
  // ------- Conso Energies SCC (Casa) -------
  Future<void> fetchConsoEnergiesSCC({bool silent = false}) async {
    if (_startDate == null || _endDate == null) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _loadingConsoEnergiesSCC = true;
      _consoEnergiesSCCData = [];
      if (!silent) {
        _showProductionTable = false;
        _showDowntimeTable = false;
        _showConsoEnergiesSCC = true;
        _showRatiosEnergiesSCC = false;
        _showConsoEnergiesBerrechid = false;
        _showRatiosEnergiesBerrechid = false;
        _showConsoEnergiesKenitra = false;
        _showRatiosEnergiesKenitra = false;
        _showConsoEnergiesSCK = false;
        _showRatiosEnergiesSCK = false;
        _showSynthesis = false;
      }
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<String> desiredFields = [
          "Stock citerne Butane  (Kg)²",
          "Stock citerne Propane  (Kg)²",
          "Stock Fuel (Kg)²",
          "Arrivage Afriquia butane (Kg)²",
          "Arrivage Afriquia propane (Kg)²",
          "Arrivage Total butane (Kg)²",
          "Arrivage Total Propane (Kg)²",
          "Arrivage Fuel (Kg)²",
        ];
        final filtered =
            jsonData
                .where(
                  (item) =>
                      item['station'] ==
                      "Machine d'injection / Entrée four PH 8 casa",
                )
                .toList();

        Map<String, Map<String, String>> dateToFieldResults = {};
        for (var item in filtered) {
          final date = (item['date'] ?? item['Date'] ?? '')
              .toString()
              .substring(0, 10);
          final field = item['itemname'] ?? '';
          final result = item['itemresult']?.toString() ?? '';
          if (desiredFields.contains(field)) {
            dateToFieldResults.putIfAbsent(date, () => {});
            dateToFieldResults[date]![field] = result;
          }
        }

        final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
        final endDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(_endDate!.add(const Duration(days: 1)));

        List<Map<String, dynamic>> result = [];
        for (var field in desiredFields) {
          result.add({
            'champ': field,
            'startValue': dateToFieldResults[startDateStr]?[field] ?? '',
            'endValue': dateToFieldResults[endDateStr]?[field] ?? '',
          });
        }
        setState(() {
          _consoEnergiesSCCData = result.cast<Map<String, dynamic>>();
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données Conso Energies SCC chargées !'),
            ),
          );
        }
      } else {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Échec du chargement Conso Energies SCC : ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Conso Energies SCC : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergiesSCC = false;
        });
      }
    }
  }

  // ------- Conso Energies SCB (Berrechid) -------
  Future<void> fetchConsoEnergiesBerrechid({bool silent = false}) async {
    if (_startDate == null || _endDate == null) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _loadingConsoEnergiesBerrechid = true;
      _consoEnergiesBerrechidData = [];
      if (!silent) {
        _showProductionTable = false;
        _showDowntimeTable = false;
        _showConsoEnergiesSCC = false;
        _showRatiosEnergiesSCC = false;
        _showConsoEnergiesBerrechid = true;
        _showRatiosEnergiesBerrechid = false;
        _showConsoEnergiesKenitra = false;
        _showRatiosEnergiesKenitra = false;
        _showConsoEnergiesSCK = false;
        _showRatiosEnergiesSCK = false;
        _showSynthesis = false;
      }
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<String> desiredFields = [
          "Stock citerne Butane  (Kg)¹",
          "Stock citerne Propane  (Kg)¹",
          "Stock Fuel (Kg)¹",
          "Arrivage Afriquia Butane (Kg)¹",
          "Arrivage Afriquia propane (Kg)¹",
          "Arrivage Total Butane (Kg)¹",
          "Arrivage Total Propane (Kg)¹",
          "Arrivage Fuel (Kg)¹",
        ];
        final filtered =
            jsonData
                .where((item) => item['station'] == "Four 1 Berrechid")
                .toList();

        Map<String, Map<String, String>> dateToFieldResults = {};
        for (var item in filtered) {
          final date = (item['date'] ?? item['Date'] ?? '')
              .toString()
              .substring(0, 10);
          final field = item['itemname'] ?? '';
          final result = item['itemresult']?.toString() ?? '';
          if (desiredFields.contains(field)) {
            dateToFieldResults.putIfAbsent(date, () => {});
            dateToFieldResults[date]![field] = result;
          }
        }

        final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
        final endDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(_endDate!.add(const Duration(days: 1)));

        List<Map<String, dynamic>> result = [];
        for (var field in desiredFields) {
          result.add({
            'champ': field,
            'startValue': dateToFieldResults[startDateStr]?[field] ?? '',
            'endValue': dateToFieldResults[endDateStr]?[field] ?? '',
          });
        }
        setState(() {
          _consoEnergiesBerrechidData = result.cast<Map<String, dynamic>>();
        });
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données Conso Energies  SCB Berrechid chargées !'),
            ),
          );
        }
      } else {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Échec du chargement Conso Energies  SCB : ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Conso Energies  SCB : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergiesBerrechid = false;
        });
      }
    }
  }

  // ------- Conso Energies Kenitra -------
  Future<void> fetchConsoEnergiesKenitra({bool silent = false}) async {
    if (_startDate == null || _endDate == null) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }
    setState(() {
      _loadingConsoEnergiesKenitra = true;
      _consoEnergiesKenitraData = [];
      if (!silent) {
        _showProductionTable = false;
        _showDowntimeTable = false;
        _showConsoEnergiesSCC = false;
        _showRatiosEnergiesSCC = false;
        _showConsoEnergiesBerrechid = false;
        _showRatiosEnergiesBerrechid = false;
        _showConsoEnergiesKenitra = true;
        _showRatiosEnergiesKenitra = false;
        _showConsoEnergiesSCK = false;
        _showRatiosEnergiesSCK = false;
        _showSynthesis = false;
      }
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<String> desiredFields = [
          "Stock citerne Butane  (Kg)³",
          "Stock citerne Propane  (Kg)³",
          "Stock Fuel (Kg)³",
          "Arrivage Afriquia (Kg)³",
          "Arrivage Total (Kg)³",
          "Arrivage Vitogaz (Kg)³",
          "Arrivage Fuel (Kg)³",
        ];
        final filtered =
            jsonData
                .where(
                  (item) =>
                      item['station'] == "Machine d'injection A8-16 Kenitra",
                )
                .toList();

        Map<String, Map<String, String>> dateToFieldResults = {};
        for (var item in filtered) {
          final date = (item['date'] ?? item['Date'] ?? '')
              .toString()
              .substring(0, 10);
          final field = item['itemname'] ?? '';
          final result = item['itemresult']?.toString() ?? '';
          if (desiredFields.contains(field)) {
            dateToFieldResults.putIfAbsent(date, () => {});
            dateToFieldResults[date]![field] = result;
          }
        }

        final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
        final endDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(_endDate!.add(const Duration(days: 1)));

        List<Map<String, dynamic>> result = [];
        for (var field in desiredFields) {
          result.add({
            'champ': field,
            'startValue': dateToFieldResults[startDateStr]?[field] ?? '',
            'endValue': dateToFieldResults[endDateStr]?[field] ?? '',
          });
        }

        setState(() {
          _consoEnergiesKenitraData = result.cast<Map<String, dynamic>>();
        });

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données Conso Energies Kenitra chargées !'),
            ),
          );
        }
      } else {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Échec du chargement Conso Energies Kenitra : ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Conso Energies Kenitra : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergiesKenitra = false;
        });
      }
    }
  }

  // ------- Conso Energies SCT (Tétouan) -------
  Future<void> fetchConsoEnergiesSCK({bool silent = false}) async {
    if (_startDate == null || _endDate == null) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une plage de dates.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _loadingConsoEnergiesSCK = true;
      _consoEnergiesSCKData = [];
      if (!silent) {
        _showProductionTable = false;
        _showDowntimeTable = false;
        _showConsoEnergiesSCC = false;
        _showRatiosEnergiesSCC = false;
        _showConsoEnergiesBerrechid = false;
        _showRatiosEnergiesBerrechid = false;
        _showConsoEnergiesKenitra = false;
        _showRatiosEnergiesKenitra = false;
        _showConsoEnergiesSCK = true;
        _showRatiosEnergiesSCK = false;
        _showSynthesis = false;
      }
    });

    final String stationIds = "70,81,6,49";
    final String startTime = _startDate!.toIso8601String();
    final String endTime =
        _endDate!.add(const Duration(days: 1)).toIso8601String();
    final String apiUrl =
        'https://api.evocon.com/api/reports/checklists_json?stationId=$stationIds&startTime=$startTime&endTime=$endTime';

    try {
      final response = await ApiClient.getWithBasicAuth(
        apiUrl,
        'measuredata@supercerame',
        'EaQI7CyQcE6blSnkd5oKagzxE6F0oQ',
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<String> desiredFields = [
          "Stock citerne Butane  (Kg)",
          "Stock citerne Propane  (Kg)",
          "Stock Fuel (Kg)",
          "Arrivage Afriquia (Kg)",
          "Arrivage VITOGAZ (Kg)",
          "Arrivage Fuel (Kg)",
        ];
        final filtered =
            jsonData
                .where((item) => item['station'] == "Four 1 TN240 Tétouan")
                .toList();

        Map<String, Map<String, String>> dateToFieldResults = {};
        for (var item in filtered) {
          final date = (item['date'] ?? item['Date'] ?? '')
              .toString()
              .substring(0, 10);
          final field = item['itemname'] ?? '';
          final result = item['itemresult']?.toString() ?? '';
          if (desiredFields.contains(field)) {
            dateToFieldResults.putIfAbsent(date, () => {});
            dateToFieldResults[date]![field] = result;
          }
        }

        final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
        final endDateStr = DateFormat(
          'yyyy-MM-dd',
        ).format(_endDate!.add(const Duration(days: 1)));

        List<Map<String, dynamic>> result = [];
        for (var field in desiredFields) {
          result.add({
            'champ': field,
            'startValue': dateToFieldResults[startDateStr]?[field] ?? '',
            'endValue': dateToFieldResults[endDateStr]?[field] ?? '',
          });
        }

        setState(() {
          _consoEnergiesSCKData = result.cast<Map<String, dynamic>>();
        });

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données Conso Energies SCT chargées !'),
            ),
          );
        }
      } else {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Échec du chargement Conso Energies SCT : ${response.statusCode}',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && !silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur Conso Energies SCT : ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingConsoEnergiesSCK = false;
        });
      }
    }
  }

  // SCC : divisés par Casablanca
  List<Map<String, String>> getRatiosEnergiesSCC(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesSCCData.isEmpty) return [];
    Map<String, dynamic> getRow(String champ) => _consoEnergiesSCCData
        .firstWhere((r) => r['champ'] == champ, orElse: () => {});
    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane  (Kg)²")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane  (Kg)²")['endValue'],
    );
    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane  (Kg)²")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane  (Kg)²")['endValue'],
    );
    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)²")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)²")['endValue']);
    double arrivageAfriquiaButaneEnd = parseVal(
      getRow("Arrivage Afriquia butane (Kg)²")['endValue'],
    );
    double arrivageAfriquiaPropaneEnd = parseVal(
      getRow("Arrivage Afriquia propane (Kg)²")['endValue'],
    );
    double arrivageTotalButaneEnd = parseVal(
      getRow("Arrivage Total butane (Kg)²")['endValue'],
    );
    double arrivageTotalPropaneEnd = parseVal(
      getRow("Arrivage Total Propane (Kg)²")['endValue'],
    );
    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)²")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaButaneEnd +
                arrivageTotalButaneEnd) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaPropaneEnd +
                arrivageTotalPropaneEnd) *
            12.78);
    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double qt = _quantiteTotaleCasa;
    String qtStr = qt > 0 ? qt.toStringAsFixed(0) : "0";
    double gazDiv = qt > 0 ? gaz / qt : 0.0;
    double fuelDiv = qt > 0 ? fuel / qt : 0.0;
    double sommeDiv = qt > 0 ? somme / qt : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Casablanca': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Casablanca': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Casablanca': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Casablanca',
        'Ratios (KWH)': '',
        'Ratios/Qté Casablanca': qtStr,
      },
    ];
  }

  // BERRECHID : divisés par Berrechid
  List<Map<String, String>> getRatiosEnergiesBerrechid(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesBerrechidData.isEmpty) return [];
    Map<String, dynamic> getRow(String champ) => _consoEnergiesBerrechidData
        .firstWhere((r) => r['champ'] == champ, orElse: () => {});
    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane  (Kg)¹")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane  (Kg)¹")['endValue'],
    );
    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane  (Kg)¹")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane  (Kg)¹")['endValue'],
    );
    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)¹")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)¹")['endValue']);
    double arrivageAfriquiaButaneEnd = parseVal(
      getRow("Arrivage Afriquia Butane (Kg)¹")['endValue'],
    );
    double arrivageAfriquiaPropaneEnd = parseVal(
      getRow("Arrivage Afriquia propane (Kg)¹")['endValue'],
    );
    double arrivageTotalButaneEnd = parseVal(
      getRow("Arrivage Total Butane (Kg)¹")['endValue'],
    );
    double arrivageTotalPropaneEnd = parseVal(
      getRow("Arrivage Total Propane (Kg)¹")['endValue'],
    );
    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)¹")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaButaneEnd +
                arrivageTotalButaneEnd) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaPropaneEnd +
                arrivageTotalPropaneEnd) *
            12.78);
    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double qt = _quantiteTotaleBerrechid;
    String qtStr = qt > 0 ? qt.toStringAsFixed(0) : "0";
    double gazDiv = qt > 0 ? gaz / qt : 0.0;
    double fuelDiv = qt > 0 ? fuel / qt : 0.0;
    double sommeDiv = qt > 0 ? somme / qt : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Berrechid': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Berrechid',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Berrechid': qtStr,
      },
    ];
  }

  // KENITRA : divisés par Kenitra
  List<Map<String, String>> getRatiosEnergiesKenitra(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesKenitraData.isEmpty) return [];
    Map<String, dynamic> getRow(String champ) => _consoEnergiesKenitraData
        .firstWhere((r) => r['champ'] == champ, orElse: () => {});
    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane  (Kg)³")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane  (Kg)³")['endValue'],
    );
    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane  (Kg)³")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane  (Kg)³")['endValue'],
    );
    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)³")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)³")['endValue']);

    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia (Kg)³")['endValue'],
    );
    double arrivageTotalEnd = parseVal(
      getRow("Arrivage Total (Kg)³")['endValue'],
    );
    double arrivageVitogazEnd = parseVal(
      getRow("Arrivage Vitogaz (Kg)³")['endValue'],
    );
    double arrivageFuelEnd = parseVal(
      getRow("Arrivage Fuel (Kg)³")['endValue'],
    );

    double gaz =
        ((stockButaneStart -
                stockButaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalEnd * 0.8) *
            12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaEnd +
                arrivageTotalEnd * 0.2 +
                arrivageVitogazEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double qt = _quantiteTotaleKenitra;
    String qtStr = qt > 0 ? qt.toStringAsFixed(0) : "0";
    double gazDiv = qt > 0 ? gaz / qt : 0.0;
    double fuelDiv = qt > 0 ? fuel / qt : 0.0;
    double sommeDiv = qt > 0 ? somme / qt : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Kenitra': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Kenitra',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Kenitra': qtStr,
      },
    ];
  }

  // SCT (Tétouan)
  List<Map<String, String>> getRatiosEnergiesSCK(
    Map<String, Map<String, dynamic>> mainTableSummary,
  ) {
    if (_consoEnergiesSCKData.isEmpty) return [];

    Map<String, dynamic> getRow(String champ) => _consoEnergiesSCKData
        .firstWhere((r) => r['champ'] == champ, orElse: () => {});

    double parseVal(dynamic val) {
      if (val == null || val.toString().trim().isEmpty || val == '-') {
        return 0.0;
      }
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    double stockButaneStart = parseVal(
      getRow("Stock citerne Butane  (Kg)")['startValue'],
    );
    double stockButaneEnd = parseVal(
      getRow("Stock citerne Butane  (Kg)")['endValue'],
    );
    double stockPropaneStart = parseVal(
      getRow("Stock citerne Propane  (Kg)")['startValue'],
    );
    double stockPropaneEnd = parseVal(
      getRow("Stock citerne Propane  (Kg)")['endValue'],
    );
    double stockFuelStart = parseVal(getRow("Stock Fuel (Kg)")['startValue']);
    double stockFuelEnd = parseVal(getRow("Stock Fuel (Kg)")['endValue']);
    double arrivageAfriquiaEnd = parseVal(
      getRow("Arrivage Afriquia (Kg)")['endValue'],
    );
    double arrivageVitogazEnd = parseVal(
      getRow("Arrivage VITOGAZ (Kg)")['endValue'],
    );
    double arrivageFuelEnd = parseVal(getRow("Arrivage Fuel (Kg)")['endValue']);

    double gaz =
        ((stockButaneStart - stockButaneEnd) * 12.66) +
        ((stockPropaneStart -
                stockPropaneEnd +
                arrivageAfriquiaEnd +
                arrivageVitogazEnd) *
            12.78);

    double fuel = (stockFuelStart - stockFuelEnd + arrivageFuelEnd) * 10.8;
    double somme = gaz + fuel;

    double qt = 0.0;
    if (mainTableSummary.containsKey("Tétouan")) {
      qt = mainTableSummary["Tétouan"]?['totalQty'] ?? 0.0;
    }
    if (qt == 0.0 && mainTableSummary.containsKey("Tetouan")) {
      qt = mainTableSummary["Tetouan"]?['totalQty'] ?? 0.0;
    }
    String qtStr = qt > 0 ? qt.toStringAsFixed(0) : "0";
    double gazDiv = qt > 0 ? gaz / qt : 0.0;
    double fuelDiv = qt > 0 ? fuel / qt : 0.0;
    double sommeDiv = qt > 0 ? somme / qt : 0.0;

    return [
      {
        'Nom': 'Gaz',
        'Ratios (KWH)': gaz.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': gazDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Fuel',
        'Ratios (KWH)': fuel.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': fuelDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Somme',
        'Ratios (KWH)': somme.toStringAsFixed(2),
        'Ratios/Qté Totale Tétouan': sommeDiv.toStringAsFixed(2),
      },
      {
        'Nom': 'Quantité totale Tétouan',
        'Ratios (KWH)': '',
        'Ratios/Qté Totale Tétouan': qtStr,
      },
    ];
  }

  // Construit les lignes de la synthèse (uniquement dernières colonnes)
  List<Map<String, String>> buildSynthesisRows(
    List<Map<String, String>> scc, // 'Ratios/Qté Casablanca'
    List<Map<String, String>> scb, // 'Ratios/Qté Totale Berrechid'
    List<Map<String, String>> ken, // 'Ratios/Qté Totale Kenitra'
    List<Map<String, String>> sct, // 'Ratios/Qté Totale Tétouan'
  ) {
    String val(Map<String, String> row, String key) => row[key] ?? '';
    Map<String, Map<String, String>> byNom(List<Map<String, String>> list) {
      final map = <String, Map<String, String>>{};
      for (final r in list) {
        map[r['Nom'] ?? ''] = r.cast<String, String>();
      }
      return map;
    }

    final sccBy = byNom(scc);
    final scbBy = byNom(scb);
    final kenBy = byNom(ken);
    final sctBy = byNom(sct);

    const kScc = 'Ratios/Qté Casablanca';
    const kScb = 'Ratios/Qté Totale Berrechid';
    const kKen = 'Ratios/Qté Totale Kenitra';
    const kSct = 'Ratios/Qté Totale Tétouan';

    // Récupère les libellés utiles (sans les "Quantité totale ...")
    final labels = <String>{};
    void addLabels(List<Map<String, String>> list) {
      for (final r in list) {
        final nom = (r['Nom'] ?? '').trim();
        if (nom.isEmpty) continue;
        if (nom.toLowerCase().startsWith('quantité totale')) continue;
        labels.add(nom);
      }
    }

    addLabels(scc.cast<Map<String, String>>());
    addLabels(scb.cast<Map<String, String>>());
    addLabels(ken.cast<Map<String, String>>());
    addLabels(sct.cast<Map<String, String>>());

    final rows = <Map<String, String>>[];

    // Lignes Gaz / Fuel / Somme
    const order = ['Gaz', 'Fuel', 'Somme'];
    final sortedLabels =
        labels.toList()..sort((a, b) {
          final ai = order.indexOf(a);
          final bi = order.indexOf(b);
          if (ai != -1 && bi != -1) return ai.compareTo(bi);
          if (ai != -1) return -1;
          if (bi != -1) return 1;
          return a.compareTo(b);
        });

    for (final label in sortedLabels) {
      rows.add({
        'Nom': label,
        'SCC': val(sccBy[label] ?? {}, kScc),
        'SCB': val(scbBy[label] ?? {}, kScb),
        'SCK': val(kenBy[label] ?? {}, kKen),
        'SCT': val(sctBy[label] ?? {}, kSct),
      });
    }

    // Trouve les 4 quantités totales dans chaque liste (peut être vide si non chargée)
    String findTotal(List<Map<String, String>> list, String colKey) {
      for (final r in list) {
        final nom = (r['Nom'] ?? '').toLowerCase();
        if (nom.startsWith('quantité totale')) {
          return r[colKey] ?? '';
        }
      }
      return '';
    }

    final totalScc = findTotal(scc.cast<Map<String, String>>(), kScc);
    final totalScb = findTotal(scb.cast<Map<String, String>>(), kScb);
    final totalKen = findTotal(ken.cast<Map<String, String>>(), kKen);
    final totalSct = findTotal(sct.cast<Map<String, String>>(), kSct);

    // Ajoute une seule ligne "Quantité totale"
    rows.add({
      'Nom': 'Quantité totale',
      'SCC': totalScc,
      'SCB': totalScb,
      'SCK': totalKen,
      'SCT': totalSct,
    });

    return rows;
  }

  Future<void> refreshAllData() async {
    // 1) Actualise les données OEE (Production/Vide four)
    await fetchData();

    // 2) Si les dates ne sont pas définies, on s’arrête
    if (_startDate == null || _endDate == null) return;

    // 3) Recharge en parallèle les 4 consommations sans changer l’UI
    await Future.wait([
      fetchConsoEnergiesSCC(silent: true),
      fetchConsoEnergiesBerrechid(silent: true),
      fetchConsoEnergiesKenitra(silent: true),
      fetchConsoEnergiesSCK(silent: true),
    ]);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les données ont été actualisées.')),
    );
  }
  // ====== AJOUTER DANS SynthesisPageState ======
  // Contrôle du défilement horizontal des boutons

  @override
  void initState() {
    super.initState();
    _buttonsScrollController.addListener(_updateButtonsScrollArrows);
    // On attend le layout pour calculer l'état des flèches
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _updateButtonsScrollArrows(),
    );
  }

  @override
  void dispose() {
    _buttonsScrollController.removeListener(_updateButtonsScrollArrows);
    _buttonsScrollController.dispose();
    super.dispose();
  }

  void _updateButtonsScrollArrows() {
    if (!_buttonsScrollController.hasClients) return;
    final pos = _buttonsScrollController.position;
    final canLeft = pos.pixels > pos.minScrollExtent + 1;
    final canRight = pos.pixels < pos.maxScrollExtent - 1;
    if (canLeft != _canScrollLeft || canRight != _canScrollRight) {
      setState(() {
        _canScrollLeft = canLeft;
        _canScrollRight = canRight;
      });
    }
  }

  Future<void> _scrollButtonsBy(double delta) async {
    if (!_buttonsScrollController.hasClients) return;
    final pos = _buttonsScrollController.position;
    final target = (pos.pixels + delta).clamp(
      pos.minScrollExtent,
      pos.maxScrollExtent,
    );
    await _buttonsScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Map<String, dynamic>> mainTableSummary =
        calculateMainTableSummary();
    final Map<String, double> downtimeTableSummary = calculateDowntimeSummary();
    final sortedMainTableEntries =
        mainTableSummary.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
    final sortedDowntimeTableEntries =
        downtimeTableSummary.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

    double totalQtyAllFactories = 0.0;
    double totalGoodQtyAllFactories = 0.0;
    final numberFormat = NumberFormat("###,###", "fr_FR");

    for (final factoryData in mainTableSummary.values) {
      totalQtyAllFactories += factoryData['totalQty'];
      totalGoodQtyAllFactories += factoryData['goodQty'];
    }
    final double overallQualityPercentage =
        totalQtyAllFactories > 0
            ? (totalGoodQtyAllFactories / totalQtyAllFactories) * 100
            : 0.0;
    double totalDowntimeAllFactories = downtimeTableSummary.values.fold(
      0.0,
      (sum, downtime) => sum + downtime,
    );

    // Ratios existants
    final ratiosEnergiesSCC = getRatiosEnergiesSCC(mainTableSummary);
    final ratiosEnergiesBerrechid = getRatiosEnergiesBerrechid(
      mainTableSummary,
    );
    final ratiosEnergiesKenitra = getRatiosEnergiesKenitra(mainTableSummary);
    final ratiosEnergiesSCK = getRatiosEnergiesSCK(mainTableSummary);

    // Lignes de Synthèse (utilise uniquement la dernière colonne de chaque tableau de ratios)
    final synthesisRows = buildSynthesisRows(
      ratiosEnergiesSCC,
      ratiosEnergiesBerrechid,
      ratiosEnergiesKenitra,
      ratiosEnergiesSCK,
    );

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Evocon Data'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: const Text('Sélectionner une plage de dates'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start date: ${_startDate != null ? _startDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'End date: ${_endDate != null ? _endDate!.toLocal().toString().split(' ')[0] : 'Not selected'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: refreshAllData,
                  child: const Text('Actualiser'),
                ),
              ],
            ),
          ),

          // ====== BANDEAU DE BOUTONS AVEC FLÈCHES ======
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                // Flèche gauche
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  color: _canScrollLeft ? Colors.deepPurple : Colors.grey,
                  onPressed:
                      _canScrollLeft ? () => _scrollButtonsBy(-300) : null,
                  tooltip: 'Défiler à gauche',
                ),

                // Bandeau scrollable
                Expanded(
                  child: Scrollbar(
                    controller: _buttonsScrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _buttonsScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(width: 4),

                          // Production par usine
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = true;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Production par usine'),
                          ),
                          const SizedBox(width: 8),

                          // Vide Four par usine
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = true;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Vide Four par usine'),
                          ),
                          const SizedBox(width: 8),

                          // Synthèse (PLACÉ ICI)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = true;
                              });
                            },
                            child: const Text('Synthèse'),
                          ),
                          const SizedBox(width: 8),

                          // Conso Energies SCC
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: fetchConsoEnergiesSCC,
                            child: const Text('Conso Energies SCC'),
                          ),
                          const SizedBox(width: 8),

                          // Ratios Energies SCC
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = true;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Ratios Energies SCC'),
                          ),
                          const SizedBox(width: 8),

                          // Conso Energies  SCB
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: fetchConsoEnergiesBerrechid,
                            child: const Text('Conso Energies  SCB'),
                          ),
                          const SizedBox(width: 8),

                          // Ratios Energies SCB
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = true;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Ratios Energies SCB'),
                          ),
                          const SizedBox(width: 8),

                          // Conso Energies SCK (Kenitra)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: fetchConsoEnergiesKenitra,
                            child: const Text('Conso Energies SCK'),
                          ),
                          const SizedBox(width: 8),

                          // Ratios Energies SCK (Kenitra)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = true;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = false;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Ratios Energies SCK'),
                          ),
                          const SizedBox(width: 8),

                          // Conso Energies SCT (Tétouan)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: fetchConsoEnergiesSCK,
                            child: const Text('Conso Energies SCT'),
                          ),
                          const SizedBox(width: 8),

                          // Ratios Energies SCT (Tétouan)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 0.5,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _showProductionTable = false;
                                _showDowntimeTable = false;
                                _showConsoEnergiesSCC = false;
                                _showRatiosEnergiesSCC = false;
                                _showConsoEnergiesBerrechid = false;
                                _showRatiosEnergiesBerrechid = false;
                                _showConsoEnergiesKenitra = false;
                                _showRatiosEnergiesKenitra = false;
                                _showConsoEnergiesSCK = false;
                                _showRatiosEnergiesSCK = true;
                                _showSynthesis = false;
                              });
                            },
                            child: const Text('Ratios Energies SCT'),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ),

                // Flèche droite
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: _canScrollRight ? Colors.deepPurple : Colors.grey,
                  onPressed:
                      _canScrollRight ? () => _scrollButtonsBy(300) : null,
                  tooltip: 'Défiler à droite',
                ),
              ],
            ),
          ),

          // ====== FIN BANDEAU ======
          if (_loading) const CircularProgressIndicator(),

          if (_showProductionTable)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Usine')),
                      DataColumn(label: Text('Quantité totale')),
                      DataColumn(label: Text('% Qualité')),
                      DataColumn(label: Text('TRS')),
                    ],
                    rows: [
                      ...sortedMainTableEntries.map((entry) {
                        final String factory = entry.key;
                        final double totalQty = entry.value['totalQty'];
                        final double goodQty = entry.value['goodQty'];
                        final double trs = entry.value['trs'];
                        final double qualityPercentage =
                            totalQty > 0 ? (goodQty / totalQty) * 100 : 0.0;
                        return DataRow(
                          cells: [
                            DataCell(Text(factory)),
                            DataCell(
                              Center(
                                child: Text(
                                  numberFormat.format(totalQty),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            DataCell(
                              Text('${qualityPercentage.toStringAsFixed(2)}%'),
                            ),
                            DataCell(
                              Text('${(trs * 100).toStringAsFixed(2)}%'),
                            ),
                          ],
                        );
                      }),
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Center(
                              child: Text(
                                numberFormat.format(totalQtyAllFactories),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${overallQualityPercentage.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const DataCell(Text('')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showDowntimeTable)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Usine')),
                      DataColumn(label: Text('Vide Four (heures)')),
                    ],
                    rows: [
                      ...sortedDowntimeTableEntries.map((entry) {
                        final String factory = entry.key;
                        final double downtimeInSeconds = entry.value;
                        final double downtimeInHours = downtimeInSeconds / 3600;
                        return DataRow(
                          cells: [
                            DataCell(Text(factory)),
                            DataCell(Text(downtimeInHours.toStringAsFixed(2))),
                          ],
                        );
                      }),
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              (totalDowntimeAllFactories / 3600)
                                  .toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_showConsoEnergiesSCC)
            Expanded(
              child:
                  _loadingConsoEnergiesSCC
                      ? const Center(child: CircularProgressIndicator())
                      : _consoEnergiesSCCData.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucune donnée trouvée pour Conso Energies SCC Machine d\'injection / Entrée four PH 8 casa.',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Champ')),
                              DataColumn(
                                label: Text(
                                  _startDate != null
                                      ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!)
                                      : '',
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  _endDate != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                        _endDate!.add(const Duration(days: 1)),
                                      )
                                      : '',
                                ),
                              ),
                            ],
                            rows:
                                _consoEnergiesSCCData.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['champ'] ?? '')),
                                      DataCell(
                                        Text('${row['startValue'] ?? ''}'),
                                      ),
                                      DataCell(
                                        Text('${row['endValue'] ?? ''}'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showRatiosEnergiesSCC)
            Expanded(
              child:
                  ratiosEnergiesSCC.isEmpty
                      ? const Center(
                        child: Text('Aucune donnée pour Ratios Energies SCC'),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nom')),
                              DataColumn(label: Text('Ratios (KWH)')),
                              DataColumn(label: Text('Ratios/Qté Casablanca')),
                            ],
                            rows:
                                ratiosEnergiesSCC.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['Nom'] ?? '')),
                                      DataCell(Text(row['Ratios (KWH)'] ?? '')),
                                      DataCell(
                                        Text(
                                          row['Ratios/Qté Casablanca'] ?? '',
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showConsoEnergiesBerrechid)
            Expanded(
              child:
                  _loadingConsoEnergiesBerrechid
                      ? const Center(child: CircularProgressIndicator())
                      : _consoEnergiesBerrechidData.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucune donnée trouvée pour Conso Energies  SCB Four 1 Berrechid.',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Champ')),
                              DataColumn(
                                label: Text(
                                  _startDate != null
                                      ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!)
                                      : '',
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  _endDate != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                        _endDate!.add(const Duration(days: 1)),
                                      )
                                      : '',
                                ),
                              ),
                            ],
                            rows:
                                _consoEnergiesBerrechidData.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['champ'] ?? '')),
                                      DataCell(
                                        Text('${row['startValue'] ?? ''}'),
                                      ),
                                      DataCell(
                                        Text('${row['endValue'] ?? ''}'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showRatiosEnergiesBerrechid)
            Expanded(
              child:
                  ratiosEnergiesBerrechid.isEmpty
                      ? const Center(
                        child: Text('Aucune donnée pour Ratios Energies'),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nom')),
                              DataColumn(label: Text('Ratios (KWH)')),
                              DataColumn(
                                label: Text('Ratios/Qté Totale Berrechid'),
                              ),
                            ],
                            rows:
                                ratiosEnergiesBerrechid.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['Nom'] ?? '')),
                                      DataCell(Text(row['Ratios (KWH)'] ?? '')),
                                      DataCell(
                                        Text(
                                          row['Ratios/Qté Totale Berrechid'] ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showConsoEnergiesKenitra)
            Expanded(
              child:
                  _loadingConsoEnergiesKenitra
                      ? const Center(child: CircularProgressIndicator())
                      : _consoEnergiesKenitraData.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucune donnée trouvée pour Conso Energies Kenitra.',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Champ')),
                              DataColumn(
                                label: Text(
                                  _startDate != null
                                      ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!)
                                      : '',
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  _endDate != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                        _endDate!.add(const Duration(days: 1)),
                                      )
                                      : '',
                                ),
                              ),
                            ],
                            rows:
                                _consoEnergiesKenitraData.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['champ'] ?? '')),
                                      DataCell(
                                        Text('${row['startValue'] ?? ''}'),
                                      ),
                                      DataCell(
                                        Text('${row['endValue'] ?? ''}'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showRatiosEnergiesKenitra)
            Expanded(
              child:
                  ratiosEnergiesKenitra.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucune donnée pour Ratios Energies Kenitra',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nom')),
                              DataColumn(label: Text('Ratios (KWH)')),
                              DataColumn(
                                label: Text('Ratios/Qté Totale Kenitra'),
                              ),
                            ],
                            rows:
                                ratiosEnergiesKenitra.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['Nom'] ?? '')),
                                      DataCell(Text(row['Ratios (KWH)'] ?? '')),
                                      DataCell(
                                        Text(
                                          row['Ratios/Qté Totale Kenitra'] ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showConsoEnergiesSCK)
            Expanded(
              child:
                  _loadingConsoEnergiesSCK
                      ? const Center(child: CircularProgressIndicator())
                      : _consoEnergiesSCKData.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucune donnée trouvée pour Conso Energies SCK (Four 1 TN240 Tétouan).',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              const DataColumn(label: Text('Champ')),
                              DataColumn(
                                label: Text(
                                  _startDate != null
                                      ? DateFormat(
                                        'yyyy-MM-dd',
                                      ).format(_startDate!)
                                      : '',
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  _endDate != null
                                      ? DateFormat('yyyy-MM-dd').format(
                                        _endDate!.add(const Duration(days: 1)),
                                      )
                                      : '',
                                ),
                              ),
                            ],
                            rows:
                                _consoEnergiesSCKData.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['champ'] ?? '')),
                                      DataCell(
                                        Text('${row['startValue'] ?? ''}'),
                                      ),
                                      DataCell(
                                        Text('${row['endValue'] ?? ''}'),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          if (_showRatiosEnergiesSCK)
            Expanded(
              child:
                  ratiosEnergiesSCK.isEmpty
                      ? const Center(
                        child: Text('Aucune donnée pour Ratios Energies SCK'),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nom')),
                              DataColumn(label: Text('Ratios (KWH)')),
                              DataColumn(
                                label: Text('Ratios/Qté Totale Tétouan'),
                              ),
                            ],
                            rows:
                                ratiosEnergiesSCK.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['Nom'] ?? '')),
                                      DataCell(Text(row['Ratios (KWH)'] ?? '')),
                                      DataCell(
                                        Text(
                                          row['Ratios/Qté Totale Tétouan'] ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),

          // NOUVELLE SECTION: VUE SYNTHÈSE
          if (_showSynthesis)
            Expanded(
              child:
                  synthesisRows.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Aucune donnée de synthèse.\nAstuce: Cliquez sur "Actualiser", puis chargez les Conso (SCC/SCB/SCK/SCT) avant de venir ici.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Nom')),
                              DataColumn(label: Text('SCC')),
                              DataColumn(label: Text('SCB')),
                              DataColumn(label: Text('SCK')),
                              DataColumn(label: Text('SCT')),
                            ],
                            rows:
                                synthesisRows.map((row) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(row['Nom'] ?? '')),
                                      DataCell(Text(row['SCC'] ?? '')),
                                      DataCell(Text(row['SCB'] ?? '')),
                                      DataCell(Text(row['SCK'] ?? '')),
                                      DataCell(Text(row['SCT'] ?? '')),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
            ),
        ],
      ),
    );
  }
}

// ===== CLASSE PROXY NETLIFY =====
// ===== CLASSE PROXY NETLIFY =====
class ApiClient {
  // ✅ CHANGEZ CETTE LIGNE
  static const String netlifyProxyUrl =
      'https://evocon-super-cerame.netlify.app/.netlify/functions/evocon-proxy';
  static Future<http.Response> getWithBasicAuth(
    String apiUrl,
    String username,
    String password,
  ) async {
    try {
      final String basicAuth = base64Encode(utf8.encode('$username:$password'));
      final String encodedUrl = Uri.encodeComponent(apiUrl);
      final String proxyUrl =
          '$netlifyProxyUrl?url=$encodedUrl&auth=$basicAuth';

      return await http.get(Uri.parse(proxyUrl));
    } catch (e) {
      developer.log('ApiClient Error: $e', name: 'ApiClient');
      rethrow;
    }
  }
}
