import 'package:flutter/material.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
import 'add_blog_page_user.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futurePosts;
  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'id_usr': 0,
    'nombre': 'Usuario',
    'correo': '',
    'tipo_usr': 2,
  };
  bool argumentoLeido = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        if (argumento['usuario'] is Map<String, dynamic>) {
          usuarioActual = Map<String, dynamic>.from(argumento['usuario']);
        } else if (argumento['data'] is Map<String, dynamic>) {
          usuarioActual = Map<String, dynamic>.from(argumento['data']);
        } else {
          usuarioActual = Map<String, dynamic>.from(argumento);
        }

        nombreUsuario = (usuarioActual['nombre'] ??
                usuarioActual['nombre_usr'] ??
                usuarioActual['correo'] ??
                'Usuario')
            .toString();
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {
          'id_usr': 0,
          'nombre': nombreUsuario,
          'correo': '',
          'tipo_usr': 2,
        };
      }

      argumentoLeido = true;
    }
  }

  @override
  void initState() {
    super.initState();
    futurePosts = postService.obtenerPosts();
  }

  void recargarPosts() {
    setState(() {
      futurePosts = postService.obtenerPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final int usuarioIdActual = ((usuarioActual['id_usr'] ??
                usuarioActual['id'] ??
                usuarioActual['id_usuario']) as num?)
            ?.toInt() ??
        0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Aula Abierta UTEQ'),
            Text(
              'Bienvenido, $nombreUsuario',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFECF0F1),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar publicación',
            icon: const Icon(Icons.note_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: RouteSettings(arguments: usuarioActual),
                  builder: (context) => AddBlogPageUsr(usuario: usuarioActual),
                ),
              ).then((_) {
                recargarPosts();
              });
            },
          ),
          IconButton(
            tooltip: 'Actualizar publicaciones',
            icon: const Icon(Icons.refresh),
            onPressed: recargarPosts,
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: Colors.white,
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(color: Color(0xFF2C3E50)),
                  ),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                    style: TextStyle(color: Color(0xFF212529)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7B8A8B),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE74C3C),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      size: 45,
                      color: Color(0xFFE74C3C),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible cargar el blog.',
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
                      onPressed: recargarPosts,
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

          final posts = snapshot.data ?? <PostModel>[];

          if (posts.isEmpty) {
            return const Center(
              child: Text(
                'No hay publicaciones registradas.',
                style: TextStyle(color: Color(0xFF7B8A8B)),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Últimas Publicaciones',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Entérate de las últimas publicaciones, eventos académicos y avisos importantes de la comunidad universitaria.',
                style: TextStyle(fontSize: 16, color: Color(0xFF7B8A8B)),
              ),
              const SizedBox(height: 20),
              ...posts.map(
                (post) => PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(
                          post: post,
                          usuarioId: usuarioIdActual,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}