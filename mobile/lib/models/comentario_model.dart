class ComentarioModel {
  final int id;
  final String comentario;
  final String fecha;
  final int usuarioId;
  final int blogId;

  ComentarioModel({
    required this.id,
    required this.comentario,
    required this.fecha,
    required this.usuarioId,
    required this.blogId,
  });

  factory ComentarioModel.fromJson(Map<String, dynamic> json) {
    return ComentarioModel(
      id: (json['id_comentario'] as num).toInt(),
      comentario: json['comentario']?.toString() ?? '',
      fecha: json['fecha_comentario']?.toString() ?? '',
      usuarioId: (json['id_usr'] as num).toInt(),
      blogId: (json['id_blog'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJsonCrear() {
    return {
      'comentario': comentario,
      'id_usr': usuarioId,
      'id_blog': blogId,
    };
  }
}