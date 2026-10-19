import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/filter_screen.dart';
import '../screens/home_screen.dart';

enum AppDrawerSection { home, filtros, sobreNos, patreon }

class AppDrawer extends StatelessWidget {
  final AppDrawerSection? current;
  final Map<dynamic, dynamic>? filtrosAtuais;
  final ValueChanged<Map<String, dynamic>>? onFiltrosAplicados;

  const AppDrawer({
    super.key,
    this.current,
    this.filtrosAtuais,
    this.onFiltrosAplicados,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DrawerItem(
                label: 'HOME',
                isCurrent: current == AppDrawerSection.home,
                onTap: () {
                  Navigator.pop(context);
                  if (current != AppDrawerSection.home) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  }
                },
              ),

              _DrawerItem(
                label: 'FILTROS',
                isCurrent: current == AppDrawerSection.filtros,
                onTap: () async {
                  Navigator.pop(context);

                  final resultado = await FilterScreen.show(
                    context,
                    initial: filtrosAtuais,
                  );

                  if (resultado == null || !context.mounted) {
                    return;
                  }

                  if (onFiltrosAplicados != null) {
                    onFiltrosAplicados!(resultado);
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeScreen(filtrosIniciais: resultado),
                    ),
                    (route) => false,
                  );
                },
              ),

              _DrawerItem(
                label: 'SOBRE NÓS',
                isCurrent: current == AppDrawerSection.sobreNos,
                onTap: () {
                  Navigator.pop(context);
                  if (current != AppDrawerSection.sobreNos) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  }
                },
              ),

              _DrawerItem(
                label: 'PATREON',
                isCurrent: current == AppDrawerSection.patreon,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Em breve')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.onTap,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isCurrent ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      ),
    );
  }
}
