import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class MedicineItem {
  MedicineItem({
    required this.id,
    required this.kodeObat,
    required this.namaObat,
    required this.kategori,
    required this.satuan,
    required this.stok,
    required this.harga,
  });

  final int id;
  final String kodeObat;
  final String namaObat;
  final String kategori;
  final String satuan;
  final int stok;
  final double harga;

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: _toInt(json['id']),
      kodeObat: _toString(json['kode_obat']),
      namaObat: _toString(json['nama_obat']),
      kategori: _nullableString(json['kategori']) ?? '-',
      satuan: _nullableString(json['satuan']) ?? '-',
      stok: _toInt(json['stok']),
      harga: _toDouble(json['harga']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static String _toString(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _nullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return null;
    }

    return text;
  }
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<MedicineItem>> _medicineFuture;

  // Prioritaskan LAN IP agar perangkat fisik mengakses host melalui LAN
  static final List<Uri> _apiEndpoints = <Uri>[
    Uri.parse('http://192.168.1.9:8000/api/obat'),
  ];

  @override
  void initState() {
    super.initState();
    _medicineFuture = _loadMedicines();
  }

  Future<List<MedicineItem>> _loadMedicines() async {
    final errors = <String>[];

    for (final endpoint in _apiEndpoints) {
      try {
        final response = await http
            .get(endpoint)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('status ${response.statusCode}');
        }

        final decodedBody = jsonDecode(response.body);
        final rawItems = _extractItems(decodedBody);

        return rawItems
            .whereType<Map<String, dynamic>>()
            .map(MedicineItem.fromJson)
            .toList(growable: false);
      } catch (error, stackTrace) {
        final detail = '${endpoint.toString()}: $error\n$stackTrace';
        errors.add(detail);
        debugPrint('Error fetching $endpoint: $error');
        debugPrintStack(
          label: 'API fetch stacktrace for $endpoint',
          stackTrace: stackTrace,
        );
      }
    }

    throw Exception(
      'Gagal memuat list obat dari API.\n${errors.join('\n---\n')}',
    );
  }

  List<dynamic> _extractItems(dynamic decodedBody) {
    if (decodedBody is List) {
      return decodedBody;
    }

    if (decodedBody is Map<String, dynamic>) {
      final candidates = <dynamic>[
        decodedBody['data'],
        decodedBody['obat'],
        decodedBody['results'],
      ];

      for (final candidate in candidates) {
        if (candidate is List) {
          return candidate;
        }
      }

      final singleItem = decodedBody['data'];
      if (singleItem is Map<String, dynamic>) {
        return <dynamic>[singleItem];
      }
    }

    throw Exception('Format response API tidak dikenali');
  }

  Future<void> _refreshMedicines() async {
    setState(() {
      _medicineFuture = _loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Obat'),
        actions: [
          IconButton(
            onPressed: _refreshMedicines,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<MedicineItem>>(
        future: _medicineFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final medicines = snapshot.data ?? <MedicineItem>[];

          if (medicines.isEmpty) {
            return const Center(
              child: Text('Belum ada data obat di tabel obat.'),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshMedicines,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: medicines.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                final leadingText = medicine.kodeObat.isNotEmpty
                    ? medicine.kodeObat.characters.take(2).join().toUpperCase()
                    : '?';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(leadingText)),
                    title: Text(medicine.namaObat),
                    subtitle: Text(
                      '${medicine.kodeObat} • ${medicine.kategori} • ${medicine.satuan}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Stok: ${medicine.stok}'),
                        Text('Rp ${medicine.harga.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
