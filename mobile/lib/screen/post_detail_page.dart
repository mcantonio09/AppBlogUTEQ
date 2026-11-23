import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/comentario_model.dart';
import '../services/comentario_service.dart';
import '../services/user_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;
  final int usuarioId;

  const PostDetailPage({
    super.key,
    required this.post,
    required this.usuarioId,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService _comentarioService = ComentarioService();
  final UserService _userService = UserService();
  final TextEditingController _comentarioController = TextEditingController();

  List<ComentarioModel> _comentarios = [];
  Map<int, String> _nombresUsuarios = {};
  bool _cargandoComentarios = true;
  bool _enviandoComentario = false;
  String? _errorComentarios;

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _cargarComentarios() async {
    setState(() {
      _cargandoComentarios = true;
      _errorComentarios = null;
    });

    try {
      final todos = await _comentarioService.obtenerComentarios();
      final filtrados = todos
          .where((c) => c.blogId == widget.post.id)
          .toList();

      Map<int, String> mapaNombres = {};
      try {
        final usuarios = await _userService.obtenerUsuarios();
        mapaNombres = {
          for (final u in usuarios) u.id: u.nombre,
        };
      } catch (_) {
        // Si no se puede consultar la lista de usuarios, se usará el ID como respaldo
      }

      if (!mounted) return;
      setState(() {
        _comentarios = filtrados;
        _nombresUsuarios = mapaNombres;
        _cargandoComentarios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorComentarios = 'No se pudieron cargar los comentarios.';
        _cargandoComentarios = false;
      });
    }
  }

  Future<void> _enviarComentario() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty || _enviandoComentario) return;

    if (widget.usuarioId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFE74C3C),
          content: Text('No se identificó el usuario de la sesión actual.'),
        ),
      );
      return;
    }

    setState(() {
      _enviandoComentario = true;
    });

    try {
      final nuevoComentario = ComentarioModel(
        id: 0,
        comentario: texto,
        fecha: '',
        usuarioId: widget.usuarioId,
        blogId: widget.post.id,
      );

      await _comentarioService.agregarComentario(nuevoComentario);

      if (!mounted) return;
      _comentarioController.clear();
      FocusScope.of(context).unfocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF18BC9C),
          content: Text('Comentario publicado correctamente'),
        ),
      );

      await _cargarComentarios();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE74C3C),
          content: Text('Error al publicar: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _enviandoComentario = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: const Text('Detalle de publicación'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imagen.isNotEmpty)
              Image.network(
                post.imagen,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 150,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tags.isNotEmpty) ...[
                    Text(
                      post.tags,
                      style: const TextStyle(
                        color: Color(0xFF18BC9C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (post.fechaCreacion.isNotEmpty) ...[
                    Text(
                      'Publicado el ${post.fechaCreacion}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    post.titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  if (post.resumen.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      post.resumen,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF7B8A8B),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    post.descripcion.isNotEmpty
                        ? post.descripcion
                        : 'Esta publicación no tiene descripción.',
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.6,
                      color: Color(0xFF212529),
                    ),
                  ),

                  // --- SECCIÓN DE COMENTARIOS ---
                  const SizedBox(height: 32),
                  const Divider(
                    thickness: 1,
                    color: Color(0xFFDEE2E6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comentarios (${_comentarios.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Formulario para escribir un comentario
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          maxLines: 3,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          style: const TextStyle(color: Color(0xFF212529)),
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: const TextStyle(color: Color(0xFF95A5A6)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFFCED4DA),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: Color(0xFF2C3E50),
                                width: 1.5,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _enviandoComentario ? null : _enviarComentario,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C3E50),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: _enviandoComentario
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Lista de comentarios
                  if (_cargandoComentarios)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(
                          color: Color(0xFF18BC9C),
                        ),
                      ),
                    )
                  else if (_errorComentarios != null)
                    Column(
                      children: [
                        Text(
                          _errorComentarios!,
                          style: const TextStyle(color: Color(0xFFE74C3C)),
                        ),
                        TextButton(
                          onPressed: _cargarComentarios,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF18BC9C),
                          ),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  else if (_comentarios.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Sé el primero en comentar esta publicación.',
                        style: TextStyle(color: Color(0xFF95A5A6)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comentarios.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _comentarios[index];
                        final nombreAutor =
                            _nombresUsuarios[item.usuarioId] ??
                                'Usuario #${item.usuarioId}';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFDEE2E6),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Color(0xFF2C3E50),
                                    child: Icon(
                                      Icons.person,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      nombreAutor,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                  ),
                                  if (item.fecha.isNotEmpty)
                                    Text(
                                      item.fecha,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF95A5A6),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.comentario,
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: Color(0xFF212529),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}