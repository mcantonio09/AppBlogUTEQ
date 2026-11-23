import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddBlogPageUsr extends StatefulWidget {
  final Map<String, dynamic>? usuario;

  const AddBlogPageUsr({
    super.key,
    this.usuario,
  });

  @override
  State<AddBlogPageUsr> createState() => _AddBlogPageUsrState();
}

class _AddBlogPageUsrState extends State<AddBlogPageUsr> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _resumen = TextEditingController();
  final _descripcion = TextEditingController();
  final _tags = TextEditingController();
  String _estado = 'Publicado';

  final _picker = ImagePicker();
  XFile? _foto;
  Uint8List? _imagenBytes;

  bool _guardando = false;
  Map<String, dynamic> _usuario = {};

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _usuario = Map<String, dynamic>.from(widget.usuario!);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_usuario.isEmpty) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _usuario = Map<String, dynamic>.from(args);
      }
    }
  }

  @override
  void dispose() {
    _titulo.dispose();
    _resumen.dispose();
    _descripcion.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (imagen != null) {
      final bytes = await imagen.readAsBytes();
      setState(() {
        _foto = imagen;
        _imagenBytes = bytes;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color.fromARGB(255, 231, 76, 60),
          content: Text('Por favor, selecciona una imagen'),
        ),
      );
      return;
    }

    final rawId =
        _usuario['id_usr'] ?? _usuario['id'] ?? _usuario['id_usuario'];
    final idUsuario = rawId?.toString();

    if (idUsuario == null || idUsuario.isEmpty || idUsuario == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 231, 76, 60),
          content: Text(
            'No se encontró el id_usr (datos recibidos: $_usuario). Vuelve a iniciar sesión.',
          ),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final uri = Uri.parse('http://127.0.0.1:8000/blog');

      final request = http.MultipartRequest('POST', uri)
        ..fields['id_usr'] = idUsuario
        ..fields['titulo'] = _titulo.text.trim()
        ..fields['resumen'] = _resumen.text.trim()
        ..fields['descripcion'] = _descripcion.text.trim()
        ..fields['etiquetas'] = _tags.text.trim()
        ..fields['estado'] = _estado
        ..files.add(
          http.MultipartFile.fromBytes(
            'imagen',
            _imagenBytes!,
            filename: _foto!.name,
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color.fromARGB(255, 24, 188, 156),
            content: Text('Publicación agregada correctamente'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception(
          'Error del servidor (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color.fromARGB(255, 221, 76, 60),
          content: Text('No se pudo guardar: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombreAutor = (_usuario['nombre'] ??
            _usuario['nombre_usr'] ??
            _usuario['correo'] ??
            'Usuario')
        .toString();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 46, 66, 85),
        foregroundColor: Colors.white,
        title: const Text('Agregar blog'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                side: BorderSide(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Nueva publicación',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF2C3E50),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Autor: $nombreAutor',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 121, 135, 136),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titulo,
                        style: const TextStyle(color: Color.fromARGB(255, 33, 37, 41)),
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 123, 138, 139)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 206, 212, 218)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 40, 56, 72),
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa el título'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _resumen,
                        maxLength: 255,
                        style: const TextStyle(color: Color.fromRGBO(33, 37, 41, 1)),
                        decoration: const InputDecoration(
                          labelText: 'Resumen',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 123, 138, 139)),
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
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa un resumen breve'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descripcion,
                        maxLines: 5,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
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
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa la descripción'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: _seleccionarFoto,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2C3E50),
                          side: const BorderSide(color: Color(0xFF2C3E50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: const Icon(Icons.photo_library),
                        label: Text(
                          _imagenBytes == null
                              ? 'Seleccionar foto de galería'
                              : 'Cambiar foto',
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_imagenBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.memory(
                            _imagenBytes!,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _tags,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Etiquetas (opcional)',
                          labelStyle: TextStyle(color: Color(0xFF7B8A8B)),
                          hintText: 'flutter, tecnología, móvil',
                          hintStyle: TextStyle(color: Color(0xFF95A5A6)),
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
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _estado,
                        style: const TextStyle(color: Color(0xFF212529)),
                        decoration: const InputDecoration(
                          labelText: 'Estado',
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
                        items: const [
                          DropdownMenuItem(
                            value: 'Publicado',
                            child: Text('Publicado'),
                          ),
                          DropdownMenuItem(
                            value: 'Borrador',
                            child: Text('Borrador'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _estado = val);
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18BC9C),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF95A5A6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _guardando ? 'Guardando...' : 'Guardar publicación',
                        ),
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