import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
//import '../widgets/admin_drawer.dart';

class AddBlogPageUsr extends StatefulWidget {
  const AddBlogPageUsr({super.key});

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

  // Variables para la imagen
  final _picker = ImagePicker();
  XFile? _foto;
  Uint8List? _imagenBytes;

  bool _guardando = false;
  Map<String, dynamic> _usuario = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) _usuario = Map<String, dynamic>.from(args);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _resumen.dispose();
    _descripcion.dispose();
    _tags.dispose();
    super.dispose();
  }

  // Selección de foto (compatible con Web y Mobile)
  Future<void> _tomarFoto(ImageSource origen) async {
    final imagen = await _picker.pickImage(
      source: origen,
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

  // Envío Multipart a FastAPI
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_foto == null || _imagenBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una imagen')),
      );
      return;
    }

    final idUsuario = _usuario['id_usr']?.toString();
    if (idUsuario == null || idUsuario.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró el id_usr. Vuelve a iniciar sesión.'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      // Usa 127.0.0.1 / localhost en Web/macOS, o 10.0.2.2 en Emulador Android
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
          const SnackBar(content: Text('Publicación agregada correctamente')),
        );

        // Limpiar formulario
        _titulo.clear();
        _resumen.clear();
        _descripcion.clear();
        _tags.clear();
        setState(() {
          _estado = 'Publicado';
          _foto = null;
          _imagenBytes = null;
        });
      } else {
        throw Exception('Error del servidor (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario['nombre']?.toString() ?? 'Administrador';

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar blog')),
      //drawer: AdminDrawer(usuario: _usuario, rutaActual: '/add-blog'),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Nueva publicación',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text('Administrador: $nombre'),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titulo,
                        decoration: const InputDecoration(
                          labelText: 'Título',
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
                        decoration: const InputDecoration(
                          labelText: 'Resumen',
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
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa la descripción'
                            : null,
                      ),
                      const SizedBox(height: 14),

                      // Botones de selección de imagen
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _tomarFoto(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Cámara'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _tomarFoto(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galería'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Vista previa de la imagen cargada
                      if (_imagenBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
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
                        decoration: const InputDecoration(
                          labelText: 'Etiquetas (opcional)',
                          hintText: 'flutter, tecnología, móvil',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _estado,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
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
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: Text(_guardando ? 'Guardando...' : 'Guardar publicación'),
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