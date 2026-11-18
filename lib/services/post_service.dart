import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  Future<PostModel> agregarPost({
    required int usuarioId,
    required String titulo,
    required String resumen,
    String? descripcion,
    String? imagen,
    String? tags,
    String estado = 'Publicado',
  }) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/blog'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'id_usr': usuarioId,
            'titulo': titulo.trim(),
            'resumen': resumen.trim(),
            'descripcion': (descripcion ?? '').trim().isEmpty
                ? null
                : descripcion!.trim(),
            'url_img': (imagen ?? '').trim().isEmpty ? null : imagen!.trim(),
            'etiquetas': (tags ?? '').trim().isEmpty ? null : tags!.trim(),
            'estado': estado.trim(),
          }),
        )
        .timeout(const Duration(seconds: 10));

    final dynamic resultado =
        respuesta.body.isNotEmpty ? jsonDecode(respuesta.body) : null;

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }
    throw Exception(
      'No se pudo guardar la publicación (HTTP ${respuesta.statusCode})',
    );
  }

  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http.get(
      Uri.parse('$baseUrl/blog'),
    );

    if (respuesta.statusCode != 200) {
      throw Exception('Error al consultar publicaciones');
    }

    final List<dynamic> datos = jsonDecode(respuesta.body);

    return datos
        .map(
          (json) => PostModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}