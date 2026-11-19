import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
//import '../widgets/admin_drawer.dart';
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
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nombre']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {'nombre': nombreUsuario, 'correo': '', 'tipo_usr': 2};
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Aula Abierta UTEQ'),
            Text(
              'Bienvenido, $nombreUsuario',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Agregar publicación',
            icon: const Icon(Icons.note_add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBlogPageUsr())).then((_) {
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
                  title: const Text('Cerrar sesión'),
                  content: const Text(
                    '¿Estás seguro de que deseas cerrar sesión?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
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
                      child: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      //drawer: (usuarioActual['tipo_usr'] as num? ?? 2).toInt() == 1
      //    ? AdminDrawer(usuario: usuarioActual, rutaActual: '/blog')
      //    : null,
      body: FutureBuilder<List<PostModel>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 45),
                    const SizedBox(height: 12),
                    const Text(
                      'No fue posible cargar el blog.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: recargarPosts,
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
              child: Text('No hay publicaciones registradas.'),
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
                  color: Color(0xFF08245C),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Entérate de las últimas publicaciones, eventos académicos y avisos importantes de la comunidad universitaria.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ...posts.map(
                (post) => PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => PostDetailPage(post: post),
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