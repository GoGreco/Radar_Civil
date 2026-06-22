import 'package:flutter/material.dart';
import '../services/camara_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final CamaraService _service = CamaraService();

  String? selectedTipo;
  String? selectedAno;

  List<String> tipos = [];
  List<String> anos = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    tipos = await _service.getTiposProposicao();
    anos = await _service.getAnos();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtros"),
        backgroundColor: const Color(0xFF4F8F63),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TIPO DA PROPOSIÇÃO",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ...tipos.map(
              (tipo) => RadioListTile<String>(
                title: Text(tipo),
                value: tipo,
                groupValue: selectedTipo,
                onChanged: (value) {
                  setState(() {
                    selectedTipo = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "ANO",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedAno,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text("Selecione um ano"),
              items: anos.map((ano) {
                return DropdownMenuItem(
                  value: ano,
                  child: Text(ano),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAno = value;
                });
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4C14A),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    {
                      'tipo': selectedTipo,
                      'ano': selectedAno,
                    },
                  );
                },
                child: const Text(
                  "APLICAR FILTROS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}