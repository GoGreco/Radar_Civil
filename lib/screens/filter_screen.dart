import 'package:flutter/material.dart';
import '../services/camara_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final CamaraService _service = CamaraService();

  final TextEditingController _deputadoController = TextEditingController();
  final TextEditingController _partidoController = TextEditingController();

  String? selectedTipo;
  String? selectedAno;
  String? selectedTema;

  List<String> tipos = [];
  List<String> anos = [];
  List<Map<String, String>> temas = [];

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  @override
  void dispose() {
    _deputadoController.dispose();
    _partidoController.dispose();
    super.dispose();
  }

  Future<void> carregarDados() async {
    tipos = await _service.getTiposProposicao();
    anos = await _service.getAnos();
    temas = await _service.getTemas();

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

            const SizedBox(height: 30),

            const Text(
              "DEPUTADO",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _deputadoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite o nome do deputado",
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "PARTIDO",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _partidoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite a sigla do partido (ex: PT, PL, PSOL)",
                prefixIcon: Icon(Icons.groups),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "TEMA",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedTema,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              hint: const Text("Selecione um tema"),
              items: temas.map((tema) {
                return DropdownMenuItem(
                  value: tema['cod'],
                  child: Text(tema['nome'] ?? ''),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTema = value;
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
                  final temaSelecionado = temas.firstWhere(
                    (tema) => tema['cod'] == selectedTema,
                    orElse: () => const {},
                  );

                  Navigator.pop(
                    context,
                    {
                      'tipo': selectedTipo,
                      'ano': selectedAno,
                      'deputado': _deputadoController.text.trim(),
                      'partido': _partidoController.text.trim(),
                      'tema': selectedTema,
                      'temaNome': temaSelecionado['nome'],
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
