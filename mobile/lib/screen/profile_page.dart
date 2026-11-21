import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/admin_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String baseUrl = 'http://127.0.0.1:8000';
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  Map<String, dynamic> _usuario = {};
  bool _cargando = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inicializado) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _usuario = Map<String, dynamic>.from(args);
    }
    _nombre.text = _usuario['nombre']?.toString() ?? '';
    _correo.text = _usuario['correo']?.toString() ?? '';
    _inicializado = true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final id = _usuario['id_usr'];
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE74C3C),
          content: Text(
            'No se recibió el identificador del usuario. Vuelve a iniciar sesión.',
          ),
        ),
      );
      return;
    }
    setState(() => _cargando = true);
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'nombre': _nombre.text.trim(),
          'correo': _correo.text.trim().toLowerCase(),
          'tipo_usr': (_usuario['tipo_usr'] as num?)?.toInt() ?? 1,
        }),
      ).timeout(const Duration(seconds: 10));

      final dynamic data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      if (response.statusCode != 200) {
        final detail = data is Map ? data['detail'] : null;
        throw Exception(detail?.toString() ?? 'Error HTTP ${response.statusCode}');
      }
      if (data is Map<String, dynamic>) _usuario = Map<String, dynamic>.from(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF18BC9C),
          content: Text('Perfil actualizado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE74C3C),
          content: Text('No se pudo actualizar el perfil: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text('Mi perfil'),
      ),
      drawer: AdminDrawer(usuario: _usuario, rutaActual: '/profile'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                side: BorderSide(color: Color(0xFFDEE2E6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const CircleAvatar(
                        radius: 38,
                        backgroundColor: Color(0xFF2C3E50),
                        child: Icon(
                          Icons.person,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _nombre,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCED4DA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2C3E50),
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().length < 2
                            ? 'Ingresa un nombre válido'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _correo,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFCED4DA)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF2C3E50),
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Ingresa un correo válido'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _cargando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18BC9C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF95A5A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: Text(_cargando ? 'Guardando...' : 'Guardar cambios'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}