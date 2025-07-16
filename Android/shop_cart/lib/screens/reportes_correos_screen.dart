import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportesCorreosScreen extends StatefulWidget {
  const ReportesCorreosScreen({Key? key}) : super(key: key);

  @override
  State<ReportesCorreosScreen> createState() => _ReportesCorreosScreenState();
}

class _ReportesCorreosScreenState extends State<ReportesCorreosScreen> {
  int get totalUsuariosPorDominio {
    int total = 0;
    for (final item in dominioReporte) {
      final cantidad = int.tryParse(item['CantidadUsuarios'].toString()) ?? 0;
      total += cantidad;
    }
    return total;
  }
  List<dynamic> dominioReporte = [];
  List<dynamic> correos = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final reporteRes = await http.get(Uri.parse('https://api-sable-eta.vercel.app/api/clients/reporte'));
      final correosRes = await http.get(Uri.parse('https://api-sable-eta.vercel.app/api/clients/correos'));
      if (reporteRes.statusCode == 200 && correosRes.statusCode == 200) {
        setState(() {
          dominioReporte = json.decode(reporteRes.body);
          correos = json.decode(correosRes.body);
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error al obtener los datos del servidor';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reportes de correos'),
        backgroundColor: const Color(0xFF1e40af),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      const Text(
                        'Reporte por dominio',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1e40af)),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFF1e40af)), // azul fuerte
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            dataRowColor: MaterialStateProperty.all(Colors.white),
                            dataTextStyle: const TextStyle(color: Colors.black),
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('N°')),
                              DataColumn(label: Text('Dominio')),
                              DataColumn(label: Text('Cantidad')),
                            ],
                            rows: [
                              for (int i = 0; i < dominioReporte.length; i++)
                                DataRow(cells: [
                                  DataCell(Text('${i + 1}')),
                                  DataCell(Text(dominioReporte[i]['Dominio'].toString())),
                                  DataCell(Text(dominioReporte[i]['CantidadUsuarios'].toString())),
                                ]),
                              if (dominioReporte.isNotEmpty)
                                DataRow(
                                  color: MaterialStateProperty.all(const Color(0xFFf1f5f9)),
                                  cells: [
                                    const DataCell(Text('')),
                                    const DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(
                                      totalUsuariosPorDominio.toString(),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (dominioReporte.isNotEmpty)
                        
                      const SizedBox(height: 30),
                      const Text(
                        'Lista de correos',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1e40af)),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: DataTableTheme(
                          data: DataTableThemeData(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFF1e40af)),
                            headingTextStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            dataRowColor: MaterialStateProperty.all(Colors.white),
                            dataTextStyle: const TextStyle(color: Colors.black),
                          ),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('N°')),
                              DataColumn(label: Text('Correo')),
                            ],
                            rows: [
                              for (int i = 0; i < correos.length; i++)
                                DataRow(cells: [
                                  DataCell(Text('${i + 1}')),
                                  DataCell(Text(correos[i]['Email'].toString())),
                                ]),
                            ],
                          ),
                        ),
                      ),
                      if (correos.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 2.0),
                          child: Text(
                            'Total de correos: ${correos.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1e40af)),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
