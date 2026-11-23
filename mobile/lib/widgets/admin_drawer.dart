import 'package:flutter/material.dart';

class AdminDrawer extends StatelessWidget {
  final Map<String, dynamic> usuario;
  final String rutaActual;
  final VoidCallback? onRegistrarUsuario; // Callback opcional

  const AdminDrawer({
    super.key,
    required this.usuario,
    required this.rutaActual,
    this.onRegistrarUsuario,
  });

  String get nombre => usuario['nombre']?.toString() ?? 'Administrador';
  String get correo => usuario['correo']?.toString() ?? '';

  void _navegar(BuildContext context, String ruta) {
    Navigator.pop(context); // Cerrar el drawer

    if (ruta == '/register') {
      if (onRegistrarUsuario != null) {
        // Si ya estamos en UsersPage, ejecutamos la apertura del modal directamente
        onRegistrarUsuario!();
      } else {
        // Si estamos en otra pantalla, redirigimos a /users indicando que abra el modal
        final args = Map<String, dynamic>.from(usuario);
        args['abrirRegistro'] = true;
        Navigator.pushReplacementNamed(context, '/users', arguments: args);
      }
      return;
    }

    if (ruta == rutaActual) return;

    Navigator.pushReplacementNamed(
      context,
      ruta,
      arguments: usuario,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 57, 115, 230)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Color.fromARGB(255, 15, 40, 90),
                  size: 34,
                ),
              ),
              accountName: Text(nombre),
              accountEmail: Text(correo),
            ),
            _opcion(
              context,
              Icons.people_alt_outlined,
              'Gestión de usuarios',
              '/users',
            ),
            _opcion(
              context,
              Icons.person_add_alt_1,
              'Registrar usuario',
              '/register',
            ),
            _opcion(
              context,
              Icons.post_add,
              'Agregar blog',
              '/add_blog',
            ),
            _opcion(
              context,
              Icons.account_circle_outlined,
              'Mi perfil',
              '/profile',
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _opcion(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final seleccionado = ruta == rutaActual;
    return ListTile(
      leading: Icon(
        icono,
        color: seleccionado ? const Color.fromARGB(255, 19, 47, 105) : null,
      ),
      title: Text(titulo),
      selected: seleccionado,
      onTap: () => _navegar(context, ruta),
    );
  }
}