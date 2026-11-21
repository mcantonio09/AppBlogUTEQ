import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/admin_drawer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final UserService userService = UserService();

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  late Future<List<UserModel>> futuroUsuarios;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nombre': 'Usuario',
    'correo': '',
    'tipo_usr': 1,
  };
  bool argumentoLeido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;
      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nombre']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.trim().isNotEmpty) {
        nombreUsuario = argumento.trim();
        usuarioActual = {'nombre': nombreUsuario, 'correo': '', 'tipo_usr': 1};
      }
      argumentoLeido = true;
    }
  }

  @override
  void initState() {
    super.initState();
    futuroUsuarios = userService.obtenerUsuarios();
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void recargarUsuarios() {
    setState(() {
      futuroUsuarios = userService.obtenerUsuarios();
    });
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C3E50),
        content: Text(mensaje),
      ),
    );
  }

  Future<void> mostrarFormulario({UserModel? usuario}) async {
    final esEdicion = usuario != null;

    nombreController.text = usuario?.nombre ?? '';
    correoController.text = usuario?.correo ?? '';
    passwordController.clear();

    final resultado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool guardando = false;

        return StatefulBuilder(
          builder: (contextDialogo, actualizarDialogo) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                esEdicion ? 'Editar usuario' : 'Nuevo usuario',
                style: const TextStyle(color: Color(0xFF2C3E50)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      style: const TextStyle(color: Color(0xFF212529)),
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCED4DA)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2C3E50)),
                        ),
                      ),
                    ),
                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Color(0xFF212529)),
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFCED4DA)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2C3E50)),
                        ),
                      ),
                    ),
                    if (!esEdicion)
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCED4DA)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2C3E50)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () => Navigator.pop(dialogContext, false),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF7B8A8B),
                  ),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          final nombre = nombreController.text.trim();
                          final correo = correoController.text.trim();
                          final password = passwordController.text;

                          if (nombre.isEmpty || correo.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFE74C3C),
                                content: Text('Ingresa nombre y correo'),
                              ),
                            );
                            return;
                          }

                          if (!correo.contains('@')) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFE74C3C),
                                content: Text('Ingresa un correo válido'),
                              ),
                            );
                            return;
                          }

                          if (!esEdicion && password.length < 8) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFE74C3C),
                                content: Text(
                                  'La contraseña debe tener al menos 8 caracteres',
                                ),
                              ),
                            );
                            return;
                          }

                          actualizarDialogo(() {
                            guardando = true;
                          });

                          try {
                            if (esEdicion) {
                              final actualizado = UserModel(
                                id: usuario.id,
                                nombre: nombre,
                                correo: correo,
                                tipoUsuario: usuario.tipoUsuario,
                              );

                              await userService.actualizarUsuario(
                                actualizado,
                              );
                            } else {
                              final nuevo = UserModel(
                                id: 0,
                                nombre: nombre,
                                correo: correo,
                                password: password,
                                tipoUsuario: 1,
                              );

                              await userService.agregarUsuario(nuevo);
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFFE74C3C),
                                content: Text('No se pudo guardar: $e'),
                              ),
                            );

                            actualizarDialogo(() {
                              guardando = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF18BC9C),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    esEdicion ? 'Actualizar' : 'Guardar',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (resultado == true && mounted) {
      recargarUsuarios();

      mostrarMensaje(
        esEdicion
            ? 'Usuario actualizado correctamente'
            : 'Usuario registrado correctamente',
      );
    }
  }

  Future<void> eliminarUsuario(UserModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Eliminar usuario',
          style: TextStyle(color: Color(0xFF2C3E50)),
        ),
        content: Text(
          '¿Deseas eliminar a ${usuario.nombre}?',
          style: const TextStyle(color: Color(0xFF212529)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7B8A8B),
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await userService.eliminarUsuario(usuario.id);

      if (!mounted) return;

      recargarUsuarios();
      mostrarMensaje('Usuario eliminado correctamente');
    } catch (e) {
      mostrarMensaje('No se pudo eliminar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Gestión de usuarios',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Bienvenido, $nombreUsuario',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFECF0F1),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: recargarUsuarios,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: AdminDrawer(usuario: usuarioActual, rutaActual: '/users'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        backgroundColor: const Color(0xFF18BC9C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: futuroUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF18BC9C),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 48,
                      color: Color(0xFFE74C3C),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No se pudieron cargar los usuarios.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF212529)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF7B8A8B)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarUsuarios,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C3E50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios registrados',
                style: TextStyle(color: Color(0xFF7B8A8B)),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF18BC9C),
            onRefresh: () async {
              final nuevoFuturo = userService.obtenerUsuarios();

              setState(() {
                futuroUsuarios = nuevoFuturo;
              });

              await nuevoFuturo;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    side: BorderSide(color: Color(0xFFDEE2E6)),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      usuario.nombre,
                      style: const TextStyle(
                        color: Color(0xFF212529),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      usuario.correo,
                      style: const TextStyle(color: Color(0xFF7B8A8B)),
                    ),
                    trailing: PopupMenuButton<String>(
                      color: Colors.white,
                      iconColor: const Color(0xFF7B8A8B),
                      onSelected: (opcion) {
                        if (opcion == 'editar') {
                          mostrarFormulario(usuario: usuario);
                        } else if (opcion == 'eliminar') {
                          eliminarUsuario(usuario);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text(
                            'Editar',
                            style: TextStyle(color: Color(0xFF2C3E50)),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text(
                            'Eliminar',
                            style: TextStyle(color: Color(0xFFE74C3C)),
                          ),
                        ),
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